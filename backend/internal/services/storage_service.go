package services

import (
	"bytes"
	"context"
	"fmt"
	"io"
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

// NewStorageService returns LocalStorage or R2Storage based on config.
func NewStorageService(cfg *config.Config) StorageService {
	if strings.ToLower(cfg.StorageDriver) == "r2" {
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
	// Return relative path so Flutter/Admin prepend the base URL
	return "/" + folder + "/" + filename, nil
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
		return "", fmt.Errorf("read file: %w", err)
	}

	// Detect Content-Type from extension or header
	contentType := header.Header.Get("Content-Type")
	if contentType == "" || contentType == "application/octet-stream" {
		contentType = detectContentType(ext, buf)
	}

	// Build R2 endpoint
	endpoint := fmt.Sprintf("https://%s.r2.cloudflarestorage.com", s.cfg.R2AccountID)

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
		return "", fmt.Errorf("R2 upload: %w", err)
	}

	// Return full public URL
	publicURL := strings.TrimRight(s.cfg.R2PublicURL, "/") + "/" + objectKey
	return publicURL, nil
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
