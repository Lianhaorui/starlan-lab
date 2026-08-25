@extends('layouts.app')

@section('content')
<h1>报名详情 #{{ $reg ? $reg->id : $id }}</h1>

@if ($reg)
<div class="panel">
    <table class="table">
        <tr><th>活动</th><td>{{ $activity ? $activity->title : '-' }}</td></tr>
        <tr><th>姓名</th><td>{{ $reg->real_name }}</td></tr>
        <tr><th>身份证号</th><td>{{ $reg->idcard }}</td></tr>
        <tr><th>手机号</th><td>{{ $reg->phone }}</td></tr>
        <tr><th>备注</th><td>{{ $reg->remark }}</td></tr>
    </table>
</div>
@else
<p class="muted">报名记录不存在</p>
@endif
@endsection
