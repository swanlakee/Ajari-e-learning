<?php

namespace App\Http\Controllers;

use App\Models\Course;
use App\Models\Purchase;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PurchaseController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'course_id' => 'required|exists:courses,id',
        ]);

        $user = $request->user();
        $course = Course::findOrFail($request->course_id);

        // Check if already purchased
        if ($user->purchasedCourses()->where('courses.id', $course->id)->exists()) {
            return response()->json(['message' => 'Course already purchased'], 400);
        }

        // Check if course is free
        if ($course->price <= 0) {
            $user->purchasedCourses()->attach($course->id);
            return response()->json(['message' => 'Free course joined successfully']);
        }

        // Check balance
        if ($user->balance < $course->price) {
            return response()->json(['message' => 'Insufficient balance'], 400);
        }

        // Process purchase in transaction
        return DB::transaction(function () use ($user, $course) {
            // Deduct balance
            $user->decrement('balance', $course->price);

            // Create purchase record
            $user->purchasedCourses()->attach($course->id);

            // Increment course joined count
            $course->increment('joined_count');

            return response()->json([
                'message' => 'Course purchased successfully',
                'new_balance' => $user->fresh()->balance
            ]);
        });
    }

    public function userBalance(Request $request)
    {
        return response()->json([
            'balance' => $request->user()->balance
        ]);
    }
}
