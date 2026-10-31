#!/bin/bash
# ============================================================
# 로그인 도우미 (macOS): GitHub → Vercel → Supabase
# 사용법: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/login.sh)"
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

# 새 터미널이 아니어도 Homebrew 와 npm 전역 명령을 찾을 수 있게
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -x /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"
[[ -d "$HOME/.npm-global/bin" ]] && export PATH="$HOME/.npm-global/bin:$PATH"

total=3
result_lines=()
fail_count=0

progress() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}[$1/$total] $2${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

guide() {
  for line in "$@"; do echo -e "  ${CYAN}$line${NC}"; done
  echo ""
}

has() {
  command -v "$1" &>/dev/null
}

# result "이름" ok|fail "설명"
result() {
  if [[ "$2" == "ok" ]]; then
    echo -e "  ${GREEN}✓${NC} $1 로그인됨 $3"
    result_lines+=("$(printf "  ${GREEN}✓ %-10s %s${NC}" "$1" "$3")")
  else
    echo -e "  ${RED}✗${NC} $1 로그인 안 됨 $3"
    result_lines+=("$(printf "  ${RED}✗ %-10s %s${NC}" "$1" "$3")")
    fail_count=$((fail_count + 1))
  fi
}

echo ""
echo -e "${BOLD}GitHub, Vercel, Supabase 로그인을 차례로 진행합니다${NC}"
echo -e "  ${GRAY}이미 로그인된 서비스는 건너뜁니다.${NC}"
echo -e "  ${GRAY}Vercel, Supabase 계정이 없다면 'Continue with GitHub' 로 가입하는 게 가장 편합니다.${NC}"

# 상태 확인 명령은 입력을 /dev/null 로 막아 로그인 질문이 뜨지 않게 하고 종료 코드만 본다

# ── 1. GitHub ──
progress 1 "GitHub"

if ! has gh; then
  result "GitHub" fail "(gh 가 없습니다. 설치 스크립트를 먼저 실행하세요)"
else
  if ! gh auth status </dev/null &>/dev/null; then
    guide "1. 질문이 나오면 그냥 엔터" \
          "2. 화면에 나오는 8자리 코드(XXXX-XXXX)를 확인" \
          "3. 엔터를 누르면 브라우저가 열립니다. 코드를 입력하고 Authorize 클릭"
    gh auth login --hostname github.com --git-protocol https --web </dev/tty
  fi

  if gh auth status </dev/null &>/dev/null; then
    # git push 할 때 GitHub 로그인을 gh 가 대신 처리하게 연결
    gh auth setup-git

    # 커밋 작성자 정보가 비어 있으면 GitHub 계정으로 채운다.
    # 이메일은 GitHub 가 주는 비공개 주소를 써서 개인 이메일이 공개 저장소에 남지 않게 한다.
    gh_login=$(gh api user --jq .login 2>/dev/null)
    gh_id=$(gh api user --jq .id 2>/dev/null)
    gh_name=$(gh api user --jq '.name // empty' 2>/dev/null)
    [[ -z "$gh_name" ]] && gh_name="$gh_login"

    if [[ -n "$gh_login" ]]; then
      [[ -z "$(git config --global user.name)" ]] && git config --global user.name "$gh_name"
      [[ -z "$(git config --global user.email)" ]] && git config --global user.email "${gh_id}+${gh_login}@users.noreply.github.com"
      [[ -z "$(git config --global init.defaultBranch)" ]] && git config --global init.defaultBranch main
      result "GitHub" ok "($gh_login)"
    else
      result "GitHub" ok ""
    fi
  else
    result "GitHub" fail ""
  fi
fi

# ── 2. Vercel ──
progress 2 "Vercel"

if ! has vercel; then
  result "Vercel" fail "(vercel 이 없습니다. 설치 스크립트를 먼저 실행하세요)"
else
  if ! vercel whoami </dev/null &>/dev/null; then
    guide "1. 안내에 따라 엔터를 누르면 브라우저가 열립니다" \
          "2. 로그인 후, 화면의 코드가 터미널과 같은지 확인하고 승인"
    vercel login </dev/tty
  fi

  if who=$(vercel whoami </dev/null 2>/dev/null); then
    result "Vercel" ok "($(echo "$who" | tail -1))"
  else
    result "Vercel" fail ""
  fi
fi

# ── 3. Supabase ──
progress 3 "Supabase"

if ! has supabase; then
  result "Supabase" fail "(supabase 가 없습니다. 설치 스크립트를 먼저 실행하세요)"
else
  if ! supabase projects list </dev/null &>/dev/null; then
    guide "1. 엔터를 누르면 브라우저가 열립니다. 로그인하세요" \
          "2. 브라우저에 나오는 인증 코드(verification code)를 복사" \
          "3. 이 터미널에 ⌘ + V 로 붙여넣고 엔터"
    supabase login </dev/tty
  fi

  if supabase projects list </dev/null &>/dev/null; then
    result "Supabase" ok ""
  else
    result "Supabase" fail ""
  fi
fi

# ── 결과 ──
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ $fail_count -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}  로그인이 모두 끝났습니다${NC}"
else
  echo -e "${YELLOW}${BOLD}  ${fail_count}개 서비스 로그인이 안 됐습니다${NC}"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
for line in "${result_lines[@]}"; do echo -e "$line"; done
if [[ $fail_count -gt 0 ]]; then
  echo ""
  echo -e "  ${YELLOW}같은 명령어를 다시 실행하면 안 된 것만 다시 시도합니다.${NC}"
fi
echo ""
