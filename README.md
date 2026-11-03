# SmartStock

SmartStock is now a web application with a separated Laravel API backend and
React frontend.

## Project structure

```text
backend/                         # Laravel 11 API
├── app/
│   ├── Http/Controllers/Api/    # API controllers
│   └── Models/                  # Eloquent models
├── database/migrations/         # Database schema
├── routes/api.php               # API routes
└── composer.json
frontend/                        # React + Vite web client
├── src/
│   ├── services/                # HTTP/API clients
│   ├── App.jsx                  # Application screens and state
│   └── styles.css               # Web design system
└── package.json
```

The frontend communicates with Laravel through `/api/products` and
`/api/dashboard`. Product data is persisted by Laravel and SQLite.

## Requirements

- PHP 8.2+
- Composer 2+
- Node.js 20+ and npm
- SQLite PHP extension (enabled in `php.ini`)
- Git
- VS Code (recommended)

## Install and run

Terminal 1 — backend:

```powershell
cd backend
copy .env.example .env
New-Item database\database.sqlite -ItemType File
composer install
php artisan key:generate
php artisan migrate
php artisan serve
```

Terminal 2 — frontend:

```powershell
cd frontend
npm install
npm run dev
```

Open <http://localhost:5173>.

## Production builds

```powershell
cd frontend
npm run build
```

The production frontend is generated in `frontend/dist`. Deploy it with the
Laravel API or configure the hosting server to proxy `/api` to Laravel.
