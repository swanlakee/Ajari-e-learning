<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class Transaction extends Model
{
    protected $fillable = [
        'user_id',
        'external_id',
        'amount',
        'status',
        'payment_url',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
