# 评分表

总分 100 分，适合 4 小时课堂实战。三套系统（Laravel 主站 / ThinkPHP 后台 / WordPress 资讯站）共 9 个漏洞点，每个按"找到入口 + 拿到 flag + 报告完整"综合给分。

| 项目 | 系统 | 分值 | 要求 |
|---|---|---:|---|
| 信息泄露（调试报错） | portal | 10 | 发现生产环境开着 APP_DEBUG 的 Laravel 报错页，从报错上下文取得 `sms_secret` |
| 备份文件 | portal | 8 | 发现并下载 web 根残留的 `/backup.zip`，从旧版 `.env` 取得 `SMS_API_SECRET` |
| IDOR 越权 | portal | 8 | 枚举他人活动报名详情（`/registration/{id}`），从管理员报名备注取得 flag |
| SSRF 云元数据 | portal | 12 | 利用链接预览功能让服务端请求 `169.254.169.254`，取得 IAM 凭证中的 `SecretAccessKey` |
| 本地文件包含 | portal | 10 | 下载接口路径穿越读取 web 根外的 `legacy_config.txt`，取得 `api_key` |
| SQL 注入 | admin | 12 | ThinkPHP 后台登录 `whereRaw` 拼接注入绕过认证，进入后台取得 flag |
| 反射 XSS | news | 8 | 自研插件会员电子卡页 `sm_card` 参数未转义执行脚本，取得页面 canary flag |
| 文件上传 RCE | news | 12 | 后台「会员数据导入」上传 PHP 并直接访问执行，从 `/flag_upload.txt` 取得 flag |
| 框架 nday RCE | admin | 12 | 识别 ThinkPHP 5.0.22 并利用公开路由 RCE（`invokefunction`），执行命令取得 `FLAG_TP` |
| 报告质量 | — | 8 | 复现步骤清楚，关键请求/截图完整，影响和修复建议准确 |

## 难度建议

- 入门：备份文件、IDOR、调试报错信息泄露
- 中等：SQL 注入（TP5 括号闭合技巧）、反射 XSS、LFI 路径穿越
- 进阶：SSRF 云元数据利用、文件上传 RCE、ThinkPHP nday RCE
- 串联加分：SQLi 绕过后进入后台发现 ThinkPHP 版本线索 -> 定位 nday；backup.zip 源码审计 -> 定位其余漏洞入口

## flag 分布说明

- 数据库类（IDOR、SQLI）与元数据服务（SSRF）的 flag 为固定值，写在 `db/init.sql` 和 `metadata/internal_metadata.py` 中。
- 其余 flag（INFO、BACKUP、LFI、XSS、UPLOAD、RCE）由 web 容器每次启动时随机生成，重建容器（`docker compose down -v`）后会变化。
