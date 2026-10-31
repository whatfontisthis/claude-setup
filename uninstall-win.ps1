# ============================================================
# 윈도우 개발 환경 초기화 (클린 테스트용)
# install.ps1 / login.ps1 이 만든 것을 지운다. C:\projects 안의 프로젝트는 건드리지 않는다.
# 사용법: irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/uninstall-win.ps1 | iex
# ============================================================

# 관리자 권한 체크 & 자동 재실행
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  관리자 권한으로 재실행합니다..." -ForegroundColor Yellow
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/uninstall-win.ps1 | iex`""
    return
}

$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "윈도우 개발 환경을 초기화합니다" -ForegroundColor White
Write-Host ""

# AI 데스크톱 앱
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "  Claude 앱 제거..." -ForegroundColor Yellow
    winget uninstall --id Anthropic.Claude -e --silent
    Write-Host "  ChatGPT 앱 제거..." -ForegroundColor Yellow
    winget uninstall --id 9PLM9XGG6VKS --silent
    Write-Host "  VS Code 제거..." -ForegroundColor Yellow
    winget uninstall --id Microsoft.VisualStudioCode -e --silent
}

# vscode.ps1 이 쓴 VS Code 설정/키바인딩 (백업본은 남김)
foreach ($file in @("$env:APPDATA\Code\User\settings.json", "$env:APPDATA\Code\User\keybindings.json")) {
    if (Test-Path $file) { Remove-Item -Force $file }
}

# Scoop 과 Scoop 으로 설치한 전부 (Git, Node.js, Python, uv, gh, Supabase CLI, npm 전역 패키지인 Vercel CLI 포함)
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "  Scoop 제거 (설치된 패키지 포함)..." -ForegroundColor Yellow
    scoop uninstall scoop -p
}
foreach ($dir in @("$HOME\scoop", "C:\scoop")) {
    if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
}

# Scoop 이 아닌 Node.js 에 깔린 Vercel CLI
npm uninstall -g vercel 2>$null

# install.ps1 이 등록한 환경 변수
[System.Environment]::SetEnvironmentVariable("SCOOP", $null, "User")
[System.Environment]::SetEnvironmentVariable("CLAUDE_CODE_GIT_BASH_PATH", $null, "User")

# 로그인 정보 (login.ps1 을 다시 테스트할 수 있게)
Write-Host "  GitHub / Vercel / Supabase 로그인 정보 제거..." -ForegroundColor Yellow
foreach ($dir in @("$env:APPDATA\GitHub CLI", "$env:APPDATA\com.vercel.cli", "$HOME\.supabase")) {
    if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
}

# 실행 정책을 Windows 기본값으로
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser -Force

$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host "  초기화 완료" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host ""
Write-Host "  PowerShell 을 새로 열고 확인하세요 (모두 '인식되지 않습니다' 가 나오면 정상):" -ForegroundColor White
Write-Host "  node --version" -ForegroundColor Gray
Write-Host "  python --version" -ForegroundColor Gray
Write-Host "  git --version" -ForegroundColor Gray
Write-Host "  gh --version" -ForegroundColor Gray
Write-Host "  supabase --version" -ForegroundColor Gray
Write-Host "  vercel --version" -ForegroundColor Gray
Write-Host "  scoop --version" -ForegroundColor Gray
Write-Host "  code --version" -ForegroundColor Gray
Write-Host ""
Write-Host "  C:\projects 폴더는 남겨뒀습니다." -ForegroundColor Gray
Write-Host ""
