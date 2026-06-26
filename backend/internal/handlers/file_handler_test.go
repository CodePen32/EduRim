package handlers

import "testing"

func TestSanitizeFileKey(t *testing.T) {
	cases := map[string]bool{
		"images/test.png":              true,
		"videos/clip.mp4":              true,
		"pdfs/doc.pdf":                 true,
		"documents/file.docx":          true,
		"uploads/sub/file.pdf":         true,
		"../../backend/.env":           false,
		"images/../../../backend/.env": false,
		"/images/test.png":             true,
		"images//test.png":             false,
		`images\..\test.png`:           false,
		"etc/passwd":                   false,
		"images":                       false,
		"":                             false,
	}
	for in, wantValid := range cases {
		got := sanitizeFileKey(in)
		gotValid := got != ""
		if gotValid != wantValid {
			t.Errorf("sanitizeFileKey(%q) = %q (valid=%v), want valid=%v", in, got, gotValid, wantValid)
		}
	}
}
