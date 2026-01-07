<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Course extends Model
{
    protected $fillable = [
        'title',
        'category',
        'description',
        'image_url',
        'instructor',
        'lessons_count',
        'duration',
        'rating',
        'review_count',
        'joined_count',
        'is_featured',
        'is_popular',
        'price',
    ];

    protected $casts = [
        'rating' => 'decimal:1',
        'price' => 'decimal:2',
        'is_featured' => 'boolean',
        'is_popular' => 'boolean',
    ];

    public function lessons()
    {
        return $this->hasMany(Lesson::class)->orderBy('order');
    }

    public function buyers()
    {
        return $this->belongsToMany(User::class, 'purchases');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }
}
