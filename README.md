# Unity 6 国际版整合包（Unity Hub + Unity 6000.6.0f1 + 教程）

> ⚠️ **本仓库的定位是「临时文件中转」**：Git 源码树里只有说明文档、校验清单和合并脚本；
> 5.33 GB 的主体数据以 **Release 分卷附件**形式存放。
>
> 为什么必须分卷：GitHub 对 Git 仓库单文件上限 100 MB，Release 单个附件上限 2 GB，
> 而且附件上传有**服务端超时限制**（实测约 750 秒），所以单个分卷不能开得太大，
> 否则慢速链路上永远传不完。本仓库因此把原始 zip 切成 36 个分卷。

---

## 一、包内有什么

合并解压后是一个名为 `国际版 UnityHub 和 Unity6编辑器 及教程` 的文件夹：

| 文件 | 大小 |
| --- | ---: |
| `Unity 6000.6.0f1.zip` | 4,676,754,024 B (4.36 GiB) |
| `EpicInstaller-20.3.3-unrealEngine.exe` | 264,283,136 B |
| `UnityHubSetup-x64.exe` | 193,266,120 B |
| `CocosDashboard-v2.2.2-win-091515.exe` | 156,221,944 B |
| `Godot_v4.7.2-stable_win64.exe.zip` | 86,013,866 B |
| `导入 Unity6-演示.mp4` | 19,628,932 B |
| `README.txt` / `阅读这个文件.txt` | 1,008 B / 795 B |

原始 zip 总大小：**5,327,028,600 字节**（4.96 GiB）。

---

## 二、下载全部 36 个分卷

Release 页面：<https://github.com/annoy-cell/unity6-intl-bundle/releases/tag/v1.0.0>

| 分卷 | 数量 | 每卷大小 |
| --- | ---: | ---: |
| `part-001` ~ `part-032` | 32 | 33,554,432 B (32 MiB) |
| `part-033` ~ `part-035` | 3 | 1,073,741,824 B (1 GiB) |
| `part-036` | 1 | 1,032,061,304 B |

合计 = 5,327,028,600 B，与原始 zip 完全一致。

### 推荐：命令行批量下载（支持断点续传）

Windows PowerShell（在目标文件夹里执行）：

```powershell
1..36 | ForEach-Object {
  $n = 'part-{0:D3}' -f $_
  curl.exe -L -C - -O "https://github.com/annoy-cell/unity6-intl-bundle/releases/download/v1.0.0/$n"
}
```

Linux / macOS：

```bash
BASE=https://github.com/annoy-cell/unity6-intl-bundle/releases/download/v1.0.0
for i in $(seq -w 1 36); do curl -L -C - -O "$BASE/part-0$i"; done
```

> 浏览器逐个点 36 次也可以，但 1 GB 的分卷容易断，命令行断点续传更省心。

---

## 三、合并 + 解压（一步搞定）

把 **36 个分卷** 和 [`merge_and_extract.bat`](merge_and_extract.bat) 放在同一个文件夹，
**双击 `merge_and_extract.bat`**。脚本会：

1. 检查 `part-001` ~ `part-036` 是否齐全，缺哪个会明确报出来；
2. 用 `copy /b` 按顺序二进制拼接成 `unity6-intl-bundle.zip`；
3. 校验合并后大小是否正好等于 5,327,028,600 字节；
4. 自动解压出 `国际版 UnityHub 和 Unity6编辑器 及教程` 文件夹。

> 需要约 11 GB 空闲磁盘（合并产物 5.0 GB + 解压产物 5.0 GB）。

### 手动方式

```bat
copy /b part-001+part-002+...+part-036 unity6-intl-bundle.zip
```

顺序必须是 `part-001` → `part-036`，不能乱。然后用 7-Zip / Bandizip / 资源管理器解压。

---

## 四、完整性校验

[`SHA256SUMS.txt`](SHA256SUMS.txt) 记录了每个分卷的 SHA-256：

```bash
sha256sum -c SHA256SUMS.txt
```

Windows：

```powershell
Get-FileHash .\part-001 -Algorithm SHA256
```

> 上传完成后已做过一次全量核验：GitHub 为每个附件记录的 `digest:sha256`
> 与本地文件逐一比对，**36/36 全部一致**。

---

## 五、注意事项

- **分卷不能单独解压**，`part-001` 只是原始 zip 的开头一段字节，必须凑齐 36 个再合并。
- 本仓库拿 GitHub 当临时存储桶用，Release 附件**可能随时失效或被清理**，重要文件请自行备份。
- 包内 Unity Hub、Unity 编辑器等软件的著作权归 Unity Technologies 及各厂商所有，
  此处仅作个人学习与内网分发用途，请勿用于商业再分发。
