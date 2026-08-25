<?php

namespace App\Http\Middleware;

use Closure;

class CheckLogin
{
    public function handle($request, Closure $next)
    {
        if (!$request->session()->has('uid')) {
            return redirect('/login');
        }
        return $next($request);
    }
}
