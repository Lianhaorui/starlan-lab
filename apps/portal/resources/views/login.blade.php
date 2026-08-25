@extends('layouts.app')

@section('content')
<div class="authbox">
<h1>登录</h1>
<form method="POST" action="/login">
    @csrf
    <label>邮箱 <input type="email" name="email" value="{{ old('email') }}" required></label>
    <label>密码 <input type="password" name="password" required></label>
    <button type="submit">登录</button>
</form>
<p class="muted">还没有账号？<a href="/register">注册</a></p>
</div>
@endsection
