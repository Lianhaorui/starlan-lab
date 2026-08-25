@extends('layouts.app')

@section('content')
<h1>链接预览</h1>
<p class="muted">粘贴一个网页链接，系统会抓取页面生成摘要卡片（用于活动分享配图）。</p>

<form method="POST" action="/preview">
    @csrf
    <div class="searchbar">
        <input name="url" placeholder="https://example.com/page" required>
        <button type="submit">生成预览</button>
    </div>
</form>

@if ($result)
<div class="panel">
    <h3>{{ $result['title'] ?: '(无标题)' }}</h3>
    <p class="muted">{{ $result['url'] }} · HTTP {{ $result['status'] }} · {{ $result['type'] }}</p>
    <p>{{ $result['snippet'] }}</p>
</div>
@endif
@endsection
