<# 
  setup.ps1
  用法：
    1) 右键“以管理员身份运行”PowerShell
    2) 执行：  Set-ExecutionPolicy Bypass -Scope Process -Force
    3) 运行：  .\setup.ps1
       或者： .\setup.ps1 -Upgrade   # 已装则尝试升级

  提示：Xbox App / Xbox 配件 等来自 Microsoft Store，winget 可能要求登录 MS 账号。
#>

[CmdletBinding()]
param(
  [switch]$Upgrade
)

function Test-Admin {
  $current = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($current)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
  Write-Warning "建议以管理员身份运行 PowerShell（右键→以管理员身份运行），否则某些安装可能失败或频繁弹 UAC。"
}

# 基础准备
Write-Host "Configuring Devices, Power, and Startup..." -ForegroundColor "Yellow"
Write-Host "🧰 初始化 winget 源..." -ForegroundColor Yellow
try {
  winget source update --accept-source-agreements | Out-Null
} catch { Write-Warning "winget 源更新失败：$($_.Exception.Message)" }

# 安装/升级器：避免重复安装
function Install-IfMissing {
  param(
    [Parameter(Mandatory=$true)][string]$Id,
    [string]$DisplayName
  )

  if (-not $DisplayName) { $DisplayName = $Id }

  # 检查是否已安装（winget list 返回里包含该 Id 即视为已安装）
  $installed = winget list --id $Id --exact --accept-source-agreements 2>$null | Select-String -SimpleMatch $Id

  if ($installed) {
    Write-Host "✔ 已安装：$DisplayName（$Id）" -ForegroundColor Green
    if ($using:Upgrade) {
      Write-Host "↻ 尝试升级：$DisplayName" -ForegroundColor Yellow
      winget upgrade --id $Id --exact --silent --accept-package-agreements --accept-source-agreements
      if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 升级完成：$DisplayName" -ForegroundColor Green
      } else {
        Write-Host "ℹ️ 无可用升级或升级失败（退出码 $LASTEXITCODE）：$DisplayName" -ForegroundColor DarkYellow
      }
    }
  } else {
    Write-Host "↓ 正在安装：$DisplayName" -ForegroundColor Yellow
    winget install --id $Id --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
      Write-Host "✅ 安装完成：$DisplayName" -ForegroundColor Green
    } else {
      Write-Host "❌ 安装失败（退出码 $LASTEXITCODE）：$DisplayName" -ForegroundColor Red
    }
  }
}

function Section {
  param([string]$Title)
  Write-Host ""
  Write-Host "================ $Title ================" -ForegroundColor Cyan
}

# -------------------------
# Google Chrome
# -------------------------
Section "浏览器"
Install-IfMissing -Id "Google.Chrome" -DisplayName "Google Chrome"

# -------------------------
# 游戏
# -------------------------
Section "游戏平台 / 游戏服务"
Install-IfMissing -Id "Valve.Steam"                        -DisplayName "Steam"
Install-IfMissing -Id "ElectronicArts.EADesktop"           -DisplayName "EA App"
Install-IfMissing -Id "EpicGames.EpicGamesLauncher"        -DisplayName "Epic Games Launcher"
Install-IfMissing -Id "Microsoft.XboxApp"                  -DisplayName "Xbox App（Microsoft Store）"
Install-IfMissing -Id "Microsoft.XboxAccessories"          -DisplayName "Xbox 配件（手柄配对）"

# -------------------------
# 必备
# -------------------------
Section "必备工具"
# NVIDIA（注意：部分设备新版为“NVIDIA App”，此处沿用 GeForce Experience Id）
Install-IfMissing -Id "NVIDIA.GeForceExperience"           -DisplayName "NVIDIA GeForce Experience / 驱动"
# Clash
Install-IfMissing -Id "ClashVergeRev.ClashVergeRev"        -DisplayName "Clash Verge Rev"
# 微信
Install-IfMissing -Id "Tencent.WeChat"                     -DisplayName "微信"

Write-Host "⚠ 以下软件未收录 winget，请手动下载安装：UU 加速器、Myth.Cool、技嘉 Control Center" -ForegroundColor DarkYellow

# -------------------------
# 开发
# -------------------------
Section "开发环境"
Install-IfMissing -Id "JetBrains.PyCharm.Community"        -DisplayName "PyCharm Community"
Install-IfMissing -Id "Microsoft.VisualStudioCode"         -DisplayName "Visual Studio Code"
Install-IfMissing -Id "Python.Python.3.12"                 -DisplayName "Python 3.12"
Install-IfMissing -Id "Git.Git"                            -DisplayName "Git"

# -------------------------
# 外观&终端提示
# -------------------------
Section "外观与终端（手动步骤提示）"
Write-Host "🅰 Win11 字体更换 → 参考： https://juejin.cn/post/7336761948066168883" -ForegroundColor DarkCyan
Write-Host "💻 Windows Terminal 美化 → 参考： https://juejin.cn/post/7169994155643371528" -ForegroundColor DarkCyan

Write-Host ""
Write-Host "🎉 全部处理完毕。" -ForegroundColor Green


# win11换字体
# 更换为mac字体
# 参考 https://juejin.cn/post/7336761948066168883
# 需要手动操作

# win11 terminal美化
# 参考 https://juejin.cn/post/7169994155643371528