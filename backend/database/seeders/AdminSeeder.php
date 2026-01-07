<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'admin@ajari.com'],
            [
                'name' => 'Admin Ajari',
                'fullname' => 'Administrator',
                'email' => 'admin@ajari.com',
                'password' => Hash::make('password'),
                'role' => 'admin',
                'balance' => 0,
            ]
        );
    }
}
