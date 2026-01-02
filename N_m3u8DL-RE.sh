#!/bin/bash

# 设置输出目录和日志目录
OUTPUT_DIR="/www/OssOpen/DLoss"
LOG_DIR="/www/OssOpen/TXTOss/Log"
DOWNLOAD_LOG="$LOG_DIR/download.log"

# 创建一个数组来存储所有下载的文件名，用于后续清理临时文件夹
DOWNLOADED_FILENAMES=()

# 创建目录
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

# 设置TXT文件链接（硬编码）
TXT_URL="https://raw.githubusercontent.com/OsGits/dl.m3u8/main/cs.txt"

# 下载远程TXT文件到临时目录
TMP_FILE="$LOG_DIR/$(basename "$TXT_URL")"
if command -v curl &> /dev/null; then
    curl -s -o "$TMP_FILE" "$TXT_URL"
elif command -v wget &> /dev/null; then
    wget -q -O "$TMP_FILE" "$TXT_URL"
else
    echo "错误：未安装 curl 或 wget！"
    exit 1
fi

if [ ! -s "$TMP_FILE" ]; then
    echo "错误：下载 $TXT_URL 失败！"
    exit 1
fi

TXT_FILE="$TMP_FILE"

# 检查 N_m3u8DL-RE 是否存在
if ! command -v N_m3u8DL-RE &> /dev/null; then
    echo "错误：N_m3u8DL-RE 未安装或不在 PATH 中！"
    exit 1
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
    
    # 将文件名添加到数组，用于后续统一清理临时文件夹
    DOWNLOADED_FILENAMES+=($FILENAME)

    # 记录开始时间
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    
    # 调用 N_m3u8DL-RE 下载（使用正确的参数格式）
    N_m3u8DL-RE "$M3U8_URL" --save-dir "$OUTPUT_DIR" --save-name "$FILENAME" --tmp-dir "$LOG_DIR" --log-level error
    
    # 检查下载结果
    if [ $? -eq 0 ]; then
        STATUS="成功"
    else
        STATUS="失败"
    fi
    
    # 记录到日志文件
    echo "$TIMESTAMP:$STATUS:$FILENAME:$M3U8_URL" >> "$DOWNLOAD_LOG"
    
    # 1. 清理 /usr/local/bin/Logs 中的日志（实时清理，不影响转换）
    rm -f /usr/local/bin/Logs/*.log /usr/local/bin/Logs/*.tmp /usr/local/bin/Logs/*.temp 2>/dev/null

done < "$TXT_FILE"

# 清理临时文件（包括远程下载的TXT文件）
rm -f "$TXT_FILE"

# 2. 统一清理临时目录下生成的临时文件夹（所有下载完成后）
echo "正在清理 $LOG_DIR/ 中的临时文件夹..."
for fname in "${DOWNLOADED_FILENAMES[@]}"; do
    # 检查OUTPUT_DIR中是否存在对应的视频文件
    # 支持多种视频文件扩展名
    VIDEO_FILE_FOUND=false
    for ext in mp4 mkv avi flv mov webm; do
        if [ -f "$OUTPUT_DIR/$fname.$ext" ]; then
            VIDEO_FILE_FOUND=true
            break
        fi
    done
    
    # 只有当对应的视频文件存在时，才清理临时目录下的临时文件夹
    if [ "$VIDEO_FILE_FOUND" = true ] && [ -d "$LOG_DIR/$fname" ]; then
        echo "正在删除临时文件夹：$LOG_DIR/$fname（视频文件已存在）"
        rm -rf "$LOG_DIR/$fname" 2>/dev/null
    elif [ -d "$LOG_DIR/$fname" ]; then
        echo "跳过清理：$LOG_DIR/$fname（未找到视频文件）"
    fi
done

# 完成提示
echo "下载完成！"
echo "日志文件：$DOWNLOAD_LOG"
echo "输出目录：$OUTPUT_DIR"