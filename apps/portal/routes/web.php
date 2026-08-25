<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect('/home');
});

Route::get('/login', 'AuthController@showLogin')->name('login');
Route::post('/login', 'AuthController@login');
Route::get('/register', 'AuthController@showRegister');
Route::post('/register', 'AuthController@register');
Route::get('/logout', 'AuthController@logout');

Route::get('/home', 'ActivityController@index');
Route::get('/activities/{activity}', 'ActivityController@show');
Route::post('/activities/{activity}/register', 'ActivityController@storeRegistration')->middleware('auth.check');
Route::get('/registration/{id}', 'ActivityController@showRegistration')->middleware('auth.check');

Route::get('/products', 'ProductController@index');
Route::get('/preview', 'PreviewController@index')->middleware('auth.check');
Route::post('/preview', 'PreviewController@fetch')->middleware('auth.check');
Route::get('/files', 'FileController@index');
Route::get('/files/download', 'FileController@download');
