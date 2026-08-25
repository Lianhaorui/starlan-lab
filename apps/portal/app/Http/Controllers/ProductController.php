<?php

namespace App\Http\Controllers;

use App\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $keyword = $request->input('keyword', '');
        $products = Product::where('visible', 1)
            ->where('name', 'like', "%{$keyword}%")
            ->orderBy('category')
            ->get();
        return view('products', ['products' => $products, 'keyword' => $keyword]);
    }
}
