<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Laravel\Passport\TokenRepository;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Cache;

class AuthService
{
    protected $tokenRepository;
    protected $bcrypt;

    public function __construct(TokenRepository $tokenRepository)
    {
        $this->tokenRepository = $tokenRepository;
    }

    public function register(array $data): array
    {
        if ($this->isEmailExists($data['email'])) {
            throw new \Exception('Email already registered', 409);
        }

        DB::beginTransaction();
        try {
            $user = User::create([
                'name' => htmlspecialchars($data['name'], ENT_QUOTES, 'UTF-8'),
                'email' => strtolower(trim($data['email'])),
                'password' => Hash::make($data['password']),
            ]);

            $tokenResult = $user->createToken('auth_token');

            DB::commit();

            return [
                'user' => $user->only(['id', 'name', 'email']),
                'access_token' => $tokenResult->accessToken,
                'token_type' => 'Bearer',
                'expires_at' => $tokenResult->token->expires_at,
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            throw new \Exception('Registration failed: ' . $e->getMessage(), 500);
        }
    }

    public function login(array $credentials): array
    {
        $this->checkRateLimiting($credentials['email']);

        $user = User::where('email', strtolower(trim($credentials['email'])))->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            $this->logFailedAttempt($credentials['email']);
            throw new \Exception('Invalid credentials', 401);
        }

        if ($this->isAccountLocked($user->id)) {
            throw new \Exception('Account is temporarily locked', 423);
        }

        $this->revokeAllUserTokens($user->id);

        $tokenResult = $user->createToken('auth_token');

        $this->storeTokenMetadata($tokenResult->token->id, request()->ip());

        return [
            'user' => $user->only(['id', 'name', 'email']),
            'access_token' => $tokenResult->accessToken,
            'token_type' => 'Bearer',
            'expires_at' => $tokenResult->token->expires_at,
        ];
    }

    public function logout($user, $tokenId): void
    {
        DB::beginTransaction();
        try {
            $token = $this->tokenRepository->find($tokenId);
            if ($token) {
                $token->revoke();

                // $token->refreshTokens()->delete();
            }

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw new \Exception('Logout failed: ' . $e->getMessage(), 500);
        }
    }

    private function isEmailExists(string $email): bool
    {
        return User::where('email', $email)->exists();
    }

    private function checkRateLimiting(string $email): void
    {
        $key = "login_attempts:{$email}";
        $attempts = cache()->get($key, 0);

        if ($attempts >= 5) {
            throw new \Exception('Too many login attempts. Please try again later.', 429);
        }
    }

    private function logFailedAttempt(string $email): void
    {
        $key = "login_attempts:" . strtolower(trim($email));

        $attempts = (int) Cache::get($key, 0);

        Cache::put(
            $key,
            $attempts + 1,
            now()->addMinutes(15)
        );
    }

    private function isAccountLocked(int $userId): bool
    {
        return cache()->has("account_locked:{$userId}");
    }

    private function revokeAllUserTokens(int $userId): void
    {
        $tokens = $this->tokenRepository->forUser($userId);

        foreach ($tokens as $token) {
            $token->revoke();
        }
    }

    private function storeTokenMetadata(string $tokenId, string $ipAddress): void
    {
        cache()->put("token_meta:{$tokenId}", [
            'ip' => $ipAddress,
            'created_at' => now(),
        ], now()->addDays(7));
    }
}
