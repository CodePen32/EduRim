// Package cache provides a small in-memory, TTL-based cache for semi-static
// data (learning paths, bac branches, subjects, active announcements,
// subscription plans). It must never be used for data that depends on
// user_id (subscriptions, notifications, progress, favorites, payments) —
// see Phase 2A scope notes in the handlers/repositories that use it.
package cache

import (
	"log"
	"os"
	"sync"
	"time"
)

type entry struct {
	value     interface{}
	expiresAt time.Time
}

// Store is a generic, thread-safe, TTL-based in-memory cache.
// Zero value is not usable; use New.
type Store struct {
	mu      sync.RWMutex
	items   map[string]entry
	ttl     time.Duration
	debug   bool
	logName string
}

// New creates a Store with the given TTL. name is used only for debug logs
// (e.g. "subjects", "announcements") to distinguish stores in output.
func New(name string, ttl time.Duration) *Store {
	debug := os.Getenv("APP_ENV") != "production" && os.Getenv("GIN_MODE") != "release"
	return &Store{
		items:   make(map[string]entry),
		ttl:     ttl,
		debug:   debug,
		logName: name,
	}
}

// Get returns the cached value for key if present and not expired.
func (s *Store) Get(key string) (interface{}, bool) {
	s.mu.RLock()
	e, ok := s.items[key]
	s.mu.RUnlock()

	if !ok || time.Now().After(e.expiresAt) {
		if s.debug {
			log.Printf("[cache:%s] MISS key=%q", s.logName, key)
		}
		return nil, false
	}
	if s.debug {
		log.Printf("[cache:%s] HIT key=%q", s.logName, key)
	}
	return e.value, true
}

// Set stores value under key with the store's configured TTL.
func (s *Store) Set(key string, value interface{}) {
	s.mu.Lock()
	s.items[key] = entry{value: value, expiresAt: time.Now().Add(s.ttl)}
	s.mu.Unlock()
}

// Delete removes a single key (used for targeted invalidation).
func (s *Store) Delete(key string) {
	s.mu.Lock()
	delete(s.items, key)
	s.mu.Unlock()
}

// Clear removes all entries in the store. Used as a simple invalidation
// strategy on admin writes (create/update/delete) — cheaper and safer than
// tracking every possible key combination, and the TTL is short enough
// (60-120s) that this never causes prolonged staleness.
func (s *Store) Clear() {
	s.mu.Lock()
	s.items = make(map[string]entry)
	s.mu.Unlock()
	if s.debug {
		log.Printf("[cache:%s] CLEAR (invalidated)", s.logName)
	}
}
