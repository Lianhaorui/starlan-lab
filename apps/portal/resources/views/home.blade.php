@extends('layouts.app')

@section('content')
<h1>活动列表</h1>
<div class="cards">
    @forelse($activities as $a)
    <a class="card" href="/activities/{{ $a->id }}">
        <h3>{{ $a->title }}</h3>
        <p class="muted">{{ \Illuminate\Support\Str::limit($a->description, 60) }}</p>
        <p>名额：{{ $a->capacity }} 人 · 状态：{{ $a->status === 'open' ? '报名中' : $a->status }}</p>
    </a>
    @empty
    <p class="muted">暂无活动</p>
    @endforelse
</div>
@endsection
