# ============================================================
# 로그인 도우미 (Windows PowerShell): GitHub → Vercel → Supabase
# 사용법: irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/login.ps1 | iex
# ============================================================

# install.ps1 과 같은 이유로 exit 와 Stop 을 쓰지 않는다
$ErrorActionPreference = "Continue"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# 실행 정책이 풀리지 않은 PC 에서도 이 창에서는 동작하도록
try { Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction Stop } catch { }

$machine = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
$user = [System.Environment]::GetEnvironmentVariable("PATH", "User")
$env:PATH = "$machine;$user"

$Results = New-Object System.Collections.ArrayList

function Write-Step {
    param([int]$Num, [int]$Total, [string]$Message)
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host "[$Num/$Total] $Message" -ForegroundColor White
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
}

function Write-Guide {
    param([string[]]$Lines)
    foreach ($line in $Lines) { Write-Host "  $line" -ForegroundColor Cyan }
    Write-Host ""
}

function Test-Command {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Add-Result {
    param([string]$Name, [bool]$Ok, [string]$Detail)
    if ($Ok) {
        Write-Host "  ✓ $Name 로그인됨 $Detail" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $Name 로그인 안 됨 $Detail" -ForegroundColor Red
    }
    [void]$Results.Add([pscustomobject]@{ Name = $Name; Ok = $Ok; Detail = $Detail })
}

# 상태 확인용 명령은 입력을 막아(파이프로 빈 입력) 로그인 질문이 뜨지 않게 하고 종료 코드만 본다
function Test-Exit {
    param([string]$Exe, [string[]]$Arguments)
    $null | & $Exe @Arguments *> $null
    return ($LASTEXITCODE -eq 0)
}

Write-Host ""
Write-Host "GitHub, Vercel, Supabase 로그인을 차례로 진행합니다" -ForegroundColor White
Write-Host "  이미 로그인된 서비스는 건너뜁니다." -ForegroundColor Gray
Write-Host "  Vercel, Supabase 계정이 없다면 'Continue with GitHub' 로 가입하는 게 가장 편합니다." -ForegroundColor Gray

$total = 3

# ── 1. GitHub ──
Write-Step -Num 1 -Total $total -Message "GitHub"

if (-not (Test-Command "gh")) {
    Add-Result "GitHub" $false "(gh 가 없습니다. 설치 스크립트를 먼저 실행하세요)"
} else {
    if (-not (Test-Exit "gh" @("auth", "status"))) {
        Write-Guide @(
            "1. 질문이 나오면 그냥 엔터",
            "2. 화면에 나오는 8자리 코드(XXXX-XXXX)를 확인",
            "3. 엔터를 누르면 브라우저가 열립니다. 코드를 입력하고 Authorize 클릭"
        )
        & gh auth login --hostname github.com --git-protocol https --web
    }

    if (Test-Exit "gh" @("auth", "status")) {
        # git push 할 때 GitHub 로그인을 gh 가 대신 처리하게 연결
        & gh auth setup-git

        # 커밋 작성자 정보가 비어 있으면 GitHub 계정으로 채운다.
        # 이메일은 GitHub 가 주는 비공개 주소를 써서 개인 이메일이 공개 저장소에 남지 않게 한다.
        $prevEnc = [Console]::OutputEncoding
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        $ghUser = $null
        try { $ghUser = (& gh api user) -join "`n" | ConvertFrom-Json } catch { }
        [Console]::OutputEncoding = $prevEnc

        if ($ghUser) {
            if (-not (& git config --global user.name)) {
                $gitName = $ghUser.name
                if (-not $gitName) { $gitName = $ghUser.login }
                & git config --global user.name "$gitName"
            }
            if (-not (& git config --global user.email)) {
                & git config --global user.email "$($ghUser.id)+$($ghUser.login)@users.noreply.github.com"
            }
            Add-Result "GitHub" $true "($($ghUser.login))"
        } else {
            Add-Result "GitHub" $true ""
        }
    } else {
        Add-Result "GitHub" $false ""
    }
}

# ── 2. Vercel ──
# vercel.ps1 대신 vercel.cmd 를 불러 실행 정책과 상관없이 동작하게 한다
Write-Step -Num 2 -Total $total -Message "Vercel"

if (-not (Test-Command "vercel.cmd")) {
    Add-Result "Vercel" $false "(vercel 이 없습니다. 설치 스크립트를 먼저 실행하세요)"
} else {
    if (-not (Test-Exit "vercel.cmd" @("whoami"))) {
        Write-Guide @(
            "1. 안내에 따라 엔터를 누르면 브라우저가 열립니다",
            "2. 로그인 후, 화면의 코드가 터미널과 같은지 확인하고 승인"
        )
        & vercel.cmd login
    }

    $who = ($null | & vercel.cmd whoami 2>$null | Select-Object -Last 1)
    if ($LASTEXITCODE -eq 0) {
        Add-Result "Vercel" $true "($("$who".Trim()))"
    } else {
        Add-Result "Vercel" $false ""
    }
}

# ── 3. Supabase ──
Write-Step -Num 3 -Total $total -Message "Supabase"

if (-not (Test-Command "supabase")) {
    Add-Result "Supabase" $false "(supabase 가 없습니다. 설치 스크립트를 먼저 실행하세요)"
} else {
    if (-not (Test-Exit "supabase" @("projects", "list"))) {
        Write-Guide @(
            "1. 엔터를 누르면 브라우저가 열립니다. 로그인하세요",
            "2. 브라우저에 나오는 인증 코드(verification code)를 복사",
            "3. 이 창에 붙여넣고(우클릭) 엔터"
        )
        & supabase login
    }

    Add-Result "Supabase" (Test-Exit "supabase" @("projects", "list")) ""
}

# ── 결과 ──
$failed = @($Results | Where-Object { -not $_.Ok })

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
if ($failed.Count -eq 0) {
    Write-Host "  로그인이 모두 끝났습니다" -ForegroundColor Green
} else {
    Write-Host "  $($failed.Count)개 서비스 로그인이 안 됐습니다" -ForegroundColor Yellow
}
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host ""
foreach ($r in $Results) {
    if ($r.Ok) {
        Write-Host ("  ✓ {0,-10} {1}" -f $r.Name, $r.Detail) -ForegroundColor Green
    } else {
        Write-Host ("  ✗ {0,-10} {1}" -f $r.Name, $r.Detail) -ForegroundColor Red
    }
}
if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "  같은 명령어를 다시 실행하면 안 된 것만 다시 시도합니다." -ForegroundColor Yellow
}
Write-Host ""
