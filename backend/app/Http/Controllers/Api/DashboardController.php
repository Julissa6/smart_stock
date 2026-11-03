<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $products = Product::all();

        return response()->json([
            'data' => [
                'total_products' => $products->count(),
                'total_units' => $products->sum('quantity'),
                'in_stock' => $products->filter(fn (Product $product): bool => $product->status === 'In Stock')->count(),
                'low_stock' => $products->filter(fn (Product $product): bool => $product->status === 'Low Stock')->count(),
                'out_of_stock' => $products->filter(fn (Product $product): bool => $product->status === 'Out of Stock')->count(),
                'cost_value' => $products->sum(fn (Product $product): int => $product->cost_price * $product->quantity),
                'retail_value' => $products->sum(fn (Product $product): int => $product->price * $product->quantity),
            ],
        ]);
    }
}
