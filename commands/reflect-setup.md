Inner Compass 초기 설정을 진행합니다.

## 플로우

### Step 1: 기존 설정 확인
`~/.inner-compass/config.md`가 존재하는지 확인합니다.
이미 존재하면 현재 설정을 보여주고 변경할지 물어봅니다.

### Step 2: Obsidian vault 경로
사용자에게 물어봅니다:

"Obsidian vault 경로를 알려주세요.
Obsidian을 사용하지 않으면 Enter를 누르세요.
예: ~/Documents/MyVault"

- 경로가 입력된 경우: 해당 경로가 존재하는지 확인
  - 존재하면 `{vault}/Inner-Compass/sessions/` 디렉토리 생성
  - 존재하지 않으면 경로 확인 요청
- Enter (빈 입력): 기본 경로(`~/.inner-compass/sessions/`) 사용

### Step 3: 디렉토리 생성
필요한 디렉토리를 생성합니다:
- `~/.inner-compass/` (설정 저장)
- 세션 저장 디렉토리 (vault 또는 기본 경로)
- 세션 저장 경로의 perspectives/ 디렉토리 (렌즈별 해석 저장)

### Step 4: 설정 저장
`~/.inner-compass/config.md`에 설정을 저장합니다.

### Step 5: 완료 안내
"✓ Inner Compass 설정 완료!

세션 저장 경로: {경로}
사용법: /reflect 로 탐색 세션을 시작하세요."

💡 렌즈(Lens)란 같은 생각을 다른 철학적 관점으로 탐색하는 것입니다.
기본은 소크라테스(숨겨진 가정 찾기)이고,
/reflect --lens camus 처럼 다른 렌즈를 지정할 수 있습니다.
