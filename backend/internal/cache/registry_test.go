package cache

import "testing"

// These tests exercise the package-level registry used by repositories and
// admin write handlers, verifying the invalidation helpers actually clear
// the stores they claim to (Subjects, Announcements, SubscriptionPlans).

func TestClearContentCaches_ClearsSubjects(t *testing.T) {
	Subjects.Set("3:0", []string{"math", "physics"})
	if _, ok := Subjects.Get("3:0"); !ok {
		t.Fatal("expected Subjects cache to be populated before Clear")
	}

	ClearContentCaches()

	if _, ok := Subjects.Get("3:0"); ok {
		t.Fatal("expected Subjects cache to be empty after ClearContentCaches")
	}
}

func TestClearAnnouncementCache_ClearsAnnouncements(t *testing.T) {
	Announcements.Set("1:0", []string{"hello"})
	if _, ok := Announcements.Get("1:0"); !ok {
		t.Fatal("expected Announcements cache to be populated before Clear")
	}

	ClearAnnouncementCache()

	if _, ok := Announcements.Get("1:0"); ok {
		t.Fatal("expected Announcements cache to be empty after ClearAnnouncementCache")
	}
}

func TestClearSubscriptionPlanCache_ClearsPlans(t *testing.T) {
	SubscriptionPlans.Set("all", []string{"plan1"})
	if _, ok := SubscriptionPlans.Get("all"); !ok {
		t.Fatal("expected SubscriptionPlans cache to be populated before Clear")
	}

	ClearSubscriptionPlanCache()

	if _, ok := SubscriptionPlans.Get("all"); ok {
		t.Fatal("expected SubscriptionPlans cache to be empty after ClearSubscriptionPlanCache")
	}
}

func TestClearContentCaches_DoesNotAffectOtherStores(t *testing.T) {
	Announcements.Set("x", "y")
	SubscriptionPlans.Set("x", "y")

	ClearContentCaches()

	if _, ok := Announcements.Get("x"); !ok {
		t.Fatal("ClearContentCaches should not clear Announcements")
	}
	if _, ok := SubscriptionPlans.Get("x"); !ok {
		t.Fatal("ClearContentCaches should not clear SubscriptionPlans")
	}

	// cleanup so other tests in this package start clean
	Announcements.Clear()
	SubscriptionPlans.Clear()
}
