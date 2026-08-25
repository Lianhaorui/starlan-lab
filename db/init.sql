SET NAMES utf8mb4;
CREATE DATABASE IF NOT EXISTS lab_portal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS lab_admin CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS lab_news CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON lab_portal.* TO 'lab'@'%';
GRANT ALL PRIVILEGES ON lab_admin.* TO 'lab'@'%';
GRANT ALL PRIVILEGES ON lab_news.* TO 'lab'@'%';
FLUSH PRIVILEGES;

-- ---------- portal (Laravel) ----------

USE lab_portal;

DROP TABLE IF EXISTS registrations;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(60) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(30),
  created_at TIMESTAMP NULL DEFAULT NULL,
  updated_at TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE activities (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(120) NOT NULL,
  description TEXT,
  capacity INT NOT NULL DEFAULT 30,
  status VARCHAR(20) DEFAULT 'open',
  created_at TIMESTAMP NULL DEFAULT NULL,
  updated_at TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE registrations (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  activity_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  real_name VARCHAR(60) NOT NULL,
  idcard VARCHAR(30) NOT NULL,
  phone VARCHAR(30) NOT NULL,
  remark VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP NULL DEFAULT NULL,
  updated_at TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE products (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(60) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  visible TINYINT(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO activities(id,title,description,capacity,status) VALUES
(1,'秋季招新摆摊志愿者','周六全天，负责签到与物料发放，包午餐。',12,'open'),
(2,'摄影协会外拍活动','西湖沿线外拍，协会提供器材借用。',20,'open'),
(3,'迎新晚会节目统筹','统筹节目单与彩排安排，需两周时间投入。',6,'open');

INSERT INTO registrations(id,activity_id,user_id,real_name,idcard,phone,remark) VALUES
(1,1,2,'王同学','330106200408151234','13800000001',NULL),
(2,2,3,'李同学','330106200311225678','13800000002',NULL),
(3,3,1,'管理员','330106199901019876','13800000000','财务对接暗号：flag{9d2f5c81a7b3e604d8c2f1a5b9e3742c}，仅线下核对时使用');

INSERT INTO products(name,category,stock,price,visible) VALUES
('实验室门禁卡','社团资产',18,12.00,1),
('迎新活动折页','宣传物料',240,0.80,1),
('摄影灯套装','活动设备',4,399.00,1),
('社团文化贴纸','宣传物料',120,1.50,1),
('内部报销模板','财务资料',8,0.00,0);

-- ---------- admin (ThinkPHP) ----------

USE lab_admin;

DROP TABLE IF EXISTS admin_logs;
DROP TABLE IF EXISTS admin_users;

CREATE TABLE admin_users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password CHAR(32) NOT NULL,
  nickname VARCHAR(60),
  remark VARCHAR(255) DEFAULT NULL,
  last_login_at DATETIME DEFAULT NULL,
  created_at TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE admin_logs (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  uid INT UNSIGNED NOT NULL,
  action VARCHAR(60) NOT NULL,
  ip VARCHAR(45),
  created_at TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO admin_users(id,username,password,nickname,remark) VALUES
(1,'admin','ce5dec5f7d5cda41bd625bd6a23bb9aa','系统管理员','运维交接备注：flag{b71e4a92c3d8f6051a4e9c2d7b8f3610}'),
(2,'ops','463613ba15f924a1a9f4c1ed20e78c1c','运营值班','负责资讯站内容审核');

-- ---------- news (WordPress) ----------
-- 表结构由 wp-cli 安装时创建，前缀 wp_
