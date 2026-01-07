<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index()
    {
        $users = User::latest()->paginate(15);
        return view('admin.users.index', compact('users'));
    }

    public function destroy($id)
    {
        $user = User::findOrFail($id);

        // Prevent deleting self
        if (auth()->id() == $user->id) {
            return back()->withErrors(['Cannot delete your own account.']);
        }

        $user->delete();

        return back()->with('success', 'User has been deleted successfully.');
    }
}
