<#
.SYNOPSIS
    下载 Unity 6 国际版整合包（36 个分卷）→ 校验 → 合并 → 解压

.DESCRIPTION
    Unity 6 整合包被切成 36 个分卷放在 GitHub Release 上（原始 zip 5.33 GB）。
    本脚本负责：批量下载（多镜像 + 并发 + 断点续传）→ SHA-256 逐卷校验
    → 按序二进制合并 → 校验总大小 → 自动解压。

.PARAMETER Destination
    下载/解压到哪个目录，默认当前目录。目录不存在会自动创建。

.PARAMETER Concurrency
    并发下载数，1-16，默认 6。线路差可调低，线路好可调高。

.PARAMETER Mirror
    auto（默认，测速后自动选最快的）/ tvv / wk / direct（直连）。

.PARAMETER SkipExtract
    只下载并合并成 zip，不自动解压。

.PARAMETER KeepParts
    解压成功后保留 36 个分卷（默认会删掉以省磁盘）。

.PARAMETER DryRun
    只做镜像测速并打印计划，不下载。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\download_and_extract.ps1 -Destination D:\Unity6

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\download_and_extract.ps1 -Destination D:\Unity6 -Concurrency 10 -Mirror tvv
#>
[CmdletBinding()]
param(
    [string]$Destination = (Get-Location).Path,
    [ValidateRange(1, 16)][int]$Concurrency = 6,
    [ValidateSet('auto', 'tvv', 'wk', 'direct')][string]$Mirror = 'auto',
    [switch]$SkipExtract,
    [switch]$KeepParts,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------- 配置
$TAG       = 'v1.0.0'
$REPO      = 'https://github.com/annoy-cell/unity6-intl-bundle'
$REL       = "$REPO/releases/download/$TAG"
$TOTAL     = 5327028600
$ZIPNAME   = 'unity6-intl-bundle.zip'
$EXTRACTED = '国际版 UnityHub 和 Unity6编辑器 及教程'

# 分卷清单：名称|字节数|SHA-256
$Spec = @(
    'part-001|33554432|a6790226d41dcd3b718c63d41ed7a652282ce55707d6126931134ba7cc68793c'
    'part-002|33554432|7b9f05ae730927379c8d843feac16bb5c25e20d04275d7f5ecd990749e703938'
    'part-003|33554432|3e264b439bf35e047af42a30046258d882dbd2bcd98f4ab2a0515d30ebf49de2'
    'part-004|33554432|5b8fbbac6d9794cb1667d541594c8e156e1d3cf4e0f814e27805de463301a6ca'
    'part-005|33554432|657dabb7162fa2706672c5cd1a2a779cf3c69cb848133c11f1834bf5c5273215'
    'part-006|33554432|4469b66c09e5af783e1a4d86ad75ad9ffbe5f87e40b173541c9128d3efa54091'
    'part-007|33554432|749d8862f100cbc12a125774a7006aeb8c741c1a5a51aef3685128b1294f6c10'
    'part-008|33554432|271247186d8b1bd94583a8e4a15f7d5ca9dbf73a9a777e0847a722f53980fee0'
    'part-009|33554432|a9c83f73a95d7050459b0d9138c69555b7e575f1aba5ce9441c50e268e588f2c'
    'part-010|33554432|95f969b71989c13888b796f713a23911e810f99fa9cd4b3610efd22b09c650bc'
    'part-011|33554432|63d477c342aa57db51b19ec28a314ad3a25f8b4e452e28ddeb7870b610b5aa75'
    'part-012|33554432|079efbccf0fbeb177aac71c251a66fec94522e7bc0593f32776fd955e832bab8'
    'part-013|33554432|c02481c033ff7c6362aa40f89814668f561d3a89dc99908f4b7d50fae5cb440c'
    'part-014|33554432|3173b13785f6e95eafec3e9ebfc2b3e78303a84752f44d837c2fe32c7b34c4eb'
    'part-015|33554432|44da098d1d51a2071a2e248c9601e131a1c4111892657a501eb7e7dc82c79d63'
    'part-016|33554432|4ce96defb47ea9b81fa5baa34745431d439e28b34e9c3d750931da2e63391291'
    'part-017|33554432|20090f4a766c71631ed3181a550b631127314355ac558788d2d1ecd86b7f69a8'
    'part-018|33554432|bbb89c9965d869f118b284e66fb74761335d29b216bebc10ab720d24687665c5'
    'part-019|33554432|f6ac2cf5ca86758702446adf6dce114944d7c3f37ca54eb07e3563558c3ec1e9'
    'part-020|33554432|bd92d8b54d82ba4c5cffa053e79484d2ee0db814ef1ca9d60f120c00214518ca'
    'part-021|33554432|433f04816903c1e1f0631a05650f5c28b7fc4bfb3ded1f0de31e187bbe0f5fd5'
    'part-022|33554432|32893c2bcbc9154e70d083214a5ec60221d31df12c9bb72ca1c711fa81c3916e'
    'part-023|33554432|b889a1e49e9d53f91ced18019f623f9ed1c6bfe5c1aac98ea145333551a6003b'
    'part-024|33554432|3b3e239c0f6917c127a58f4f704d1073bd64cae311f06005938748676271cda1'
    'part-025|33554432|08b0f97076aa03992683eae3e759dada501aef3209962025a253a0162b584431'
    'part-026|33554432|a180d33f01793c0638956410a5268ec895804d865159174432045afbcb017293'
    'part-027|33554432|52b4350ee4a6b26050394cfd939be03669f59e9e42cf735cd64e30c75668e9b6'
    'part-028|33554432|416d4885217b276abe0fc2bddb0a8bcc1e598a588e66a872bdd9990a10979192'
    'part-029|33554432|2e1a0b344db4c679392d1653a8a7e68b843a2d2648d35415130e5fe16164a0d0'
    'part-030|33554432|d6f266a5bd623b92e5b980f5de0b2d1f17d04f86b0f073d4f7323b78ea409b36'
    'part-031|33554432|32e71e56a47dc3884ad45fa025bf00cf4ebf99f9e17132dd84edda7633cddc4a'
    'part-032|33554432|b6369ee118630f3f606ad15d4fd1e90ae01b42715a0504264a151b74924daeba'
    'part-033|1073741824|f327d94d8943fd9faab5deefc844d29b937624afbdf41c6acf3da5607bf43b48'
    'part-034|1073741824|f93d7da101f4cff8509fa32f1e8b1b69b7ec50e0d349f81497f82464e6bf2f49'
    'part-035|1073741824|b4588ae5cbae93f599020e6a3f5471355ce02d16940337b40e329414017449c6'
    'part-036|1032061304|bb36e19255253f52779cbb1e42a02f6fd21271ca52640a6574b8d895b9247aae'
)

# 镜像前缀（拼在 GitHub 正式链接前面）
$MirrorTable = [ordered]@{
    tvv    = 'https://tvv.tw/'
    wk     = 'https://wk.dbtemper.com/'
    direct = ''
}

$Parts = @()
foreach ($line in $Spec) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $f = $line.Split('|')
    $Parts += [pscustomobject]@{
        Name = $f[0]
        Size = [int64]$f[1]
        Hash = $f[2].ToLower()
    }
}

# ---------------------------------------------------------------- 输出helper
function Info($m) { Write-Host $m -ForegroundColor Gray }
function Ok($m)   { Write-Host $m -ForegroundColor Green }
function Warn($m) { Write-Host $m -ForegroundColor Yellow }
function Fail($m) { Write-Host $m -ForegroundColor Red }

# ---------------------------------------------------------------- 测速选镜像
function Test-Mirror {
    param([string]$prefix)
    $probe = "$prefix$REL/part-001"
    $r = & curl.exe -s -L -o NUL --connect-timeout 15 --max-time 45 -r 0-1048575 `
         -w '%{http_code} %{speed_download}' $probe 2>$null
    if (-not $r) { return $null }
    $p = "$r".Trim().Split(' ')
    if ($p.Count -lt 2) { return $null }
    if ($p[0] -notmatch '^(200|206)$') { return $null }
    return [double]$p[1]
}

$order = switch ($Mirror) {
    'tvv'    { @('tvv') }
    'wk'     { @('wk') }
    'direct' { @('direct') }
    default  { @('tvv', 'wk', 'direct') }
}

Info "正在测速镜像（最多 15 秒/个）..."
$usable = @()
foreach ($k in $order) {
    $prefix = $MirrorTable[$k]
    $label = if ($prefix) { $k } else { 'direct' }
    $spd = Test-Mirror $prefix
    if ($null -eq $spd) {
        Warn ("  {0,-7} 不可用" -f $label)
    } else {
        Ok ("  {0,-7} 可用  {1:N0} KB/s" -f $label, ($spd / 1KB))
        $usable += [pscustomobject]@{ Key = $label; Prefix = $prefix; Speed = $spd }
    }
}
if ($usable.Count -eq 0) {
    Fail '所有下载通道都不可用。请检查网络，或换 -Mirror 参数再试。'
    exit 1
}
$usable = @($usable | Sort-Object Speed -Descending)
Ok ("已选定通道: " + (($usable | ForEach-Object { $_.Key }) -join ' > '))

# ---------------------------------------------------------------- 准备目录
if (-not (Test-Path -LiteralPath $Destination)) {
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Info "已创建目录: $Destination"
}
$Destination = (Resolve-Path -LiteralPath $Destination).Path
$destParts = Join-Path $Destination 'parts'
if (-not (Test-Path -LiteralPath $destParts)) { New-Item -ItemType Directory -Force -Path $destParts | Out-Null }

try {
    $drive = (Get-Item -LiteralPath $Destination).PSDrive
    if ($drive -and $drive.Free -gt 0 -and $drive.Free -lt 12GB) {
        Warn ("该磁盘剩余 {0:N1} GB，合并+解压约需 11 GB，可能不够。" -f ($drive.Free / 1GB))
    }
} catch { }

Info ""
Info ("下载目录: $destParts")
Info ("分卷数量: {0}    合计: {1:N0} 字节（{2:N2} GiB）" -f $Parts.Count, $TOTAL, ($TOTAL / 1GB))
Info ("并发数  : {0}    镜像: {1}" -f $Concurrency, (($usable | ForEach-Object { $_.Key }) -join ' > '))
Info ""

if ($DryRun) {
    foreach ($p in $Parts) { Info ("  {0}  {1,12:N0}" -f $p.Name, $p.Size) }
    Ok 'DryRun 结束，未下载任何文件。'
    exit 0
}

# ---------------------------------------------------------------- 单卷下载
function Start-Part {
    param($Part, [string]$Prefix)
    $path = Join-Path $destParts $Part.Name
    $url  = "$Prefix$REL/$($Part.Name)"
    $err  = Join-Path $env:TEMP ("dsh_dl_" + $Part.Name + ".err")
    $arg  = @(
        '-s', '-S', '-L',
        '-C', '-',
        '--retry', '20', '--retry-delay', '3', '--retry-all-errors',
        '--connect-timeout', '30',
        '--speed-limit', '2048', '--speed-time', '120',
        '-o', ('"' + $path + '"'),
        ('"' + $url + '"')
    ) -join ' '
    return Start-Process -FilePath 'curl.exe' -ArgumentList $arg -NoNewWindow -PassThru `
        -RedirectStandardError $err |
        Select-Object @{n='Part';e={$Part}}, @{n='Proc';e={$_}}, @{n='Err';e={$err}}, @{n='Path';e={$path}}
}

# ---------------------------------------------------------------- 下载队列（大卷优先，尾部带宽不会闲置）
$queue = New-Object System.Collections.Queue
foreach ($p in ($Parts | Sort-Object Size -Descending)) { $queue.Enqueue($p) }

$running  = @{}
$doneCnt  = 0
$failCnt  = 0
$failed   = New-Object System.Collections.ArrayList
$swAll    = [Diagnostics.Stopwatch]::StartNew()
$mi       = 0

Info "开始下载..."
while ($queue.Count -gt 0 -or $running.Count -gt 0) {
    while ($running.Count -lt $Concurrency -and $queue.Count -gt 0) {
        $part = $queue.Dequeue()
        $prefix = $usable[$mi % $usable.Count].Prefix
        $mi++
        try {
            $job = Start-Part -Part $part -Prefix $prefix
            $running[$job.Proc.Id] = $job
        } catch {
            Warn ("  启动失败: {0}  {1}" -f $part.Name, $_.Exception.Message)
            [void]$failed.Add($part)
        }
    }

    Start-Sleep -Milliseconds 400

    foreach ($pid2 in @($running.Keys)) {
        $job = $running[$pid2]
        if (-not $job.Proc.HasExited) { continue }

        $p = $job.Part
        $ok = $false
        if (Test-Path -LiteralPath $job.Path) {
            $len = (Get-Item -LiteralPath $job.Path).Length
            $ok = ($len -eq $p.Size)
        }
        $doneCnt++
        if ($ok) {
            Ok ("  [{0}/{1}] {2}  {3:N0} 字节" -f $doneCnt, $Parts.Count, $p.Name, $p.Size)
        } else {
            $failCnt++
            $got = 'missing'
            if (Test-Path -LiteralPath $job.Path) { $got = (Get-Item -LiteralPath $job.Path).Length }
            $msg = ''
            if (Test-Path -LiteralPath $job.Err) {
                $msg = ([string](Get-Content -LiteralPath $job.Err -Raw -ErrorAction SilentlyContinue)) -replace '\s+', ' '
                if ($msg.Length -gt 160) { $msg = $msg.Substring(0, 160) }
            }
            Warn ("  [{0}/{1}] {2} 不完整（{3}/{4}）{5}" -f $doneCnt, $Parts.Count, $p.Name, $got, $p.Size, $msg)
            [void]$failed.Add($p)
        }
        $running.Remove($pid2)
    }
}

# ---------------------------------------------------------------- 校验 + 补下
function Get-Sha($path) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower() }

$round = 1
while ($round -le 4) {
    Info ""
    Info "=== 第 $round 轮校验 ==="
    $bad = @()
    foreach ($p in $Parts) {
        $path = Join-Path $destParts $p.Name
        if (-not (Test-Path -LiteralPath $path)) { $bad += $p; continue }
        $len = (Get-Item -LiteralPath $path).Length
        if ($len -ne $p.Size) {
            Warn ("  {0} 大小不符: {1} / {2}" -f $p.Name, $len, $p.Size)
            Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
            $bad += $p
            continue
        }
        if ((Get-Sha $path) -ne $p.Hash) {
            Warn ("  {0} 哈希不符，重新下载" -f $p.Name)
            Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
            $bad += $p
            continue
        }
    }

    if ($bad.Count -eq 0) { Ok ("全部 {0} 个分卷校验通过" -f $Parts.Count); break }

    Fail ("有 {0} 个分卷需要重下: {1}" -f $bad.Count, (($bad | ForEach-Object { $_.Name }) -join ', '))
    if ($round -eq 4) { Fail '重试次数用尽。请保留 parts 目录，稍后再跑一次本脚本（会断点续传/只补缺失的）。'; exit 1 }

    foreach ($p in $bad) {
        $prefix = $usable[(($round - 1) % $usable.Count)].Prefix
        Info ("  重新下载 {0} ..." -f $p.Name)
        $job = Start-Part -Part $p -Prefix $prefix
        $job.Proc.WaitForExit()
    }
    $round++
}

# ---------------------------------------------------------------- 合并
$zipPath = Join-Path $Destination $ZIPNAME
Info ""
Info ("正在合并 {0} 个分卷 → {1}" -f $Parts.Count, $ZIPNAME)
if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }

$out = [IO.File]::Create($zipPath)
$buf = New-Object byte[] (8MB)
$written = 0L
try {
    foreach ($p in $Parts) {
        $path = Join-Path $destParts $p.Name
        $in = [IO.File]::OpenRead($path)
        try {
            while ($true) {
                $n = $in.Read($buf, 0, $buf.Length)
                if ($n -le 0) { break }
                $out.Write($buf, 0, $n)
                $written += $n
            }
        } finally { $in.Close() }
    }
} finally { $out.Close() }

if ($written -ne $TOTAL) {
    Fail ("合并后大小不对: {0:N0} / {1:N0}" -f $written, $TOTAL)
    exit 1
}
Ok ("合并完成: {0}  {1:N0} 字节（校验通过）" -f $zipPath, $written)

# ---------------------------------------------------------------- 解压
if ($SkipExtract) {
    Ok '已跳过解压（-SkipExtract）。'
} else {
    Info ''
    Info '正在解压（5 GB，需要几分钟）...'
    Push-Location -LiteralPath $Destination
    try {
        $tarCmd = Get-Command tar -ErrorAction SilentlyContinue
        $exOk = $false
        if ($tarCmd) {
            & tar -xf $ZIPNAME
            $exOk = (Test-Path -LiteralPath (Join-Path $Destination $EXTRACTED))
        }
        if (-not $exOk) {
            Info '  改用 PowerShell 解压（较慢）...'
            Expand-Archive -LiteralPath $zipPath -DestinationPath $Destination -Force
            $exOk = (Test-Path -LiteralPath (Join-Path $Destination $EXTRACTED))
        }
        if ($exOk) { Ok ("解压完成: " + (Join-Path $Destination $EXTRACTED)) }
        else { Fail '解压失败，请手动用 7-Zip 解压目录下的 zip。'; exit 1 }
    } finally { Pop-Location }
}

# ---------------------------------------------------------------- 收尾
if (-not $KeepParts -and -not $SkipExtract) {
    Info ''
    Info '清理分卷...'
    Remove-Item -LiteralPath $destParts -Recurse -Force -ErrorAction SilentlyContinue
    Ok '已删除 parts 目录（想保留请下次加 -KeepParts）'
}

$swAll.Stop()
Info ''
Ok ("全部完成，耗时 {0:N1} 分钟。" -f $swAll.Elapsed.TotalMinutes)
Info ("产物: " + $Destination)
