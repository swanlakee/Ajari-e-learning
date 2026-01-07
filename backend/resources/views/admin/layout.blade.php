<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin Panel') - Ajari</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">
    <div class="min-h-screen flex">
        <!-- Sidebar -->
        <aside class="w-64 bg-blue-600 text-white">
            <div class="p-4">
                <h1 class="text-2xl font-bold">🎓 Ajari Admin</h1>
            </div>
            <nav class="mt-6">
                <a href="{{ route('admin.dashboard') }}"
                    class="block px-4 py-3 hover:bg-blue-700 {{ request()->routeIs('admin.dashboard') ? 'bg-blue-700' : '' }}">
                    📊 Dashboard
                </a>
                <a href="{{ route('admin.courses.index') }}"
                    class="block px-4 py-3 hover:bg-blue-700 {{ request()->routeIs('admin.courses.*') ? 'bg-blue-700' : '' }}">
                    📚 Courses
                </a>
                <a href="{{ route('admin.reviews.index') }}"
                    class="block px-4 py-3 hover:bg-blue-700 {{ request()->routeIs('admin.reviews.*') ? 'bg-blue-700' : '' }}">
                    ⭐ Reviews
                </a>
                <a href="{{ route('admin.transactions.index') }}"
                    class="block px-4 py-3 hover:bg-blue-700 {{ request()->routeIs('admin.transactions.*') ? 'bg-blue-700' : '' }}">
                    💸 Transactions
                </a>
                <a href="{{ route('admin.users.index') }}"
                    class="block px-4 py-3 hover:bg-blue-700 {{ request()->routeIs('admin.users.*') ? 'bg-blue-700' : '' }}">
                    👥 Users
                </a>
            </nav>
            <div class="absolute bottom-0 w-64 p-4">
                <form action="{{ route('admin.logout') }}" method="POST">
                    @csrf
                    <button type="submit" class="w-full bg-red-500 hover:bg-red-600 py-2 rounded">
                        Logout
                    </button>
                </form>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="flex-1 p-8">
            @if(session('success'))
                <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
                    {{ session('success') }}
                </div>
            @endif

            @if($errors->any())
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
                    <ul>
                        @foreach($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            @yield('content')
        </main>
    </div>
</body>

</html>