<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Models\Course;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReviewController extends Controller
{
    public function index()
    {
        $reviews = Review::with(['user', 'course'])->latest()->paginate(20);
        return view('admin.reviews.index', compact('reviews'));
    }

    public function destroy($id)
    {
        $review = Review::findOrFail($id);
        $course = $review->course;

        DB::transaction(function () use ($review, $course) {
            $review->delete();

            // Re-calculate course rating
            $stats = Review::where('course_id', $course->id)
                ->selectRaw('count(*) as count, avg(rating) as avg_rating')
                ->first();

            $course->update([
                'review_count' => $stats->count,
                'rating' => round($stats->avg_rating ?? 0, 1)
            ]);
        });

        return redirect()->back()->with('success', 'Ulasan berhasil dihapus oleh admin.');
    }
}
