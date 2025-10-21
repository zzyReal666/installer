# JumpServer v4.10.7-ce ARM64 离线部署步骤

## 📦 需要传输的文件

**只需要传输 1 个文件：**
```
/Users/zhangzhongyuan/IdeaProjects/jumpserver-installer-v4.10.7-ce-arm64.tar.gz
```
大小：约 994MB（1GB）

---

## 🚀 完整部署步骤

### 步骤 1：传输安装包到目标服务器

#### 方式 A：使用 SCP（如果有临时网络或跳板机）

**在 Mac 上执行：**
```bash
# 假设目标服务器 IP 是 192.168.1.100，用户名是 root
scp /Users/zhangzhongyuan/IdeaProjects/jumpserver-installer-v4.10.7-ce-arm64.tar.gz \
    root@192.168.1.100:/tmp/

# 或者使用你的实际用户名和服务器 IP
scp /Users/zhangzhongyuan/IdeaProjects/jumpserver-installer-v4.10.7-ce-arm64.tar.gz \
    your_user@your_server_ip:/tmp/
```

#### 方式 B：使用 U 盘或移动硬盘

**在 Mac 上：**
```bash
# 1. 插入 U 盘
# 2. 复制文件到 U 盘
cp /Users/zhangzhongyuan/IdeaProjects/jumpserver-installer-v4.10.7-ce-arm64.tar.gz \
   /Volumes/YOUR_USB_NAME/

# 3. 弹出 U 盘
# 4. 将 U 盘插入目标服务器
# 5. 在服务器上挂载并复制（见下方服务器操作）
```

**在目标服务器上：**
```bash
# 查看 U 盘设备
lsblk

# 挂载 U 盘（假设是 /dev/sdb1）
mkdir -p /mnt/usb
mount /dev/sdb1 /mnt/usb

# 复制文件
cp /mnt/usb/jumpserver-installer-v4.10.7-ce-arm64.tar.gz /tmp/

# 卸载 U 盘
umount /mnt/usb
```

#### 方式 C：使用局域网文件共享（NFS/Samba）

根据你的实际情况设置。

---

### 步骤 2：验证目标服务器环境

**在目标 ARM 服务器上执行：**

```bash
# 1. 验证系统架构（必须是 aarch64）
uname -m
# 输出应该是: aarch64

# 2. 检查内核版本（需要 >= 4.0）
uname -r
# 例如: 5.10.0 或更高

# 3. 检查可用磁盘空间（至少需要 50GB）
df -h /opt
df -h /data

# 4. 检查内存（建议 >= 4GB）
free -h

# 5. 检查系统版本
cat /etc/os-release
```

**✅ 环境要求确认：**
- [x] 架构：aarch64
- [x] 内核：>= 4.0
- [x] 磁盘：>= 50GB 可用空间
- [x] 内存：>= 4GB
- [x] 系统：CentOS 7+/Ubuntu 18.04+/Debian 10+ 等

---

### 步骤 3：解压安装包

**在目标服务器上执行：**

```bash
# 1. 切换到 root 用户（如果不是）
sudo su -

# 2. 进入 /opt 目录
cd /opt

# 3. 解压安装包
tar -xzf /tmp/jumpserver-installer-v4.10.7-ce-arm64.tar.gz

# 4. 验证解压结果
ls -la /opt/installer/

# 5. 查看目录结构
tree -L 2 /opt/installer/  # 如果没有 tree 命令可以跳过
```

**解压后的目录结构：**
```
/opt/installer/
├── jmsctl.sh                    # 主管理脚本
├── static.env                   # 版本配置
├── prepare_arm_offline.sh       # 离线包准备脚本（已完成）
├── pull_images_manual.sh        # 手动拉取脚本（已完成）
├── ARM_OFFLINE_GUIDE.md         # 完整指南
├── ARM_QUICK_START.md           # 快速开始
├── ARM_OFFLINE_INSTALL.md       # 安装说明
├── config-example.txt           # 配置示例
├── scripts/
│   ├── docker/
│   │   ├── docker.tar.gz        # Docker 二进制
│   │   ├── docker-compose       # Docker Compose 二进制
│   │   └── ...
│   ├── images/                  # Docker 镜像（7个 .zst 文件）
│   │   ├── redis:7-bookworm.zst
│   │   ├── postgres:16.3-bullseye.zst
│   │   ├── core:v4.10.7-ce.zst
│   │   ├── koko:v4.10.7-ce.zst
│   │   ├── lion:v4.10.7-ce.zst
│   │   ├── chen:v4.10.7-ce.zst
│   │   └── web:v4.10.7-ce.zst
│   └── ...
└── compose/                     # Docker Compose 配置文件
```

---

### 步骤 4：执行安装

**在目标服务器上执行：**

```bash
# 1. 进入安装目录
cd /opt/installer

# 2. 查看帮助（可选）
./jmsctl.sh --help

# 3. 执行安装（这将自动完成所有操作）
./jmsctl.sh install
```

**安装过程会自动完成：**
1. ✅ 检查系统环境
2. ✅ 安装 Docker 27.4.0（使用预下载的 ARM64 二进制）
3. ✅ 安装 Docker Compose v2.31.0（使用预下载的 ARM64 二进制）
4. ✅ 加载所有 Docker 镜像（从 scripts/images/ 目录）
5. ✅ 生成配置文件到 /opt/jumpserver/config/
6. ✅ 创建数据目录
7. ✅ 初始化数据库

**预计安装时间：5-15 分钟**

---

### 步骤 5：启动服务

**安装完成后，执行：**

```bash
# 1. 启动所有服务
./jmsctl.sh start

# 2. 查看容器状态
./jmsctl.sh status
# 或
docker ps

# 3. 查看日志（确认启动正常）
./jmsctl.sh tail
# 按 Ctrl+C 退出日志查看
```

**等待所有容器启动完成（约1-3分钟），应该看到以下容器：**
- jms_redis
- jms_postgresql
- jms_core
- jms_koko
- jms_lion
- jms_chen
- jms_web
- jms_celery

---

### 步骤 6：访问系统

#### 6.1 获取服务器 IP

```bash
# 查看服务器 IP 地址
ip addr show | grep "inet "
# 或
hostname -I
```

#### 6.2 浏览器访问

**访问地址：**
```
http://服务器IP

例如：
http://192.168.1.100
```

**默认登录凭据：**
```
用户名: admin
密码: ChangeMe
```

**⚠️ 重要：首次登录后必须立即修改密码！**

#### 6.3 验证功能

1. 登录系统
2. 修改管理员密码
3. 检查系统设置
4. 创建测试用户
5. 添加测试资产

---

## 🔧 常用管理命令

**进入管理目录：**
```bash
cd /opt/installer
```

**服务管理：**
```bash
# 启动所有服务
./jmsctl.sh start

# 停止服务（不包含数据库）
./jmsctl.sh stop

# 停止所有服务（包含数据库）
./jmsctl.sh down

# 重启服务
./jmsctl.sh restart

# 查看服务状态
./jmsctl.sh status
```

**日志管理：**
```bash
# 查看所有服务日志
./jmsctl.sh tail

# 查看特定服务日志
./jmsctl.sh tail core
./jmsctl.sh tail koko
./jmsctl.sh tail web
```

**数据库管理：**
```bash
# 备份数据库
./jmsctl.sh backup_db

# 查看备份文件
ls -lh /opt/jumpserver/db_backup/

# 恢复数据库
./jmsctl.sh restore_db /opt/jumpserver/db_backup/jumpserver-xxxx.sql
```

**系统管理：**
```bash
# 查看版本
./jmsctl.sh version

# 升级系统（需要新的离线包）
./jmsctl.sh upgrade

# 卸载系统
./jmsctl.sh uninstall
```

---

## 🔍 故障排查

### 问题 1：安装失败 - Docker 无法启动

```bash
# 检查 Docker 状态
systemctl status docker

# 查看 Docker 日志
journalctl -u docker -f

# 手动启动 Docker
systemctl start docker
systemctl enable docker
```

### 问题 2：容器无法启动

```bash
# 查看所有容器（包括停止的）
docker ps -a

# 查看容器日志
docker logs jms_core
docker logs jms_postgresql

# 重启容器
docker restart jms_core
```

### 问题 3：无法访问 Web 界面

```bash
# 1. 检查容器是否运行
docker ps | grep jms_web

# 2. 检查端口是否监听
netstat -tlnp | grep :80
# 或
ss -tlnp | grep :80

# 3. 检查防火墙
systemctl status firewalld

# 临时关闭防火墙测试（不推荐生产环境）
systemctl stop firewalld

# 或开放指定端口
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
```

### 问题 4：数据库连接失败

```bash
# 1. 检查 PostgreSQL 容器
docker ps | grep postgresql

# 2. 查看数据库日志
docker logs jms_postgresql

# 3. 进入数据库容器
docker exec -it jms_postgresql bash
psql -U jumpserver

# 4. 检查配置文件
cat /opt/jumpserver/config/config.txt | grep DB_
```

### 问题 5：性能问题

```bash
# 查看系统资源使用
top
htop

# 查看容器资源使用
docker stats

# 查看磁盘使用
df -h
du -sh /opt/jumpserver/*
```

---

## 📝 配置优化

### 修改访问端口

```bash
# 1. 编辑配置文件
vim /opt/jumpserver/config/config.txt

# 2. 修改以下参数
HTTP_PORT=8080
HTTPS_PORT=8443
SSH_PORT=2222

# 3. 重启服务
cd /opt/installer
./jmsctl.sh restart
```

### 修改数据存储路径

```bash
# 1. 编辑配置文件
vim /opt/jumpserver/config/config.txt

# 2. 修改
VOLUME_DIR=/data/jumpserver

# 3. 创建新目录
mkdir -p /data/jumpserver

# 4. 如果已有数据，需要迁移
systemctl stop docker  # 或 ./jmsctl.sh down
mv /opt/jumpserver/data/* /data/jumpserver/

# 5. 重启
./jmsctl.sh restart
```

### 配置 HTTPS

```bash
# 1. 准备证书文件
# 将证书放到：
/opt/jumpserver/config/nginx/cert/server.crt
/opt/jumpserver/config/nginx/cert/server.key

# 2. 修改配置
vim /opt/jumpserver/config/config.txt
# 设置：
SERVER_NAME=your-domain.com
HTTPS_PORT=443

# 3. 重启
./jmsctl.sh restart
```

---

## 📊 系统监控

### 日志位置

```bash
# 应用日志
/opt/jumpserver/core/logs/
/opt/jumpserver/koko/logs/
/opt/jumpserver/lion/logs/

# 录像文件
/opt/jumpserver/koko/data/

# 数据库数据
/opt/jumpserver/postgresql/data/
```

### 定期维护

```bash
# 1. 每周备份数据库
cd /opt/installer
./jmsctl.sh backup_db

# 2. 清理旧日志（保留30天）
find /opt/jumpserver/*/logs/ -name "*.log" -mtime +30 -delete

# 3. 清理 Docker 镜像
docker image prune -f

# 4. 检查磁盘空间
df -h
```

---

## ⚠️ 重要提示

1. **安全建议**
   - ✅ 首次登录后立即修改默认密码
   - ✅ 配置防火墙，只开放必要端口
   - ✅ 定期更新系统补丁（需要网络）
   - ✅ 启用 HTTPS（生产环境必须）
   - ✅ 定期备份数据库

2. **性能建议**
   - 推荐配置：4核8G内存，100GB SSD
   - 最低配置：2核4G内存，50GB 存储
   - 根据并发用户数调整资源

3. **网络要求**
   - 部署阶段：完全离线，无需网络
   - 运行阶段：可完全离线运行
   - 升级阶段：需要网络或新的离线包

4. **数据持久化**
   - 数据默认存储在：`/opt/jumpserver/`
   - 包括：数据库、录像、日志等
   - 确保该目录有足够空间并定期备份

---

## 📞 获取帮助

- 官方网站: https://www.jumpserver.com/
- 文档中心: https://docs.jumpserver.org/
- GitHub: https://github.com/jumpserver/jumpserver
- 社区论坛: https://community.fit2cloud.com/

---

**部署完成后，请根据实际情况进行配置和优化！**

**创建时间**: 2025-10-21  
**版本**: JumpServer v4.10.7-ce (ARM64)  
**安装包大小**: 994MB

