<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReviewController extends Controller
{
    public function index($courseId)
    {
        $reviews = Review::with('user:id,name,photo_url')
            ->where('course_id', $courseId)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $reviews
        ]);
    }

    public function store(Request $request, $courseId)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string',
        ]);

        $user = $request->user();
        $course = Course::findOrFail($courseId);

        // Check if user already purchased the course
        $hasPurchased = DB::table('purchases')
            ->where('user_id', $user->id)
            ->where('course_id', $courseId)
            ->exists();

        if (!$hasPurchased) {
            return response()->json([
                'success' => false,
                'message' => 'Anda harus membeli kursus ini terlebih dahulu sebelum memberikan ulasan.'
            ], 403);
        }

        // Check if user already reviewed
        $existingReview = Review::where('user_id', $user->id)
            ->where('course_id', $courseId)
            ->first();

        if ($existingReview) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah memberikan ulasan untuk kursus ini.'
            ], 400);
        }

        $review = DB::transaction(function () use ($request, $user, $course) {
            $review = Review::create([
                'user_id' => $user->id,
                'course_id' => $course->id,
                'rating' => $request->rating,
                'comment' => $request->comment,
            ]);

            $this->updateCourseRating($course);

            return $review;
        });

        return response()->json([
            'success' => true,
            'message' => 'Ulasan berhasil ditambahkan.',
            'data' => $review->load('user:id,name,photo_url')
        ]);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string',
        ]);

        $review = Review::findOrFail($id);

        if ($review->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized.'
            ], 403);
        }

        DB::transaction(function () use ($request, $review) {
            $review->update([
                'rating' => $request->rating,
                'comment' => $request->comment,
            ]);

            $this->updateCourseRating($review->course);
        });

        return response()->json([
            'success' => true,
            'message' => 'Ulasan berhasil diperbarui.',
            'data' => $review->load('user:id,name,photo_url')
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $review = Review::findOrFail($id);

        // Admin or the user itself can delete
        // For now, let's just allow the user to delete their own
        if ($review->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized.'
            ], 403);
        }

        $course = $review->course;

        DB::transaction(function () use ($review, $course) {
            $review->delete();
            $this->updateCourseRating($course);
        });

        return response()->json([
            'success' => true,
            'message' => 'Ulasan berhasil dihapus.'
        ]);
    }

    private function updateCourseRating(Course $course)
    {
        $stats = Review::where('course_id', $course->id)
            ->selectRaw('count(*) as count, avg(rating) as avg_rating')
            ->first();

        $course->update([
            'review_count' => $stats->count,
            'rating' => round($stats->avg_rating ?? 0, 1)
        ]);
    }
}
