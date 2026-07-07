# mise-moonbit

<p align="center">
  <a href="https://github.com/morning-start/moonbit/actions"><img src="https://img.shields.io/github/actions/workflow/status/morning-start/moonbit/ci.yml?style=flat-square" alt="CI Status"></a>
  <a href="https://github.com/morning-start/moonbit/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="License"></a>
</p>

> 通过 [mise](https://mise.jdx.dev/) 或 [vfox](https://vfox.dev/) 一键管理 MoonBit 版本 —— 告别手动下载，版本切换只需一行命令。

## 为什么选择 mise-moonbit？

| 传统方式                   | mise-moonbit                      |
| -------------------------- | --------------------------------- |
| 手动下载解压，占用磁盘空间 | 自动下载安装，版本隔离            |
| 切换版本需要重新安装       | 一行命令切换任意版本              |
| 项目间版本冲突             | 项目级版本锁定，互不干扰          |
| 无法追踪已安装版本         | `mise ls-remote` 查看所有可用版本 |

## 快速开始

```bash
# 安装插件
mise plugin add moonbit

# 安装最新版本
mise install moonbit@latest

# 设置全局默认版本
mise use -g moonbit@latest
```

## 版本管理

```bash
# 查看所有可用版本
mise ls-remote moonbit

# 安装指定版本
mise install moonbit@0.10.3+16975d007

# 安装最新的 0.10.x 版本
mise install moonbit@0.10

# 安装 nightly 版本
mise install moonbit@nightly

# 项目级版本锁定（创建 .mise.toml）
mise use moonbit@0.10
```

## 环境变量

| 变量                      | 说明                                 | 默认值                       |
| ------------------------- | ------------------------------------ | ---------------------------- |
| `MOONBIT_INSTALL_DEV`     | 设置为 `1` 安装开发版本              | `0`                          |
| `MOONBIT_INSTALL_VERSION` | 指定要安装的版本（优先级高于命令行） | -                            |
| `VFOX_MOONBIT_MIRROR`     | 下载镜像地址                         | `https://cli.moonbitlang.cn` |

## 支持的平台

| 操作系统 | 架构                  |
| -------- | --------------------- |
| macOS    | arm64 (Apple Silicon) |
| Linux    | x86_64, aarch64       |
| Windows  | x86_64, arm64         |

## 开发

```bash
# 链接本地插件进行调试
mise plugin link --force moonbit .

# 运行测试
mise run test

# 运行 lint
mise run lint

# 调试模式
MISE_DEBUG=1 mise install moonbit@latest
```

## 许可证

[MIT](https://github.com/morning-start/moonbit/blob/main/LICENSE)
