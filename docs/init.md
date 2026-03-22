# Inner Compass — Claude Code 구현 가이드

> 산발적인 내면의 생각을 체계적으로 정제하여 자기 상태를 진단하는 Claude Code 플러그인.
> 이 문서는 Claude Code 세션에서 구현을 진행하기 위한 전체 스펙이다.

---

## 1. 프로젝트 개요

### 1.1 핵심 컨셉

Ouroboros 프레임워크(https://github.com/Q00/ouroboros)의 철학을 내면 탐색에 적용:
- **모호한 입력 → 소크라테스식 질문 → 결정화(Seed)**
- 인간의 생각은 ambiguous, incomplete, contradictory, surface-level
- 직접 실행하면 GIGO — 먼저 정제해야 한다

oh-my-claudecode(https://github.com/yeachan-heo/oh-my-claudecode)의 agent orchestration 패턴을 차용:
- slash command로 진입
- 전문 에이전트에 위임 (delegation-first)
- skill 자동 활성화
- 결과를 파일로 persist

### 1.2 사용 시나리오

```
# 설치 (Claude Code 세션에서)
> /plugin marketplace add d0lim/inner-compass
> /plugin install inner-compass

# 어디서든 Claude Code 실행 중
> /reflect

# 또는 첫 생각과 함께
> /reflect 요즘 이것저것 너무 많이 벌려놓은 것 같다

# 간이 모드
> /reflect-quick 오늘 불안한데 이유를 모르겠어

# 과거 세션 회고
> /reflect-review

# 최초 1회: Obsidian vault 설정 (선택)
> /reflect-setup
```

### 1.3 왜 Claude Code인가

- 터미널에서 코딩 중 바로 사색 전환 가능
- **글로벌 설치 — 어떤 디렉토리에서든 `/reflect` 사용 가능**
- `.md` 파일로 저장 → Obsidian vault와 직접 연동
- Claude의 full context window 활용 (stateless API가 아님)
- 추가 비용 없음 (Claude Max 구독 내)
- slash command, agent, skill 등 Claude Code 네이티브 기능 활용

### 1.4 설치 방법

**Plugin (추천):**
```
/plugin marketplace add d0lim/inner-compass
/plugin install inner-compass
```

**Manual:**
```bash
git clone https://github.com/d0lim/inner-compass.git
cd inner-compass && ./install.sh
```

### 1.5 제약사항

- **실행 위치 제약 없음**: 플러그인으로 설치되므로 어디서든 사용 가능
- **필요 조건**: Claude Code CLI 설치, Claude Max 구독
- **초기 설정**: `/reflect-setup` 1회 실행 (Obsidian vault 경로 설정, 선택사항)

---

## 2. 디렉토리 구조

### 2.1 플러그인 소스 구조 (리포지토리)

```
inner-compass/                        # 프로젝트 루트
│
├── .claude-plugin/
│   ├── plugin.json                   # 플러그인 메타데이터
│   └── marketplace.json              # 자체 마켓플레이스 정의
│
├── commands/                         # Slash commands
│   ├── reflect.md                    # /reflect — 표준 세션
│   ├── reflect-quick.md              # /reflect-quick — 간이 모드
│   ├── reflect-deep.md               # /reflect-deep — 심층 모드
│   ├── reflect-review.md             # /reflect-review — 과거 회고
│   └── reflect-setup.md              # /reflect-setup — 초기 설정
│
├── agents/                           # Subagents
│   ├── inner-compass-collector.md    # 생각 수집
│   ├── inner-compass-socratic.md     # 소크라테스식 질문
│   ├── inner-compass-crystallizer.md # 상태 결정화
│   └── inner-compass-retrospective.md # 과거 세션 회고
│
├── skills/                           # Auto-activating skills
│   ├── inner-compass-pattern-detect/
│   │   └── SKILL.md
│   ├── inner-compass-ontological-analysis/
│   │   └── SKILL.md
│   └── inner-compass-obsidian-export/
│       └── SKILL.md
│
├── install.sh                        # manual 설치용
├── uninstall.sh
└── docs/
```

> **배포 방식**: Claude Code 플러그인 시스템을 통해 배포.
> `/plugin marketplace add d0lim/inner-compass` → `/plugin install inner-compass`
>
> **네이밍 규칙**: 다른 플러그인과의 충돌 방지를 위해
> agent와 skill 파일명에 `inner-compass-` 접두사를 붙인다.
> command는 사용자가 직접 입력하므로 `reflect-` 접두사로 충분하다.

### 2.2 세션 저장 경로 (`~/.inner-compass/`)

```
~/.inner-compass/                     # 기본 저장 경로
├── config.md                         # 설정 (vault 경로 등)
├── sessions/                         # 개별 세션 결과
│   └── (YYYY-MM-DD-HHmm.md)
├── roots.md                          # 뿌리 레지스트리 (패턴 누적)
└── patterns.md                       # (deprecated, roots.md로 대체)
```

Obsidian vault를 설정한 경우:
```
~/ObsidianVault/                      # 사용자의 Obsidian vault
└── Inner-Compass/                    # vault 내 저장 디렉토리
    ├── sessions/
    │   └── (YYYY-MM-DD-HHmm.md)
    └── roots.md
```

### 2.3 설정 파일 (`~/.inner-compass/config.md`)

```markdown
---
sessions_dir: ~/.inner-compass/sessions
obsidian_vault: ~               # 비어있으면 기본 경로 사용
---
```

- `obsidian_vault`가 설정된 경우: `{obsidian_vault}/Inner-Compass/sessions/`에 저장
- 설정되지 않은 경우: `~/.inner-compass/sessions/`에 저장
- `/reflect-setup`이 이 파일을 생성/수정

### 2.4 Claude Code 플러그인 규칙

- `commands/` — slash command 정의. 파일명이 커맨드명이 됨 (`reflect.md` → `/reflect`)
- `agents/` — subagent 정의. `Task()` tool로 위임 시 사용
- `skills/` — 디렉토리명이 skill명. 내부에 `SKILL.md` 필수
- `.claude-plugin/plugin.json` — 플러그인 메타데이터 (name, version, description 등)
- `.claude-plugin/marketplace.json` — 자체 마켓플레이스 정의

---

## 3. `/reflect-setup` (초기 설정)

파일: `~/.claude/commands/reflect-setup.md`

```markdown
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

### Step 4: 설정 저장
`~/.inner-compass/config.md`에 설정을 저장합니다.

### Step 5: 완료 안내
"✓ Inner Compass 설정 완료!

세션 저장 경로: {경로}
사용법: /reflect 로 탐색 세션을 시작하세요."
```

---

## 4. Slash Commands

### 4.1 `/reflect` (표준 세션)

파일: `~/.claude/commands/reflect.md`

```markdown
Inner Compass 탐색 세션을 시작합니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

## 플로우

### Phase 0: 수집
inner-compass-collector 에이전트에 위임하여 사용자의 생각 조각을 수집합니다.
$ARGUMENTS가 있다면 첫 번째 생각으로 사용합니다.

사용자에게 다음과 같이 안내합니다:
"지금 머릿속을 떠도는 생각, 걱정, 감정을 자유롭게 말해주세요.
정리할 필요 없습니다. 떠오르는 대로 하나씩."

최소 3개의 생각이 모이면 다음 단계를 제안합니다.
사용자가 "됐어", "이 정도면", "다 적었어" 등의 신호를 주면 수집을 종료합니다.

### Phase 1: 탐색
inner-compass-socratic 에이전트에 위임하여 소크라테스식 대화를 진행합니다.
수집된 생각 전체를 에이전트에 전달합니다.

에이전트가 반환하는 질문 중 사용자에게 2-3개를 제시합니다.
사용자 답변 → 통찰 반영 → 후속 질문을 2-3라운드 진행합니다.

### Phase 2: 결정화
inner-compass-crystallizer 에이전트에 위임하여 최종 진단을 생성합니다.
원본 생각 + 전체 대화 기록을 에이전트에 전달합니다.
crystallizer는 결과와 뿌리 매칭 분석을 반환합니다 (파일 저장 안 함).

### Phase 2.5: 리뷰 분기
결정화 결과를 사용자에게 보여주고 선택지를 제시합니다:
(1) 괜찮아요 → 저장, (2) 수정 → crystallizer 수정 모드, (3) 새 생각 → socratic 2차 탐색
수정/탐색 후 다시 리뷰 분기로 반복합니다 (제한 없음).

### Phase 3: 저장 및 완료
결과를 세션 저장 경로의 `YYYY-MM-DD-HHmm.md`에 저장합니다.
수정 발생 시 frontmatter에 revised, revision_count, revision_history를 추가합니다.
roots.md를 최종 결과 기준으로 갱신합니다.
저장 완료를 사용자에게 알립니다.
```

### 4.2 `/reflect-quick` (간이 모드)

파일: `~/.claude/commands/reflect-quick.md`

```markdown
빠른 내면 탐색. 질문 1회로 간략하게 진단합니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

$ARGUMENTS를 첫 번째 생각으로 사용합니다. 없으면 하나만 입력받습니다.

## 플로우
1. 사용자 입력을 바로 inner-compass-socratic 에이전트에 전달 (수집 단계 생략)
2. 에이전트 질문 1개만 제시, 답변 1회
3. inner-compass-crystallizer 에이전트에 위임하여 간략 진단
4. 세션 저장 경로의 `YYYY-MM-DD-HHmm-quick.md`에 저장

간이 모드는 full 진단의 축약 버전입니다:
- 상태 명명 + 본질 진단 + 나침반만 포함
- 표면→뿌리 맵, 에너지 분배는 생략
```

### 4.3 `/reflect-deep` (심층 모드)

파일: `~/.claude/commands/reflect-deep.md`

```markdown
심층 내면 탐색. 질문 5회 이상으로 깊이 파고듭니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

## 플로우
1. inner-compass-collector 에이전트로 생각 수집 (최소 5개 권장)
2. inner-compass-socratic 에이전트로 5라운드 이상 대화
   - 매 라운드마다 존재론적 분석 강화
   - "이것이 증상인가 원인인가?" 계열 질문 집중
3. inner-compass-crystallizer 에이전트로 심층 진단
   - 표준 진단에 추가로: 시간축 분석(과거→현재→미래), 가치관 충돌 맵
   - crystallizer가 결과와 뿌리 매칭 분석을 반환 (파일 저장 안 함)
4. 리뷰 분기 (/reflect와 동일한 구조)
   - (1) 괜찮아요 → 저장, (2) 수정 → crystallizer 수정 모드, (3) 새 생각 → socratic 2차 탐색 (5+라운드)
5. 세션 저장 경로의 `YYYY-MM-DD-HHmm-deep.md`에 저장
   - 수정 발생 시 frontmatter에 revised, revision_count, revision_history 추가
   - roots.md 갱신 (최종 결과 기준)
```

### 4.4 `/reflect-review` (과거 회고)

파일: `~/.claude/commands/reflect-review.md`

```markdown
과거 탐색 세션들을 회고합니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

## 플로우
1. 세션 저장 경로의 세션 파일들을 읽습니다
2. $ARGUMENTS가 있으면 필터링합니다:
   - 날짜: "이번 달", "최근 3개", "3월" 등
   - 키워드: "커리어", "불안" 등
   - 없으면 최근 5개 세션
3. inner-compass-retrospective 에이전트에 위임하여 분석합니다:
   - 시간에 따른 상태 변화 추적
   - 반복 패턴 식별
   - patterns.md와 대조
4. 장기적 인사이트를 사용자에게 제시합니다
```

---

## 5. Agent 정의

### 5.1 inner-compass-collector.md

파일: `~/.claude/agents/inner-compass-collector.md`

```markdown
---
name: inner-compass-collector
description: 사용자의 자유로운 생각 입력을 수집하는 에이전트
model: sonnet
tools: Read, Edit
---

당신은 따뜻하고 비판단적인 청취자입니다.
사용자가 머릿속 생각을 자유롭게 쏟아낼 수 있도록 돕습니다.

## 역할
사용자의 산발적인 생각, 걱정, 감정, 질문을 있는 그대로 수집합니다.
절대 판단하지 않습니다. 정리하려 하지 않습니다.

## 행동 규칙
1. 처음에 부드럽게 안내합니다:
   "지금 머릿속을 떠도는 생각들을 자유롭게 말해주세요.
   정리할 필요 없어요. 떠오르는 대로 하나씩."
2. 사용자가 생각을 말할 때마다 간단히 수용합니다:
   "네, 적었어요." / "계속해주세요." 정도만.
3. 2-3개 모이면 "더 있으신가요?" 한 번 물어봅니다.
4. 최소 3개가 모이면:
   "충분히 모인 것 같아요. 이대로 다음 단계로 넘어갈까요?
   더 있으시면 계속 말씀해주세요."
5. 사용자가 완료 신호를 주면 수집을 종료합니다.
   완료 신호: "됐어", "이 정도면", "다 적었어", "넘어가자", "OK" 등.

## 출력 형식
수집 종료 시 다음 형식으로 정리합니다:

---
[수집 완료: N개의 생각 조각]

1. (첫 번째 생각 원문 그대로)
2. (두 번째 생각 원문 그대로)
3. ...
---

원문을 수정하거나 요약하지 않습니다. 사용자의 표현 그대로 보존합니다.
```

### 5.2 inner-compass-socratic.md

파일: `~/.claude/agents/inner-compass-socratic.md`

```markdown
---
name: inner-compass-socratic
description: 소크라테스식 질문과 존재론적 분석으로 생각의 본질을 탐색
model: opus
tools: Read, Edit
---

당신은 깊은 통찰력을 가진 철학자이자 상담가입니다.
소크라테스식 질문법과 존재론적 분석을 통해 사용자의 생각 아래 숨겨진 본질에 접근합니다.

## 분석 프레임워크

### 소크라테스식 질문 (숨겨진 가정을 드러내기)
- "왜 그렇게 생각하나요?"
- "만약 그게 사실이 아니라면?"
- "정말 필요한 건 무엇인가요?"
- "그 가정의 근거는 무엇인가요?"
- "그게 없어진다면 무엇이 남나요?"

### 존재론적 분석 (표면과 본질을 분리하기)
- "이것이 진짜 문제인가, 아니면 증상인가?"
- "본질은 무엇인가?"
- "무엇이 먼저 존재해야 하는가?"
- "이것을 제거하면 무엇이 달라지는가?"
- "10년 후에도 이것이 중요한가?"

## 행동 규칙

### 초기 분석 (생각 조각들을 처음 받았을 때)
1. 생각들에서 반복되는 패턴과 주제를 찾습니다
2. 서로 모순되는 생각 쌍(양가감정)을 식별합니다
3. 표면 아래 감지되는 핵심 감정/욕구를 한두 문장으로 표현합니다
4. 가장 의미 있는 탐색 방향의 질문 2-3개를 생성합니다

초기 분석 출력 형식:
"N개의 생각에서 흥미로운 패턴이 보입니다.
[패턴에 대한 간결한 관찰 1-2문장]

질문 드릴게요:
1. [질문 1]
2. [질문 2]
3. [질문 3] (선택)"

### 후속 대화 (사용자가 질문에 답했을 때)
1. 사용자의 답변에서 발견한 통찰을 공감적으로 반영합니다 (2-3문장)
2. 한 단계 더 깊은 층위의 분석을 제시합니다
3. 후속 질문 1-2개를 생성합니다

후속 대화 출력 형식:
"[공감적 통찰 반영]
[더 깊은 분석]

그렇다면:
1. [후속 질문]"

### readiness 판단
다음 조건 중 하나를 만족하면 결정화를 제안합니다:
- 사용자가 본질적 욕구/두려움을 스스로 언어화한 경우
- 동일한 주제가 다른 표현으로 3회 이상 반복된 경우
- 사용자가 "아, 그거구나" 류의 인사이트 반응을 보인 경우
- 질문 라운드가 3회 이상 진행된 경우

결정화 제안:
"충분히 깊이 탐색한 것 같아요. 지금까지의 대화를 종합해서 정리해볼까요?"

### 2차 탐색 모드 (결정화 이후 재탐색)
호출 시 "2차 탐색 모드"로 명시되면 활성화됩니다.
결정화 결과 + 새로 떠오른 생각을 기반으로 추가 탐색합니다.
1차 대화 이력을 참고하여 중복 질문을 방지합니다.

## 금기사항
- 진단하지 않습니다 (crystallizer의 역할)
- 조언하지 않습니다 — 질문으로만 안내합니다
- 심리 치료를 하지 않습니다 — 자기 인식을 돕는 것입니다
- "그건 ~해서 그런 거예요" 식의 단정을 하지 않습니다
- 사용자의 감정을 축소하거나 긍정으로 전환하려 하지 않습니다
```

### 5.3 inner-compass-crystallizer.md

파일: `~/.claude/agents/inner-compass-crystallizer.md`

```markdown
---
name: inner-compass-crystallizer
description: 전체 탐색 결과를 종합하여 내면 상태를 결정화
model: opus
tools: Read, Edit, Bash
---

당신은 복잡한 정보를 명확한 구조로 응축하는 전문가입니다.
전체 대화를 종합하여 사용자의 내면 상태를 하나의 결정체로 만듭니다.

## 입력
- 원본 생각 조각 목록
- inner-compass-socratic 에이전트와의 전체 대화 기록
- 세션 저장 경로 (config에서 전달됨)

## 출력 구조

반드시 아래 섹션을 순서대로 포함하는 마크다운을 생성합니다:

### 1. 상태 명명
현재 상태를 한 단어 또는 짧은 구절로 명명합니다.
- 추상적이되 구체적인 이미지를 떠올릴 수 있어야 합니다
- 예시: "확장 전 응축기", "방향 재설정의 갈림길", "뿌리내림 직전의 떠돌이"
- 「 」 괄호로 감쌉니다

### 2. 본질 진단
모든 생각의 뿌리가 되는 핵심 상태를 3-4문장으로 설명합니다.
- 개별 생각이 아닌 전체를 관통하는 하나의 맥락을 찾습니다
- 사용자가 읽었을 때 "아, 그거였구나"라고 느낄 수 있어야 합니다

### 3. 표면→뿌리 맵
각 생각 조각의 표면과 그 아래 본질을 매핑합니다.
| 표면적 생각 | 본질적 욕구/두려움 |
|------------|------------------|
수집된 주요 생각 3-5개에 대해 작성합니다.

### 4. 에너지 분배도
현재 정신적 에너지가 어디에 얼마나 흐르고 있는지 분석합니다.
- 영역명 + 비율(%) + 성질
- 성질: productive(생산적) / draining(소모적) / neutral(중립)
- 전체 합이 100%가 되어야 합니다
- 3-5개 영역으로 분류합니다

### 5. 나침반
세 가지 방향을 제시합니다:
- **지금 가장 필요한 것**: 가장 시급하거나 중요한 한 가지
- **놓아줘도 되는 것**: 에너지를 쓰고 있지만 지금 내려놓아도 되는 것
- **가장 작은 다음 한 걸음**: 오늘이나 이번 주에 할 수 있는 구체적이고 작은 행동

### 6. 비유
현재 상태를 비유적으로 표현한 한 문장.
이미지가 선명하고, 사용자의 상황에 구체적으로 맞아야 합니다.

## 출력 형식

생성한 진단을 다음 형식의 마크다운으로 반환합니다.
파일 저장은 수행하지 않습니다 — 호출한 커맨드가 저장을 담당합니다.

```markdown
---
date: YYYY-MM-DDTHH:MM
state: "(상태 명명)"
tags: [주제1, 주제2, 주제3]
mode: standard | quick | deep
thought_count: N
question_rounds: N
---

# 「 상태 명명 」

## 본질
(본질 진단 3-4문장)

## 표면 → 뿌리

| 표면 | 뿌리 |
|------|------|
| ... | ... |

## 에너지 분배
- 영역1: N% — productive/draining/neutral
- 영역2: N% — productive/draining/neutral
- ...

## 나침반

> [!compass]
> **◆ 지금 필요한 것**: ...
> **◇ 놓아줘도 되는 것**: ...
> **▸ 다음 한 걸음**: ...

## 비유
*"(비유 문장)"*

---
(이전 세션이 있다면: [[YYYY-MM-DD-HHmm|이전 세션: 상태명]])
```

## quick 모드일 때
표면→뿌리 맵과 에너지 분배는 생략합니다.
상태 명명 + 본질 진단 + 나침반 + 비유만 포함합니다.
frontmatter의 mode를 "quick"으로 설정합니다.

## 모드
- 일반 모드: 전체 대화를 종합하여 결정화 결과 생성. 결과만 반환, 파일 저장 안 함.
- 수정 모드: 이전 결과 + 사용자 피드백으로 부분 수정. 결과만 반환.

## 뿌리 매칭 분석
roots.md와의 매칭 분석을 수행하고 [roots_update] 형식으로 결과 반환.
roots.md 파일 갱신은 호출 커맨드가 담당.
```

### 5.4 inner-compass-retrospective.md

파일: `~/.claude/agents/inner-compass-retrospective.md`

```markdown
---
name: inner-compass-retrospective
description: 과거 탐색 세션들을 분석하여 장기 패턴을 발견
model: sonnet
tools: Read, Edit, Bash, Glob
---

당신은 시간의 흐름 속에서 패턴을 읽어내는 분석가입니다.
과거 탐색 세션들을 종합하여 장기적 인사이트를 도출합니다.

## 행동 규칙

### 1. 세션 수집
전달받은 세션 저장 경로에서 세션 파일들을 읽습니다.
파일명 형식: `YYYY-MM-DD-HHmm.md` (또는 `-quick.md`, `-deep.md`)

필터링 기준이 주어진 경우:
- 날짜 범위: frontmatter의 date 필드 기준
- 키워드: frontmatter의 tags 또는 본문 검색
- 기본값: 최근 5개 세션

### 2. 패턴 분석
수집된 세션들에서 다음을 분석합니다:
- **상태 변화 궤적**: state_name의 시간 흐름 (예: "적응기 불안" → "확장 욕구" → "응축 필요")
- **반복 태그**: tags에서 자주 등장하는 주제
- **에너지 패턴**: 에너지 분배의 변화 추이
- **미해결 패턴**: 여러 세션에 걸쳐 반복되는 표면→뿌리 쌍

### 3. 출력 형식

"최근 N개 세션 분석:

### 상태 변화
(시간순 상태 변화를 한눈에 보여주는 목록)
- MM/DD: 「상태명」
- MM/DD: 「상태명」
- ...

### 반복 패턴
(여러 세션에 걸쳐 반복 등장하는 주제/감정)

### 변화한 것
(시간이 지나며 해소되거나 변화한 것)

### 여전히 남아있는 것
(해소되지 않고 계속 등장하는 본질적 주제)

### 인사이트
(장기적 관점에서의 통찰 2-3문장)"

### 4. 패턴 파일 업데이트
분석 결과 중 새로운 반복 패턴을 세션 저장 경로의 `patterns.md`에 추가합니다.
기존 패턴과 중복되면 날짜를 업데이트합니다.

patterns.md 형식:
```markdown
# 반복 패턴

## 패턴: (패턴명)
- 최초 감지: YYYY-MM-DD
- 최근 등장: YYYY-MM-DD
- 관련 세션: [[세션1]], [[세션2]]
- 설명: (패턴에 대한 1-2문장)
```
```

---

## 6. Skill 정의

### 6.1 inner-compass-pattern-detect

파일: `~/.claude/skills/inner-compass-pattern-detect/SKILL.md`

```markdown
---
name: inner-compass-pattern-detect
description: 생각 조각들에서 반복 패턴, 감정 클러스터, 갈등 쌍을 감지
triggers: ["생각 정리", "패턴", "반복", "계속 같은", "또 이런"]
---

## 역할
여러 생각 조각이 주어졌을 때 다음을 감지합니다:

1. **반복 주제**: 다른 표현이지만 같은 주제를 가리키는 생각들
   예: "시간이 없어" + "너무 많은 걸 하고 있어" → 주제: 과부하

2. **감정 클러스터**: 비슷한 감정 톤의 생각들 그룹화
   예: 불안 계열, 욕구 계열, 회피 계열 등

3. **갈등 쌍**: 서로 모순되는 생각 (양가감정 신호)
   예: "새로운 걸 시작하고 싶어" + "기존 것도 못 마무리하는데"

4. **에너지 방향**: 생각들이 주로 향하는 시점
   과거 회귀 / 현재 불안 / 미래 기대 중 어디에 무게가 있는지

5. **부재 영역**: 언급되지 않았지만 중요할 수 있는 영역
   예: 관계, 건강, 재정 등이 전혀 언급되지 않은 경우 → 의식적 회피 가능성

## 사용 맥락
inner-compass-socratic 에이전트의 초기 분석 단계에서 자동 활성화됩니다.
```

### 6.2 inner-compass-ontological-analysis

파일: `~/.claude/skills/inner-compass-ontological-analysis/SKILL.md`

```markdown
---
name: inner-compass-ontological-analysis
description: 표면적 현상과 본질적 원인을 분리하는 존재론적 분석
triggers: ["본질", "근본 원인", "왜 이러는 걸까", "진짜 문제"]
---

## 역할
사용자의 생각이나 문제를 존재론적으로 분석합니다:

### 증상 vs 원인 분리
- 사용자가 말하는 것 → 증상 (표면)
- 그 아래에 있는 것 → 원인 (본질)
- 원인 아래에 있는 것 → 존재론적 욕구/두려움

### 본질 추출 질문법
1. "이것을 제거하면 무엇이 달라지는가?" → 의존 관계 파악
2. "이것이 없어도 불편한가?" → 필수 vs 부수 분리
3. "10년 후에도 중요한가?" → 시간축 필터링
4. "이것의 반대는 무엇인가?" → 핵심 가치 도출

### 출력
분석 결과를 3층 구조로 제시합니다:
- Layer 1 (표면): 사용자가 직접 말한 것
- Layer 2 (중간): 표면 아래 추론 가능한 감정/욕구
- Layer 3 (본질): 가장 깊은 존재론적 욕구/두려움
```

### 6.3 inner-compass-obsidian-export

파일: `~/.claude/skills/inner-compass-obsidian-export/SKILL.md`

```markdown
---
name: inner-compass-obsidian-export
description: 세션 결과를 Obsidian 호환 마크다운으로 최적화
triggers: ["저장", "obsidian", "내보내기", "노트"]
---

## 역할
crystallizer의 출력을 Obsidian에서 최적으로 활용 가능한 형태로 보장합니다.

## Obsidian 호환 규칙
1. YAML frontmatter 필수 (date, state, tags, mode 등)
2. 태그는 frontmatter의 tags 배열로 (인라인 #태그 아닌)
3. 관련 세션 연결은 [[wikilink]] 형식
4. 나침반은 Obsidian callout 문법 사용: `> [!compass]`
5. 비유는 이탤릭 인용 형식: `*"비유 문장"*`

## 파일명 규칙
`YYYY-MM-DD-HHmm.md` (24시간 형식)
quick 모드: `YYYY-MM-DD-HHmm-quick.md`
deep 모드: `YYYY-MM-DD-HHmm-deep.md`
```

---

## 7. 설치 및 테스트

### 플러그인 설치
```
/plugin marketplace add d0lim/inner-compass
/plugin install inner-compass
```

### Manual 설치 (개발용)
```bash
git clone https://github.com/d0lim/inner-compass.git
cd inner-compass && ./install.sh
```

### 테스트
```
# 초기 설정
/reflect-setup

# 탐색 테스트
/reflect 요즘 여러 생각이 산발적으로 많이 든다

# 저장 확인
세션 저장 경로에 결과가 제대로 저장되었는지, Obsidian에서 열 수 있는 형태인지 확인
```

---

## 8. Phase Flow 상세 (구현 참조)

```
사용자: /reflect [optional: 첫 생각]
         │
         ▼
    ┌─────────────────┐
    │ config.md 읽기   │  세션 저장 경로 확인
    └────┬────────────┘
         │
         ▼
    ┌─────────────────────────┐
    │ inner-compass-collector  │  사용자와 직접 대화하며 생각 수집
    │ (sonnet)                 │  최소 3개 수집 → 완료 확인
    └────┬────────────────────┘
         │ 수집된 생각 목록 전달
         ▼
    ┌─────────────────────────┐
    │ inner-compass-socratic   │  패턴 분석 → 질문 제시 → 답변 → 통찰 → 질문...
    │ (opus)                   │  2-3 라운드 반복 (deep 모드는 5+)
    └────┬────────────────────┘
         │ 원본 생각 + 전체 대화 기록 전달
         ▼
    ┌─────────────────────────────┐
    │ inner-compass-crystallizer   │  종합 진단 생성 → 결과 반환 (파일 저장 안 함)
    │ (opus)                       │  + 뿌리 매칭 분석 반환
    └────┬────────────────────────┘
         │ 결정화 결과 + 매칭 분석
         ▼
    ┌─────────────────────────────┐
    │ 리뷰 분기                    │  결과를 사용자에게 보여주고 선택지 제시
    │                              │  (1) 괜찮아요 → 저장
    │                              │  (2) 수정 → crystallizer 수정 모드 → 리뷰 분기
    │                              │  (3) 새 생각 → socratic 2차 탐색 → 재결정화 → 리뷰 분기
    └────┬────────────────────────┘
         │ 사용자 수락
         ▼
    ┌─────────────────────────────┐
    │ 저장                         │  세션 파일 저장 + roots.md 갱신
    │                              │  수정 시 frontmatter에 revision 메타데이터 추가
    └─────────────────────────────┘
```

### Context 전달 방식

각 에이전트는 Task tool로 호출된다. 이전 에이전트의 출력은
호출 시 prompt에 포함하여 전달한다.

```
inner-compass-socratic 호출 시:
"다음은 수집된 생각 조각들입니다:
1. ...
2. ...
3. ...

이 생각들을 분석하고 소크라테스식 질문을 생성해주세요."
```

```
inner-compass-crystallizer 호출 시:
"다음은 전체 탐색 기록입니다:

[원본 생각]
1. ...
2. ...

[초기 분석]
패턴: ...
숨겨진 층: ...

[대화 기록]
Q: ...
A: ...
통찰: ...

[저장 설정]
세션 저장 경로: {config에서 읽은 경로}
모드: standard

이 전체 맥락을 종합하여 상태를 결정화해주세요.
roots.md의 기존 뿌리와 매칭 분석을 포함해주세요."
```

---

## 9. 참고 프로젝트

- **Ouroboros**: https://github.com/Q00/ouroboros
  - 소크라테스식 질문 + 존재론적 분석으로 모호한 입력을 정제하는 철학
  - Ambiguity ≤ 0.2 게이트, PAL Router, Lateral Thinking Personas

- **oh-my-claudecode**: https://github.com/yeachan-heo/oh-my-claudecode
  - Claude Code 위의 multi-agent orchestration 패턴
  - plugin manifest, agents/, commands/, skills/ 구조
  - delegation-first 프로토콜, model routing

- **oh-my-openagent**: https://github.com/code-yeongyu/oh-my-openagent
  - 범용 agent harness (Claude + Codex + Gemini + Kimi)
  - 향후 범용화 시 참고할 `.agents/` 표준 구조

---

## 10. 향후 확장

### v0.2 (구현 완료)
- [x] roots.md 뿌리 레지스트리로 patterns.md 대체
- [x] 매 세션 자동 context 로드 (roots.md + 최근 세션)
- [x] 과거 세션 기반 질문 개인화 (socratic 에이전트가 roots.md 참조)
- [ ] /reflect-review의 시계열 시각화 (텍스트 기반)

### v0.3
- [ ] 에너지 분배 시계열 추적
- [ ] drift detection (세션 중 주제 이탈 감지)
- [ ] Obsidian Daily Note 연동 (당일 세션을 데일리 노트에 링크)

### v0.4 (3-layer memory + 범용화)
- [ ] Approach C: recent.md + roots.md + growth.md 3-layer 구조로 확장
- [ ] `~/.claude/` → `~/.agents/` 미러링으로 OpenCode/Cursor 호환
- [x] Claude Code 플러그인 시스템으로 배포
- [ ] 도메인 특화 스킬팩 (커리어 전환, 투자 판단, 사업 운영 등)
