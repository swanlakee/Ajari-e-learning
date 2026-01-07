<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Register a new user.
     */
    public function register(Request $request)
    {
        $request->validate([
            'fullname' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'name' => $request->fullname,
            'fullname' => $request->fullname,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'message' => 'Akun berhasil dibuat',
            'user' => [
                'uid' => (string) $user->id,
                'fullname' => $user->fullname,
                'email' => $user->email,
                'photoUrl' => $user->photo_url,
                'balance' => $user->balance,
            ],
        ], 201);
    }

    /**
     * Login user and create token.
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau kata sandi salah'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'token' => $token,
            'user' => [
                'uid' => (string) $user->id,
                'fullname' => $user->fullname,
                'email' => $user->email,
                'photoUrl' => $user->photo_url,
                'balance' => $user->balance,
            ],
        ]);
    }

    /**
     * Logout user (revoke token).
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout berhasil',
        ]);
    }

    /**
     * Get authenticated user profile.
     */
    public function user(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'uid' => (string) $user->id,
            'fullname' => $user->fullname,
            'email' => $user->email,
            'photoUrl' => $user->photo_url,
            'balance' => $user->balance,
        ]);
    }

    /**
     * Update user profile.
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'fullname' => 'sometimes|string|max:255',
            'photo_url' => 'sometimes|string|nullable',
        ]);

        if ($request->has('fullname')) {
            $user->fullname = $request->fullname;
            $user->name = $request->fullname;
        }

        if ($request->has('photo_url')) {
            $user->photo_url = $request->photo_url;
        }

        $user->save();

        return response()->json([
            'message' => 'Profil berhasil diperbarui',
            'user' => [
                'uid' => (string) $user->id,
                'fullname' => $user->fullname,
                'email' => $user->email,
                'photoUrl' => $user->photo_url,
                'balance' => $user->balance,
            ],
        ]);
    }
}
