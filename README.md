A. Backend (Laravel API)
1. Install dependencies
composer install

2. Salin file environment
cp .env.example .env

3. Generate app key
php artisan key:generate

4. Sesuaikan konfigurasi database di .env
DB_DATABASE=
DB_USERNAME=root
DB_PASSWORD=

5. Jalankan migration + seeder
php artisan migrate --seed

6. Jalankan server
php artisan serve

API berjalan di: http://localhost:8000

B. Frontend (Vue JS)
1. Install dependencies
npm install

2. Sesuaikan URL API Backend yang berjalan
src/api/index.js

3. Jalankan development server
npm run serve

App berjalan di: http://localhost:8080

C. Akun Default
- User 1
Field	        Value
Email	        usera@example.com
Password	password

- User 2
Field	        Value
Email	        userb@example.com
Password	password

- User 3
Field	        Value
Email	        userc@example.com
Password	password
