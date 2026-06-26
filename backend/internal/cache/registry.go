package cache

import "time"

// TTL is the shared cache lifetime for Phase 2A semi-static data.
// Kept short because admins add subjects/lessons/announcements/plans
// frequently and must see changes reflected quickly even without explicit
// invalidation.
const TTL = 90 * time.Second

// Named, package-level stores shared across repositories/handlers so admin
// write handlers can invalidate them without threading cache instances
// through every constructor.
var (
	LearningPaths     = New("learning_paths", TTL)
	BacBranches       = New("bac_branches", TTL)
	Subjects          = New("subjects", TTL)
	Announcements     = New("announcements", TTL)
	SubscriptionPlans = New("subscription_plans", TTL)
)

// ClearContentCaches invalidates everything affected by admin content writes
// (subjects, lessons, announcements). Lessons themselves are not cached in
// Phase 2A, but creating/editing a subject changes the subjects list and may
// change lesson counts embedded in it.
func ClearContentCaches() {
	Subjects.Clear()
}

// ClearAnnouncementCache invalidates the announcements cache.
func ClearAnnouncementCache() {
	Announcements.Clear()
}

// ClearSubscriptionPlanCache invalidates the subscription plans cache.
func ClearSubscriptionPlanCache() {
	SubscriptionPlans.Clear()
}
