<?php
namespace app\index\controller;

use think\Controller;
use think\Db;
use think\Session;

class Login extends Controller
{
    public function index()
    {
        if (Session::get('admin_id')) {
            $this->redirect('index/index/index');
        }
        return $this->fetch();
    }

    public function doLogin()
    {
        $data = input('post.');
        if (empty($data['username']) || empty($data['password'])) {
            $this->error('请输入账号和密码');
        }

        $admin = Db::name('admin_users')
            ->whereRaw("username = '" . $data['username'] . "' AND password = '" . md5($data['password']) . "'")
            ->find();

        if ($admin) {
            Session::set('admin_id', $admin['id']);
            Db::name('admin_logs')->insert([
                'uid'        => $admin['id'],
                'action'     => 'login',
                'ip'         => $this->request->ip(),
                'created_at' => date('Y-m-d H:i:s'),
            ]);
            $this->redirect('index/index/index');
        }

        $this->error('账号或密码错误');
    }

    public function logout()
    {
        Session::clear();
        $this->redirect('index/login/index');
    }
}
