@extends('layouts.app')

@section('content')
<h1>{{ $activity->title }}</h1>
<p class="muted">{{ $activity->description }}</p>
<p>名额：{{ $activity->capacity }} 人</p>

@if ($mine)
    <div class="panel">
        <h3>已提交报名</h3>
        <p>报名编号：<a href="/registration/{{ $mine->id }}">#{{ $mine->id }}</a></p>
    </div>
@else
@if (!session('uid'))
        <p><a href="/login">登录</a> 后可报名。</p>
    @else
    <div class="panel">
        <h3>活动报名</h3>
        <form method="POST" action="/activities/{{ $activity->id }}/register">
            @csrf
            <label>真实姓名 <input name="real_name" required></label>
            <label>身份证号 <input name="idcard" required></label>
            <label>手机号 <input name="phone" required></label>
            <button type="submit">提交报名</button>
        </form>
    </div>
    @endif
@endif
@endsection
