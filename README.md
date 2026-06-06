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

D. Frontend Flutter
1. Persyaratan
PHP 7.4.27 atau lebih tinggi
Composer
MySQL 5.7 atau lebih tinggi
Node.js 16.17.0
Flutter SDK 3.x

2. Clone repository
git clone https://github.com/yourusername/miniwallet-mobile.git
cd miniwallet-mobile

3. Install dependencies
flutter pub get

4. Konfigurasi base URL
# Edit lib/utils/constants.dart
static const String baseUrl = 'http://192.168.1.100:8000/api'; // Ganti dengan IP komputer

5. Run aplikasi
flutter run

6. Build APK
flutter build apk --release
