<?php

use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ProductController;
use Illuminate\Support\Facades\Route;

Route::get('/dashboard', DashboardController::class);
Route::apiResource('products', ProductController::class);
