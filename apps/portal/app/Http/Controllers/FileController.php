<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class FileController extends Controller
{
    public function index()
    {
        return view('files');
    }

    public function download(Request $request)
    {
        $name = $request->input('name', 'user_agreement.pdf');
        $path = storage_path('app/public/' . $name);
        return response()->download($path);
    }
}
