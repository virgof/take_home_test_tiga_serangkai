<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UsersSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        User::create([
            'name' => 'User A',
            'email' => 'usera@example.com',
            'password' => Hash::make('password'),
            "password_confirmation"=> Hash::make('password'),
            "balance"=> "10000",
        ]);

        User::create([
            'name' => 'User B',
            'email' => 'userb@example.com',
            'password' => Hash::make('password'),
            "password_confirmation"=> Hash::make('password'),
            "balance"=> "5000",
        ]);

        User::create([
            'name' => 'User C',
            'email' => 'userc@example.com',
            'password' => Hash::make('password'),
            "password_confirmation"=> Hash::make('password'),
            "balance"=> "1000",
        ]);
    }
}
