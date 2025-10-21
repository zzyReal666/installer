# 🚀 ARM 离线部署快速开始

## 一、在 Mac M4 上准备（需要联网）

```bash
# 1. 确保 Docker Desktop 已启动
docker ps

# 2. 可选：安装 zstd 压缩工具（减小镜像体积）
brew install zstd

# 3. 运行准备脚本
cd /Users/zhangzhongyuan/IdeaProjects/installer
./prepare_arm_offline.sh

# 4. 等待完成（20-60分钟），然后打包
cd ..
tar -czf jumpserver-installer-dev-arm64.tar.gz installer/

# 5. 传输到目标服务器
scp jumpserver-installer-dev-arm64.tar.gz user@server:/tmp/
# 或使用 U 盘、移动硬盘等方式
```

---

## 二、在 ARM 服务器上部署（无需联网）

```bash
# 1. 解压
sudo tar -xzf /tmp/jumpserver-installer-dev-arm64.tar.gz -C /opt

# 2. 安装
cd /opt/installer
sudo ./jmsctl.sh install

# 3. 启动
sudo ./jmsctl.sh start

# 4. 访问
# 浏览器打开: http://服务器IP
# 用户名: admin
# 密码: ChangeMe
```

---

## 三、常用命令

```bash
cd /opt/installer

./jmsctl.sh start      # 启动
./jmsctl.sh stop       # 停止
./jmsctl.sh restart    # 重启
./jmsctl.sh status     # 状态
./jmsctl.sh tail       # 日志
./jmsctl.sh backup_db  # 备份
```

---

## 📖 详细文档

- **完整指南**: 查看 `ARM_OFFLINE_GUIDE.md`
- **安装说明**: 安装后查看 `ARM_OFFLINE_INSTALL.md`

## ⚠️ 注意事项

1. ✅ 确保目标服务器是 ARM64 架构（`uname -m` 应显示 `aarch64`）
2. ✅ 确保有足够的磁盘空间（至少 50GB）
3. ✅ 确保系统内存至少 4GB（推荐 8GB+）
4. ❌ 此离线包**仅支持 ARM64**，不支持 x86_64

## 🆘 遇到问题？

查看 `ARM_OFFLINE_GUIDE.md` 中的故障排查章节

