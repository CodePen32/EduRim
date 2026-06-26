package cache

import (
	"testing"
	"time"
)

func TestStore_SetGet(t *testing.T) {
	s := New("test", time.Minute)
	s.Set("k1", 42)

	v, ok := s.Get("k1")
	if !ok {
		t.Fatal("expected hit, got miss")
	}
	if v.(int) != 42 {
		t.Fatalf("expected 42, got %v", v)
	}
}

func TestStore_MissOnUnknownKey(t *testing.T) {
	s := New("test", time.Minute)
	_, ok := s.Get("missing")
	if ok {
		t.Fatal("expected miss for unknown key")
	}
}

func TestStore_TTLExpiry(t *testing.T) {
	s := New("test", 10*time.Millisecond)
	s.Set("k1", "value")

	if _, ok := s.Get("k1"); !ok {
		t.Fatal("expected hit immediately after Set")
	}

	time.Sleep(20 * time.Millisecond)

	if _, ok := s.Get("k1"); ok {
		t.Fatal("expected miss after TTL expiry")
	}
}

func TestStore_Clear(t *testing.T) {
	s := New("test", time.Minute)
	s.Set("k1", "a")
	s.Set("k2", "b")

	s.Clear()

	if _, ok := s.Get("k1"); ok {
		t.Fatal("expected miss after Clear for k1")
	}
	if _, ok := s.Get("k2"); ok {
		t.Fatal("expected miss after Clear for k2")
	}
}

func TestStore_Delete(t *testing.T) {
	s := New("test", time.Minute)
	s.Set("k1", "a")
	s.Set("k2", "b")

	s.Delete("k1")

	if _, ok := s.Get("k1"); ok {
		t.Fatal("expected miss after Delete for k1")
	}
	if _, ok := s.Get("k2"); !ok {
		t.Fatal("expected k2 to remain after deleting only k1")
	}
}

func TestStore_ConcurrentAccess(t *testing.T) {
	s := New("test", time.Minute)
	done := make(chan struct{})

	for i := 0; i < 20; i++ {
		go func(n int) {
			s.Set("key", n)
			s.Get("key")
			done <- struct{}{}
		}(i)
	}
	for i := 0; i < 20; i++ {
		<-done
	}
}
