# Build Caddy

一个用于构建自定义 Caddy Web Server 的项目，集成了多个实用插件，支持 Windows 平台多架构交叉编译。

## 简介

本项目基于 [Caddy](https://caddyserver.com/) 构建，在官方标准模块的基础上，额外集成了以下插件：

| 插件 | 说明 |
|------|------|
| [forwardproxy](https://github.com/caddyserver/forwardproxy) | 正向代理支持 |
| [nginx-adapter](https://github.com/caddyserver/nginx-adapter) | Nginx 配置文件适配器 |
| [transform-encoder](https://github.com/caddyserver/transform-encoder) | 日志转换编码器 |
| [replace-response](https://github.com/caddyserver/replace-response) | HTTP 响应内容替换 |
| [caddy-webdav](https://github.com/mholt/caddy-webdav) | WebDAV 协议支持 |
| [cloudflare](https://github.com/caddy-dns/cloudflare) | Cloudflare DNS 解析支持 |

## 项目结构

```
.
├── assets/               # Windows 图标资源文件
│   ├── caddy_1.ico
│   ├── caddy_2.ico
│   ├── ...
│   └── caddy_7.ico
├── build-release.sh      # 构建脚本
├── main.go              # Caddy 主程序入口
├── versioninfo.json     # Windows 版本信息模板
└── README.md            # 本文件
```

## 使用方法

### 环境要求

- [Go](https://golang.org/dl/) 1.25 或更高版本
- [goversioninfo](https://github.com/josephspurrier/goversioninfo)（可选，用于生成 Windows 资源文件）

### 构建

运行构建脚本，指定 Caddy 版本号：

```bash
bash build-release.sh v2.10.2
```

本脚本只指定了 Windows 系统的构建，当编译完成后，将在当前目录生成以下文件：

```
caddy_v2.10.2_windows_amd64.exe
caddy_v2.10.2_windows_386.exe
caddy_v2.10.2_windows_arm64.exe
caddy_v2.10.2_windows_arm.exe
```

### 手动构建

你也可以手动构建：

```bash
# 初始化模块
go mod init caddy
echo "require github.com/caddyserver/caddy/v2 v2.10.2" >> go.mod
go mod tidy

# 构建（以 amd64 为例）
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build \
    -a -v -x -buildmode pie -compiler gc -trimpath -ldflags "-s -w -buildid=" \
    -o caddy.exe
```

## 许可证

本项目遵循 Caddy 的许可证。各插件遵循其各自的许可证。

## 相关链接

- [Caddy 官方文档](https://caddyserver.com/docs/)
- [Caddy 插件列表](https://caddyserver.com/docs/modules/)
- [Caddy GitHub](https://github.com/caddyserver/caddy)
