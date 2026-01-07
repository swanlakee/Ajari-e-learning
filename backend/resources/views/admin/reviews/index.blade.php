@extends('admin.layout')

@section('title', 'Manage Reviews')

@section('content')
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-bold">Manage User Reviews</h1>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="border-b bg-gray-50">
                        <th class="p-3 text-sm font-semibold text-gray-700">Course</th>
                        <th class="p-3 text-sm font-semibold text-gray-700">User</th>
                        <th class="p-3 text-sm font-semibold text-gray-700">Rating</th>
                        <th class="p-3 text-sm font-semibold text-gray-700">Comment</th>
                        <th class="p-3 text-sm font-semibold text-gray-700">Date</th>
                        <th class="p-3 text-sm font-semibold text-gray-700 text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($reviews as $review)
                        <tr class="border-b hover:bg-gray-50">
                            <td class="p-3">
                                <span class="font-medium text-blue-600">{{ $review->course->title }}</span>
                            </td>
                            <td class="p-3">
                                <div class="flex items-center gap-2">
                                    @if($review->user->photo_url)
                                        <img src="{{ $review->user->photo_url }}" class="w-8 h-8 rounded-full">
                                    @else
                                        <div class="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center text-xs">
                                            {{ substr($review->user->name, 0, 1) }}
                                        </div>
                                    @endif
                                    <span>{{ $review->user->name }}</span>
                                </div>
                            </td>
                            <td class="p-3">
                                <div class="flex items-center">
                                    <span class="text-orange-400">★</span>
                                    <span class="ml-1">{{ $review->rating }}</span>
                                </div>
                            </td>
                            <td class="p-3 max-w-xs">
                                <p class="truncate" title="{{ $review->comment }}">{{ $review->comment }}</p>
                            </td>
                            <td class="p-3 text-sm text-gray-500">
                                {{ $review->created_at->format('d M Y') }}
                            </td>
                            <td class="p-3 text-center">
                                <form action="{{ route('admin.reviews.destroy', $review->id) }}" method="POST"
                                    onsubmit="return confirm('Apakah Anda yakin ingin menghapus ulasan ini?')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="text-red-600 hover:text-red-800 font-medium">
                                        Delete
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        <div class="mt-6">
            {{ $reviews->links() }}
        </div>
    </div>
@endsection