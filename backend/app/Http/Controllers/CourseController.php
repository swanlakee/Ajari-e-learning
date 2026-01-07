<?php

namespace App\Http\Controllers;

use App\Models\Course;
use Illuminate\Http\Request;

class CourseController extends Controller
{
    /**
     * Get all courses (public API).
     */
    public function index(Request $request)
    {
        $query = Course::query();

        // Filter by category
        if ($request->has('category') && $request->category !== 'null') {
            $query->where('category', 'LIKE', '%' . $request->category . '%');
        }

        // Filter featured
        if ($request->has('featured')) {
            $query->where('is_featured', true);
        }

        // Filter popular
        if ($request->has('popular')) {
            $query->where('is_popular', true);
        }

        // Search by title
        if ($request->has('search') && $request->search != null) {
            $query->where('title', 'LIKE', '%' . $request->search . '%');
        }

        $courses = $query->with('lessons')->orderBy('created_at', 'desc')->get();

        // If user is logged in, check which courses they have purchased
        $purchasedIds = [];
        if (auth('sanctum')->check()) {
            $purchasedIds = auth('sanctum')->user()->purchasedCourses()->pluck('courses.id')->toArray();
        }

        $courses->each(function ($course) use ($purchasedIds) {
            $course->is_purchased = in_array($course->id, $purchasedIds) || $course->price == 0;
        });

        return response()->json($courses);
    }

    /**
     * Get course detail.
     */
    public function show($id)
    {
        $course = Course::with('lessons')->find($id);

        if (!$course) {
            return response()->json(['message' => 'Course not found'], 404);
        }

        $isPurchased = false;
        if (auth('sanctum')->check()) {
            $isPurchased = auth('sanctum')->user()->purchasedCourses()->where('courses.id', $id)->exists();
        }

        $course->is_purchased = $isPurchased || $course->price == 0;

        return response()->json($course);
    }

    /**
     * Get all categories.
     */
    public function categories()
    {
        $categories = Course::select('category')
            ->distinct()
            ->pluck('category');

        return response()->json($categories);
    }

    /**
     * Get authenticated user's purchased courses.
     */
    public function myCourses(Request $request)
    {
        $user = $request->user();
        $courses = $user->purchasedCourses()->with('lessons')->orderBy('purchases.created_at', 'desc')->get();

        // Add purchased flag (always true here)
        $courses->each(function ($course) {
            $course->is_purchased = true;
        });

        return response()->json($courses);
    }
}
