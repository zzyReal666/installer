#!/bin/bash
#
# ARM 架构离线安装包准备脚本
# 在 Mac M4 上运行此脚本，准备 ARM 架构的离线安装包
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# 读取版本信息
source ./static.env
echo "准备 JumpServer ${VERSION} 的 ARM 离线安装包..."

# 创建必要的目录
mkdir -p scripts/images
mkdir -p scripts/docker

# 设置架构为 ARM64
export BUILD_ARCH=aarch64
ARCH=aarch64

echo ""
echo "========================================="
echo "步骤 1: 下载 ARM 架构的 Docker 和 Docker Compose"
echo "========================================="

DOCKER_VERSION=27.4.0
DOCKER_COMPOSE_VERSION=v2.31.0
DOCKER_MIRROR="https://download.jumpserver.org/docker/docker-ce/linux/static/stable"
DOCKER_COMPOSE_MIRROR="https://download.jumpserver.org/docker/compose/releases/download"

DOCKER_URL="${DOCKER_MIRROR}/${ARCH}/docker-${DOCKER_VERSION}.tgz"
DOCKER_COMPOSE_URL="${DOCKER_COMPOSE_MIRROR}/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH}"

echo "下载 Docker ${DOCKER_VERSION} for ARM64..."
if [ ! -f "scripts/docker/docker.tar.gz" ]; then
    curl -# -L "${DOCKER_URL}" -o scripts/docker/docker.tar.gz
    curl -# -L "${DOCKER_URL}.md5" -o scripts/docker/docker.tar.gz.md5
    echo "✓ Docker 下载完成"
else
    echo "✓ Docker 已存在，跳过下载"
fi

echo ""
echo "下载 Docker Compose ${DOCKER_COMPOSE_VERSION} for ARM64..."
if [ ! -f "scripts/docker/docker-compose" ]; then
    curl -# -L "${DOCKER_COMPOSE_URL}" -o scripts/docker/docker-compose
    curl -# -L "${DOCKER_COMPOSE_URL}.md5" -o scripts/docker/docker-compose.md5
    chmod +x scripts/docker/docker-compose
    echo "✓ Docker Compose 下载完成"
else
    echo "✓ Docker Compose 已存在，跳过下载"
fi

echo ""
echo "========================================="
echo "步骤 2: 拉取并保存 ARM 架构的 Docker 镜像"
echo "========================================="
echo ""
echo "请确保 Docker Desktop 已启动！"
echo ""

# 检查 Docker 是否运行
if ! docker info &>/dev/null; then
    echo "❌ 错误: Docker 未运行，请先启动 Docker Desktop"
    exit 1
fi

# 定义需要的镜像列表（这里以社区版为例，如需企业版请修改 USE_XPACK=1）
USE_XPACK=${USE_XPACK:-0}

# 基础镜像
IMAGES=(
    "redis:7.0-bullseye"
    "mysql:8.0"
)

# 企业版镜像
if [ "$USE_XPACK" == "1" ]; then
    IMAGES+=(
        "registry.fit2cloud.com/jumpserver/core:${VERSION}"
        "registry.fit2cloud.com/jumpserver/koko:${VERSION}"
        "registry.fit2cloud.com/jumpserver/lion:${VERSION}"
        "registry.fit2cloud.com/jumpserver/chen:${VERSION}"
        "registry.fit2cloud.com/jumpserver/web:${VERSION}"
        "registry.fit2cloud.com/jumpserver/magnus:${VERSION}"
        "registry.fit2cloud.com/jumpserver/razor:${VERSION}"
        "registry.fit2cloud.com/jumpserver/video-worker:${VERSION}"
        "registry.fit2cloud.com/jumpserver/xrdp:${VERSION}"
        "registry.fit2cloud.com/jumpserver/panda:${VERSION}"
    )
else
    # 社区版镜像
    IMAGES+=(
        "jumpserver/core:${VERSION}"
        "jumpserver/koko:${VERSION}"
        "jumpserver/lion:${VERSION}"
        "jumpserver/chen:${VERSION}"
        "jumpserver/web:${VERSION}"
    )
fi

# 拉取并保存镜像
for image in "${IMAGES[@]}"; do
    echo ""
    echo "处理镜像: ${image}"
    
    # 拉取 ARM64 镜像
    echo "  拉取 ARM64 镜像..."
    docker pull --platform linux/arm64 "${image}"
    
    # 保存镜像
    filename=$(basename "${image}").zst
    image_path="scripts/images/${filename}"
    md5_path="scripts/images/$(basename "${image}").md5"
    
    if [ -f "${image_path}" ]; then
        echo "  镜像已保存，跳过: ${image}"
    else
        echo "  保存镜像: ${image} -> ${image_path}"
        # 检查是否安装了 zstd
        if command -v zstd &>/dev/null; then
            docker save "${image}" | zstd -f -q -o "${image_path}"
        else
            echo "  ⚠️  未安装 zstd，使用 tar.gz 格式保存（文件会更大）"
            image_path="${image_path%.zst}.tar.gz"
            docker save "${image}" | gzip > "${image_path}"
        fi
        
        # 保存镜像 ID 作为版本标识
        image_id=$(docker inspect -f "{{.ID}}" "${image}")
        echo "${image_id}" > "${md5_path}"
        echo "  ✓ 保存完成"
    fi
done

echo ""
echo "========================================="
echo "步骤 3: 创建离线安装说明文件"
echo "========================================="

cat > ARM_OFFLINE_INSTALL.md << 'EOF'
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
EOF

echo "✓ 安装说明已生成: ARM_OFFLINE_INSTALL.md"

echo ""
echo "========================================="
echo "准备工作完成！"
echo "========================================="
echo ""
echo "下一步操作："
echo "1. 打包整个 installer 目录："
echo "   cd $(dirname ${SCRIPT_DIR})"
echo "   tar -czf jumpserver-installer-${VERSION}-arm64.tar.gz installer/"
echo ""
echo "2. 将 jumpserver-installer-${VERSION}-arm64.tar.gz 传输到目标服务器"
echo ""
echo "3. 在目标服务器上解压并安装："
echo "   tar -xzf jumpserver-installer-${VERSION}-arm64.tar.gz"
echo "   cd installer"
echo "   ./jmsctl.sh install"
echo ""
echo "准备的文件清单："
echo "  - scripts/docker/docker.tar.gz (Docker 二进制)"
echo "  - scripts/docker/docker-compose (Docker Compose 二进制)"
echo "  - scripts/images/*.zst (Docker 镜像文件)"
echo "  - ARM_OFFLINE_INSTALL.md (安装说明)"
echo ""

