# 바이브코딩 올인원 설치

명령어 한 줄로 바이브코딩에 필요한 도구를 전부 설치합니다.

AI 앱(Claude 또는 ChatGPT의 Codex)과 Next.js, Python, GitHub, Vercel, Supabase를 쓰는 데 필요한 것들입니다. 이미 설치된 항목은 건너뛰므로 여러 번 실행해도 괜찮습니다.

&nbsp;

## Windows

1. **PowerShell 열기**

    시작 버튼 → `powershell` 입력 → **Windows PowerShell** 클릭. "관리자로 실행"은 하지 않아도 됩니다.

2. **설치 명령어 실행**

    아래 명령어를 복사해서 PowerShell 창에 우클릭으로 붙여넣고 엔터.

    ```powershell
    irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.ps1 | iex
    ```

3. **AI 앱 고르기**

    `1` Claude, `2` ChatGPT(Codex), `3` 둘 다. 번호를 입력하고 엔터.

    그다음은 `[1/10]`부터 `[10/10]`까지 알아서 진행됩니다. 10분 정도 걸립니다. 중간에 "예"를 누르라는 팝업이 나오면 "예"를 누르세요.

4. **로그인**

    PowerShell 창을 닫고 새로 연 뒤, 아래 명령어를 실행합니다. GitHub, Vercel, Supabase 순서로 로그인 화면이 뜹니다.

    ```powershell
    irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/login.ps1 | iex
    ```

5. **AI 앱 열기**

    Claude 또는 ChatGPT 앱을 열고, 프로젝트 폴더로 `C:\projects` 안에 새 폴더를 만들어 선택합니다.

&nbsp;

## macOS

1. **터미널 열기**

    `⌘ + Space` → `terminal` 입력 → 엔터

2. **설치 명령어 실행**

    아래 명령어를 복사해서 터미널에 `⌘ + V`로 붙여넣고 엔터.

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.sh)"
    ```

3. **AI 앱 고르기**

    `1` Claude, `2` ChatGPT(Codex), `3` 둘 다. 번호를 입력하고 엔터.

    Mac 비밀번호를 물으면 입력하고 엔터. 입력해도 화면에 아무것도 안 보이는 게 정상입니다. 처음 설정하는 Mac이면 Xcode 설치 팝업이 뜨는데, "설치"를 누르면 10~20분이 더 걸립니다.

4. **로그인**

    터미널을 `⌘ + Q`로 완전히 끄고 다시 연 뒤, 아래 명령어를 실행합니다.

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/login.sh)"
    ```

5. **AI 앱 열기**

    Claude 또는 ChatGPT 앱을 열고, 프로젝트 폴더로 `~/projects` 안에 새 폴더를 만들어 선택합니다.

&nbsp;

## 로그인할 때 알아둘 것

Vercel이나 Supabase 계정이 없으면 로그인 화면에서 **Continue with GitHub**를 누르세요. GitHub 계정 하나로 세 서비스를 다 쓸 수 있어서 비밀번호를 따로 외울 필요가 없습니다.

| 서비스 | 터미널에서 할 일 | 브라우저에서 할 일 |
|------|------|------|
| GitHub | 질문에 엔터, 8자리 코드 확인 후 엔터 | 코드 입력 → Authorize |
| Vercel | 엔터 | 로그인 → 코드가 같은지 확인하고 승인 |
| Supabase | 엔터, 브라우저의 인증 코드를 붙여넣고 엔터 | 로그인 → 인증 코드 복사 |

&nbsp;

## 자주 겪는 문제

<details>
<summary>"이 시스템에서 스크립트를 실행할 수 없으므로..." (Windows)</summary>

설치 명령어를 한 번 더 실행하세요. 설치 스크립트가 이 설정을 풀어줍니다.

그래도 계속 나오면 학교나 회사가 관리하는 PC일 가능성이 높습니다. 이 경우는 PC 관리자만 풀 수 있습니다.
</details>

<details>
<summary>"명령을 찾을 수 없습니다" / "인식되지 않습니다"</summary>

PowerShell(또는 터미널) 창을 완전히 닫고 새로 여세요. 그래도 안 되면 컴퓨터를 재시작하세요.
</details>

<details>
<summary>AI 앱이 "node가 없다", "gh가 없다"고 할 때</summary>

설치하기 전에 앱을 켜뒀다면 새로 설치된 도구를 못 봅니다. 앱을 완전히 종료하고 다시 켜세요.

- Windows: 작업 표시줄 오른쪽 아래 아이콘 우클릭 → 종료
- Mac: 앱을 띄운 상태에서 `⌘ + Q`
</details>

<details>
<summary>python을 치면 Microsoft Store가 열릴 때 (Windows)</summary>

설정 → 앱 → 고급 앱 설정 → 앱 실행 별칭에서 `python.exe`, `python3.exe`를 끄고 설치 명령어를 다시 실행하세요.
</details>

<details>
<summary>프로젝트를 바탕화면이나 문서 폴더에 만들면 안 되나요?</summary>

안 하는 게 좋습니다. 바탕화면과 문서는 OneDrive나 iCloud가 동기화하는 경우가 많고, Next.js 프로젝트의 수만 개 파일이 동기화되면서 설치가 깨지거나 아주 느려집니다. Windows는 `C:\projects`, Mac은 `~/projects`를 쓰세요.
</details>

<details>
<summary>여러 번 실행해도 되나요?</summary>

네. 이미 설치된 항목은 건너뛰고, 실패한 것만 다시 시도합니다. 로그인 명령어도 마찬가지입니다.
</details>

&nbsp;

## 설치되는 도구

| 도구 | 용도 |
|------|------|
| Claude / ChatGPT 앱 | AI 코딩 (고른 것만 설치) |
| Git | 버전 관리 |
| Node.js | Next.js 실행 |
| Python 3, uv | Python 실행, 패키지 관리 |
| GitHub CLI (`gh`) | GitHub 로그인, 저장소 관리 |
| Vercel CLI | 웹사이트 배포 |
| Supabase CLI | 데이터베이스 관리 |
| Scoop (Windows) / Homebrew (Mac) | 위 도구들을 설치하는 프로그램 |

&nbsp;

문의 · 버그: [Issues](https://github.com/whatfontisthis/claude-setup/issues)
