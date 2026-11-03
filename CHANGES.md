# SmartStock Change Report

## Overview

SmartStock was converted from a Flutter application into a web-only system
with a separated Laravel backend and React frontend. The purpose of this
change was to remove mobile and desktop application code, establish a
professional and understandable project structure, and prepare the system for
future backend-driven inventory management.

## 1. Removed Flutter, mobile, and desktop code

The original Flutter/Dart application and its generated platform targets were
removed:

- Android application files and Gradle configuration
- Windows desktop runner and CMake configuration
- Flutter/Dart source files
- Flutter package manifests and lockfiles
- Flutter widget tests
- Flutter web bootstrap files and generated PWA icons
- Flutter metadata and analyzer configuration

This leaves the project focused exclusively on the browser-based application.

## 2. Added separated backend and frontend folders

The repository now has two clear top-level application areas:

```text
backend/     Laravel API and persistence layer
frontend/    React browser application
```

This separation allows backend and frontend development, testing, deployment,
and scaling to happen independently.

## 3. Laravel backend

The `backend` folder contains a Laravel-style API structure with:

- Laravel application bootstrap
- Composer dependency configuration
- API routes
- Product Eloquent model
- Product database migration
- Product CRUD controller
- Dashboard statistics controller
- Request validation for product data
- SQLite database configuration
- Environment configuration template
- Laravel public entrypoint and storage placeholders

### API endpoints

```text
GET    /api/products
POST   /api/products
GET    /api/products/{product}
PUT    /api/products/{product}
DELETE /api/products/{product}
GET    /api/dashboard
```

Products support:

- Name
- SKU
- Category
- Supplier
- Cost price
- Selling price
- Quantity
- Low-stock alert level
- Calculated stock status

The dashboard endpoint calculates total products, total units, stock health,
cost value, and retail value.

## 4. React frontend

The `frontend` folder contains a Vite-powered React application with:

- React application bootstrap
- Responsive dashboard
- Product catalog screen
- Product search
- Product creation form
- Product editing form
- Product deletion flow
- Stock health summary
- Inventory value cards
- API service layer
- Laravel development proxy configuration
- Responsive styling for desktop, tablet, and mobile browsers

The frontend communicates with Laravel through `/api` endpoints. Product
operations are no longer stored only in browser memory; they are sent to the
backend API for persistence.

## 5. Design and usability improvements

The new interface includes:

- Consistent SmartStock branding
- Sidebar navigation
- Dashboard summary cards
- Inventory health indicators
- Searchable product table
- Clear product status badges
- Modal product form
- Responsive layouts
- Empty, loading, and backend-unavailable states
- Action buttons for product management

## 6. Dependency and configuration changes

Flutter dependencies were removed and replaced with:

### Backend

- Laravel framework
- PHP 8.2+
- Composer
- Eloquent ORM
- SQLite support

### Frontend

- React
- React DOM
- Vite
- Lucide React icons
- npm

Generated dependencies and environment-specific files are excluded through
`.gitignore`.

## 7. Documentation updates

`README.md` was updated to document:

- The backend/frontend architecture
- Project folders
- Required software
- Backend installation
- Frontend installation
- Development commands
- Production frontend builds

This file provides the more detailed historical record of the migration and
implementation changes.

## 8. Git delivery

The completed restructuring was committed with:

```text
1a1e0e7 done by changing the project into good stractre
```

The `dev` branch was pushed to the remote repository and configured to track
`origin/dev`.

## 9. Running the final application

Install PHP, Composer, Node.js, npm, Git, and enable the SQLite PHP extension.

Start the backend:

```powershell
cd backend
copy .env.example .env
New-Item database\database.sqlite -ItemType File
composer install
php artisan key:generate
php artisan migrate
php artisan serve
```

Start the frontend in a second terminal:

```powershell
cd frontend
npm install
npm run dev
```

Open `http://localhost:5173`.

## 10. Validation status

- Repository changes were checked with `git diff --check`.
- The final project no longer contains Flutter, Dart, Android, or Windows
  application code.
- Node.js and npm were available in the development environment.
- PHP and Composer were not installed in the development environment, so the
  Laravel dependency installation and backend runtime could not be executed
  there.
