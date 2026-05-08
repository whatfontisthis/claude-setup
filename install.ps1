# ============================================================
# 클로드 코드 올인원 설치 스크립트 (Windows PowerShell)
# 사용법: irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

# ── 색상 함수 ──
function Write-Step {
    param([int]$Num, [int]$Total, [string]$Message)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host "[$Num/$Total] $Message" -ForegroundColor White -NoNewline
    Write-Host "" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
}

function Write-Ok {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Skip {
    param([string]$Message)
    Write-Host "  → $Message (이미 설치됨, 스킵)" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  ✗ $Message" -ForegroundColor Red
    exit 1
}

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Refresh-Path {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
}

# VS Code 설치 후 PATH에 안 잡힐 때 일반 설치 경로를 직접 찾아 현재 세션 PATH에 주입
function Resolve-VSCodePath {
    if (Test-Command "code") { return $true }

    $candidates = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin",
        "$env:ProgramFiles\Microsoft VS Code\bin",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\bin",
        "$HOME\scoop\apps\vscode\current\bin"
    )

    foreach ($bin in $candidates) {
        if ($bin -and (Test-Path "$bin\code.cmd")) {
            $env:PATH = "$bin;$env:PATH"
            if (Test-Command "code") { return $true }
        }
    }
    return $false
}

# 기존 파일을 타임스탬프 백업본으로 보존한 뒤 덮어쓰기 안전성 확보
function Backup-IfExists {
    param([string]$Path)
    if (Test-Path $Path) {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupPath = "$Path.bak.$stamp"
        Copy-Item -Path $Path -Destination $backupPath -Force
        Write-Host "    → 기존 파일 백업: $backupPath" -ForegroundColor Yellow
    }
}

# PowerShell 5.1의 Out-File -Encoding utf8은 BOM을 포함시킨다. JSON 파서 호환성 위해 BOM 없는 UTF-8로 기록
function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

Write-Host ""
Write-Host "🚀 클로드 코드 올인원 설치를 시작합니다" -ForegroundColor White
Write-Host "   Windows $([System.Environment]::OSVersion.Version)" -ForegroundColor Gray
Write-Host ""

$total = 8
$step = 0

# ── 1. Scoop (패키지 매니저) ──
$step++
Write-Step -Num $step -Total $total -Message "Scoop (패키지 매니저)"

if (Test-Command "scoop") {
    Write-Skip "Scoop"
} else {
    Write-Host "  Scoop를 설치합니다..."

    # Scoop 설치에 필요한 실행 정책 설정
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

    # Scoop 설치
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

    Refresh-Path

    if (Test-Command "scoop") {
        Write-Ok "Scoop 설치 완료"
    } else {
        Write-Fail "Scoop 설치에 실패했습니다. PowerShell을 재시작한 뒤 다시 시도해주세요."
    }
}

# ── 2. Node.js ──
$step++
Write-Step -Num $step -Total $total -Message "Node.js"

if (Test-Command "node") {
    $nodeVer = node -v
    Write-Skip "Node.js $nodeVer"
} else {
    Write-Host "  Node.js를 설치합니다..."
    scoop install nodejs

    Refresh-Path

    $nodeVer = node -v
    Write-Ok "Node.js $nodeVer 설치 완료"
}

# ── 3. Python 3 ──
$step++
Write-Step -Num $step -Total $total -Message "Python 3"

if (Test-Command "python") {
    $pyVer = & { $ErrorActionPreference = 'SilentlyContinue'; (python --version 2>&1) -join '' }
    Write-Skip "$pyVer"
} elseif (Test-Command "python3") {
    $pyVer = & { $ErrorActionPreference = 'SilentlyContinue'; (python3 --version 2>&1) -join '' }
    Write-Skip "$pyVer"
} else {
    Write-Host "  Python 3를 설치합니다..."
    scoop install python

    Refresh-Path

    $pyVer = & { $ErrorActionPreference = 'SilentlyContinue'; (python --version 2>&1) -join '' }
    Write-Ok "$pyVer 설치 완료"
}

# ── 4. Git ──
$step++
Write-Step -Num $step -Total $total -Message "Git"

if (Test-Command "git") {
    $gitVer = git --version
    Write-Skip "$gitVer"
} else {
    Write-Host "  Git을 설치합니다..."
    scoop install git

    Refresh-Path

    $gitVer = git --version
    Write-Ok "$gitVer 설치 완료"
}

# ── 5. GitHub CLI ──
$step++
Write-Step -Num $step -Total $total -Message "GitHub CLI"

if (Test-Command "gh") {
    $ghVer = (gh --version | Select-Object -First 1)
    Write-Skip "$ghVer"
} else {
    Write-Host "  GitHub CLI를 설치합니다..."
    scoop install gh

    Refresh-Path

    $ghVer = (gh --version | Select-Object -First 1)
    Write-Ok "$ghVer 설치 완료"
}

# ── 6. Claude Code ──
$step++
Write-Step -Num $step -Total $total -Message "Claude Code"

if (Test-Command "claude") {
    Write-Skip "Claude Code"
} else {
    Write-Host "  Claude Code를 설치합니다..."

    # winget으로 설치 (Windows 10+ 기본 내장). --scope user로 UAC 회피
    if (Test-Command "winget") {
        winget install --id Anthropic.ClaudeCode -e --scope user --accept-source-agreements --accept-package-agreements
    } else {
        # winget 없으면 npm 폴백
        npm install -g @anthropic-ai/claude-code
    }

    Refresh-Path

    Write-Ok "Claude Code 설치 완료"
}

# ── 7. VS Code ──
$step++
Write-Step -Num $step -Total $total -Message "VS Code"

if (Test-Command "code") {
    Write-Skip "VS Code"
} else {
    Write-Host "  VS Code를 설치합니다..."

    if (Test-Command "winget") {
        # --scope user로 관리자 권한(UAC) 없이 설치
        winget install Microsoft.VisualStudioCode -e --scope user --accept-source-agreements --accept-package-agreements
    } else {
        # winget 없으면 scoop extras 폴백
        scoop bucket add extras 2>$null
        scoop install vscode
    }

    Refresh-Path
    [void](Resolve-VSCodePath)

    Write-Ok "VS Code 설치 완료"
}

# ── 8. VS Code 설정 (Extensions + settings.json + keybindings.json) ──
$step++
Write-Step -Num $step -Total $total -Message "VS Code 설정"

if (-not (Resolve-VSCodePath)) {
    Write-Host "  ! VS Code (code 명령)를 PATH에서 찾지 못했습니다." -ForegroundColor Yellow
    Write-Host "    설치 직후라면 새 PowerShell 창에서 다시 실행해주세요." -ForegroundColor Yellow
    Write-Host "    그래도 안 되면 VS Code를 한 번 실행해 PATH 통합을 완료해주세요." -ForegroundColor Yellow
} else {
    # Extensions (이미 설치된 것은 스킵)
    $extensions = @(
        "anthropic.claude-code",
        "bierner.markdown-mermaid",
        "cweijan.vscode-office",
        "gabrielgrinberg.auto-run-command",
        "gera2ld.markmap-vscode",
        "peakchen90.open-html-in-browser",
        "pkief.material-icon-theme",
        "tomoki1207.pdf"
    )

    Write-Host "  Extensions 설치 중..."
    $installed = @(code --list-extensions 2>$null)
    foreach ($ext in $extensions) {
        if ($installed -contains $ext) {
            Write-Host "    → $ext (이미 설치됨, 스킵)" -ForegroundColor Yellow
        } else {
            Write-Host "    → $ext"
            code --install-extension $ext --force | Out-Null
        }
    }
    Write-Ok "Extensions 처리 완료"

    # settings.json
    $settingsDir = "$env:APPDATA\Code\User"
    if (!(Test-Path $settingsDir)) {
        New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
    }

    $settingsPath = "$settingsDir\settings.json"
    Backup-IfExists $settingsPath
    $settings = @'
{
  // Terminal settings
  "terminal.integrated.defaultProfile.windows": "PowerShell",
  "terminal.integrated.mouseWheelZoom": true,
  // Editor settings
  "editor.fontSize": 16,
  "editor.minimap.enabled": false,
  "editor.mouseWheelZoom": true,
  "editor.autoClosingQuotes": "never",
  "editor.parameterHints.enabled": true,
  // File settings
  "files.autoSave": "off",
  // Extensions and other settings
  "explorer.confirmDelete": false,
  "workbench.iconTheme": "material-icon-theme",
  "workbench.startupEditor": "none",
  "update.showReleaseNotes": false,
  "editor.quickSuggestions": {
    "strings": "on"
  },
  "terminal.integrated.focusAfterRun": "terminal",
  "terminal.integrated.inheritEnv": true,
  "python.terminal.activateEnvironment": true,
  "editor.formatOnSave": true,
  "editor.accessibilitySupport": "on",
  "github.copilot.enable": {
    "*": false
  },
  "git.openRepositoryInParentFolders": "never",
  "html.autoCreateQuotes": false,
  "editor.autoClosingBrackets": "always",
  "editor.indentSize": "tabSize",
  "editor.tabSize": 4,
  "editor.detectIndentation": true,
  "[jsonc]": {
    "editor.defaultFormatter": "vscode.json-language-features"
  },
  "security.workspace.trust.banner": "never",
  "claudeCode.preferredLocation": "sidebar",
  "security.allowedUNCHosts": [
    "wsl.localhost"
  ],
  "explorer.fileNesting.patterns": {
    "*.ts": "${capture}.js",
    "*.js": "${capture}.js.map, ${capture}.min.js, ${capture}.d.ts",
    "*.jsx": "${capture}.js",
    "*.tsx": "${capture}.ts",
    "tsconfig.json": "tsconfig.*.json",
    "package.json": "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb, bun.lock",
    "pubspec.yaml": "pubspec.lock,pubspec_overrides.yaml,.packages,.flutter-plugins,.flutter-plugins-dependencies,.metadata",
    "*.dart": "${capture}.g.dart",
    "*.sqlite": "${capture}.${extname}-*",
    "*.db": "${capture}.${extname}-*",
    "*.sqlite3": "${capture}.${extname}-*",
    "*.db3": "${capture}.${extname}-*",
    "*.sdb": "${capture}.${extname}-*",
    "*.s3db": "${capture}.${extname}-*"
  },
  "workbench.editorAssociations": {
    "*.md": "vscode.markdown.preview.editor"
  },
  "claudeCode.allowDangerouslySkipPermissions": true,
  "files.exclude": {
    "**/.git": false,
    "**/*.log": true,
    "**/.gitignore": true
  },
  "material-icon-theme.folders.theme": "classic",
  "window.restoreWindows": "preserve",
  "window.restoreFullscreen": true,
  "claudeCode.initialPermissionMode": "bypassPermissions",
  "terminal.integrated.fontSize": 14,
  "explorer.confirmDragAndDrop": false,
  "claudeCode.useTerminal": true,
  "workbench.secondarySideBar.defaultVisibility": "visibleInWorkspace",
  "auto-run-command.rules": [
    {
      "condition": "always",
      "command": "claude-vscode.sidebar.open",
      "delay": 2000
    }
  ],
  "extensions.ignoreRecommendations": true
}
'@

    Write-Utf8NoBom -Path $settingsPath -Content $settings
    Write-Ok "settings.json 저장됨"

    # keybindings.json
    $keybindingsPath = "$settingsDir\keybindings.json"
    Backup-IfExists $keybindingsPath
    $keybindings = @'
// Place your key bindings in this file to override the defaults
[
    {
        "key": "ctrl+o",
        "command": "-workbench.action.files.openFile",
        "when": "true"
    },
    {
        "key": "ctrl+o",
        "command": "-workbench.action.files.openFileFolder",
        "when": "isMacNative && openFolderWorkspaceSupport"
    },
    {
        "key": "ctrl+o",
        "command": "-workbench.action.files.openLocalFile",
        "when": "remoteFileDialogVisible"
    },
    {
        "key": "ctrl+o",
        "command": "-workbench.action.files.openFolderViaWorkspace",
        "when": "!openFolderWorkspaceSupport && workbenchState == 'workspace'"
    },
    {
        "key": "ctrl+k ctrl+o",
        "command": "-workbench.action.files.openFolder",
        "when": "openFolderWorkspaceSupport"
    },
    {
        "key": "ctrl+k ctrl+o",
        "command": "-workbench.action.files.openLocalFolder",
        "when": "remoteFileDialogVisible"
    },
    {
        "key": "ctrl+o",
        "command": "workbench.action.files.openFolder"
    },
    {
        "key": "ctrl+1",
        "command": "openInDefaultBrowser.openInDefaultBrowser"
    }
]
'@

    Write-Utf8NoBom -Path $keybindingsPath -Content $keybindings
    Write-Ok "keybindings.json 저장됨"
}

# ── 완료 ──
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host "  ✅ 설치가 모두 완료되었습니다!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host ""
Write-Host "  설치된 항목:" -ForegroundColor White

# 버전 출력은 native command error 무시 (stderr 병합 시 PowerShell이 throw 방지)
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = "Continue"
if ($PSVersionTable.PSVersion.Major -ge 7) { $PSNativeCommandUseErrorActionPreference = $false }

function Get-CmdVersion {
    param([scriptblock]$Block)
    try { (& $Block 2>&1 | Out-String).Trim() } catch { "" }
}

if (Test-Command "scoop") { Write-Host "  ✓ Scoop" -ForegroundColor Green }
if (Test-Command "node") { Write-Host "  ✓ Node.js   $(Get-CmdVersion { node -v })" -ForegroundColor Green }
if (Test-Command "python") {
    $pySrc = (Get-Command python -ErrorAction SilentlyContinue).Source
    if ($pySrc -and $pySrc -notmatch "WindowsApps") {
        $pyVer = Get-CmdVersion { python --version }
        if ($pyVer) { Write-Host "  ✓ Python    $pyVer" -ForegroundColor Green }
    }
}
if (Test-Command "git") { Write-Host "  ✓ Git       $(Get-CmdVersion { git --version })" -ForegroundColor Green }
if (Test-Command "gh") {
    $ghVer = Get-CmdVersion { gh --version | Select-Object -First 1 }
    Write-Host "  ✓ GitHub CLI $ghVer" -ForegroundColor Green
}
if (Test-Command "claude") { Write-Host "  ✓ Claude Code" -ForegroundColor Green }
if (Test-Command "code") { Write-Host "  ✓ VS Code" -ForegroundColor Green }

$ErrorActionPreference = $prevEAP

Write-Host ""
Write-Host "  다음 단계:" -ForegroundColor White
Write-Host "  터미널에 " -NoNewline
Write-Host "claude" -ForegroundColor Yellow -NoNewline
Write-Host " 를 입력하면 클로드 코드가 실행됩니다."
Write-Host "  처음 실행하면 Anthropic 계정 연결을 안내합니다."
Write-Host ""
