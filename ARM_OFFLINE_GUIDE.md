# JumpServer ARM 架构离线部署完整指南

## 📌 方案概述

由于官方只提供 amd64 的离线安装包，本指南将帮助你在 Mac M4 上准备 ARM64 架构的完整离线安装包，然后部署到无法联网的 ARM 服务器上。

---

## 🔧 准备阶段（在 Mac M4 上操作）

### 前置条件

1. **安装 Docker Desktop**
   - 确保 Docker Desktop for Mac 已安装并运行
   - 验证：`docker --version`

2. **安装 zstd 压缩工具**（可选，但强烈推荐，可大幅减小镜像文件体积）
   ```bash
   brew install zstd
   ```

3. **确保网络畅通**
   - 需要从 Docker Hub 和 registry.fit2cloud.com 拉取镜像
   - 需要从 download.jumpserver.org 下载 Docker 二进制文件

### 步骤 1: 准备离线安装包

```bash
# 进入项目目录
cd /Users/zhangzhongyuan/IdeaProjects/installer

# 赋予执行权限
chmod +x prepare_arm_offline.sh

# 运行准备脚本（预计需要 20-60 分钟，取决于网络速度）
./prepare_arm_offline.sh
```

**脚本会自动完成以下操作：**
- ✅ 下载 ARM64 架构的 Docker 27.4.0
- ✅ 下载 ARM64 架构的 Docker Compose v2.31.0
- ✅ 拉取所有需要的 ARM64 Docker 镜像
- ✅ 压缩并保存镜像文件到 `scripts/images/` 目录
- ✅ 生成安装说明文档

### 步骤 2: 检查准备结果

```bash
# 检查文件结构
ls -lh scripts/docker/
# 应该看到:
# - docker.tar.gz (约 60-80MB)
# - docker-compose (约 50-60MB)

ls -lh scripts/images/
# 应该看到多个 .zst 镜像文件（每个几百MB）

# 查看总大小
du -sh scripts/
```

### 步骤 3: 打包整个项目

```bash
# 返回上级目录
cd ..

# 打包（注意：最终包可能有 2-5GB，取决于镜像数量）
tar -czf jumpserver-installer-dev-arm64.tar.gz installer/

# 查看包大小
ls -lh jumpserver-installer-dev-arm64.tar.gz
```

### 步骤 4: 传输到目标服务器

选择以下任一方式传输：

**方式 1: 使用 scp（如果服务器有临时网络或通过跳板机）**
```bash
scp jumpserver-installer-dev-arm64.tar.gz user@target-server:/tmp/
```

**方式 2: 使用 U 盘或移动硬盘**
- 复制文件到存储设备
- 物理传输到目标服务器

**方式 3: 使用局域网文件共享**
- NFS / Samba / 其他文件共享方式

---

## 🚀 部署阶段（在目标 ARM 服务器上操作）

### 环境要求

- ✅ Linux ARM64 (aarch64) 系统
- ✅ Kernel 版本 >= 4.0
- ✅ 至少 4GB 内存（推荐 8GB+）
- ✅ 至少 50GB 可用磁盘空间
- ❌ **不需要网络连接**
- ❌ **不需要提前安装 Docker**

### 步骤 1: 上传并解压安装包

```bash
# 切换到 root 用户或使用 sudo
sudo su -

# 解压到 /opt 目录
cd /opt
tar -xzf /tmp/jumpserver-installer-dev-arm64.tar.gz

# 进入安装目录
cd /opt/installer
```

### 步骤 2: 验证架构和文件

```bash
# 验证系统架构
uname -m
# 应该输出: aarch64

# 检查离线文件是否完整
ls -lh scripts/docker/
ls -lh scripts/images/

# 查看安装说明
cat ARM_OFFLINE_INSTALL.md
```

### 步骤 3: 执行安装

```bash
# 执行安装（全自动，预计需要 5-15 分钟）
./jmsctl.sh install
```

**安装过程会自动完成：**
1. ✅ 安装 Docker 和 Docker Compose（使用预下载的二进制文件）
2. ✅ 加载所有 Docker 镜像（从 scripts/images/ 目录）
3. ✅ 配置 JumpServer
4. ✅ 初始化数据库
5. ✅ 生成配置文件到 `/opt/jumpserver/config/`

### 步骤 4: 启动服务

```bash
# 启动所有服务
./jmsctl.sh start

# 查看容器状态
docker ps
# 或
./jmsctl.sh status
```

### 步骤 5: 访问系统

**获取服务器 IP：**
```bash
ip addr show | grep inet
```

**浏览器访问：**
- HTTP: `http://<服务器IP>:80`
- HTTPS: `https://<服务器IP>:443`

**默认登录凭据：**
- 用户名: `admin`
- 密码: `ChangeMe`

**⚠️ 首次登录后请立即修改密码！**

---

## 📝 配置说明

### 配置文件位置

所有配置文件位于：`/opt/jumpserver/config/`

```
/opt/jumpserver/config/
├── config.txt          # 主配置文件
├── mysql/
│   └── my.cnf
├── redis/
│   └── redis.conf
└── nginx/
    ├── cert/
    ├── lb_http_server.conf
    └── lb_ssh_server.conf
```

### 常用配置修改

**修改访问端口：**
```bash
# 编辑配置文件
vim /opt/jumpserver/config/config.txt

# 修改以下参数
HTTP_PORT=8080
HTTPS_PORT=8443
SSH_PORT=2222

# 重启服务
cd /opt/installer
./jmsctl.sh restart
```

**修改数据存储目录：**
```bash
# 编辑配置文件
vim /opt/jumpserver/config/config.txt

# 修改
VOLUME_DIR=/data/jumpserver

# 重启服务
./jmsctl.sh restart
```

---

## 🔧 管理命令

```bash
# 进入管理目录
cd /opt/installer

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

# 查看实时日志
./jmsctl.sh tail

# 查看特定服务日志
./jmsctl.sh tail core
./jmsctl.sh tail koko

# 备份数据库
./jmsctl.sh backup_db

# 恢复数据库
./jmsctl.sh restore_db <备份文件>

# 查看版本
./jmsctl.sh version

# 升级（需要网络，或准备新的离线包）
./jmsctl.sh upgrade

# 卸载
./jmsctl.sh uninstall
```

---

## 🐛 故障排查

### 问题 1: Docker 启动失败

```bash
# 检查 Docker 状态
systemctl status docker

# 查看 Docker 日志
journalctl -u docker -f

# 手动启动 Docker
systemctl start docker
```

### 问题 2: 容器启动失败

```bash
# 查看所有容器（包括停止的）
docker ps -a

# 查看容器日志
docker logs jms_core
docker logs jms_koko
docker logs jms_mysql

# 重启特定容器
docker restart jms_core
```

### 问题 3: 镜像加载失败

```bash
# 检查镜像是否存在
docker images | grep jumpserver

# 手动加载镜像
cd /opt/installer/scripts
docker load < images/jumpserver_core*.zst
# 或如果是 tar.gz 格式
docker load < images/jumpserver_core*.tar.gz
```

### 问题 4: 无法访问 Web 界面

```bash
# 检查防火墙
systemctl status firewalld

# 临时关闭防火墙测试（生产环境不推荐）
systemctl stop firewalld

# 或开放端口
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

# 检查端口监听
netstat -tlnp | grep :80
```

### 问题 5: 数据库连接失败

```bash
# 检查 MySQL 容器
docker ps | grep mysql

# 查看 MySQL 日志
docker logs jms_mysql

# 检查配置文件
cat /opt/jumpserver/config/config.txt | grep DB_
```

---

## 📊 系统监控

### 查看资源使用

```bash
# 查看容器资源使用
docker stats

# 查看磁盘使用
df -h /opt/jumpserver

# 查看系统负载
top
htop
```

### 日志管理

```bash
# 日志文件位置
ls -lh /opt/jumpserver/logs/

# 清理旧日志（谨慎操作）
find /opt/jumpserver/logs/ -name "*.log" -mtime +30 -delete
```

---

## 🔄 升级说明

### 准备新版本离线包

1. 在 Mac M4 上修改 `static.env` 中的版本号
2. 重新运行 `./prepare_arm_offline.sh`
3. 打包并传输到服务器

### 执行升级

```bash
# 备份数据
cd /opt/installer
./jmsctl.sh backup_db

# 停止服务
./jmsctl.sh stop

# 解压新版本到临时目录
cd /tmp
tar -xzf jumpserver-installer-vX.X.X-arm64.tar.gz

# 复制新版本的镜像
cp -r /tmp/installer/scripts/images/* /opt/installer/scripts/images/

# 加载新镜像
cd /opt/installer
./jmsctl.sh load_image

# 执行升级
./jmsctl.sh upgrade

# 启动服务
./jmsctl.sh start
```

---

## 📌 重要提示

1. **定期备份**
   - 每周至少备份一次数据库
   - 备份文件存储在 `/opt/jumpserver/db_backup/`

2. **安全建议**
   - 修改默认密码
   - 配置 HTTPS（将证书放到 `/opt/jumpserver/config/nginx/cert/`）
   - 定期更新系统补丁

3. **性能优化**
   - 根据并发用户数调整 MySQL 参数
   - 配置 Redis 持久化策略
   - 考虑使用外部数据库（生产环境）

4. **磁盘空间**
   - 定期清理录像文件
   - 监控磁盘使用情况
   - 考虑配置日志轮转

---

## 📚 参考文档

- 官方网站: https://www.jumpserver.com/
- 文档中心: https://docs.jumpserver.org/
- GitHub: https://github.com/jumpserver/jumpserver
- 社区论坛: https://community.fit2cloud.com/

---

## ❓ 常见问题

**Q: 可以在虚拟机中部署吗？**
A: 可以，但需要确保虚拟机是 ARM64 架构。

**Q: 支持哪些数据库？**
A: MySQL 8.0（默认）、MariaDB、PostgreSQL

**Q: 如何修改管理员密码？**
A: 登录后在 Web 界面的"用户管理"中修改，或使用命令行重置。

**Q: 录像文件存储在哪里？**
A: 默认存储在 `/opt/jumpserver/data/` 目录。

**Q: 如何清理 Docker 镜像释放空间？**
```bash
# 清理未使用的镜像
docker image prune -a

# 清理未使用的容器、网络、镜像
docker system prune -a
```

---

**创建时间**: 2025-10-21  
**适用版本**: JumpServer dev (ARM64)  
**维护者**: 根据项目实际情况填写

