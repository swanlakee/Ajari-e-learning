<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\Casts\Attribute;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'fullname',
        'email',
        'password',
        'photo_url',
        'balance',
        'role',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'balance' => 'integer',
        ];
    }

    /**
     * Get the user's photo URL.
     */
    public function getPhotoUrlAttribute($value)
    {
        return $value ?: 'https://ui-avatars.com/api/?name=' . urlencode($this->name) . '&background=1665D8&color=fff&size=128';
    }

    public function purchases()
    {
        return $this->hasMany(Purchase::class);
    }

    public function purchasedCourses()
    {
        return $this->belongsToMany(Course::class, 'purchases');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }
}
