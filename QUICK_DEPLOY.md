# 🚀 JumpServer ARM64 离线部署 - 快速参考

## 📦 传输文件

**只需传输 1 个文件：**
```
jumpserver-installer-v4.10.7-ce-arm64.tar.gz (994MB)
```

**位置：**
```
/Users/zhangzhongyuan/IdeaProjects/jumpserver-installer-v4.10.7-ce-arm64.tar.gz
```

---

## 🎯 5 步完成部署

### 在 Mac 上

```bash
# 1. 传输到服务器（替换 IP 和用户名）
scp /Users/zhangzhongyuan/IdeaProjects/jumpserver-installer-v4.10.7-ce-arm64.tar.gz \
    root@192.168.1.100:/tmp/
```

### 在目标 ARM 服务器上

```bash
# 2. 解压
cd /opt
tar -xzf /tmp/jumpserver-installer-v4.10.7-ce-arm64.tar.gz

# 3. 安装
cd /opt/installer
./jmsctl.sh install

# 4. 启动
./jmsctl.sh start

# 5. 访问
# 浏览器打开: http://服务器IP
# 用户名: admin
# 密码: ChangeMe
```

---

## 📋 验证清单

**部署前检查：**
```bash
uname -m          # 必须显示: aarch64
df -h /opt        # 可用空间: >= 50GB
free -h           # 内存: >= 4GB
```

**部署后检查：**
```bash
cd /opt/installer
./jmsctl.sh status       # 查看服务状态
docker ps                # 应该看到 7-8 个容器运行中
./jmsctl.sh tail         # 查看日志，确认无错误
```

---

## 🔧 常用命令

```bash
cd /opt/installer

./jmsctl.sh start        # 启动
./jmsctl.sh stop         # 停止
./jmsctl.sh restart      # 重启
./jmsctl.sh status       # 状态
./jmsctl.sh tail         # 日志
./jmsctl.sh backup_db    # 备份
```

---

## ⚠️ 重要

1. ✅ 首次登录后立即修改密码
2. ✅ 配置防火墙开放 80/443 端口
3. ✅ 定期备份数据库（每周）
4. ✅ 生产环境配置 HTTPS

---

## 📚 详细文档

- 完整部署步骤：`DEPLOYMENT_STEPS.md`
- 离线安装指南：`ARM_OFFLINE_GUIDE.md`
- 快速开始：`ARM_QUICK_START.md`

---

**版本**: v4.10.7-ce | **架构**: ARM64 | **大小**: 994MB

