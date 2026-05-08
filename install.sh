#!/bin/bash
# ============================================================
# 클로드 코드 올인원 설치 스크립트 (macOS)
# 사용법: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.sh)"
# ============================================================

set -e

# ── 색상 ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

step=0
total=9

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

fail() {
  echo -e "  ${RED}✗${NC} $1"
  exit 1
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

echo ""
echo -e "${BOLD}🚀 클로드 코드 올인원 설치를 시작합니다${NC}"
echo -e "   macOS $(sw_vers -productVersion) | $(uname -m)"
echo ""

# ── sudo 미리 획득 (이후 비밀번호 재입력 없음) ──
echo -e "  설치에 관리자 권한이 필요합니다."
sudo -v
# sudo 타임아웃 방지 (백그라운드에서 갱신)
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &

# ── 1. Xcode Command Line Tools ──
progress "Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
  skip "Xcode CLT"
else
  echo "  Xcode Command Line Tools를 설치합니다..."
  echo "  (팝업이 뜨면 '설치'를 눌러주세요)"
  xcode-select --install 2>/dev/null || true

  # 설치 완료 대기
  echo "  설치가 완료될 때까지 기다립니다..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  ok "Xcode CLT 설치 완료"
fi

# ── 2. Homebrew ──
progress "Homebrew (패키지 매니저)"

if command -v brew &>/dev/null; then
  skip "Homebrew"
else
  echo "  Homebrew를 설치합니다..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon PATH 등록
  if [[ "$(uname -m)" == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    ok "Homebrew 설치 + PATH 등록 (Apple Silicon)"
  else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/usr/local/bin/brew shellenv)"
    ok "Homebrew 설치 + PATH 등록 (Intel)"
  fi
fi

# brew가 PATH에 있는지 재확인
if ! command -v brew &>/dev/null; then
  # 직접 경로로 시도
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    fail "Homebrew 설치에 실패했습니다. 터미널을 재시작한 뒤 다시 시도해주세요."
  fi
fi

# ── 3. Node.js ──
progress "Node.js"

if command -v node &>/dev/null; then
  node_ver=$(node -v)
  skip "Node.js $node_ver"
else
  echo "  Node.js를 설치합니다..."
  brew install node
  ok "Node.js $(node -v) 설치 완료"
fi

# ── 4. Python 3 ──
progress "Python 3"

if command -v python3 &>/dev/null; then
  py_ver=$(python3 --version 2>&1)
  skip "$py_ver"
else
  echo "  Python 3를 설치합니다..."
  brew install python
  ok "$(python3 --version) 설치 완료"
fi

# ── 5. Git ──
progress "Git"

if command -v git &>/dev/null; then
  git_ver=$(git --version)
  skip "$git_ver"
else
  echo "  Git을 설치합니다..."
  brew install git
  ok "$(git --version) 설치 완료"
fi

# ── 6. GitHub CLI ──
progress "GitHub CLI"

if command -v gh &>/dev/null; then
  gh_ver=$(gh --version | head -1)
  skip "$gh_ver"
else
  echo "  GitHub CLI를 설치합니다..."
  brew install gh
  ok "$(gh --version | head -1) 설치 완료"
fi

# ── 7. Claude Code ──
progress "Claude Code"

if command -v claude &>/dev/null; then
  skip "Claude Code"
else
  echo "  Claude Code를 설치합니다..."
  brew install --cask claude-code
  ok "Claude Code 설치 완료"
fi

# ── 8. VS Code ──
progress "VS Code"

if command -v code &>/dev/null; then
  skip "VS Code"
else
  echo "  VS Code를 설치합니다..."
  brew install --cask visual-studio-code
  resolve_vscode_path || true
  ok "VS Code 설치 완료"
fi

# ── 9. VS Code 설정 (Extensions + settings.json + keybindings.json) ──
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

# ── 완료 ──
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  ✅ 설치가 모두 완료되었습니다!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  설치된 항목:"
echo -e "  ${GREEN}✓${NC} Homebrew  $(brew --version 2>/dev/null | head -1)"
echo -e "  ${GREEN}✓${NC} Node.js   $(node -v 2>/dev/null)"
echo -e "  ${GREEN}✓${NC} Python    $(python3 --version 2>&1)"
echo -e "  ${GREEN}✓${NC} Git       $(git --version 2>/dev/null)"
echo -e "  ${GREEN}✓${NC} GitHub CLI $(gh --version 2>/dev/null | head -1)"
echo -e "  ${GREEN}✓${NC} Claude Code"
command -v code &>/dev/null && echo -e "  ${GREEN}✓${NC} VS Code"
echo ""
echo -e "  ${BOLD}다음 단계:${NC}"
echo -e "  터미널에 ${YELLOW}claude${NC} 를 입력하면 클로드 코드가 실행됩니다."
echo -e "  처음 실행하면 Anthropic 계정 연결을 안내합니다."
echo ""
