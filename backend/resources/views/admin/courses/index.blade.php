@extends('admin.layout')

@section('title', 'Courses')

@section('content')
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold">Courses</h1>
        <a href="{{ route('admin.courses.create') }}" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">
            + Tambah Course
        </a>
    </div>

    <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="w-full">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Image</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Title</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Instructor</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($courses as $course)
                    <tr>
                        <td class="px-6 py-4">
                            @if($course->image_url)
                                <img src="{{ $course->image_url }}" alt="" class="w-16 h-12 object-cover rounded">
                            @else
                                <div class="w-16 h-12 bg-gray-200 rounded flex items-center justify-center text-gray-400">
                                    📷
                                </div>
                            @endif
                        </td>
                        <td class="px-6 py-4">
                            <div class="font-medium">{{ $course->title }}</div>
                            <div class="text-sm text-gray-500">{{ $course->lessons_count }} lessons • {{ $course->duration }}
                            </div>
                        </td>
                        <td class="px-6 py-4">
                            <span class="px-2 py-1 bg-blue-100 text-blue-800 rounded text-sm">
                                {{ $course->category }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-gray-500">{{ $course->instructor ?? '-' }}</td>
                        <td class="px-6 py-4">
                            @if($course->is_featured)
                                <span class="px-2 py-1 bg-yellow-100 text-yellow-800 rounded text-xs mr-1">Featured</span>
                            @endif
                            @if($course->is_popular)
                                <span class="px-2 py-1 bg-purple-100 text-purple-800 rounded text-xs">Popular</span>
                            @endif
                        </td>
                        <td class="px-6 py-4">
                            <a href="{{ route('admin.courses.edit', $course->id) }}"
                                class="text-blue-600 hover:underline mr-3">Edit</a>
                            <form action="{{ route('admin.courses.destroy', $course->id) }}" method="POST" class="inline"
                                onsubmit="return confirm('Hapus course ini?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="text-red-600 hover:underline">Delete</button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="px-6 py-12 text-center text-gray-500">
                            Belum ada course. <a href="{{ route('admin.courses.create') }}" class="text-blue-600">Tambah course
                                pertama</a>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection