@extends('layouts.app')

@section('content')
<div class="authbox">
<h1>注册</h1>
<form method="POST" action="/register">
    @csrf
    <label>姓名 <input name="name" value="{{ old('name') }}" required></label>
    <label>邮箱 <input type="email" name="email" value="{{ old('email') }}" required></label>
    <label>手机号 <input name="phone" value="{{ old('phone') }}"></label>
    <label>密码 <input type="password" name="password" required></label>
    <label>确认密码 <input type="password" name="password_confirmation" required></label>
    <button type="submit">注册</button>
</form>
</div>
@endsection
