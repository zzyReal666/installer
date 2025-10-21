#!/bin/bash
#
# 手动拉取 ARM64 镜像脚本
# 适用于网络不稳定的环境，逐个拉取镜像
#

set -e

echo "开始拉取 ARM64 Docker 镜像..."
echo "================================"
echo ""

# 定义镜像列表
images=(
    "redis:7-bookworm"
    "postgres:16.3-bullseye"
    "jumpserver/core:v4.10.7-ce"
    "jumpserver/koko:v4.10.7-ce"
    "jumpserver/lion:v4.10.7-ce"
    "jumpserver/chen:v4.10.7-ce"
    "jumpserver/web:v4.10.7-ce"
)

total=${#images[@]}
current=0
success=0
failed=0
failed_images=()

# 拉取每个镜像
for image in "${images[@]}"; do
    current=$((current + 1))
    echo "[$current/$total] 正在拉取: $image"
    echo "----------------------------------------"
    
    if docker pull --platform linux/arm64 "$image"; then
        success=$((success + 1))
        echo "✅ $image 拉取成功"
    else
        failed=$((failed + 1))
        failed_images+=("$image")
        echo "❌ $image 拉取失败"
    fi
    
    echo ""
done

echo "================================"
echo "拉取完成！"
echo "总计: $total 个镜像"
echo "成功: $success 个"
echo "失败: $failed 个"

if [ $failed -gt 0 ]; then
    echo ""
    echo "失败的镜像列表："
    for img in "${failed_images[@]}"; do
        echo "  - $img"
    done
    echo ""
    echo "请手动重试失败的镜像，或检查网络连接。"
    exit 1
else
    echo ""
    echo "🎉 所有镜像拉取成功！"
    echo ""
    echo "下一步："
    echo "  cd /Users/zhangzhongyuan/IdeaProjects/installer"
    echo "  ./prepare_arm_offline.sh"
    echo ""
fi

