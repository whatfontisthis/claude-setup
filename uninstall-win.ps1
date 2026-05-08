# ============================================================
# 윈도우 개발 환경 초기화 (클린 테스트용)
# 사용법: irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/uninstall-win.ps1 | iex
# ============================================================

# 관리자 권한 체크 & 자동 재실행
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "  관리자 권한으로 재실행합니다..." -ForegroundColor Yellow
    Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/uninstall-win.ps1 | iex`""
    exit
}

$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "🧹 윈도우 개발 환경을 초기화합니다" -ForegroundColor White
Write-Host ""

# Claude Code (npm + winget)
Write-Host "  Claude Code 제거..." -ForegroundColor Yellow
npm uninstall -g @anthropic-ai/claude-code 2>$null

# winget으로 설치된 도구 제거
if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget uninstall Anthropic.ClaudeCode --silent 2>$null

    Write-Host "  VS Code 제거..." -ForegroundColor Yellow
    winget uninstall Microsoft.VisualStudioCode --silent 2>$null
    winget uninstall XP9KHM4BK9FZ7Q --silent 2>$null

    Write-Host "  GitHub CLI 제거..." -ForegroundColor Yellow
    winget uninstall GitHub.cli --silent 2>$null

    Write-Host "  Node.js 제거..." -ForegroundColor Yellow
    winget uninstall OpenJS.NodeJS --silent 2>$null
    winget uninstall OpenJS.NodeJS.LTS --silent 2>$null
    winget uninstall OpenJS.NodeJS.22 --silent 2>$null
    winget uninstall OpenJS.NodeJS.20 --silent 2>$null
    winget uninstall OpenJS.NodeJS.18 --silent 2>$null

    Write-Host "  Python 제거..." -ForegroundColor Yellow
    winget uninstall Python.Python.3.12 --silent 2>$null
    winget uninstall Python.Python.3.13 --silent 2>$null
    winget uninstall Python.Python.3.11 --silent 2>$null

    Write-Host "  Git 제거..." -ForegroundColor Yellow
    winget uninstall Git.Git --silent 2>$null
    winget uninstall Git.Git.2 --silent 2>$null
}

# Scoop 앱 + Scoop 자체 (위에서 winget으로 못 잡힌 것까지 정리)
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "  Scoop 제거 (설치된 패키지 포함)..." -ForegroundColor Yellow
    scoop uninstall scoop -p 2>$null
}
if (Test-Path "$HOME\scoop") {
    Remove-Item -Recurse -Force "$HOME\scoop"
}

# VS Code 사용자 설정/키바인딩 제거 (백업본은 남김 — 안전)
$vscodeUserDir = "$env:APPDATA\Code\User"
if (Test-Path "$vscodeUserDir\settings.json") {
    Write-Host "  VS Code settings.json 제거 (백업본은 보존)..." -ForegroundColor Yellow
    Remove-Item -Force "$vscodeUserDir\settings.json"
}
if (Test-Path "$vscodeUserDir\keybindings.json") {
    Remove-Item -Force "$vscodeUserDir\keybindings.json"
}

# PATH 새로고침
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "Machine")

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host "  ✅ 초기화 완료" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host ""
Write-Host "  PowerShell을 재시작한 뒤 확인하세요:" -ForegroundColor White
Write-Host "  node --version     # 인식 안 되면 OK" -ForegroundColor Gray
Write-Host "  python --version   # 인식 안 되면 OK" -ForegroundColor Gray
Write-Host "  git --version      # 인식 안 되면 OK" -ForegroundColor Gray
Write-Host "  gh --version       # 인식 안 되면 OK" -ForegroundColor Gray
Write-Host "  claude --version   # 인식 안 되면 OK" -ForegroundColor Gray
Write-Host "  code --version     # 인식 안 되면 OK" -ForegroundColor Gray
Write-Host "  scoop --version    # 인식 안 되면 OK" -ForegroundColor Gray
Write-Host ""
