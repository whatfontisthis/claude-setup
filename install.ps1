# ============================================================
# 바이브코딩 올인원 설치 스크립트 (Windows PowerShell)
# 사용법: irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.ps1 | iex
# ============================================================

# irm | iex 로 실행되므로 exit 를 쓰면 학생의 PowerShell 창이 통째로 닫힌다.
# 그래서 중간에 멈추지 않고, 실패한 항목을 모아뒀다가 마지막에 보여준다.
# Stop 을 쓰면 native 명령의 stderr 출력이 예외로 바뀌므로(PowerShell 5.1) Continue 를 쓴다.
$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$RepoRaw = "https://raw.githubusercontent.com/whatfontisthis/claude-setup/main"
$Failures = New-Object System.Collections.ArrayList

# ── 출력 함수 ──
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

function Write-Warn {
    param([string]$Message)
    Write-Host "  ! $Message" -ForegroundColor Yellow
}

function Add-Failure {
    param([string]$Name, [string]$Hint)
    Write-Host "  ✗ $Name 실패" -ForegroundColor Red
    if ($Hint) { Write-Host "    $Hint" -ForegroundColor Yellow }
    if ($Hint) { [void]$Failures.Add("${Name}: $Hint") } else { [void]$Failures.Add($Name) }
}

# ── 유틸 ──
function Test-Command {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

# 설치 직후 새 PATH 를 현재 창에도 반영. 새 창과 같은 순서(Machine → User)로 합친다.
function Update-SessionPath {
    $machine = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    $user = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $env:PATH = "$machine;$user"
}

function Get-Version {
    param([string]$Exe, [string[]]$Arguments = @("--version"))
    try {
        $out = & $Exe @Arguments 2>&1 | Select-Object -First 1
        return ("$out").Trim()
    } catch {
        return ""
    }
}

# Windows 에는 python 을 치면 Microsoft Store 를 여는 가짜 python.exe 가 기본으로 들어 있다.
# 명령이 "존재"하는 것만 보면 설치를 건너뛰게 되므로, 실제로 버전이 나오는지 확인한다.
function Test-RealPython {
    if (-not (Test-Command "python")) { return $false }
    return ((Get-Version "python") -match "^Python 3")
}

function Get-NodeMajor {
    if (-not (Test-Command "node")) { return 0 }
    if ((Get-Version "node" @("-v")) -match "^v(\d+)") { return [int]$Matches[1] }
    return 0
}

function Get-ScoopRoot {
    if ($env:SCOOP) { return $env:SCOOP }
    return "$HOME\scoop"
}

function Install-ScoopApp {
    param([string]$App)
    if (-not (Test-Command "scoop")) { return }
    & scoop install $App
    Update-SessionPath
}

# winget 종료 코드: 0 = 설치 완료, -1978335189 = 이미 최신 버전, -1978335135 = 이미 설치됨
function Install-WingetApp {
    param([string]$Name, [string]$Id, [string]$Source, [string]$FallbackUrl)
    $wingetArgs = @("install", "--id", $Id, "-e", "--accept-source-agreements", "--accept-package-agreements")
    if ($Source) { $wingetArgs += @("--source", $Source) }

    Write-Host "  $Name 을(를) 설치합니다..."
    & winget @wingetArgs
    $code = $LASTEXITCODE

    if ($code -eq 0 -or $code -eq -1978335189 -or $code -eq -1978335135) {
        Write-Ok "$Name 준비 완료"
    } else {
        Add-Failure $Name "자동 설치가 안 됐습니다. 지금 열리는 페이지에서 직접 받아 설치해주세요."
        Start-Process $FallbackUrl
    }
}

# 일부 Windows 10 PC 에는 winget 이 깔려 있지만 사용자 계정에 등록이 안 돼 있다.
function Initialize-Winget {
    if (Test-Command "winget") { return $true }
    try {
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop
    } catch { }
    Update-SessionPath
    return (Test-Command "winget")
}

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Write-Host ""
Write-Host "바이브코딩 개발 환경 설치를 시작합니다" -ForegroundColor White
Write-Host "   Windows $([System.Environment]::OSVersion.Version) | PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host ""

# ── 설치할 AI 앱 선택 (처음에 한 번만 묻고, 이후는 자리를 비워도 끝까지 진행) ──
Write-Host "  어떤 AI 앱을 설치할까요?" -ForegroundColor White
Write-Host "    1) Claude"
Write-Host "    2) ChatGPT (Codex)"
Write-Host "    3) 둘 다"
$choice = ""
$tries = 0
while ($choice -notin @("1", "2", "3") -and $tries -lt 5) {
    $tries++
    $answer = Read-Host "  번호를 입력하고 엔터"
    if ($answer) { $choice = $answer.Trim() }
}
if ($choice -notin @("1", "2", "3")) {
    $choice = "3"
    Write-Warn "입력을 못 받아서 둘 다 설치합니다."
}
$WantClaude = ($choice -eq "1" -or $choice -eq "3")
$WantChatGPT = ($choice -eq "2" -or $choice -eq "3")

$total = 10
$step = 0

# ── 1. PowerShell 스크립트 실행 허용 ──
# 기본값(Restricted)이면 npm, vercel 같은 명령이 "스크립트를 실행할 수 없으므로..." 오류를 낸다.
# 학생이 직접 칠 때뿐 아니라 AI 앱이 대신 명령을 실행할 때도 똑같이 막히므로 여기서 풀어둔다.
$step++
Write-Step -Num $step -Total $total -Message "PowerShell 스크립트 실행 허용"

try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
} catch { }
# PowerShell 7 에서 실행했다면 Windows PowerShell(5.1)은 설정이 따로라서 한 번 더 적용
if ($PSVersionTable.PSEdition -eq "Core" -and (Test-Command "powershell.exe")) {
    & powershell.exe -NoProfile -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force" 2>$null
}
try {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction Stop
} catch { }

# 학교/회사 PC 는 그룹 정책이 위 설정을 덮어쓸 수 있다. 이 경우는 PC 관리자만 풀 수 있다.
$gpoPolicy = @((Get-ExecutionPolicy -Scope MachinePolicy), (Get-ExecutionPolicy -Scope UserPolicy)) |
    Where-Object { "$_" -ne "Undefined" } | Select-Object -First 1
if ($gpoPolicy -and "$gpoPolicy" -in @("Restricted", "AllSigned")) {
    Add-Failure "스크립트 실행 허용" "이 PC 는 관리 정책($gpoPolicy)으로 막혀 있습니다. PC 관리자에게 실행 정책을 RemoteSigned 로 바꿔달라고 요청하세요."
} else {
    Write-Ok "실행 정책: $(Get-ExecutionPolicy -Scope CurrentUser) (현재 사용자)"
}

# ── 2. Scoop (패키지 매니저) ──
# 관리자 권한 없이 사용자 폴더에 설치되고, PATH 도 알아서 등록해준다.
$step++
Write-Step -Num $step -Total $total -Message "Scoop (패키지 매니저)"

if (Test-Command "scoop") {
    Write-Skip "Scoop"
} else {
    # 사용자 폴더 이름에 한글이나 공백이 있으면 (예: C:\Users\홍길동) 일부 도구가 경로를 못 읽는다.
    # 그럴 땐 Scoop 을 C:\scoop 에 설치해 경로 문제를 피한다.
    if ($HOME -notmatch '^[A-Za-z0-9_.\-\\:]+$' -and -not $env:SCOOP) {
        try {
            New-Item -ItemType Directory -Path "C:\scoop" -Force -ErrorAction Stop | Out-Null
            $env:SCOOP = "C:\scoop"
            [System.Environment]::SetEnvironmentVariable("SCOOP", "C:\scoop", "User")
            Write-Warn "사용자 폴더 이름에 한글/공백이 있어 C:\scoop 에 설치합니다."
        } catch { }
    }

    Write-Host "  Scoop 을 설치합니다..."
    # 설치기를 별도 PowerShell 프로세스에서 돌린다. 설치기가 실패하며 멈춰도 이 창은 계속 진행된다.
    $adminArg = ""
    if ($IsAdmin) { $adminArg = "-RunAsAdmin" }
    $scoopCmd = "[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; & ([scriptblock]::Create((Invoke-RestMethod -UseBasicParsing https://get.scoop.sh))) $adminArg"
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $scoopCmd
    Update-SessionPath

    if (Test-Command "scoop") {
        Write-Ok "Scoop 설치 완료"
    } else {
        Add-Failure "Scoop" "인터넷 연결을 확인하고 새 PowerShell 창에서 다시 실행해주세요. 아래 도구 대부분이 Scoop 으로 설치되므로 같이 실패합니다."
    }
}

# ── 3. Git ──
$step++
Write-Step -Num $step -Total $total -Message "Git"

if (Test-Command "git") {
    Write-Skip (Get-Version "git")
} else {
    Install-ScoopApp "git"
    if (Test-Command "git") { Write-Ok "$(Get-Version 'git') 설치 완료" } else { Add-Failure "Git" "" }
}

if (Test-Command "git") {
    # node_modules 처럼 깊은 폴더에서 "Filename too long" 오류 방지
    & git config --global core.longpaths true
    if (-not (& git config --global init.defaultBranch)) { & git config --global init.defaultBranch main }

    # Claude 는 Windows 에서 Git Bash 로 명령을 실행한다. Scoop 으로 설치한 Git 은 위치가
    # 일반 설치와 달라 Claude 가 못 찾을 수 있으므로 bash.exe 위치를 직접 알려준다.
    $scoopBash = "$(Get-ScoopRoot)\apps\git\current\bin\bash.exe"
    if ((Test-Path $scoopBash) -and -not (Test-Path "$env:ProgramFiles\Git\bin\bash.exe")) {
        [System.Environment]::SetEnvironmentVariable("CLAUDE_CODE_GIT_BASH_PATH", $scoopBash, "User")
        $env:CLAUDE_CODE_GIT_BASH_PATH = $scoopBash
    }
}

# ── 4. Node.js (LTS) ──
# Next.js 와 Supabase CLI 는 Node.js 20 이상이 필요하다.
$step++
Write-Step -Num $step -Total $total -Message "Node.js (LTS)"

$nodeMajor = Get-NodeMajor
if ($nodeMajor -ge 20) {
    Write-Skip "Node.js $(Get-Version 'node' @('-v'))"
} else {
    if ($nodeMajor -gt 0) { Write-Warn "Node.js 버전이 너무 낮아 새로 설치합니다 ($(Get-Version 'node' @('-v')))" }
    Install-ScoopApp "nodejs-lts"
    $nodeMajor = Get-NodeMajor
    if ($nodeMajor -ge 20) {
        Write-Ok "Node.js $(Get-Version 'node' @('-v')) 설치 완료"
    } elseif ($nodeMajor -gt 0) {
        Add-Failure "Node.js" "예전 Node.js 가 먼저 잡힙니다. 설정 → 앱 → 설치된 앱에서 'Node.js' 를 제거한 뒤 다시 실행해주세요."
    } else {
        Add-Failure "Node.js" ""
    }
}

# ── 5. Python 3 + uv ──
$step++
Write-Step -Num $step -Total $total -Message "Python 3 + uv"

if (Test-RealPython) {
    Write-Skip (Get-Version "python")
} else {
    Install-ScoopApp "python"
    if (Test-RealPython) {
        Write-Ok "$(Get-Version 'python') 설치 완료"
    } else {
        Add-Failure "Python" "설정 → 앱 → 고급 앱 설정 → 앱 실행 별칭에서 'python.exe', 'python3.exe' 를 끈 뒤 다시 실행해주세요."
    }
}

# uv: AI 가 Python 프로젝트를 만들 때 가상환경과 패키지 설치를 한 번에 처리해주는 도구
if (Test-Command "uv") {
    Write-Skip (Get-Version "uv")
} else {
    Install-ScoopApp "uv"
    if (Test-Command "uv") { Write-Ok "$(Get-Version 'uv') 설치 완료" } else { Add-Failure "uv" "" }
}

# ── 6. GitHub CLI ──
$step++
Write-Step -Num $step -Total $total -Message "GitHub CLI (gh)"

if (Test-Command "gh") {
    Write-Skip (Get-Version "gh")
} else {
    Install-ScoopApp "gh"
    if (Test-Command "gh") { Write-Ok "$(Get-Version 'gh') 설치 완료" } else { Add-Failure "GitHub CLI" "" }
}

# ── 7. Supabase CLI ──
# Windows 에서는 npm 전역 설치를 지원하지 않아 Supabase 공식 Scoop 저장소로 설치한다.
$step++
Write-Step -Num $step -Total $total -Message "Supabase CLI"

if (Test-Command "supabase") {
    Write-Skip "Supabase CLI $(Get-Version 'supabase')"
} elseif (Test-Command "scoop") {
    & scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
    Install-ScoopApp "supabase"
    if (Test-Command "supabase") { Write-Ok "Supabase CLI $(Get-Version 'supabase') 설치 완료" } else { Add-Failure "Supabase CLI" "" }
} else {
    Add-Failure "Supabase CLI" "Scoop 이 없어 건너뜀"
}

# ── 8. Vercel CLI ──
$step++
Write-Step -Num $step -Total $total -Message "Vercel CLI"

if (Test-Command "vercel") {
    Write-Skip "Vercel CLI $(Get-Version 'vercel')"
} elseif (Test-Command "npm") {
    Write-Host "  Vercel CLI 를 설치합니다..."
    # npm.ps1 대신 npm.cmd 를 불러 실행 정책과 상관없이 동작하게 한다
    & npm.cmd install -g vercel
    Update-SessionPath
    if (Test-Command "vercel") { Write-Ok "Vercel CLI 설치 완료" } else { Add-Failure "Vercel CLI" "" }
} else {
    Add-Failure "Vercel CLI" "Node.js 가 없어 건너뜀"
}

# ── 9. AI 데스크톱 앱 ──
$step++
Write-Step -Num $step -Total $total -Message "AI 데스크톱 앱"

if (Initialize-Winget) {
    if ($WantClaude) {
        Install-WingetApp -Name "Claude" -Id "Anthropic.Claude" -FallbackUrl "https://claude.ai/download"
    }
    if ($WantChatGPT) {
        # Codex 는 2026년 7월부터 ChatGPT 데스크톱 앱 안에 들어 있다. 9PLM9XGG6VKS = Microsoft Store 공식 ChatGPT 앱
        Install-WingetApp -Name "ChatGPT (Codex)" -Id "9PLM9XGG6VKS" -Source "msstore" -FallbackUrl "https://get.microsoft.com/installer/download/9PLM9XGG6VKS"
    }
} else {
    if ($WantClaude) {
        Add-Failure "Claude" "winget 이 없어 자동 설치를 못 했습니다. 지금 열리는 페이지에서 받아주세요."
        Start-Process "https://claude.ai/download"
    }
    if ($WantChatGPT) {
        Add-Failure "ChatGPT (Codex)" "winget 이 없어 자동 설치를 못 했습니다. 지금 열리는 페이지에서 받아주세요."
        Start-Process "https://get.microsoft.com/installer/download/9PLM9XGG6VKS"
    }
}

# ── 10. 프로젝트 폴더 ──
# 바탕화면/문서는 OneDrive 동기화 폴더인 경우가 많아 node_modules 가 잠기거나 깨진다.
# 경로가 짧고 한글이 없는 C:\projects 를 만들어 모든 프로젝트를 여기에 둔다.
$step++
Write-Step -Num $step -Total $total -Message "프로젝트 폴더"

$ProjectsDir = "C:\projects"
try {
    New-Item -ItemType Directory -Path $ProjectsDir -Force -ErrorAction Stop | Out-Null
} catch {
    $ProjectsDir = "$HOME\projects"
    New-Item -ItemType Directory -Path $ProjectsDir -Force | Out-Null
}
Write-Ok "$ProjectsDir"

# ── 완료 ──
Update-SessionPath

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
if ($Failures.Count -eq 0) {
    Write-Host "  설치가 모두 끝났습니다" -ForegroundColor Green
} else {
    Write-Host "  설치가 끝났지만 $($Failures.Count)개 항목이 실패했습니다" -ForegroundColor Yellow
}
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host ""

function Write-Check {
    param([string]$Label, [bool]$Ok, [string]$Detail)
    if ($Ok) {
        Write-Host ("  ✓ {0,-14} {1}" -f $Label, $Detail) -ForegroundColor Green
    } else {
        Write-Host ("  ✗ {0,-14} 없음" -f $Label) -ForegroundColor Red
    }
}

Write-Check "Git" (Test-Command "git") (Get-Version "git")
Write-Check "Node.js" ((Get-NodeMajor) -ge 20) (Get-Version "node" @("-v"))
Write-Check "Python" (Test-RealPython) (Get-Version "python")
Write-Check "uv" (Test-Command "uv") (Get-Version "uv")
Write-Check "GitHub CLI" (Test-Command "gh") (Get-Version "gh")
Write-Check "Supabase CLI" (Test-Command "supabase") (Get-Version "supabase")
Write-Check "Vercel CLI" (Test-Command "vercel") ""

if ($Failures.Count -gt 0) {
    Write-Host ""
    Write-Host "  실패한 항목:" -ForegroundColor Yellow
    foreach ($f in $Failures) { Write-Host "  - $f" -ForegroundColor Yellow }
    Write-Host ""
    Write-Host "  같은 명령어를 다시 실행하면 실패한 것만 다시 시도합니다." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  다음 단계" -ForegroundColor White
Write-Host "  1. 이 창을 닫고, PowerShell 을 새로 열어 아래 로그인 명령어를 실행하세요."
Write-Host "     irm $RepoRaw/login.ps1 | iex" -ForegroundColor Yellow
Write-Host "  2. Claude / ChatGPT 앱이 켜져 있었다면 완전히 종료 후 다시 켜세요."
Write-Host "     (작업 표시줄 오른쪽 아래 아이콘 우클릭 → 종료)" -ForegroundColor Gray
Write-Host "  3. 앱에서 프로젝트 폴더로 " -NoNewline
Write-Host "$ProjectsDir" -ForegroundColor Yellow -NoNewline
Write-Host " 안의 폴더를 선택하세요."
Write-Host ""
