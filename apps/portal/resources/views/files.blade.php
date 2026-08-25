@extends('layouts.app')

@section('content')
<h1>文件下载</h1>
<ul class="filelist">
    <li><a href="/files/download?name=user_agreement.pdf">用户协议（user_agreement.pdf）</a></li>
    <li><a href="/files/download?name=reimbursement_template.txt">报销模板（reimbursement_template.txt）</a></li>
</ul>
@endsection
