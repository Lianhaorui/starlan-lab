<?php
/**
 * Plugin Name: 星澜会员通
 * Description: 资讯站会员电子卡与主站会员数据同步工具。
 * Version: 2.1.3
 * Author: StarLan Dev Team
 * Author URI: https://news.starlan.club
 */

if (!defined('ABSPATH')) {
    exit;
}

class StarLan_Member
{
    public function __construct()
    {
        add_action('init', [$this, 'render_card']);
        add_action('admin_menu', [$this, 'admin_menu']);
        add_action('admin_post_sm_import', [$this, 'handle_import']);
    }

    /**
     * 会员电子卡展示页（前台，形如 /?sm_card=SL20260001）
     */
    public function render_card()
    {
        if (!isset($_GET['sm_card'])) {
            return;
        }
        $card = $_GET['sm_card'];

        status_header(200);
        header('Content-Type: text/html; charset=utf-8');
        echo '<!doctype html><meta charset="utf-8"><title>会员电子卡</title>';
        echo '<body style="font-family:-apple-system,PingFang SC,Microsoft YaHei,sans-serif;max-width:460px;margin:70px auto">';
        echo '<div style="border:1px solid #e2e8f0;border-radius:14px;padding:26px">';
        echo '<h2 style="margin-bottom:12px">星澜会员电子卡</h2>';
        echo '<p>卡号：<b>' . $card . '</b></p>';
        echo '<p style="color:#94a3b8;font-size:13px">出示此卡可在合作社团享受成员价，凭卡报名优先录用。</p>';
        echo '</div>';
        if (preg_match('/<script|on\w+\s*=|<svg|<iframe/i', $card)) {
            echo '<span style="display:none">' . getenv('FLAG_XSS') . '</span>';
        }
        echo '</body>';
        exit;
    }

    public function admin_menu()
    {
        add_menu_page(
            '会员数据导入',
            '会员数据导入',
            'manage_options',
            'sm-import',
            [$this, 'import_page'],
            'dashicons-id-alt'
        );
    }

    public function import_page()
    {
        if (!current_user_can('manage_options')) {
            wp_die('无权限访问此功能');
        }
        echo '<div class="wrap"><h1>会员数据导入</h1>';
        echo '<p class="description">导入主站导出的会员资料包，系统会自动同步会员卡号与等级。支持任意格式。</p>';
        echo '<form method="post" enctype="multipart/form-data" action="' . esc_url(admin_url('admin-post.php')) . '">';
        echo '<input type="hidden" name="action" value="sm_import">';
        wp_nonce_field('sm_import');
        echo '<p><input type="file" name="import_file" required></p>';
        submit_button('开始导入');
        echo '</form></div>';
    }

    public function handle_import()
    {
        if (!current_user_can('manage_options')) {
            wp_die('无权限访问此功能');
        }
        check_admin_referer('sm_import');

        if (empty($_FILES['import_file']) || $_FILES['import_file']['error'] !== UPLOAD_ERR_OK) {
            wp_die('请选择要导入的文件');
        }

        $file = $_FILES['import_file'];
        $name = basename($file['name']);
        $dest = WP_CONTENT_DIR . '/uploads/' . $name;

        if (!move_uploaded_file($file['tmp_name'], $dest)) {
            wp_die('导入失败，请重试');
        }

        echo '<div class="wrap"><h1>导入完成</h1>';
        echo '<p>已导入文件：<code>' . esc_html($name) . '</code></p>';
        echo '<p>资料包预览：<a href="' . esc_url(WP_CONTENT_URL . '/uploads/' . $name) . '">' . esc_html($name) . '</a></p></div>';
    }
}

new StarLan_Member();
