# R4S / NEO3 的 dae 内核

本 Fork 的构建矩阵只保留 NanoPi R4S（rk3399）和 NEO3（rk3328）。
两者使用 `sd-fuse_<CPU>` 的 `kernel-6.6.y` 分支，内核源码来自
`friendlyarm/kernel-rockchip` 的 `nanopi-r2-v6.6.y` 分支。

| 板子 | 默认配置 |
| --- | --- |
| R4S | `nanopi4_linux_defconfig` |
| NEO3 | `nanopi-r2_linux_defconfig` |

## 定制入口

- `configs/dae.config`：共用 BPF、TC、BTF 配置片段。
- `scripts/build-dae-kernel.sh`：在 sd-fuse 工作目录调用，通过 `KCFG`
  将板级默认配置和片段合并。不要直接修改 `.config`，上游会执行 distclean。
- `.github/workflows/build.yml`：安装宿主机 `dwarves` / `libelf-dev`，
  调用编译脚本，继续使用上游流程打包内核、DTB 和模块。

编译后会检查最终 `.config` 中的所有片段设置以及 vmlinux 的 `.BTF` section；
检查失败则停止镜像打包。源码仍跟随上游分支，没有固定 commit。
工作流触发方式不变：仓库所有者给自己的仓库加星。

## 启动后检查

建议先使用备用 TF 卡测试，保留旧系统以便回退。

```sh
uname -r
ls -lh /sys/kernel/btf/vmlinux
zcat /proc/config.gz | grep -E 'CONFIG_(BPF|BPF_SYSCALL|BPF_JIT|BPF_STREAM_PARSER|DEBUG_INFO_BTF|NET_CLS_BPF|NET_SCH_INGRESS)='
```

本次修改只提供内核能力，不自动安装或启动 dae，也不修改网关、DNS、
防火墙或非特权 BPF 策略。部署 dae 时还需要：

1. 配置 Alpine/OpenRC 的 cgroups（`rc-update add cgroups boot`）。
2. 确认 bpffs 挂载在 `/sys/fs/bpf`，并配置持久挂载。
3. 安装 ARM64 dae 和 OpenRC 服务，配置代理节点和接口。
4. 实际启动 dae，验证 verifier 加载成功及客户端流量路径。

R4S 可做双网口主路由；NEO3 单网口通常用于旁路由，需单独规划回程与 DNS。
以上构建检查不能替代板上启动与 dae 流量测试。

参考：
- https://github.com/daeuniverse/dae/blob/main/docs/en/README.md
- https://github.com/daeuniverse/dae/blob/main/docs/en/tutorials/run-on-alpine.md
