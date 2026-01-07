@extends('admin.layout')

@section('title', 'Dashboard')

@section('content')
    <h1 class="text-2xl font-bold mb-6">Dashboard</h1>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div class="bg-white rounded-lg shadow p-6">
            <div class="flex items-center">
                <div class="bg-blue-100 p-3 rounded-full">
                    <span class="text-2xl">📚</span>
                </div>
                <div class="ml-4">
                    <p class="text-gray-500 text-sm">Total Courses</p>
                    <p class="text-2xl font-bold">{{ $coursesCount }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
            <div class="flex items-center">
                <div class="bg-green-100 p-3 rounded-full">
                    <span class="text-2xl">👥</span>
                </div>
                <div class="ml-4">
                    <p class="text-gray-500 text-sm">Total Users</p>
                    <p class="text-2xl font-bold">{{ $usersCount }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
            <div class="flex items-center">
                <div class="bg-yellow-100 p-3 rounded-full">
                    <span class="text-2xl">⭐</span>
                </div>
                <div class="ml-4">
                    <p class="text-gray-500 text-sm">Featured</p>
                    <p class="text-2xl font-bold">{{ $featuredCount }}</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow p-6">
            <div class="flex items-center">
                <div class="bg-purple-100 p-3 rounded-full">
                    <span class="text-2xl">🔥</span>
                </div>
                <div class="ml-4">
                    <p class="text-gray-500 text-sm">Popular</p>
                    <p class="text-2xl font-bold">{{ $popularCount }}</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Charts Section -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-8">
        <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-lg font-bold mb-4">Revenue (Last 7 Days)</h2>
            <canvas id="revenueChart"></canvas>
        </div>
        <div class="bg-white rounded-lg shadow p-6">
            <h2 class="text-lg font-bold mb-4">New Users (Last 7 Days)</h2>
            <canvas id="usersChart"></canvas>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        const dates = @json($dates);
        const revenueData = @json($revenueData);
        const newUsersData = @json($newUsersData);

        // Revenue Chart
        new Chart(document.getElementById('revenueChart'), {
            type: 'line',
            data: {
                labels: dates,
                datasets: [{
                    label: 'Revenue (Rp)',
                    data: revenueData,
                    borderColor: 'rgb(75, 192, 192)',
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    tension: 0.1,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'bottom' }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function (value) {
                                return 'Rp ' + value.toLocaleString('id-ID');
                            }
                        }
                    }
                }
            }
        });

        // Users Chart
        new Chart(document.getElementById('usersChart'), {
            type: 'bar',
            data: {
                labels: dates,
                datasets: [{
                    label: 'New Users',
                    data: newUsersData,
                    backgroundColor: 'rgba(54, 162, 235, 0.6)',
                    borderColor: 'rgb(54, 162, 235)',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'bottom' }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1 }
                    }
                }
            }
        });
    </script>

    <div class="mt-8">
        <a href="{{ route('admin.courses.create') }}"
            class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg inline-block">
            + Tambah Course Baru
        </a>
    </div>
@endsection