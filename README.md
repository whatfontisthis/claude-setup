# Claude Code 올인원 설치

한 줄 명령어로 Claude Code + VS Code 개발 환경을 자동 설치합니다.

이미 설치된 항목은 스킵 · 여러 번 실행해도 안전 · Apple Silicon(M1~M4) 자동 대응

## Windows

**1단계.** 키보드의 `Windows` 키를 누르면 검색창이 나타납니다. 거기에 `powershell`이라고 입력하면 검색 결과 맨 위에 **Windows PowerShell**이 뜹니다. 클릭하면 파란색(또는 검은색) 명령창이 하나 열립니다. 앞으로 모든 작업은 이 창에서 진행됩니다.

**2단계.** 아래 명령어 한 줄을 통째로 복사하세요. PowerShell 창 안에서 **마우스 우클릭**을 하면 자동으로 붙여넣기가 됩니다(또는 `Ctrl + V`). 그 상태에서 엔터(↵)를 누르면 설치가 시작됩니다.

```powershell
irm https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.ps1 | iex
```

설치 도중 **"이 앱이 디바이스를 변경할 수 있도록 허용"** 같은 UAC 팝업이 뜰 수 있습니다. 정상이며, **"예"**를 클릭하면 됩니다.

**3단계.** 화면에 `[1/8]`부터 `[8/8]`까지 순서대로 진행 상황이 출력됩니다. 보통 5~10분 정도 걸리니 그동안 다른 일을 해도 됩니다. 마지막에 ✓ 표시들이 뜨면 설치가 끝난 것입니다.

**4단계.** 설치된 도구들을 PowerShell이 인식하려면 **창을 X 버튼으로 완전히 닫고 새 창을 다시 열어주세요.** 그 다음 아래 명령어를 한 줄씩 실행해 각 도구가 제대로 깔렸는지 확인합니다.

```powershell
node --version
python --version
git --version
gh --version
claude --version
code --version
```

각 명령어가 `v22.x.x` 같은 **버전 번호**를 출력하면 정상입니다. 만약 "명령을 찾을 수 없습니다"가 나오면 아래 **자주 겪는 문제** 섹션을 확인하세요.

## macOS

**1단계.** 키보드에서 `⌘ + Space`를 동시에 누르면 화면 가운데에 검색창(Spotlight)이 뜹니다. `terminal`이라고 입력하고 엔터를 누르면 검은 배경의 명령창이 열립니다.

**2단계.** 아래 명령어를 복사한 뒤 터미널 창에서 `⌘ + V`로 붙여넣고 엔터를 누르세요.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/whatfontisthis/claude-setup/main/install.sh)"
```

**처음 설치하는 Mac이라면** Xcode Command Line Tools 다운로드 단계에서 별도 팝업이 뜨고 시간이 꽤 걸릴 수 있습니다(인터넷 속도에 따라 10~20분). 팝업이 뜨면 **"설치"**를 클릭하고 끝날 때까지 기다려주세요.

**3단계.** `[1/9]`부터 `[9/9]`까지 진행 단계가 표시됩니다. 마지막에 ✓ 표시들이 다 뜨면 완료입니다.

**4단계.** 터미널 창을 완전히 닫고(`⌘ + Q`) 새로 열어주세요. 그 다음 아래 명령어를 한 줄씩 실행합니다.

```bash
node --version
python3 --version
git --version
gh --version
claude --version
code --version
```

각 명령어가 버전 번호를 출력하면 완료입니다.

## 자주 겪는 문제

<details>
<summary>"이 시스템에서 스크립트를 실행할 수 없으므로..." (Windows)</summary>

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

위 명령어 실행 후 다시 시도.
</details>

<details>
<summary>"명령을 찾을 수 없습니다"</summary>

터미널/PowerShell 창을 완전히 닫고 새로 열기. 그래도 안 되면 컴퓨터 재시작 후 다시 확인.
</details>

<details>
<summary>VS Code의 code 명령만 안 잡힐 때</summary>

VS Code를 한 번 실행 → 새 터미널 열고 `code --version` 재시도.
</details>

<details>
<summary>같은 명령어 여러 번 실행해도 되나?</summary>

네. 이미 설치된 항목은 자동 스킵됩니다.
</details>

## 설치되는 도구

| 도구 | 용도 |
|------|------|
| Scoop / Homebrew | 패키지 매니저 |
| Node.js | JavaScript 런타임 |
| Python 3 | Python 실행 환경 |
| Git | 버전 관리 |
| GitHub CLI (`gh`) | 깃허브 터미널 도구 |
| Claude Code | AI 코딩 도구 (본체) |
| VS Code | 코드 편집기 |
| VS Code 확장 + 설정 | 확장 8개 + 권장 설정 자동 적용 |

문의 · 버그: [Issues](https://github.com/whatfontisthis/claude-setup/issues)
