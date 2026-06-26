package services

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"log"
	"mime"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"

	"edurim/backend/internal/config"
)

// StorageService uploads a file and returns its public URL.
type StorageService interface {
	Upload(ctx context.Context, folder string, file multipart.File, header *multipart.FileHeader) (string, error)
}

// FileReader fetches a stored file by key (e.g. "images/xxx.jpg").
// Returns the body stream, detected content-type, and any error.
type FileReader interface {
	Get(ctx context.Context, key string) (body io.ReadCloser, contentType string, err error)
}

// NewFileReader returns the same backend as NewStorageService but typed as FileReader.
func NewFileReader(cfg *config.Config) FileReader {
	if strings.ToLower(cfg.StorageDriver) == "r2" &&
		cfg.R2AccountID != "" && cfg.R2AccessKeyID != "" &&
		cfg.R2SecretAccessKey != "" && cfg.R2Bucket != "" {
		return &R2Storage{cfg: cfg}
	}
	return &LocalStorage{cfg: cfg}
}

// NewStorageService returns LocalStorage or R2Storage based on config.
func NewStorageService(cfg *config.Config) StorageService {
	driver := strings.ToLower(cfg.StorageDriver)
	log.Printf("[storage] driver=%q bucket=%q publicURL=%q accountID=%q",
		driver, cfg.R2Bucket, cfg.R2PublicURL, cfg.R2AccountID)

	if driver == "r2" {
		// Validate required R2 credentials at startup
		missing := []string{}
		if cfg.R2AccountID == ""       { missing = append(missing, "R2_ACCOUNT_ID") }
		if cfg.R2AccessKeyID == ""     { missing = append(missing, "R2_ACCESS_KEY_ID") }
		if cfg.R2SecretAccessKey == "" { missing = append(missing, "R2_SECRET_ACCESS_KEY") }
		if cfg.R2Bucket == ""          { missing = append(missing, "R2_BUCKET") }
		if cfg.R2PublicURL == ""       { missing = append(missing, "R2_PUBLIC_URL") }
		if len(missing) > 0 {
			log.Printf("[storage] WARNING: R2 driver selected but missing env vars: %v", missing)
			log.Printf("[storage] Falling back to local storage until R2 is configured")
			return &LocalStorage{cfg: cfg}
		}
		log.Printf("[storage] R2 configured OK — endpoint=https://%s.r2.cloudflarestorage.com", cfg.R2AccountID)
		return &R2Storage{cfg: cfg}
	}
	return &LocalStorage{cfg: cfg}
}

// ─────────────────────────────────────────────
// LocalStorage — stores files on disk
// ─────────────────────────────────────────────

type LocalStorage struct {
	cfg *config.Config
}

func (s *LocalStorage) Upload(_ context.Context, folder string, file multipart.File, header *multipart.FileHeader) (string, error) {
	ext := strings.ToLower(filepath.Ext(header.Filename))
	dir := filepath.Join(s.cfg.LocalUploadsDir, folder)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return "", fmt.Errorf("mkdir: %w", err)
	}
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
	dest, err := os.Create(filepath.Join(dir, filename))
	if err != nil {
		return "", fmt.Errorf("create file: %w", err)
	}
	defer dest.Close()
	if _, err := io.Copy(dest, file); err != nil {
		return "", fmt.Errorf("write file: %w", err)
	}
	url := "/" + folder + "/" + filename
	log.Printf("[storage:local] saved folder=%s filename=%s url=%s", folder, filename, url)
	return url, nil
}

// Get fetches a file from local disk.
func (s *LocalStorage) Get(_ context.Context, key string) (io.ReadCloser, string, error) {
	base, err := filepath.Abs(s.cfg.LocalUploadsDir)
	if err != nil {
		return nil, "", fmt.Errorf("resolve uploads dir: %w", err)
	}
	path, err := filepath.Abs(filepath.Join(base, key))
	if err != nil {
		return nil, "", fmt.Errorf("resolve path: %w", err)
	}
	if path != base && !strings.HasPrefix(path, base+string(filepath.Separator)) {
		return nil, "", fmt.Errorf("invalid key %q: escapes uploads dir", key)
	}
	f, err := os.Open(path)
	if err != nil {
		return nil, "", fmt.Errorf("open %s: %w", path, err)
	}
	// Sniff content type from first 512 bytes
	sniff := make([]byte, 512)
	n, _ := f.Read(sniff)
	ct := http.DetectContentType(sniff[:n])
	if idx := strings.Index(ct, ";"); idx != -1 {
		ct = strings.TrimSpace(ct[:idx])
	}
	// Seek back to start
	f.Seek(0, io.SeekStart)
	return f, ct, nil
}

// ─────────────────────────────────────────────
// R2Storage — uploads to Cloudflare R2 via S3 API
// ─────────────────────────────────────────────

type R2Storage struct {
	cfg *config.Config
}

func (s *R2Storage) Upload(ctx context.Context, folder string, file multipart.File, header *multipart.FileHeader) (string, error) {
	ext := strings.ToLower(filepath.Ext(header.Filename))
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
	objectKey := folder + "/" + filename

	// Read file into buffer (needed for Content-Length)
	buf, err := io.ReadAll(file)
	if err != nil {
		return "", fmt.Errorf("read file bytes: %w", err)
	}

	// Detect Content-Type: prefer sniffed, fall back to declared, then extension
	contentType := http.DetectContentType(func() []byte {
		if len(buf) > 512 { return buf[:512] }
		return buf
	}())
	if idx := strings.Index(contentType, ";"); idx != -1 {
		contentType = strings.TrimSpace(contentType[:idx])
	}
	// If sniff returned generic octet-stream, try extension
	if contentType == "application/octet-stream" {
		contentType = detectContentType(ext, buf)
	}

	// Build R2 endpoint
	endpoint := fmt.Sprintf("https://%s.r2.cloudflarestorage.com", s.cfg.R2AccountID)

	log.Printf("[storage:r2] uploading key=%s size=%d contentType=%s bucket=%s endpoint=%s",
		objectKey, len(buf), contentType, s.cfg.R2Bucket, endpoint)

	// Create S3 client pointing to R2
	client := s3.NewFromConfig(
		aws.Config{
			Region: "auto",
			Credentials: credentials.NewStaticCredentialsProvider(
				s.cfg.R2AccessKeyID,
				s.cfg.R2SecretAccessKey,
				"",
			),
		},
		func(o *s3.Options) {
			o.BaseEndpoint = aws.String(endpoint)
			o.UsePathStyle = true
		},
	)

	_, err = client.PutObject(ctx, &s3.PutObjectInput{
		Bucket:        aws.String(s.cfg.R2Bucket),
		Key:           aws.String(objectKey),
		Body:          bytes.NewReader(buf),
		ContentType:   aws.String(contentType),
		ContentLength: aws.Int64(int64(len(buf))),
	})
	if err != nil {
		// Log the full R2 error — visible in Render logs only
		log.Printf("[storage:r2] PutObject FAILED key=%s err=%v", objectKey, err)
		return "", fmt.Errorf("R2 PutObject: %w", err)
	}

	publicURL := strings.TrimRight(s.cfg.R2PublicURL, "/") + "/" + objectKey
	log.Printf("[storage:r2] upload OK key=%s publicURL=%s", objectKey, publicURL)
	return publicURL, nil
}

// Get fetches a file from R2 using S3 GetObject.
func (s *R2Storage) Get(ctx context.Context, key string) (io.ReadCloser, string, error) {
	endpoint := fmt.Sprintf("https://%s.r2.cloudflarestorage.com", s.cfg.R2AccountID)
	client := s3.NewFromConfig(
		aws.Config{
			Region: "auto",
			Credentials: credentials.NewStaticCredentialsProvider(
				s.cfg.R2AccessKeyID,
				s.cfg.R2SecretAccessKey,
				"",
			),
		},
		func(o *s3.Options) {
			o.BaseEndpoint = aws.String(endpoint)
			o.UsePathStyle = true
		},
	)
	out, err := client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(s.cfg.R2Bucket),
		Key:    aws.String(key),
	})
	if err != nil {
		return nil, "", fmt.Errorf("R2 GetObject %q: %w", key, err)
	}
	ct := ""
	if out.ContentType != nil {
		ct = *out.ContentType
	}
	return out.Body, ct, nil
}

// detectContentType infers MIME type from extension, then sniffs bytes.
func detectContentType(ext string, data []byte) string {
	if ct := mime.TypeByExtension(ext); ct != "" {
		return ct
	}
	if len(data) > 512 {
		return http.DetectContentType(data[:512])
	}
	return http.DetectContentType(data)
}
