# Claude Code 올인원 설치

한 줄 명령어로 **Claude Code + VS Code 개발 환경**을 자동 설치합니다.

| 설치 항목 | 8개 |
|----------|-----|
| Scoop / Homebrew · Node.js · Python 3 · Git · GitHub CLI · **Claude Code** · VS Code · VS Code 설정 | 자동 |

> 이미 설치된 건 스킵, 여러 번 실행해도 안전. Apple Silicon(M1~M4) 자동 대응.

---

## 🪟 Windows

**1.** `Win` 키 → `powershell` 입력 → **Windows PowerShell** 실행
**2.** 아래 명령어 복사 → PowerShell 창에 우클릭(붙여넣기) → 엔터

```powershell
irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.ps1 | iex
```

**3.** 8단계 ✅ 모두 뜰 때까지 대기 (5~10분)
**4.** PowerShell에 `claude` 입력 → Anthropic 계정 연결

---

## 🍎 macOS

**1.** `⌘ + Space` → `terminal` → 엔터
**2.** 명령어 복사 → `⌘ + V` → 엔터

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.sh)"
```

**3.** 9단계 ✅ 완료 대기 (Xcode CLT 설치 시 더 오래 걸림)
**4.** 터미널에 `claude` 입력

---

## 추가 옵션 (선택)

```powershell
# 터미널 꾸미기 (Oh My Posh)
irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/customize.ps1 | iex

# 클린 초기화 — Node/Python/Git 모두 제거. 재설치 테스트용.
irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/uninstall-win.ps1 | iex
```

---

<details>
<summary><b>❓ 자주 겪는 문제</b></summary>

**"이 시스템에서 스크립트를 실행할 수 없으므로..." (Windows)**

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```
실행 후 다시 시도.

**`claude` 명령을 못 찾음**
→ 터미널/PowerShell 창을 **완전히 닫고 새로 열기**.

**VS Code `code` 명령을 못 찾음**
→ VS Code를 한 번 실행 후 새 터미널에서 재시도.

</details>

---

## 설치되는 도구

| 도구 | 용도 |
|------|------|
| Scoop / Homebrew | 패키지 매니저 |
| Node.js · Python 3 · Git | 개발 런타임 + 버전 관리 |
| GitHub CLI (`gh`) | 깃허브 터미널 도구 |
| **Claude Code** | AI 코딩 도구 (본체) |
| VS Code | 코드 편집기 |
| VS Code 확장 + 설정 | 확장 8개 + 권장 설정 자동 적용 |

---

문의 · 버그: [Issues](https://github.com/whatfontisthis/claude-setup/issues)
