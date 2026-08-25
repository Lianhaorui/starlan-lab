<?php
namespace app\index\controller;

use think\Controller;
use think\Db;
use think\Session;

class Index extends Controller
{
    public function index()
    {
        if (!Session::get('admin_id')) {
            $this->redirect('index/login/index');
        }

        $admin = Db::name('admin_users')->where('id', Session::get('admin_id'))->find();

        $stats = [
            'members'       => Db::query('SELECT COUNT(*) AS c FROM lab_portal.users')[0]['c'],
            'registrations' => Db::query('SELECT COUNT(*) AS c FROM lab_portal.registrations')[0]['c'],
            'products'      => Db::query('SELECT COUNT(*) AS c FROM lab_portal.products')[0]['c'],
            'logs'          => Db::name('admin_logs')->count(),
        ];

        $logs = Db::name('admin_logs')->order('id DESC')->limit(6)->select();

        $this->assign('admin', $admin);
        $this->assign('stats', $stats);
        $this->assign('logs', $logs);
        return $this->fetch();
    }
}
