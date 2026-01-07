<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CourseController;
use App\Http\Controllers\PurchaseController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Public course routes
Route::get('/courses', [CourseController::class, 'index']);
Route::get('/courses/{id}', [CourseController::class, 'show']);
Route::get('/categories', [CourseController::class, 'categories']);

// Protected routes (require authentication)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/my-courses', [CourseController::class, 'myCourses']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    Route::put('/user', [AuthController::class, 'updateProfile']);

    // Purchase routes
    Route::post('/purchase', [PurchaseController::class, 'store']);
    Route::get('/balance', [PurchaseController::class, 'userBalance']);

    // Top Up Routes
    Route::post('/topup', [Api\TransactionController::class, 'store']);
    Route::get('/transactions/{externalId}/check', [Api\TransactionController::class, 'checkStatus']);

    // Lesson Access
    Route::get('/lessons/{id}/access', [CourseController::class, 'accessLesson']);

    // Review API
    Route::get('/courses/{courseId}/reviews', [Api\ReviewController::class, 'index']);
    Route::post('/courses/{courseId}/reviews', [Api\ReviewController::class, 'store']);
    Route::put('/reviews/{id}', [Api\ReviewController::class, 'update']);
    Route::delete('/reviews/{id}', [Api\ReviewController::class, 'destroy']);
});
