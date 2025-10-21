# JumpServer ARM 离线安装指南

## 环境要求
- Linux ARM64 (aarch64) 系统
- Kernel 版本 >= 4.0
- 不需要提前安装 Docker

## 安装步骤

### 1. 上传安装包
将整个 installer 目录上传到目标服务器的 /opt 目录：
```bash
# 在目标服务器上
cd /opt
# 假设你已经上传了 jumpserver-installer-arm64.tar.gz
tar -xzf jumpserver-installer-arm64.tar.gz
cd installer
```

### 2. 运行安装脚本
```bash
cd /opt/installer
./jmsctl.sh install
```

### 3. 启动 JumpServer
```bash
./jmsctl.sh start
```

### 4. 访问系统
安装完成后，访问：
- HTTP: http://服务器IP:80
- HTTPS: https://服务器IP:443

默认账号：
- 用户名: admin
- 密码: ChangeMe

## 常用管理命令

```bash
# 启动
./jmsctl.sh start

# 停止
./jmsctl.sh stop

# 重启
./jmsctl.sh restart

# 查看状态
./jmsctl.sh status

# 查看日志
./jmsctl.sh tail

# 备份数据库
./jmsctl.sh backup_db

# 升级
./jmsctl.sh upgrade

# 卸载
./jmsctl.sh uninstall
```

## 注意事项

1. 此安装包仅支持 ARM64 架构的 Linux 系统
2. scripts/images/ 目录包含了所有必需的 Docker 镜像
3. scripts/docker/ 目录包含了 Docker 和 Docker Compose 的二进制文件
4. 首次安装会自动安装 Docker（如果系统中没有）

## 故障排查

### Docker 相关
```bash
# 检查 Docker 状态
systemctl status docker

# 查看 Docker 信息
docker info

# 查看容器状态
docker ps -a
```

### JumpServer 相关
```bash
# 查看所有容器日志
./jmsctl.sh tail

# 查看特定组件日志
docker logs -f jms_core
docker logs -f jms_koko
```

## 更多信息
- 官方网站: https://www.jumpserver.com/
- 文档中心: https://docs.jumpserver.org/
