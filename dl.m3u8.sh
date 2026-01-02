#!/bin/bash

# 设置输出目录
OUTPUT_DIR="/www/OssOpen/DLoss"
# 设置日志目录
TXT_DIR="/www/OssOpen/TXTOss"
# 设置储存m3u8链接的TXT文件链接
TXT_URL="http://127.0.0.1:10000/down/it9TvaAwEfZz.txt"

# 以下类容建议不要修改！
LOG_DIR="$TXT_DIR/Log"
DOWNLOAD_LOG="$LOG_DIR/download.log"

# 显示菜单函数
show_menu() {
    clear
    echo "========================================"
    echo "          M3U8下载工具菜单"
    echo "========================================"
    echo "1: M3u8资源下载"
    echo "2: 环境一键安装"
    echo "3: 停止下载进程"
    echo "4: 退出"
    echo "========================================"
    echo -n "请选择操作 (1-4): "
}

# 功能1: M3u8资源下载
m3u8_download() {
    echo "========================================"
    echo "          M3u8资源下载"
    echo "========================================"
    
    # 创建目录
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$LOG_DIR"
    
    # 下载远程TXT文件到临时目录
    TMP_FILE="$LOG_DIR/$(basename "$TXT_URL")"
    if command -v curl &> /dev/null; then
        curl -s -o "$TMP_FILE" "$TXT_URL"
    elif command -v wget &> /dev/null; then
        wget -q -O "$TMP_FILE" "$TXT_URL"
    else
        echo "错误：未安装 curl 或 wget！"
        read -p "按任意键返回菜单..." -n1 -s
        return
    fi
    
    if [ ! -s "$TMP_FILE" ]; then
        echo "错误：下载 $TXT_URL 失败！"
        read -p "按任意键返回菜单..." -n1 -s
        return
    fi
    
    TXT_FILE="$TMP_FILE"
    
    # 检查 N_m3u8DL-RE 是否存在
    if ! command -v N_m3u8DL-RE &> /dev/null; then
        echo "错误：N_m3u8DL-RE 未安装或不在 PATH 中！"
        read -p "按任意键返回菜单..." -n1 -s
        return
    fi
    
    # 读取 TXT 文件并下载
    while read -r LINE; do
        # 跳过空行
        if [ -z "$LINE" ]; then
            continue
        fi
        
        # 分割 M3U8_URL 和 FILENAME（假设第一个空格后面是文件名）
        M3U8_URL=$(echo "$LINE" | cut -d ' ' -f1)
        FILENAME=$(echo "$LINE" | cut -d ' ' -f2-)
        
        if [ -z "$M3U8_URL" ] || [ -z "$FILENAME" ]; then
            continue
        fi
        
        # 记录开始时间
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
        
        echo "正在下载: $FILENAME"
        # 调用 N_m3u8DL-RE 下载（使用正确的参数格式）
        N_m3u8DL-RE "$M3U8_URL" --save-dir "$OUTPUT_DIR" --save-name "$FILENAME" --tmp-dir "$LOG_DIR" --log-level error
        
        # 检查下载结果
        if [ $? -eq 0 ]; then
            STATUS="成功"
            echo "✓ 下载成功: $FILENAME"
        else
            STATUS="失败"
            echo "✗ 下载失败: $FILENAME"
        fi
        
        # 记录到日志文件
        echo "$TIMESTAMP:$STATUS:$FILENAME:$M3U8_URL" >> "$DOWNLOAD_LOG"
        
        # 1. 清理 /usr/local/bin/Logs 中的日志（实时清理，不影响转换）
        rm -f /usr/local/bin/Logs/*.log /usr/local/bin/Logs/*.tmp /usr/local/bin/Logs/*.temp 2>/dev/null
        
    done < "$TXT_FILE"
    
    # 清理临时文件（包括远程下载的TXT文件）
    rm -f "$TXT_FILE"
    
    echo "========================================"
    echo "下载完成！"
    echo "日志文件：$DOWNLOAD_LOG"
    echo "输出目录：$OUTPUT_DIR"
    read -p "按任意键返回菜单..." -n1 -s
}

# 功能2: 环境一键安装
env_install() {
    echo "========================================"
    echo "          环境一键安装"
    echo "========================================"
    
    # 检查是否以root权限运行
    if [ "$(id -u)" != "0" ]; then
        echo "错误：需要以root权限运行此安装脚本！"
        read -p "按任意键返回菜单..." -n1 -s
        return
    fi
    
    # 更新系统并安装核心依赖
    echo "正在更新系统并安装核心依赖..."
    sudo apt update
    sudo apt install -y wget tar ffmpeg libgdiplus
    
    # 安装 .NET Runtime 9.0
    echo "正在安装 .NET Runtime 9.0..."
    wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt update
    sudo apt install -y dotnet-runtime-9.0
    
    # 下载并安装 N_m3u8DL-RE
    echo "正在下载并安装 N_m3u8DL-RE..."
    wget https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v0.5.1-beta/N_m3u8DL-RE_v0.5.1-beta_linux-x64_20251029.tar.gz
    tar -xzvf N_m3u8DL-RE_v0.5.1-beta_linux-x64_20251029.tar.gz
    sudo mv N_m3u8DL-RE /usr/local/bin/
    sudo chmod +x /usr/local/bin/N_m3u8DL-RE
    
    # 清理安装文件
    echo "正在清理安装文件..."
    rm packages-microsoft-prod.deb N_m3u8DL-RE_v0.5.1-beta_linux-x64_20251029.tar.gz
    
    # 创建目录
    echo "正在创建必要的目录..."
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$TXT_DIR"
    
    # 验证安装
    echo "========================================"
    echo "安装完成！版本信息："
    N_m3u8DL-RE --version
    
    read -p "按任意键返回菜单..." -n1 -s
}

# 功能3: 停止下载进程
stop_download() {
    echo "========================================"
    echo "          停止下载进程"
    echo "========================================"
    echo "日期: $(date)"
    echo ""
    
    # 1. 显示所有相关进程的初始状态
    echo "1. 当前运行的进程:"
    ps aux | grep -E "dl.sh|N_m3u8DL-RE|bash" | grep -v grep
    
    echo ""
    echo "2. 正在停止所有相关进程..."
    
    # 使用更强制的方式终止进程
    echo "- 停止 dl.sh 进程..."
    pkill -9 -f "dl.sh" || echo "  未找到 dl.sh 进程"
    
    echo "- 停止 N_m3u8DL-RE 进程..."
    pkill -9 -f "N_m3u8DL-RE" || echo "  未找到 N_m3u8DL-RE 进程"
    
    echo "- 停止任何剩余的 dl.sh bash 进程..."
    pkill -9 -f "/bin/bash ./dl.sh" || echo "  未找到 bash dl.sh 进程"
    
    echo ""
    echo "3. 检查剩余进程..."
    # 检查是否还有相关进程在运行
    remaining=$(ps aux | grep -E "dl.sh|N_m3u8DL-RE|bash" | grep -v grep)
    
    if [ -z "$remaining" ]; then
        echo "✓ 所有进程已成功停止！"
    else
        echo "✗ 可能还有一些进程在运行:"
        echo "$remaining"
        echo ""
        echo "手动终止说明:"
        echo "1. 对于上面的每个PID，运行: kill -9 PID"
        echo "2. 例如: kill -9 1234"
    fi
    
    # 4. 清理残留的临时文件
    echo ""
    echo "4. 正在清理临时文件..."
    echo "- 清理 $LOG_DIR..."
    rm -f "$LOG_DIR"/*.tmp "$LOG_DIR"/*.temp "$LOG_DIR"/*.log 2>/dev/null
    
    echo "- 清理 /usr/local/bin/Logs..."
    rm -f /usr/local/bin/Logs/*.tmp /usr/local/bin/Logs/*.temp /usr/local/bin/Logs/*.log 2>/dev/null
    
    echo "- 清理 /root/ 临时文件夹..."
    # 清理root目录下可能残留的临时文件夹
    for folder in $(ls -d /root/* 2>/dev/null); do
        if [ -d "$folder" ]; then
            # 检查是否为视频文件夹（假设名称不包含特殊字符）
            folder_name=$(basename "$folder")
            # 检查是否有对应的视频文件存在，有的话才清理
            video_found=false
            for ext in mp4 mkv avi flv mov webm; do
                if [ -f "$OUTPUT_DIR/$folder_name.$ext" ]; then
                    video_found=true
                    break
                fi
            done
            if [ "$video_found" = true ]; then
                echo "  正在删除临时文件夹: $folder"
                rm -rf "$folder" 2>/dev/null
            fi
        fi
    done
    
    echo ""
    echo "5. 最终状态:"
    echo "- 停止操作已完成！"
    echo "- 请检查 $OUTPUT_DIR 查看已完成的文件"
    echo "- 请检查 $DOWNLOAD_LOG 查看下载历史"
    echo ""
    
    read -p "按任意键返回菜单..." -n1 -s
}

# 主程序
main() {
    while true; do
        show_menu
        read choice
        case $choice in
            1)
                m3u8_download
                ;;
            2)
                env_install
                ;;
            3)
                stop_download
                ;;
            4)
                echo "========================================"
                echo "          感谢使用，再见！"
                echo "========================================"
                exit 0
                ;;
            *)
                echo "错误：无效的选择！请输入1-4之间的数字。"
                sleep 1
                ;;
        esac
    done
}

# 执行主程序
main
