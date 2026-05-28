package models

import "time"

type Exercise struct {
	ID              uint      `json:"id"`
	SubjectID       uint      `json:"subject_id"`
	LessonID        *uint     `json:"lesson_id"`
	Title           string    `json:"title"`
	Year            int       `json:"year"`
	Difficulty      string    `json:"difficulty"`
	ExerciseFileURL string    `json:"exercise_file_url"`
	SolutionFileURL string    `json:"solution_file_url"`
	VideoSolutionURL string   `json:"video_solution_url"`
	CreatedAt       time.Time `json:"created_at"`
}
