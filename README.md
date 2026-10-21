# Unity 6 国际版整合包（Unity Hub + Unity 6000.6.0f1 + 教程）

> ⚠️ **本仓库的定位是「临时文件中转」**：Git 源码树里只放说明文档、校验清单和合并脚本；
> 5.33 GB 的主体数据放在 **Release 分卷附件**里。
> 原因：GitHub 对 Git 仓库单文件上限 100 MB，Release 单个附件上限 2 GB。
> 所以原始 zip 被按 1 GiB 切成了 5 个分卷。

---

## 一、包内到底有什么

解压后是一个名为 `国际版 UnityHub 和 Unity6编辑器 及教程` 的文件夹：

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

## 二、下载

Release 页面：<https://github.com/annoy-cell/unity6-intl-bundle/releases/tag/v1.0.0>

**必须把下面 5 个分卷全部下载到同一个文件夹**，缺一个都解不开：

| # | 文件名 | 大小 |
| --- | --- | ---: |
| 1 | [`unity6-intl-bundle.zip.001`](https://github.com/annoy-cell/unity6-intl-bundle/releases/download/v1.0.0/unity6-intl-bundle.zip.001) | 1,073,741,824 B |
| 2 | [`unity6-intl-bundle.zip.002`](https://github.com/annoy-cell/unity6-intl-bundle/releases/download/v1.0.0/unity6-intl-bundle.zip.002) | 1,073,741,824 B |
| 3 | [`unity6-intl-bundle.zip.003`](https://github.com/annoy-cell/unity6-intl-bundle/releases/download/v1.0.0/unity6-intl-bundle.zip.003) | 1,073,741,824 B |
| 4 | [`unity6-intl-bundle.zip.004`](https://github.com/annoy-cell/unity6-intl-bundle/releases/download/v1.0.0/unity6-intl-bundle.zip.004) | 1,073,741,824 B |
| 5 | [`unity6-intl-bundle.zip.005`](https://github.com/annoy-cell/unity6-intl-bundle/releases/download/v1.0.0/unity6-intl-bundle.zip.005) | 1,032,061,304 B |

浏览器下载 1 GB 文件容易断，建议用命令行断点续传（更快、可续传）：

```bash
BASE=https://github.com/annoy-cell/unity6-intl-bundle/releases/download/v1.0.0
for i in 001 002 003 004 005; do
  curl -L -C - -O "$BASE/unity6-intl-bundle.zip.$i"
done
```

---

## 三、合并 + 解压（一步搞定）

把 5 个分卷和 [`merge_and_extract.bat`](merge_and_extract.bat) 放在同一个文件夹，
**双击 `merge_and_extract.bat`**。脚本会：

1. 检查 5 个分卷是否齐全；
2. 用 `copy /b` 二进制拼接成 `unity6-intl-bundle.zip`；
3. 校验合并后大小是否等于 5,327,028,600 字节；
4. 自动解压出 `国际版 UnityHub 和 Unity6编辑器 及教程` 文件夹。

### 手动方式

```bat
copy /b unity6-intl-bundle.zip.001+unity6-intl-bundle.zip.002+unity6-intl-bundle.zip.003+unity6-intl-bundle.zip.004+unity6-intl-bundle.zip.005 unity6-intl-bundle.zip
```

然后用 7-Zip / Bandizip / Windows 资源管理器正常解压 `unity6-intl-bundle.zip` 即可。

> `copy /b` 的参数顺序不能乱，必须 .001 → .005 依次拼接。

---

## 四、完整性校验

[`SHA256SUMS.txt`](SHA256SUMS.txt) 记录了每个分卷的 SHA-256：

```bash
sha256sum -c SHA256SUMS.txt
```

Windows PowerShell：

```powershell
Get-FileHash .\unity6-intl-bundle.zip.001 -Algorithm SHA256
```

| 分卷 | SHA-256 |
| --- | --- |
| .001 | `88710521e2b0b93071b6760b3e5572fc1bb8a8cb466bdd672a6655a603bd1e54` |
| .002 | `f327d94d8943fd9faab5deefc844d29b937624afbdf41c6acf3da5607bf43b48` |
| .003 | `f93d7da101f4cff8509fa32f1e8b1b69b7ec50e0d349f81497f82464e6bf2f49` |
| .004 | `b4588ae5cbae93f599020e6a3f5471355ce02d16940337b40e329414017449c6` |
| .005 | `bb36e19255253f52779cbb1e42a02f6fd21271ca52640a6574b8d895b9247aae` |

---

## 五、注意事项

- **分卷不可单独解压**，`.001` 不是独立压缩包，必须凑齐 5 个再合并。
- 本仓库以 GitHub 作为临时存储桶，Release 附件**可能随时被删除**，需要长期保存请自行备份。
- 包内 Unity Hub、Unity 编辑器等软件的著作权归 Unity Technologies 及各厂商所有，
  这里仅作个人学习与内网分发用途，请勿用于商业再分发。
- GitHub 对单账号仓库有约 1 GB 的软性存储建议值，本仓库远超该建议值，
  因此 Release 内容随时可能失效。
