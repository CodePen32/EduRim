package services

import (
	"context"
	"log"
	"os"
	"strings"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

// PushService sends FCM push notifications. It is entirely optional and
// best-effort: if credentials are missing or Firebase init fails, the service
// stays disabled and the rest of the app is unaffected.
type PushService struct {
	client  *messaging.Client
	enabled bool
}

// NewPushService initializes Firebase from either the JSON env content
// (preferred on Render) or a file path (local dev). Never logs the credentials.
func NewPushService(credsJSON, credsFile string) *PushService {
	ps := &PushService{}
	ctx := context.Background()

	var opt option.ClientOption
	switch {
	case strings.TrimSpace(credsJSON) != "":
		opt = option.WithCredentialsJSON([]byte(credsJSON))
	case strings.TrimSpace(credsFile) != "":
		if _, err := os.Stat(credsFile); err != nil {
			log.Printf("[push] credentials file not found — push disabled")
			return ps
		}
		opt = option.WithCredentialsFile(credsFile)
	default:
		log.Printf("[push] no Firebase credentials configured — push disabled")
		return ps
	}

	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		log.Printf("[push] Firebase init failed — push disabled")
		return ps
	}
	client, err := app.Messaging(ctx)
	if err != nil {
		log.Printf("[push] Messaging client init failed — push disabled")
		return ps
	}
	ps.client = client
	ps.enabled = true
	log.Printf("[push] Firebase messaging enabled")
	return ps
}

// Enabled reports whether push is active.
func (p *PushService) Enabled() bool { return p != nil && p.enabled }

// SendToTokens delivers a notification to the given tokens. Best-effort:
// returns nothing that can fail the caller. Logs counts only — never tokens.
func (p *PushService) SendToTokens(tokens []string, title, body string) {
	if !p.Enabled() || len(tokens) == 0 {
		return
	}
	// Filter empties defensively (query already excludes NULL/'').
	clean := make([]string, 0, len(tokens))
	for _, t := range tokens {
		if strings.TrimSpace(t) != "" {
			clean = append(clean, t)
		}
	}
	if len(clean) == 0 {
		return
	}

	ctx := context.Background()
	var sent, failed int
	// FCM multicast handles up to 500 tokens per call; chunk to be safe.
	for start := 0; start < len(clean); start += 500 {
		end := start + 500
		if end > len(clean) {
			end = len(clean)
		}
		batch := clean[start:end]
		msg := &messaging.MulticastMessage{
			Tokens: batch,
			Notification: &messaging.Notification{
				Title: title,
				Body:  body,
			},
			Android: &messaging.AndroidConfig{
				Priority: "high",
				Notification: &messaging.AndroidNotification{
					ChannelID: "concouri_default_channel",
				},
			},
		}
		resp, err := p.client.SendEachForMulticast(ctx, msg)
		if err != nil {
			failed += len(batch)
			continue
		}
		sent += resp.SuccessCount
		failed += resp.FailureCount
	}
	log.Printf("[push] lesson notification: total=%d sent=%d failed=%d", len(clean), sent, failed)
}
