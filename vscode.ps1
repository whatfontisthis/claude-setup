# ============================================================
# VS Code 설치 + 확장 + 설정 (Windows PowerShell) — 선택 사항
# 사용법: irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/vscode.ps1 | iex
# ============================================================

# install.ps1 과 같은 이유로 exit 와 Stop 을 쓰지 않는다
$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

function Write-Step {
    param([int]$Num, [int]$Total, [string]$Message)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host "[$Num/$Total] $Message" -ForegroundColor White
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

function Test-Command {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Update-SessionPath {
    $machine = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    $user = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $env:PATH = "$machine;$user"
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
    if ($env:SCOOP) { $candidates += "$env:SCOOP\apps\vscode\current\bin" }

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
Write-Host "VS Code 설치를 시작합니다" -ForegroundColor White
Write-Host ""

$total = 2

# ── 1. VS Code ──
Write-Step -Num 1 -Total $total -Message "VS Code"

if (Resolve-VSCodePath) {
    Write-Skip "VS Code"
} else {
    Write-Host "  VS Code를 설치합니다..."

    if (Test-Command "winget") {
        # --scope user로 관리자 권한(UAC) 없이 설치
        & winget install --id Microsoft.VisualStudioCode -e --scope user --accept-source-agreements --accept-package-agreements
    } elseif (Test-Command "scoop") {
        & scoop bucket add extras
        & scoop install vscode
    }

    Update-SessionPath
    if (Resolve-VSCodePath) {
        Write-Ok "VS Code 설치 완료"
    } else {
        Write-Host "  ✗ VS Code 자동 설치 실패. 지금 열리는 페이지에서 받아 설치한 뒤, 이 명령어를 다시 실행해주세요." -ForegroundColor Red
        Start-Process "https://code.visualstudio.com/download"
    }
}

# ── 2. VS Code 설정 (Extensions + settings.json + keybindings.json) ──
Write-Step -Num 2 -Total $total -Message "VS Code 설정"

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
    # code.ps1 대신 code.cmd 를 불러 실행 정책과 상관없이 동작하게 한다
    $installed = @(& code.cmd --list-extensions 2>$null)
    foreach ($ext in $extensions) {
        if ($installed -contains $ext) {
            Write-Host "    → $ext (이미 설치됨, 스킵)" -ForegroundColor Yellow
        } else {
            Write-Host "    → $ext"
            & code.cmd --install-extension $ext --force | Out-Null
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

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host "  VS Code 설치가 끝났습니다" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host ""
