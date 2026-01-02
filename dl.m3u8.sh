#!/bin/bash

# 设置输出目录
OUTPUT_DIR="/www/OssOpen/DLoss"
# 设置日志目录
TXT_DIR="/www/OssOpen/TXTOss"
# 设置储存m3u8链接的TXT文件链接
TXT_URL="https://raw.githubusercontent.com/OsGits/dl.m3u8/main/cs.txt"

# 以下类容建议不要修改！
# 显示菜单函数
show_menu() {
    clear
    
    # 获取最新版本号
    local update_url="https://raw.githubusercontent.com/OsGits/dl.m3u8/main/dl.m3u8.sh"
    local latest_version="获取中..."
    
    # 尝试从GitHub获取最新版本号
    if command -v curl &> /dev/null; then
        latest_version=$(curl -s "$update_url" | grep -oP '当前版本：\Kv[0-9]+\.[0-9]+\.[0-9]+' 2>/dev/null || echo "获取失败")
    elif command -v wget &> /dev/null; then
        latest_version=$(wget -q -O - "$update_url" | grep -oP '当前版本：\Kv[0-9]+\.[0-9]+\.[0-9]+' 2>/dev/null || echo "获取失败")
    else
        latest_version="无法获取"
    fi
    
    echo "========================================"
    echo "    M3U8下载工具菜单"
    echo "    脚本来源：https://github.com/OsGits/dl.m3u8"
    echo "    当前版本：v2601.0300.08   最新版本：$latest_version"
    echo "========================================"
    echo "1: M3u8资源下载"
    echo "2: 查看下载进程"
    echo "3: 更新脚本"
    echo "4: 使用配置(首次使用第2步)"
    echo "5: 环境一键配置(首次使用第1步)"
    echo "6: 停止下载进程"
    echo "7: 删除脚本(谨慎操作)"
    echo "8: 退出"
    echo "========================================"
    echo -n "请选择操作 (1-8): "
}

# 功能1: M3u8资源下载
m3u8_download() {
    echo "========================================"
    echo "          M3u8资源下载"
    echo "========================================"
    
    # 创建目录
    mkdir -p "$OUTPUT_DIR"
    
    echo "正在启动下载进程..."
    echo "命令: nohup ./dl.sh &"
    echo ""
    
    # 运行下载命令
    nohup ./dl.sh &
    
    echo "✓ 下载进程已启动！"
    echo "进程将在后台运行，不会影响当前终端使用。"
    echo ""
    echo "========================================"
    echo "启动完成！"
    echo "输出目录：$OUTPUT_DIR"
    read -p "按任意键返回菜单..." -n1 -s
}

# 功能2: 查看下载进程
view_download_process() {
    echo "========================================"
    echo "          查看下载进程"
    echo "========================================"
    echo "正在查看下载进程日志..."
    echo "命令: tail -n 20 nohup.out"
    echo ""
    
    # 查看下载进程
    if [ -f "nohup.out" ]; then
        tail -n 20 nohup.out
    else
        echo "未找到 nohup.out 文件，可能还没有运行下载进程。"
    fi
    
    echo ""
    echo "========================================"
    read -p "按任意键返回菜单..." -n1 -s
}

# 功能5: 环境一键安装
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
    wget https://raw.githubusercontent.com/OsGits/dl.m3u8/main/N_m3u8DL-RE_v0.5.1-beta_linux-x64_20251029.tar.gz
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
    
    # 下载GitHub资源
    echo ""
    echo "正在下载GitHub资源..."
    echo "下载地址：https://raw.githubusercontent.com/OsGits/dl.m3u8/main/"
    
    # 下载dl.sh脚本到/root目录
    echo "正在下载dl.sh脚本到/root目录..."
    if command -v curl &> /dev/null; then
        curl -s -o /root/dl.sh https://raw.githubusercontent.com/OsGits/dl.m3u8/main/dl.sh
    elif command -v wget &> /dev/null; then
        wget -q -O /root/dl.sh https://raw.githubusercontent.com/OsGits/dl.m3u8/main/dl.sh
    fi
    
    # 添加执行权限
    chmod +x /root/dl.sh
    echo "✓ dl.sh脚本已下载到/root目录并添加了执行权限！"
    
    # 验证安装
    echo "========================================"
    echo "安装完成！版本信息："
    N_m3u8DL-RE --version
    
    read -p "按任意键返回菜单..." -n1 -s
}

# 功能4: 使用配置(必须)
config_setup() {
    echo "========================================"
    echo "          使用配置(必须)"
    echo "========================================"
    
    # 显示当前配置
    echo "当前配置："
    echo "下载完成后储存的目录：$OUTPUT_DIR"
    echo "临时文件目录：$TXT_DIR"
    echo "需要进行下载的TXT文件：$TXT_URL"
    echo ""
    
    # 获取用户输入，支持直接回车使用默认值
    read -p "请输入下载完成后储存的目录 [$OUTPUT_DIR]: " new_output_dir
    if [ -n "$new_output_dir" ]; then
        OUTPUT_DIR="$new_output_dir"
    fi
    
    read -p "请输入使用过程中产生的临时文件和日记目录 [$TXT_DIR]: " new_txt_dir
    if [ -n "$new_txt_dir" ]; then
        TXT_DIR="$new_txt_dir"
    fi
    
    read -p "请输入需要进行下载的TXT文件，如http://cnp.cc/urls.txt [$TXT_URL]: " new_txt_url
    if [ -n "$new_txt_url" ]; then
        TXT_URL="$new_txt_url"
    fi
    
    # 更新脚本文件中的配置
    echo "正在保存配置..."
    
    # 使用sed命令更新配置（兼容不同系统）
    if command -v sed &> /dev/null; then
        # 更新主脚本配置
        echo "正在更新dl.m3u8.sh配置..."
        # 更新OUTPUT_DIR
        sed -i "s|^OUTPUT_DIR=.*|OUTPUT_DIR=\"$OUTPUT_DIR\"|" "$0"
        # 更新TXT_DIR
        sed -i "s|^TXT_DIR=.*|TXT_DIR=\"$TXT_DIR\"|" "$0"
        # 更新TXT_URL
        sed -i "s|^TXT_URL=.*|TXT_URL=\"$TXT_URL\"|" "$0"
        
        # 更新dl.sh配置
        echo "正在更新dl.sh配置..."
        local dlsh_path="/root/dl.sh"
        if [ -f "$dlsh_path" ]; then
            # 更新OUTPUT_DIR
            sed -i "s|^OUTPUT_DIR=.*|OUTPUT_DIR=\"$OUTPUT_DIR\"|" "$dlsh_path"
            # 更新LOG_DIR（由TXT_DIR派生）
            sed -i "s|^LOG_DIR=.*|LOG_DIR=\"$TXT_DIR/Log\"|" "$dlsh_path"
            # 更新TXT_URL
            sed -i "s|^TXT_URL=.*|TXT_URL=\"$TXT_URL\"|" "$dlsh_path"
            echo "dl.sh配置更新成功！"
        else
            echo "警告：未找到dl.sh文件，跳过dl.sh配置更新！"
        fi
        
        echo "配置保存成功！"
    else
        echo "警告：无法保存配置（sed命令不可用）。配置仅在当前会话有效。"
    fi
    
    echo ""
    echo "新配置："
    echo "下载完成后储存的目录：$OUTPUT_DIR"
    echo "临时文件目录：$TXT_DIR"
    echo "需要进行下载的TXT文件：$TXT_URL"
    echo ""
    
    read -p "按任意键返回菜单..." -n1 -s
}

# 功能6: 停止下载进程
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
    echo ""
    
    read -p "按任意键返回菜单..." -n1 -s
}

# 功能3: 更新脚本
update_script() {
    echo "========================================"
    echo "          更新脚本"
    echo "========================================"
    
    local script_path="$0"
    local update_url="https://raw.githubusercontent.com/OsGits/dl.m3u8/main/dl.m3u8.sh"
    local temp_file="/tmp/dl.m3u8.sh.new"
    
    echo "正在从以下地址下载最新脚本："
    echo "$update_url"
    echo ""
    
    # 创建临时目录（如果不存在）
    mkdir -p "/tmp"
    
    # 下载最新脚本
    if command -v curl &> /dev/null; then
        if curl -s -o "$temp_file" "$update_url"; then
            echo "✓ 脚本下载成功！"
        else
            echo "✗ 脚本下载失败！"
            read -p "按任意键返回菜单..." -n1 -s
            return
        fi
    elif command -v wget &> /dev/null; then
        if wget -q -O "$temp_file" "$update_url"; then
            echo "✓ 脚本下载成功！"
        else
            echo "✗ 脚本下载失败！"
            read -p "按任意键返回菜单..." -n1 -s
            return
        fi
    else
        echo "✗ 未安装 curl 或 wget，无法下载脚本！"
        read -p "按任意键返回菜单..." -n1 -s
        return
    fi
    
    # 检查下载的脚本是否有效
    if [ ! -s "$temp_file" ]; then
        echo "✗ 下载的脚本为空，更新失败！"
        read -p "按任意键返回菜单..." -n1 -s
        rm -f "$temp_file"
        return
    fi
    
    # 替换当前脚本
    if mv "$temp_file" "$script_path"; then
        echo "✓ 脚本替换成功！"
    else
        echo "✗ 脚本替换失败！"
        read -p "按任意键返回菜单..." -n1 -s
        return
    fi
    
    # 添加可执行权限
    if chmod +x "$script_path"; then
        echo "✓ 已添加可执行权限！"
    else
        echo "✗ 添加可执行权限失败！"
        read -p "按任意键返回菜单..." -n1 -s
        return
    fi
    
    # 更新dl.sh脚本
    echo ""
    echo "========================================"
    echo "正在更新dl.sh脚本..."
    echo "下载地址：https://raw.githubusercontent.com/OsGits/dl.m3u8/main/dl.sh"
    echo ""
    
    local dlsh_url="https://raw.githubusercontent.com/OsGits/dl.m3u8/main/dl.sh"
    local dlsh_path="/root/dl.sh"
    
    if command -v curl &> /dev/null; then
        if curl -s -o "$dlsh_path" "$dlsh_url"; then
            echo "✓ dl.sh脚本下载成功！"
        else
            echo "✗ dl.sh脚本下载失败！"
        fi
    elif command -v wget &> /dev/null; then
        if wget -q -O "$dlsh_path" "$dlsh_url"; then
            echo "✓ dl.sh脚本下载成功！"
        else
            echo "✗ dl.sh脚本下载失败！"
        fi
    else
        echo "✗ 未安装 curl 或 wget，无法下载dl.sh脚本！"
    fi
    
    # 为dl.sh添加执行权限
    if chmod +x "$dlsh_path"; then
        echo "✓ dl.sh脚本已添加可执行权限！"
    else
        echo "✗ dl.sh脚本添加执行权限失败！"
    fi
    
    echo ""
    echo "========================================"
    echo "脚本更新完成！"
    echo "========================================"
    read -p "按任意键退出脚本..." -n1 -s
    echo "========================================"
    echo "      感谢使用，再见！"
    echo "下次如需使用，输入代码：   ./dl.m3u8.sh"
    echo "更多好码：https://github.com/OsGits"
    echo "========================================"
    exit 0
}

# 功能7: 删除脚本(谨慎操作)
uninstall_script() {
    echo "========================================"
    echo "          删除脚本(谨慎操作)"
    echo "========================================"
    
    echo "警告：此操作将永久删除以下内容！"
    echo "1. N_m3u8DL-RE 程序"
    echo "2. ffmpeg 及相关环境"
    echo "3. 当前脚本文件"
    echo ""
    echo "此操作不可恢复，请谨慎执行！"
    echo ""
    
    # 要求用户确认
    read -p "请输入 'YES' (大写字母)确认删除，输入其他内容取消：" confirm
    if [ "$confirm" != "YES" ]; then
        echo ""
        echo "删除操作已取消！"
        read -p "按任意键返回菜单..." -n1 -s
        return
    fi
    
    echo ""
    echo "正在执行删除操作..."
    echo "========================================"
    
    # 1. 删除N_m3u8DL-RE程序
    echo "1. 删除N_m3u8DL-RE程序..."
    if [ -f "/usr/local/bin/N_m3u8DL-RE" ]; then
        if rm -f "/usr/local/bin/N_m3u8DL-RE"; then
            echo "✓ N_m3u8DL-RE 删除成功！"
        else
            echo "✗ N_m3u8DL-RE 删除失败！"
        fi
    else
        echo "ℹ N_m3u8DL-RE 不存在，跳过删除！"
    fi
    
    # 2. 卸载ffmpeg及相关依赖
    echo ""
    echo "2. 卸载ffmpeg及相关依赖..."
    if command -v apt &> /dev/null; then
        # Ubuntu/Debian系统
        sudo apt remove -y ffmpeg libgdiplus
        sudo apt autoremove -y
        echo "✓ ffmpeg 及相关依赖卸载完成！"
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL系统
        sudo yum remove -y ffmpeg
        echo "✓ ffmpeg 卸载完成！"
    else
        echo "ℹ 不支持的包管理器，跳过ffmpeg卸载！"
    fi
    
    # 3. 删除脚本本身
    echo ""
    echo "3. 删除当前脚本文件..."
    local script_path="$0"
    local script_name="$(basename "$script_path")"
    
    # 创建一个临时删除脚本
    cat > /tmp/uninstall_final.sh << 'EOF'
#!/bin/bash
# 延迟执行删除操作
sleep 1
rm -f "$1"
echo "✓ 脚本文件已删除！"
echo ""
echo "========================================"
echo "删除操作已完成！"
echo "========================================"
sleep 2
EOF
    
    chmod +x /tmp/uninstall_final.sh
    
    # 在后台执行临时删除脚本
    /tmp/uninstall_final.sh "$script_path" &
    
    echo "========================================"
    echo "删除操作正在执行..."
    echo "脚本将在几秒后自动关闭！"
    echo "========================================"
    echo "========================================"
    echo "      感谢使用，再见！"
    echo "下次如需使用，输入代码：   ./dl.m3u8.sh"
    echo "更多好码：https://github.com/OsGits"
    echo "========================================"
    
    # 退出脚本
    exit 0
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
                view_download_process
                ;;
            3)
                update_script
                ;;
            4)
                config_setup
                ;;
            5)
                env_install
                ;;
            6)
                stop_download
                ;;
            7)
                uninstall_script
                ;;
            8)
                echo "========================================"
                echo "      感谢使用，再见！"
                echo "下次如需使用，输入代码：   ./dl.m3u8.sh"
                echo "更多好码：https://github.com/OsGits"
                echo "========================================"
                exit 0
                ;;
            *)
                echo "错误：无效的选择！请输入1-8之间的数字。"
                sleep 1
                ;;
        esac
    done
}

# 执行主程序
main
