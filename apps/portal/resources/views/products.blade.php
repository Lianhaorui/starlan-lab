@extends('layouts.app')

@section('content')
<h1>物资目录</h1>
<form method="GET" action="/products" class="searchbar">
    <input name="keyword" value="{{ $keyword }}" placeholder="搜索物资名称">
    <button type="submit">查询</button>
</form>

<table class="table">
    <tr><th>名称</th><th>分类</th><th>库存</th><th>单价</th></tr>
    @forelse($products as $p)
    <tr>
        <td>{{ $p->name }}</td>
        <td>{{ $p->category }}</td>
        <td>{{ $p->stock }}</td>
        <td>￥{{ $p->price }}</td>
    </tr>
    @empty
    <tr><td colspan="4" class="muted">暂无结果</td></tr>
    @endforelse
</table>
@endsection
