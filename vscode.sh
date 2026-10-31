#!/bin/bash
# ============================================================
# VS Code 설치 + 확장 + 설정 (macOS) — 선택 사항
# 사용법: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/vscode.sh)"
# ============================================================

# ── 색상 ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

step=0
total=2

progress() {
  step=$((step + 1))
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}[$step/$total] $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

ok() {
  echo -e "  ${GREEN}✓${NC} $1"
}

skip() {
  echo -e "  ${YELLOW}→${NC} $1 (이미 설치됨, 스킵)"
}

# VS Code 설치 후 `code` 명령이 PATH에 안 잡힐 때 일반 설치 경로를 직접 찾아 주입
resolve_vscode_path() {
  if command -v code &>/dev/null; then return 0; fi

  local candidates=(
    "/opt/homebrew/bin/code"
    "/usr/local/bin/code"
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
    "$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  )

  for path in "${candidates[@]}"; do
    if [[ -x "$path" ]]; then
      export PATH="$(dirname "$path"):$PATH"
      command -v code &>/dev/null && return 0
    fi
  done
  return 1
}

# 기존 파일을 타임스탬프 백업본으로 보존한 뒤 덮어쓰기 안전성 확보
backup_if_exists() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local stamp
    stamp=$(date +%Y%m%d-%H%M%S)
    cp "$file" "$file.bak.$stamp"
    echo -e "    ${YELLOW}→${NC} 기존 파일 백업: $file.bak.$stamp"
  fi
}

# Homebrew 가 현재 터미널 PATH 에 없으면 잡아준다
if ! command -v brew &>/dev/null; then
  [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [[ -x /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
fi

echo ""
echo -e "${BOLD}VS Code 설치를 시작합니다${NC}"
echo ""

# ── 1. VS Code ──
progress "VS Code"

if resolve_vscode_path; then
  skip "VS Code"
elif command -v brew &>/dev/null; then
  echo "  VS Code를 설치합니다..."
  brew install --cask visual-studio-code
  if resolve_vscode_path; then
    ok "VS Code 설치 완료"
  else
    echo -e "  ${RED}✗${NC} VS Code 설치 실패"
  fi
else
  echo -e "  ${RED}✗${NC} Homebrew 가 없습니다. 기본 설치 명령어(install.sh)를 먼저 실행하거나,"
  echo -e "    지금 열리는 페이지에서 VS Code 를 받아 설치한 뒤 이 명령어를 다시 실행해주세요."
  open "https://code.visualstudio.com/download"
fi

# ── 2. VS Code 설정 (Extensions + settings.json + keybindings.json) ──
progress "VS Code 설정"

if ! resolve_vscode_path; then
  echo -e "  ${YELLOW}!${NC} VS Code (code 명령)를 PATH에서 찾지 못했습니다."
  echo -e "    터미널을 새로 열고 다시 실행하거나, VS Code를 한 번 실행해 PATH 통합을 완료해주세요."
else
  # Extensions (이미 설치된 것은 스킵)
  extensions=(
    "anthropic.claude-code"
    "bierner.markdown-mermaid"
    "cweijan.vscode-office"
    "gabrielgrinberg.auto-run-command"
    "gera2ld.markmap-vscode"
    "peakchen90.open-html-in-browser"
    "pkief.material-icon-theme"
    "tomoki1207.pdf"
  )

  echo "  Extensions 설치 중..."
  installed_exts=$(code --list-extensions 2>/dev/null || true)
  for ext in "${extensions[@]}"; do
    if echo "$installed_exts" | grep -qx "$ext"; then
      echo -e "    ${YELLOW}→${NC} $ext (이미 설치됨, 스킵)"
    else
      echo "    → $ext"
      code --install-extension "$ext" --force >/dev/null
    fi
  done
  ok "Extensions 처리 완료"

  # settings.json
  settings_dir="$HOME/Library/Application Support/Code/User"
  mkdir -p "$settings_dir"

  settings_path="$settings_dir/settings.json"
  backup_if_exists "$settings_path"
  cat > "$settings_path" <<'JSON'
{
  // Terminal settings
  "terminal.integrated.defaultProfile.osx": "zsh",
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
JSON
  ok "settings.json 저장됨"

  # keybindings.json
  keybindings_path="$settings_dir/keybindings.json"
  backup_if_exists "$keybindings_path"
  cat > "$keybindings_path" <<'JSON'
// Place your key bindings in this file to override the defaults
[
    {
        "key": "cmd+o",
        "command": "-workbench.action.files.openFile",
        "when": "true"
    },
    {
        "key": "cmd+o",
        "command": "-workbench.action.files.openFileFolder",
        "when": "isMacNative && openFolderWorkspaceSupport"
    },
    {
        "key": "cmd+o",
        "command": "-workbench.action.files.openLocalFile",
        "when": "remoteFileDialogVisible"
    },
    {
        "key": "cmd+o",
        "command": "-workbench.action.files.openFolderViaWorkspace",
        "when": "!openFolderWorkspaceSupport && workbenchState == 'workspace'"
    },
    {
        "key": "cmd+k cmd+o",
        "command": "-workbench.action.files.openFolder",
        "when": "openFolderWorkspaceSupport"
    },
    {
        "key": "cmd+k cmd+o",
        "command": "-workbench.action.files.openLocalFolder",
        "when": "remoteFileDialogVisible"
    },
    {
        "key": "cmd+o",
        "command": "workbench.action.files.openFolder"
    },
    {
        "key": "cmd+1",
        "command": "openInDefaultBrowser.openInDefaultBrowser"
    }
]
JSON
  ok "keybindings.json 저장됨"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  VS Code 설치가 끝났습니다${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
