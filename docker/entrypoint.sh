#!/bin/sh
set -eu

DB_HOST_V="${DB_HOST:-mysql}"
DB_USER_V="${DB_USER:-lab}"
DB_PASS_V="${DB_PASS:-labpass}"
DB_PORTAL_V="${DB_PORTAL_DB:-lab_portal}"
DB_NEWS_V="${DB_NEWS_DB:-lab_news}"
NEWS_PORT_V="${NEWS_PORT:-8301}"

rand() { od -An -N16 -tx1 /dev/urandom | tr -d ' \n'; }
make_flag() { printf 'flag{%s}' "$(printf '%s_%s' "$1" "$(rand)" | md5sum | cut -c1-32)"; }

FLAG_TP="$(make_flag tp_rce)"
FLAG_XSS="$(make_flag xss_canary)"
FLAG_INFO="$(make_flag env_leak)"
FLAG_BACKUP="$(make_flag backup)"
FLAG_LFI="$(make_flag legacy_config)"
FLAG_UPLOAD="$(make_flag upload_shell)"

export FLAG_TP FLAG_XSS

# ---- portal (Laravel) .env ----
cat > /opt/portal/.env <<EOF
APP_NAME=StarLan
APP_ENV=local
APP_KEY=base64:$(head -c 32 /dev/urandom | base64 -w0)
APP_DEBUG=true
LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=${DB_HOST_V}
DB_PORT=3306
DB_DATABASE=${DB_PORTAL_V}
DB_USERNAME=${DB_USER_V}
DB_PASSWORD=${DB_PASS_V}

SESSION_DRIVER=file
SESSION_LIFETIME=120
FILESYSTEM_DRIVER=public

SMS_API_KEY=1400123456
SMS_API_SECRET=${FLAG_INFO}
EOF

# ---- secret flag files ----
cat > /var/www/legacy_config.txt <<EOF
StarLan legacy payment gateway config (deprecated 2024-03, do not delete)
merchant_id=M20000123
gateway=https://pay.starlan-internal.example/gateway/v1
api_key=${FLAG_LFI}
EOF

printf '%s\n' "$FLAG_UPLOAD" > /flag_upload.txt
chmod 644 /flag_upload.txt

# ---- deployment backup left in web root ----
TMPBK="$(mktemp -d)"
cat > "$TMPBK/.env" <<EOF
APP_NAME=StarLan
APP_ENV=production
APP_KEY=base64:$(head -c 32 /dev/urandom | base64 -w0)
APP_DEBUG=false

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=${DB_PORTAL_V}
DB_USERNAME=${DB_USER_V}

SMS_API_KEY=1400123456
SMS_API_SECRET=${FLAG_BACKUP}
EOF
(cd "$TMPBK" && zip -q -r /opt/portal/public/backup.zip .)
rm -rf "$TMPBK"

# ---- placeholder files served by the download endpoint ----
mkdir -p /opt/portal/storage/app/public
cat > /opt/portal/storage/app/public/user_agreement.pdf <<'EOF'
StarLan Club Platform User Agreement

1. This platform is for internal club resource, activity and member management only.
2. Accounts are for personal use. Keep your password safe.
3. Uploaded materials must comply with campus regulations.
EOF

cat > /opt/portal/storage/app/public/reimbursement_template.txt <<'EOF'
Internal reimbursement template v2.

Project:
Applicant:
Amount:
Attachments: upload receipts via the portal before submission.
EOF

chown -R www-data:www-data /opt/portal/storage /opt/portal/public/backup.zip

# ---- wait for mysql ----
i=0
until php -r 'try { new PDO("mysql:host=".getenv("DB_HOST"), getenv("DB_USER"), getenv("DB_PASS")); echo "ok"; } catch (Exception $e) { exit(1); }' >/dev/null 2>&1; do
  i=$((i+1))
  [ "$i" -gt 60 ] && break
  sleep 2
done

# ---- seed portal users (bcrypt hashes) ----
php -r '
$pdo = new PDO("mysql:host=".getenv("DB_HOST").";dbname=".getenv("DB_PORTAL_DB"), getenv("DB_USER"), getenv("DB_PASS"),
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$users = [
    [1, "系统管理员", "admin@starlan.club", "Admin@2026", "13800000000"],
    [2, "测试同学", "test@starlan.club", "123456", "13800000001"],
    [3, "Alice", "alice@starlan.club", "alice0817", "13800000002"],
    [4, "Bob", "bob@starlan.club", "bob@finance", "13800000003"],
];
$st = $pdo->prepare("INSERT IGNORE INTO users(id,name,email,password,phone) VALUES(?,?,?,?,?)");
foreach ($users as $u) { $st->execute([$u[0], $u[1], $u[2], password_hash($u[3], PASSWORD_BCRYPT), $u[4]]); }
echo "seeded\n";
' || true

# ---- WordPress ----
S1=$(rand)$(rand); S2=$(rand)$(rand); S3=$(rand)$(rand); S4=$(rand)$(rand)
S5=$(rand)$(rand); S6=$(rand)$(rand); S7=$(rand)$(rand); S8=$(rand)$(rand)
cat > /opt/news/wp-config.php <<EOF
<?php
define('DB_NAME', '${DB_NEWS_V}');
define('DB_USER', '${DB_USER_V}');
define('DB_PASSWORD', '${DB_PASS_V}');
define('DB_HOST', '${DB_HOST_V}');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');
define('AUTH_KEY', '${S1}');
define('SECURE_AUTH_KEY', '${S2}');
define('LOGGED_IN_KEY', '${S3}');
define('NONCE_KEY', '${S4}');
define('AUTH_SALT', '${S5}');
define('SECURE_AUTH_SALT', '${S6}');
define('LOGGED_IN_SALT', '${S7}');
define('NONCE_SALT', '${S8}');
\$table_prefix = 'wp_';
define('WP_DEBUG', false);
\$wp_host = (isset(\$_SERVER['HTTP_HOST']) && \$_SERVER['HTTP_HOST']) ? \$_SERVER['HTTP_HOST'] : 'localhost';
define('WP_HOME', 'http://' . \$wp_host);
define('WP_SITEURL', 'http://' . \$wp_host);
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF

WP="wp --path=/opt/news --allow-root"
WP_URL="http://localhost:${NEWS_PORT_V}"

if ! $WP core is-installed >/dev/null 2>&1; then
    $WP db create >/dev/null 2>&1 || true
    $WP core install --url="$WP_URL" --title="星澜校园资讯" \
        --admin_user=admin --admin_password="Starlan@2026" \
        --admin_email="admin@starlan.club" --skip-email >/dev/null
    $WP plugin activate starlan-member >/dev/null 2>&1 || true
    $WP post create --post_title="2026 秋季社团招新启动" --post_status=publish \
        --post_content="本周六上午九点，大学生活动中心，星澜旗下 12 家社团集体摆摊。现场扫码注册即送周边。" >/dev/null
    $WP post create --post_title="物资借用新规试运行" --post_status=publish \
        --post_content="自本月起，贵重设备借用需提前两个工作日在主站提交申请，凭审批码到值班室领取。" >/dev/null
    $WP post create --post_title="系统维护通知" --post_status=publish \
        --post_content="主站将于本周日凌晨 2:00-4:00 例行维护，期间报名与查询功能暂停使用。" >/dev/null
fi

chown -R www-data:www-data /opt/news/wp-content

exec apache2-foreground
