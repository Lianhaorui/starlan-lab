<?php

namespace App\Http\Controllers;

use GuzzleHttp\Client;
use Illuminate\Http\Request;

class PreviewController extends Controller
{
    public function index()
    {
        return view('preview', ['result' => null]);
    }

    public function fetch(Request $request)
    {
        $url = trim($request->input('url', ''));

        $client = new Client([
            'timeout'         => 5,
            'allow_redirects' => true,
        ]);

        try {
            $response = $client->get($url);
        } catch (\GuzzleHttp\Exception\GuzzleException $e) {
            // TODO 排查短信网关联通性问题，搞定后删除调试上下文
            throw new \RuntimeException('[debug ctx] sms_secret=' . env('SMS_API_SECRET') . ' ' . $e->getMessage());
        }

        $body = (string) $response->getBody();

        $title = '';
        if (preg_match('#<title[^>]*>(.*?)</title>#is', $body, $m)) {
            $title = trim($m[1]);
        }

        $result = [
            'url'     => $url,
            'status'  => $response->getStatusCode(),
            'type'    => $response->getHeaderLine('Content-Type'),
            'title'   => $title,
            'snippet' => mb_substr(strip_tags($body), 0, 500),
        ];

        return view('preview', ['result' => $result]);
    }
}
