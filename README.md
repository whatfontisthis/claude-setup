# Claude Code 올인원 설치

터미널에 한 줄 복사하면 클로드 코드 + VS Code 환경이 자동 세팅됩니다.

> 비개발자도 따라 할 수 있도록 단계별로 설명합니다. 막히면 README 아래쪽 **자주 겪는 문제** 부분을 보세요.

---

## Windows 사용자

### 1단계 — PowerShell 열기

1. 키보드에서 **`Windows`** 키를 누르세요.
2. **`powershell`** 이라고 입력하세요.
3. 검색 결과에 뜨는 **`Windows PowerShell`**을 클릭해서 실행하세요.

> 검은색 또는 파란색 글자 창이 하나 열리면 성공입니다.

### 2단계 — 명령어 복사 & 붙여넣기

아래 명령어를 통째로 복사하세요. (코드 블록 오른쪽 위 📋 아이콘 클릭)

```powershell
irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.ps1 | iex
```

PowerShell 창에 **마우스 우클릭**하면 자동으로 붙여넣기 됩니다.
(또는 `Ctrl + V`)

### 3단계 — 엔터 치고 기다리기

엔터(↵)를 누르면 자동으로 8가지가 순서대로 설치됩니다:

| 순서 | 설치 항목 | 용도 |
|------|----------|------|
| 1 | Scoop | 윈도우용 앱스토어 (다른 도구 설치에 필요) |
| 2 | Node.js | 자바스크립트 실행 환경 |
| 3 | Python 3 | 파이썬 실행 환경 |
| 4 | Git | 코드 버전 관리 도구 |
| 5 | GitHub CLI | 깃허브 터미널 도구 |
| 6 | **Claude Code** | AI 코딩 도구 (이게 본체) |
| 7 | VS Code | 코드 편집기 |
| 8 | VS Code 설정 | 확장 프로그램 + 추천 설정 자동 적용 |

✅ 표시가 8개 다 뜨면 완료입니다. (보통 5~10분 소요)

### 4단계 — Claude Code 실행

PowerShell 창에 다음을 입력하고 엔터:

```powershell
claude
```

처음 실행하면 Anthropic 계정 연결 안내가 나옵니다. 화면 안내대로 따라가세요.

---

## macOS 사용자

### 1단계 — 터미널 열기

`Command(⌘) + Space` → `terminal` 입력 → 엔터

### 2단계 — 명령어 복사 & 붙여넣기

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.sh)"
```

`Command(⌘) + V`로 붙여넣고 엔터.

### 3단계 — 기다리기

설치 항목: Xcode CLT → Homebrew → Node.js → Python 3 → Git → Claude Code

### 4단계 — 실행

```bash
claude
```

---

## 추가 옵션 (선택사항, 안 해도 됨)

### 터미널 꾸미기 (Windows)

PowerShell 프롬프트를 예쁘게 + 깃 정보 자동 표시:

```powershell
irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/customize.ps1 | iex
```

### 클린 초기화 (Windows, 개발자 테스트용)

설치를 처음부터 다시 하고 싶을 때만 사용. **Node/Python/Git까지 다 지웁니다.**

```powershell
irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/uninstall-win.ps1 | iex
```

---

## 자주 겪는 문제

### "이 시스템에서 스크립트를 실행할 수 없으므로..." 에러가 떠요 (Windows)

PowerShell 보안 정책 때문입니다. PowerShell 창에서 아래 명령어를 한 번 실행하고 다시 시도하세요:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### `claude` 입력했는데 "명령을 찾을 수 없습니다"

PowerShell(또는 터미널) 창을 **완전히 닫았다가 다시 열어주세요**. 새 창에서 다시 `claude` 입력.

### VS Code의 `code` 명령을 못 찾는다고 나와요

스크립트가 친절히 안내하는데, 그래도 안 되면:

1. VS Code를 한 번 실행해주세요 (시작 메뉴 → Visual Studio Code)
2. PowerShell 창을 새로 열고 스크립트를 다시 실행

### 이미 설치된 게 있어도 괜찮나요?

네. 이미 설치된 항목은 자동으로 스킵합니다. 같은 명령어를 여러 번 실행해도 안전합니다.

---

## 무엇이 설치되나요? (요약)

| 도구 | 용도 |
|------|------|
| Scoop / Homebrew | 패키지 매니저 (앱스토어 같은 것) |
| Node.js | JavaScript 런타임 |
| Python 3 | 파이썬 실행 환경 |
| Git | 버전 관리 |
| GitHub CLI | 깃허브 터미널 도구 |
| Claude Code | AI와 대화하며 일하는 터미널 도구 |
| VS Code | 코드 편집기 |
| VS Code 확장 + 설정 | 추천 확장 8개 + 권장 설정 자동 적용 |

- 이미 설치된 항목은 자동으로 스킵
- Apple Silicon(M1~M4) 자동 대응
- 설치 중 진행 상황이 한국어로 표시됩니다

---

문의 / 버그 제보: [Issues](https://github.com/whatfontisthis/claude-setup/issues)
