<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = [
        'name',
        'sku',
        'category',
        'supplier',
        'cost_price',
        'price',
        'quantity',
        'low_level',
    ];

    protected $casts = [
        'cost_price' => 'integer',
        'price' => 'integer',
        'quantity' => 'integer',
        'low_level' => 'integer',
    ];

    protected $appends = ['status'];

    public function getStatusAttribute(): string
    {
        return match (true) {
            $this->quantity <= 0 => 'Out of Stock',
            $this->quantity <= $this->low_level => 'Low Stock',
            default => 'In Stock',
        };
    }
}
