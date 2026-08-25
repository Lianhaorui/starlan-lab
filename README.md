# starlan-lab

**星澜校园云社团平台靶场 / StarLan Campus Cloud Security Lab**

> 仓库名 `starlan-lab`;「星澜校园云」是靶场内虚构的目标公司。

## English

StarLan Campus Cloud is an intentionally vulnerable PHP security lab for OWASP Top 10 training. It simulates a typical small Chinese internet company running three heterogeneous production systems side by side: a Laravel 7 portal, a ThinkPHP 5.0.22 admin console, and a WordPress news site with a custom plugin — plus a simulated AWS-style instance metadata service (169.254.169.254) for SSRF practice. 9 exploitable vulns, 9 flags.

> For **authorized education only**. Never expose it to the public internet. Full documentation (challenge brief, writeup, scorecard) is in Chinese — see below.

## 中文

这是一个面向 OWASP Top 10 学员的综合实战靶场,单人单实例部署,一套 `docker compose` 拉起全部环境。项目仅用于本地、内网、课堂或明确授权环境,故意包含信息泄露、SQL 注入、XSS、SSRF、文件上传 RCE、本地文件包含、IDOR 越权和框架已知漏洞(nday)。

靶场模拟一家典型的国内中小互联网公司「星澜校园云」,用三套真实异构框架并存作为外壳,漏洞成因贴近真实生产环境:

| 系统 | 框架 | 业务 |
|---|---|---|
| portal 主站 | Laravel 7.30(PHP 7.4,APP_DEBUG=true) | 会员 / 活动报名 / 链接预览 / 文件下载 |
| admin 运营后台 | ThinkPHP 5.0.22 | 登录 / 数据总览 |
| news 资讯站 | WordPress + 自研插件「星澜会员通」 | 资讯 / 会员电子卡 / 会员数据导入 |

框架漏洞均为网上可公开搜到的 nday(如 ThinkPHP 5.0.22 路由 RCE,vulhub `thinkphp/5-rce` 同款);应用层漏洞(SQL 注入、上传等)为业务代码自行引入。

## 一键启动

```bash
docker compose up --build -d
```

构建需要拉取 composer 依赖、WordPress 与 wp-cli(已随仓库内置)。国内网络默认使用阿里 apt 源;海外构建可用 `docker compose build --build-arg USE_CN_MIRROR=0` 切回官方源。

| 系统 | 地址 |
|---|---|
| portal 主站 | http://localhost:8101 |
| admin 运营后台 | http://localhost:8201 |
| news 资讯站 | http://localhost:8301 |

默认账号:

```text
主站测试账号:test@starlan.club / 123456
资讯站后台(交接弱口令):admin / Starlan@2026
运营后台:无已知明文密码,唯一入口是 SQL 注入(刻意设计)
```

停止并清理数据(会重置 MySQL 卷并重跑 `db/init.sql`):

```bash
docker compose down -v
```

## 漏洞设计

9 个漏洞点覆盖:生产环境开 DEBUG 的报错信息泄露、部署备份残留、无归属校验的 IDOR、无限制的 SSRF、下载接口路径穿越(LFI)、字符串拼接 SQL 登录绕过、自研插件输出未转义的反射 XSS、后端无校验上传导致 RCE,以及 ThinkPHP 5.0.22 公开路由 RCE。漏洞之间存在可串联的利用关系,详见 [docs/WRITEUP.md](docs/WRITEUP.md)。

## flag 说明

- 数据库类(SQLI、IDOR)与元数据服务(SSRF)的 flag 为固定值,写在 `db/init.sql` 和 `metadata/internal_metadata.py` 中。
- 其余 flag(INFO、BACKUP、LFI、XSS、UPLOAD、RCE)由 web 容器每次启动时随机生成,重建容器后变化。

## 文档与目录结构

- [docs/CHALLENGE.md](docs/CHALLENGE.md):挑战题目说明(动手前阅读)
- [docs/WRITEUP.md](docs/WRITEUP.md):完整 Writeup(含全部 9 条利用链与修复建议,剧透警告)
- [docs/SCORECARD.md](docs/SCORECARD.md):评分点与建议分值
- [scripts/verify.sh](scripts/verify.sh):9 条利用链全链路自动验证脚本

```
├── docker-compose.yml      # 编排:mysql + metadata + web(单实例)
├── docker/                 # web 镜像构建:Dockerfile、entrypoint.sh、apache 配置、wp-cli
├── apps/                   # 三套应用的自研代码(portal / admin / news-plugin)
├── metadata/               # SSRF 云元数据模拟服务(169.254.169.254,专用内网)
├── db/                     # MySQL 初始化脚本(含固定 flag)
├── scripts/                # 验证脚本
└── docs/                   # 题目说明、Writeup、评分表
```

## 安全提醒与免责声明

本项目故意包含多处可利用漏洞,仅用于本地、内网、课堂或明确授权环境,**切勿暴露到公网**。上传目录允许 PHP 执行,文件下载接口可读取容器内任意可读文件;这些设计只服务于授权教学。使用者自行承担风险,作者不对任何滥用后果负责。
