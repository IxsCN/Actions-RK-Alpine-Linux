# Actions-RK-Alpine-Linux

面向 **NanoPi R4S 和 NEO3** 的 Alpine Linux 镜像构建项目，由 IxsCN 独立维护，基于 [FriendlyElec Actions-Alpine-Linux](https://github.com/friendlyarm/Actions-Alpine-Linux) 定制。

通过 GitHub Actions 构建 ARM64 系统镜像，在友善 Linux 6.6 内核配置上增加 dae 所需的 **eBPF、BTF 和 TC** 支持，适用于轻量路由、旁路由和网络实验环境。

[English](README_en.md) · [构建进度](https://github.com/IxsCN/Actions-RK-Alpine-Linux/actions) · [镜像下载](https://github.com/IxsCN/Actions-RK-Alpine-Linux/releases) · [内核定制说明](docs/dae-kernel.md)

## 当前构建范围

| 开发板 | 平台 | 系统 | 内核系列 |
| --- | --- | --- | --- |
| NanoPi R4S | rk3399 | Alpine Linux 3.23 / ARM64 | Linux 6.6 |
| NanoPi NEO3 | rk3328 | Alpine Linux 3.23 / ARM64 | Linux 6.6 |

- **dae 内核能力**：启用 eBPF、BTF、TC 等选项，构建时校验最终配置及内核 BTF。
- **预装工具**：`htop`、`tio`、`kitty-terminfo`、`tailscale`。
- **两种镜像输出**：SD 启动镜像与 eMMC 刷写镜像；eMMC 输出仅适用于具备兼容 eMMC 硬件的设备，不代表所有目标板都支持。
- **独立构建**：两个平台分别构建，一个失败不会自动取消另一个。

> dae 本身尚未预装。Tailscale 仅安装，不自动启动或加入 tailnet。内核编译检查不替代板上启动及 dae 实际流量验证，请以对应 Actions 运行结果和实机测试为准。

## 默认系统设置

| 项目 | 默认值 |
| --- | --- |
| 用户名 | `root` |
| 密码 | `fa` |
| 网络 | 第一个网口通过 DHCP 获取地址 |
| 登录 | SSH 和串口终端 |

**首次启动后立即修改默认密码。完成安全配置前，不要将 SSH 暴露到公网。**

## 构建镜像

1. 打开本仓库的 **Actions** 页面；如果工作流被禁用，先启用。
2. 选择 `.github/workflows/build.yml`。
3. 点击 **Run workflow**，选择 `master` 后启动。
4. 等待对应平台构建及上传成功，在 **Releases** 下载镜像。

工作流仅允许仓库所有者触发，仍兼容给自己的仓库加 Star 的触发方式。发布所需的 `contents: write` 权限已在工作流中声明。

> Release 会在编译前创建，因此出现 Release 不代表镜像已经构建成功。

## 通过 TF / microSD 卡运行

按平台下载 `*-sd-alpine-linux-arm64-*.img.gz`：

- R4S：`rk3399-sd-alpine-linux-arm64-*.img.gz`
- NEO3：`rk3328-sd-alpine-linux-arm64-*.img.gz`

解压后使用写卡工具将 `.img` 写入 TF 卡（或使用支持 `.gz` 的工具），插入对应开发板启动。建议先使用备用卡测试，保留原系统以便回退。

## eMMC 刷写镜像

带 `-eflasher-` 的镜像用于从 TF 卡自动刷写 eMMC，**不是普通 SD 启动镜像**。

仅在确认设备具备兼容 eMMC、镜像匹配且已备份数据后使用。将镜像写入 TF 卡后启动设备，会自动覆盖目标 eMMC 上的数据；刷写完成后按设备指引移除 TF 卡并重启。

## 定制入口

- [`configs/dae.config`](configs/dae.config)：dae 所需内核配置片段。
- [`scripts/build-dae-kernel.sh`](scripts/build-dae-kernel.sh)：板级配置选择、内核编译和校验。
- [`scripts/setup-alpine.sh`](scripts/setup-alpine.sh)：预装软件及 rootfs 初始化。
- [`.github/workflows/build.yml`](.github/workflows/build.yml)：构建、打包与 Release 上传。
- [`docs/dae-kernel.md`](docs/dae-kernel.md)：内核构建细节及启动后检查。

## 致谢与参考

感谢 FriendlyElec 提供开发板支持、内核及镜像构建工具。本仓库保留其构建基础，维护自己的配置与发布流程，不代表 FriendlyElec 官方发布。

- [上游项目](https://github.com/friendlyarm/Actions-Alpine-Linux)
- [FriendlyElec Alpine Linux 文档](https://wiki.friendlyelec.com/wiki/index.php/Getting_Started_with_Alpine-Linux/zh)
- [dae 项目](https://github.com/daeuniverse/dae)
