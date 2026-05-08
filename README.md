# Claude Code 올인원 설치

한 줄 명령어로 **Claude Code + VS Code 개발 환경**을 자동 설치합니다.

> 이미 설치된 항목은 스킵 · 여러 번 실행해도 안전 · Apple Silicon(M1~M4) 자동 대응

---

## 🪟 Windows

### 1단계 — PowerShell 열기

`Win` 키 → `powershell` 입력 → **Windows PowerShell** 실행

### 2단계 — 명령어 복사 + 실행

PowerShell 창에 우클릭(붙여넣기) → 엔터:

```powershell
irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.ps1 | iex
```

> 설치 중 UAC(관리자 권한) 창이 뜰 수 있습니다 → "예" 클릭

### 3단계 — 8단계 ✅ 완료까지 대기 (5~10분)

### 4단계 — 설치 확인

**PowerShell 창을 완전히 닫고 새로 열어주세요.** 그 다음 한 줄씩 실행:

```powershell
node --version
python --version
git --version
gh --version
claude --version
code --version
```

각 명령어가 **버전 번호**를 출력하면 정상 설치 완료.

---

## 🍎 macOS

### 1단계 — 터미널 열기

`⌘ + Space` → `terminal` → 엔터

### 2단계 — 명령어 복사 + 실행

`⌘ + V`로 붙여넣고 엔터:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.sh)"
```

> 처음 macOS에서 설치하면 Xcode CLT 다운로드로 시간이 더 걸립니다.

### 3단계 — 9단계 ✅ 완료까지 대기

### 4단계 — 설치 확인

**터미널 창을 완전히 닫고 새로 열어주세요.** 그 다음 한 줄씩:

```bash
node --version
python3 --version
git --version
gh --version
claude --version
code --version
```

각 명령어가 **버전 번호**를 출력하면 완료.

---

## 추가 옵션 (선택)

```powershell
# 터미널 꾸미기 (Oh My Posh) — Windows
irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/customize.ps1 | iex

# 클린 초기화 — 8개 도구 모두 제거. 재설치 테스트용 (Windows)
irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/uninstall-win.ps1 | iex
```

---

<details>
<summary><b>❓ 자주 겪는 문제</b></summary>

#### "이 시스템에서 스크립트를 실행할 수 없으므로..." (Windows)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

위 명령어 실행 후 다시 시도.

#### `명령어 --version` 했는데 "명령을 찾을 수 없습니다"

터미널/PowerShell 창을 **완전히 닫고 새로 열기**.
그래도 안 되면 컴퓨터 재시작 후 다시 확인.

#### VS Code의 `code` 명령만 안 잡힐 때

VS Code를 한 번 실행 → 새 터미널 열고 `code --version` 재시도.

#### 같은 명령어 여러 번 실행해도 되나?

네. 이미 설치된 항목은 자동 스킵됩니다.

</details>

---

## 설치되는 도구

| 도구 | 용도 |
|------|------|
| Scoop / Homebrew | 패키지 매니저 |
| Node.js | JavaScript 런타임 |
| Python 3 | Python 실행 환경 |
| Git | 버전 관리 |
| GitHub CLI (`gh`) | 깃허브 터미널 도구 |
| **Claude Code** | AI 코딩 도구 (본체) |
| VS Code | 코드 편집기 |
| VS Code 확장 + 설정 | 확장 8개 + 권장 설정 자동 적용 |

---

문의 · 버그 제보: [Issues](https://github.com/whatfontisthis/claude-setup/issues)
