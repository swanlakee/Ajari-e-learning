<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Course;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AdminController extends Controller
{
    public function showLogin()
    {
        if (Auth::check()) {
            return redirect()->route('admin.dashboard');
        }
        return view('admin.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (Auth::attempt($request->only('email', 'password'))) {
            if (auth()->user()->role !== 'admin') {
                Auth::logout();
                return back()->withErrors([
                    'email' => 'Anda tidak memiliki akses admin.',
                ]);
            }

            $request->session()->regenerate();
            return redirect()->route('admin.dashboard');
        }

        return back()->withErrors([
            'email' => 'Email atau password salah.',
        ]);
    }

    public function dashboard()
    {
        $coursesCount = Course::count();
        $usersCount = User::count();
        $featuredCount = Course::where('is_featured', true)->count();
        $popularCount = Course::where('is_popular', true)->count();

        // Chart Data: Last 7 Days
        $dates = collect();
        for ($i = 6; $i >= 0; $i--) {
            $dates->push(now()->subDays($i)->format('Y-m-d'));
        }

        $revenueData = $dates->map(function ($date) {
            return \App\Models\Transaction::whereDate('created_at', $date)
                ->where('status', 'PAID')
                ->sum('amount');
        });

        $newUsersData = $dates->map(function ($date) {
            return User::whereDate('created_at', $date)->count();
        });

        return view('admin.dashboard', compact(
            'coursesCount',
            'usersCount',
            'featuredCount',
            'popularCount',
            'dates',
            'revenueData',
            'newUsersData'
        ));
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login');
    }
}
