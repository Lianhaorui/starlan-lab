<!doctype html>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>星澜校园云</title>
    <link rel="stylesheet" href="/app.css">
</head>
<body>
<header class="topbar">
    <div class="brand">星澜校园云</div>
    <nav>
        <a href="/home">活动</a>
        <a href="/products">物资</a>
        <a href="/preview">链接预览</a>
        <a href="/files">文件下载</a>
        @if(session('uid'))
            <span class="muted">{{ session('name') }}</span>
            <a href="/logout">退出</a>
        @else
            <a href="/login">登录</a>
            <a href="/register">注册</a>
        @endif
    </nav>
</header>
<main class="container">
    @if ($errors->any())
        <div class="alert error">
            @foreach ($errors->all() as $err)
                <p>{{ $err }}</p>
            @endforeach
        </div>
    @endif
    @yield('content')
    <footer class="footer muted">星澜校园云 · 校园社团数字化服务平台 · v3.2</footer>
</main>
</body>
</html>
