<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Course;
use Illuminate\Http\Request;

class CourseController extends Controller
{
    public function index()
    {
        $courses = Course::orderBy('created_at', 'desc')->get();
        return view('admin.courses.index', compact('courses'));
    }

    public function create()
    {
        return view('admin.courses.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|string|max:100',
            'price' => 'nullable|numeric|min:0',
            'duration' => 'required|string|max:50',
            'lessons' => 'nullable|array',
            'lessons.*.title' => 'required|string|max:255',
        ]);

        $totalMinutes = $this->parseDurationToMinutes($request->duration);
        $lessonCount = is_array($request->lessons) ? count($request->lessons) : 0;
        $durationPerLesson = $lessonCount > 0 ? floor($totalMinutes / $lessonCount) : 0;

        $course = Course::create([
            'title' => $request->title,
            'category' => $request->category,
            'description' => $request->description,
            'image_url' => $request->image_url,
            'instructor' => $request->instructor,
            'lessons_count' => $lessonCount,
            'duration' => $request->duration,
            'price' => $request->price ?? 0,
            'rating' => 0,
            'review_count' => 0,
            'joined_count' => 0,
            'is_featured' => $request->has('is_featured'),
            'is_popular' => $request->has('is_popular'),
        ]);

        if ($request->has('lessons')) {
            foreach ($request->lessons as $index => $lessonData) {
                $course->lessons()->create([
                    'title' => $lessonData['title'],
                    'duration' => $durationPerLesson,
                    'order' => $index,
                ]);
            }
        }

        return redirect()->route('admin.courses.index')
            ->with('success', 'Course berhasil ditambahkan!');
    }

    public function edit($id)
    {
        $course = Course::findOrFail($id);
        return view('admin.courses.edit', compact('course'));
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'category' => 'required|string|max:100',
            'price' => 'nullable|numeric|min:0',
            'duration' => 'required|string|max:50',
            'lessons' => 'nullable|array',
            'lessons.*.title' => 'required|string|max:255',
        ]);

        $totalMinutes = $this->parseDurationToMinutes($request->duration);
        $lessonCount = is_array($request->lessons) ? count($request->lessons) : 0;
        $durationPerLesson = $lessonCount > 0 ? floor($totalMinutes / $lessonCount) : 0;

        $course = Course::findOrFail($id);
        $course->update([
            'title' => $request->title,
            'category' => $request->category,
            'description' => $request->description,
            'image_url' => $request->image_url,
            'instructor' => $request->instructor,
            'lessons_count' => $lessonCount,
            'duration' => $request->duration,
            'price' => $request->price ?? 0,
            'is_featured' => $request->has('is_featured'),
            'is_popular' => $request->has('is_popular'),
        ]);

        // Sync lessons: simpler to delete and recreate for this implementation
        $course->lessons()->delete();
        if ($request->has('lessons')) {
            foreach ($request->lessons as $index => $lessonData) {
                $course->lessons()->create([
                    'title' => $lessonData['title'],
                    'duration' => $durationPerLesson,
                    'order' => $index,
                ]);
            }
        }

        return redirect()->route('admin.courses.index')
            ->with('success', 'Course berhasil diupdate!');
    }

    public function destroy($id)
    {
        $course = Course::findOrFail($id);
        $course->delete();

        return redirect()->route('admin.courses.index')
            ->with('success', 'Course berhasil dihapus!');
    }

    private function parseDurationToMinutes($duration)
    {
        // Handle format like "5h 6m", "5h", "6m", or just numbers (assumed minutes)
        $totalMinutes = 0;

        if (is_numeric($duration)) {
            return (int) $duration;
        }

        // Pattern for hours (e.g., 5h)
        if (preg_match('/(\d+)\s*h/i', $duration, $matches)) {
            $totalMinutes += (int) $matches[1] * 60;
        }

        // Pattern for minutes (e.g., 6m or 6min)
        if (preg_match('/(\d+)\s*m/i', $duration, $matches)) {
            $totalMinutes += (int) $matches[1];
        }

        // If no unit found, but contains space separated numbers (e.g. "5 6")
        if ($totalMinutes == 0 && preg_match_all('/\d+/', $duration, $matches)) {
            if (count($matches[0]) >= 2) {
                $totalMinutes = ((int) $matches[0][0] * 60) + (int) $matches[0][1];
            } elseif (count($matches[0]) == 1) {
                $totalMinutes = (int) $matches[0][0];
            }
        }

        return $totalMinutes > 0 ? $totalMinutes : 0;
    }
}
