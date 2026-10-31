#!/bin/bash
# ============================================================
# 바이브코딩 올인원 설치 스크립트 (macOS)
# 사용법: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.sh)"
# ============================================================

# set -e 를 쓰지 않는다. 한 항목이 실패해도 나머지는 계속 설치하고, 실패 목록을 마지막에 보여준다.
# macOS 기본 bash(3.2)에서 돌아가야 하므로 연관 배열 같은 bash 4 문법은 쓰지 않는다.

REPO_RAW="https://raw.githubusercontent.com/whatfontisthis/claude-setup/main"

# ── 색상 ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

step=0
total=9
failures=()

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

warn() {
  echo -e "  ${YELLOW}!${NC} $1"
}

# fail "이름" "해결 방법(선택)"
fail() {
  echo -e "  ${RED}✗${NC} $1 실패"
  [[ -n "$2" ]] && echo -e "    ${YELLOW}$2${NC}"
  if [[ -n "$2" ]]; then failures+=("$1: $2"); else failures+=("$1"); fi
}

has() {
  command -v "$1" &>/dev/null
}

node_major() {
  has node || { echo 0; return; }
  node -v 2>/dev/null | sed -E 's/^v([0-9]+).*/\1/'
}

# ~/.zprofile 에 한 줄을 (중복 없이) 추가. AI 앱이 여는 터미널도 이 파일을 읽는다.
add_to_zprofile() {
  local line="$1"
  touch "$HOME/.zprofile"
  grep -qxF "$line" "$HOME/.zprofile" || echo "$line" >> "$HOME/.zprofile"
}

brew_install() {
  has brew || return 1
  brew install "$@"
}

macos_major=$(sw_vers -productVersion | cut -d. -f1)

echo ""
echo -e "${BOLD}바이브코딩 개발 환경 설치를 시작합니다${NC}"
echo -e "   macOS $(sw_vers -productVersion) | $(uname -m)"
echo ""

# ── 설치할 AI 앱 선택 (처음에 한 번만 묻고, 이후는 자리를 비워도 끝까지 진행) ──
echo -e "  ${BOLD}어떤 AI 앱을 설치할까요?${NC}"
echo "    1) Claude"
echo "    2) ChatGPT (Codex)"
echo "    3) 둘 다"
choice=""
tries=0
while [[ "$choice" != "1" && "$choice" != "2" && "$choice" != "3" && $tries -lt 5 ]]; do
  tries=$((tries + 1))
  read -r -p "  번호를 입력하고 엔터: " choice </dev/tty || choice=""
  choice=$(echo "$choice" | tr -d '[:space:]')
done
if [[ "$choice" != "1" && "$choice" != "2" && "$choice" != "3" ]]; then
  choice="3"
  warn "입력을 못 받아서 둘 다 설치합니다."
fi
want_claude=false
want_chatgpt=false
[[ "$choice" == "1" || "$choice" == "3" ]] && want_claude=true
[[ "$choice" == "2" || "$choice" == "3" ]] && want_chatgpt=true

# ── 1. Xcode Command Line Tools (git 포함) ──
progress "Xcode Command Line Tools"

if xcode-select -p &>/dev/null; then
  skip "Xcode CLT"
else
  echo "  Xcode Command Line Tools 를 설치합니다..."
  echo "  (팝업이 뜨면 '설치'를 눌러주세요. 10~20분 걸립니다)"
  xcode-select --install 2>/dev/null || true

  echo "  설치가 끝날 때까지 기다립니다..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  ok "Xcode CLT 설치 완료"
fi

# ── 2. Homebrew ──
progress "Homebrew (패키지 매니저)"

# 이미 설치돼 있지만 현재 터미널 PATH 에 없는 경우 먼저 잡아준다
if ! has brew; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if has brew; then
  skip "Homebrew"
else
  # Homebrew 설치에는 관리자 계정 비밀번호가 필요하다
  if ! dseditgroup -o checkmember -m "$USER" admin &>/dev/null; then
    fail "Homebrew" "이 Mac 계정은 관리자 계정이 아닙니다. 관리자 계정으로 로그인해서 다시 실행해주세요."
  else
    echo "  Homebrew 를 설치합니다. Mac 로그인 비밀번호를 입력하세요 (입력해도 화면에 안 보이는 게 정상)."
    sudo -v
    # 설치가 길어져도 비밀번호를 다시 묻지 않게 백그라운드에서 갱신
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -x /opt/homebrew/bin/brew ]]; then
      add_to_zprofile 'eval "$(/opt/homebrew/bin/brew shellenv)"'
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      add_to_zprofile 'eval "$(/usr/local/bin/brew shellenv)"'
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    if has brew; then ok "Homebrew 설치 완료"; else fail "Homebrew" "터미널을 새로 열고 다시 실행해주세요."; fi
  fi
fi

# ── 3. Node.js ──
# Next.js 와 Supabase CLI 는 Node.js 20 이상이 필요하다
progress "Node.js"

if [[ $(node_major) -ge 20 ]]; then
  skip "Node.js $(node -v)"
else
  [[ $(node_major) -gt 0 ]] && warn "Node.js 버전이 너무 낮아 새로 설치합니다 ($(node -v))"
  brew_install node
  hash -r
  if [[ $(node_major) -ge 20 ]]; then
    ok "Node.js $(node -v) 설치 완료"
  elif [[ $(node_major) -gt 0 ]]; then
    fail "Node.js" "예전 Node.js 가 먼저 잡힙니다 ($(command -v node)). 그 Node.js 를 지운 뒤 다시 실행해주세요."
  else
    fail "Node.js"
  fi
fi

# npm 전역 설치 폴더에 쓰기 권한이 없으면 (예: 공식 설치 파일로 깐 Node.js) sudo 없이 쓸 수 있는 폴더로 바꾼다
if has npm; then
  npm_prefix=$(npm config get prefix 2>/dev/null)
  if [[ -n "$npm_prefix" && ! -w "$npm_prefix/lib" && ! -w "$npm_prefix" ]]; then
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    add_to_zprofile 'export PATH="$HOME/.npm-global/bin:$PATH"'
    export PATH="$HOME/.npm-global/bin:$PATH"
    warn "npm 전역 설치 폴더를 ~/.npm-global 로 바꿨습니다."
  fi
fi

# ── 4. Python 3 + uv ──
progress "Python 3 + uv"

# /usr/bin/python3 는 Xcode CLT 에 딸린 구버전이라 그것만 있으면 Homebrew Python 을 따로 설치한다
if has python3 && [[ "$(command -v python3)" != "/usr/bin/python3" ]]; then
  skip "$(python3 --version 2>&1)"
else
  brew_install python
  hash -r
  if has python3; then ok "$(python3 --version 2>&1) 설치 완료"; else fail "Python"; fi
fi

# uv: AI 가 Python 프로젝트를 만들 때 가상환경과 패키지 설치를 한 번에 처리해주는 도구
if has uv; then
  skip "$(uv --version)"
else
  brew_install uv
  if has uv; then ok "$(uv --version) 설치 완료"; else fail "uv"; fi
fi

# ── 5. GitHub CLI ──
progress "GitHub CLI (gh)"

if has gh; then
  skip "$(gh --version | head -1)"
else
  brew_install gh
  if has gh; then ok "$(gh --version | head -1) 설치 완료"; else fail "GitHub CLI"; fi
fi

# ── 6. Supabase CLI ──
progress "Supabase CLI"

if has supabase; then
  skip "Supabase CLI $(supabase --version 2>/dev/null)"
else
  brew_install supabase/tap/supabase
  if has supabase; then ok "Supabase CLI $(supabase --version 2>/dev/null) 설치 완료"; else fail "Supabase CLI"; fi
fi

# ── 7. Vercel CLI ──
progress "Vercel CLI"

if has vercel; then
  skip "Vercel CLI"
elif has npm; then
  echo "  Vercel CLI 를 설치합니다..."
  npm install -g vercel
  hash -r
  if has vercel; then ok "Vercel CLI 설치 완료"; else fail "Vercel CLI"; fi
else
  fail "Vercel CLI" "Node.js 가 없어 건너뜀"
fi

# ── 8. AI 데스크톱 앱 ──
progress "AI 데스크톱 앱"

# install_app "표시 이름" "cask 이름" "앱 이름(.app 제외)" "직접 받는 주소"
install_app() {
  local name="$1" cask="$2" app="$3" url="$4"
  # 직접 받아서 설치한 앱이 있으면 brew 가 덮어쓰기를 거부하므로 먼저 확인
  if [[ -d "/Applications/$app.app" || -d "$HOME/Applications/$app.app" ]]; then
    skip "$name"
    return
  fi
  echo "  $name 을(를) 설치합니다..."
  if brew_install --cask "$cask" && [[ -d "/Applications/$app.app" || -d "$HOME/Applications/$app.app" ]]; then
    ok "$name 설치 완료"
  else
    fail "$name" "지금 열리는 페이지에서 직접 받아 설치해주세요."
    open "$url"
  fi
}

if [[ "$macos_major" -lt 13 ]]; then
  fail "AI 데스크톱 앱" "macOS 13(Ventura) 이상이 필요합니다. 지금은 $(sw_vers -productVersion) 입니다."
else
  $want_claude && install_app "Claude" "claude" "Claude" "https://claude.ai/download"
  # Codex 는 2026년 7월부터 ChatGPT 데스크톱 앱 안에 들어 있다
  $want_chatgpt && install_app "ChatGPT (Codex)" "chatgpt" "ChatGPT" "https://chatgpt.com/download"
fi

# ── 9. 프로젝트 폴더 ──
# 데스크톱/문서는 iCloud 동기화 폴더인 경우가 많아 node_modules 가 동기화되며 느려지거나 깨진다
progress "프로젝트 폴더"

projects_dir="$HOME/projects"
mkdir -p "$projects_dir"
ok "$projects_dir"

# ── 완료 ──
hash -r

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ ${#failures[@]} -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}  설치가 모두 끝났습니다${NC}"
else
  echo -e "${YELLOW}${BOLD}  설치가 끝났지만 ${#failures[@]}개 항목이 실패했습니다${NC}"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

check() {
  # check "이름" "확인 명령" "버전 명령"
  if eval "$2" &>/dev/null; then
    printf "  ${GREEN}✓ %-14s %s${NC}\n" "$1" "$(eval "$3" 2>/dev/null | head -1)"
  else
    printf "  ${RED}✗ %-14s 없음${NC}\n" "$1"
  fi
}

check "Homebrew" "has brew" "brew --version"
check "Git" "has git" "git --version"
check "Node.js" "[[ \$(node_major) -ge 20 ]]" "node -v"
check "Python" "has python3" "python3 --version"
check "uv" "has uv" "uv --version"
check "GitHub CLI" "has gh" "gh --version"
check "Supabase CLI" "has supabase" "supabase --version"
check "Vercel CLI" "has vercel" "true"

if [[ ${#failures[@]} -gt 0 ]]; then
  echo ""
  echo -e "  ${YELLOW}실패한 항목:${NC}"
  for f in "${failures[@]}"; do echo -e "  ${YELLOW}- $f${NC}"; done
  echo ""
  echo -e "  ${YELLOW}같은 명령어를 다시 실행하면 실패한 것만 다시 시도합니다.${NC}"
fi

echo ""
echo -e "  ${BOLD}다음 단계${NC}"
echo -e "  1. 터미널을 ⌘ + Q 로 완전히 끄고 다시 열어, 아래 로그인 명령어를 실행하세요."
echo -e "     ${YELLOW}/bin/bash -c \"\$(curl -fsSL $REPO_RAW/login.sh)\"${NC}"
echo -e "  2. Claude / ChatGPT 앱이 켜져 있었다면 ⌘ + Q 로 완전히 끄고 다시 켜세요."
echo -e "  3. 앱에서 프로젝트 폴더로 ${YELLOW}$projects_dir${NC} 안의 폴더를 선택하세요."
echo ""
