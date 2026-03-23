# 다중 철학 렌즈 시스템 설계

## 배경

현재 Inner Compass의 탐색 에이전트는 소크라테스식 질문법과 존재론적 분석에 기반한다. 같은 내면의 문제라도 다른 철학적 관점에서 보면 다른 직관과 통찰을 도출할 수 있다. 이 설계는 다중 철학 렌즈를 지원하는 확장 가능한 시스템을 정의한다.

## 도메인 용어: 렌즈

**렌즈(Lens):** 같은 생각을 다른 철학적 관점으로 탐색하는 것. 각 렌즈는 고유한 질문법, 해석 축, 추이 판단 기준을 가진다.

예시:
- 소크라테스 렌즈: "숨겨진 가정은 무엇인가?"
- 카뮈 렌즈: "이것에 의미가 없다면, 그래도 계속할 것인가?"
- 스토아 렌즈: "이 중 통제 가능한 것은 무엇인가?"

사용자에게는 `/reflect-setup` 초기 설정과 세션 중 첫 렌즈 전환 시 설명을 제공한다.

## 결정 사항

- **접근법:** C — 렌즈 = 에이전트 + 분리된 memory 레이어
- **Memory 재설계:** roots.md(중립 사실) + perspectives/(렌즈별 해석) 분리
- **에이전트 네이밍:** `inner-compass-lens-{name}` 통일 (기존 socratic 포함 리네이밍)
- **Cold start:** 새 렌즈 첫 사용 시 기존 활성 뿌리 + 최근 3개 세션 기반 bootstrap
- **초기 범위:** socratic(리네이밍) + camus(신규). 이후 렌즈는 에이전트 파일 추가만으로 확장
- **DB 마이그레이션 고려:** perspectives/ 분리 구조가 관계형/graph DB로 1:1 매핑 가능

---

## 1. Memory 구조 재설계

### 디렉토리 구조 변경

```
~/.inner-compass/
├── config.md
├── sessions/
├── roots.md              # 철학-중립적 사실만
└── perspectives/          # 렌즈별 해석
    ├── socratic.md
    └── (추가되는 렌즈마다 파일 생성)
```

### roots.md (중립화)

기존 roots.md에서 해석적 요소(추이)를 제거하고 사실만 남긴다.

```markdown
## 뿌리: {뿌리명}

- 등장 횟수: N
- 표면 변형: ["표현1", "표현2", ...]
- 상태: 활성 | 해소
- 관련 세션: [[YYYY-MM-DD-HHmm]], ...
```

"추이(악화/유지/개선)"를 roots.md에서 제거한다. 추이는 해석이지 사실이 아니다 — 같은 뿌리가 반복되어도 스토아는 "수용 단계 진입"으로, 소크라테스는 "미해결 가정 지속"으로 볼 수 있다.

### perspectives/{lens}.md (렌즈별 해석)

```markdown
## {뿌리명}

- 핵심 해석: {이 렌즈 고유의 해석}
- 추이: {이 렌즈 고유의 추이 판단}
- 세션별 변화:
  - MM/DD: {관찰}
  - MM/DD: {관찰}
```

예시 — perspectives/socratic.md:
```markdown
## 과부하

- 핵심 해석: 숨겨진 가정 — "모든 기회를 잡아야 한다"
- 추이: 유지 (가정이 아직 의식화되지 않음)
- 세션별 변화:
  - 03/20: 표면에서만 인식
  - 03/23: "정말 다 해야 하나?" 질문에서 처음 흔들림
```

예시 — perspectives/camus.md:
```markdown
## 과부하

- 핵심 해석: 시지프스적 반복 — 의미 없음을 감지하면서도 계속 짊어지는 중
- 추이: 관찰 중 (반항의 조짐은 아직 없음)
- 부조리 판단: 행위와 기대 사이 간극 감지됨
```

### DB 매핑 프리뷰

```
roots (id, name, status, surface_variants[])
root_sessions (root_id, session_id, lens)
interpretations (root_id, lens, core_interpretation, trend, notes)
interpretation_history (interpretation_id, session_id, observation)
```

---

## 2. 렌즈 에이전트 구조

### 네이밍 규칙

모든 렌즈: `inner-compass-lens-{name}.md`

- `inner-compass-socratic` → `inner-compass-lens-socratic` (리네이밍)
- `inner-compass-lens-camus` (신규)
- 향후: `inner-compass-lens-stoic`, `inner-compass-lens-nietzsche`, ...

### 렌즈 에이전트 필수 섹션

| 섹션 | 용도 |
|------|------|
| 철학적 프레임워크 | 핵심 개념 3-5개 |
| 질문법 | 대표 질문 4-6개 |
| 해석 축 | 이 렌즈가 뿌리를 해석하는 기준 (2-4개) |
| 추이 판단 | 이 렌즈 고유의 단계/상태 정의 |
| 한 줄 설명 | 렌즈 선택 UI에서 보여줄 설명 |

나머지 행동 규칙(초기 분석, 후속 대화, readiness 판단, 2차 탐색 모드, 과거 맥락 활용, 금기사항)은 현재 socratic과 동일한 구조를 공유한다.

### 렌즈 에이전트의 입출력

- **입력:** 생각 조각 + roots.md + 자기 perspective 파일 + (선택) 다른 렌즈의 perspective
- **출력:** 질문 제시 → 대화 → readiness 판단 (기존 socratic과 동일한 인터페이스)
- **perspective 업데이트:** 세션 종료 시 자기 perspective 파일에 해석 추가 (커맨드가 담당)

### crystallizer와의 관계

crystallizer는 렌즈-중립을 유지한다. 어떤 렌즈로 탐색했든 결정화 포맷은 동일하되, frontmatter에 `lens` 필드를 기록한다.

**변경 필요:**
- crystallizer의 입력 설명에서 `inner-compass-socratic 에이전트와의 대화 기록` → `렌즈 에이전트와의 대화 기록`으로 일반화
- `[roots_update]` 출력 구조 변경:
  - 기존: `갱신할 추이` 포함 → roots.md에 기록
  - 변경: `[roots_update]`는 중립 사실만 (matched/new/ambiguous/resolved, 표면 변형 추가, 등장 횟수 증가). 추이 제거
  - 신규: `[perspective_update]` 블록 추가 — 이번 세션의 렌즈별 해석과 추이를 구조화하여 반환
  - 커맨드는 `[roots_update]`로 roots.md를, `[perspective_update]`로 perspectives/{lens}.md를 각각 갱신

`[perspective_update]` 형식:
```
[perspective_update]
- lens: {사용된 렌즈}
- interpretations:
  - root: {뿌리명}
    interpretation: {핵심 해석}
    trend: {추이}
    observation: {이번 세션 관찰}
```

### 렌즈 추가 방법

1. `agents/inner-compass-lens-{name}.md` 파일 작성 (위 필수 섹션 포함)
2. 끝 — 커맨드나 flow 수정 불필요

커맨드는 `--lens {name}`을 받아 `agents/` 디렉토리에서 `inner-compass-lens-{name}.md`를 찾아 호출한다. 파일이 없으면 에러.

### 렌즈 에이전트 예시: camus

```markdown
---
name: inner-compass-lens-camus
description: 카뮈의 부조리 철학으로 내면 상태를 탐색
model: opus
tools: Read, Edit
lens_id: camus
lens_name: 카뮈 (부조리주의)
---

## 철학적 프레임워크

### 핵심 개념
- 부조리: 의미를 원하는 인간 vs 침묵하는 세계의 간극
- 반항: 부조리를 인식하면서도 굴복하지 않는 태도
- 시지프스의 행복: 고통 속에서도 의미를 선택하는 자유

### 질문법
- "이 상황에서 의미를 기대하고 있나요? 그 기대가 고통의 원인은 아닌가요?"
- "만약 이것에 아무 의미가 없다면, 그래도 계속할 건가요?"
- "지금 굴복하고 있나요, 반항하고 있나요?"
- "이 짐을 내려놓을 수 없다면, 짊어지는 방식을 바꿀 수 있나요?"

### 해석 축
- 부조리 감지: 행위와 기대 사이 간극이 있는가
- 반항 여부: 무의미를 인식하면서도 능동적으로 행동하는가
- 자유 인식: 선택의 여지를 보고 있는가

### 추이 판단
- 수용 전: 부조리를 감지하지 못하거나 회피 중
- 인식: 간극을 의식하기 시작
- 반항: 무의미를 알면서도 자기 방식으로 계속함
- 시지프스의 행복: 고통 속 자유를 경험

### 한 줄 설명
부조리와 반항 — 의미 없음을 알면서도 계속하는 자세를 탐색합니다.
```

---

## 3. 커맨드 인터페이스

### 렌즈 선택

```bash
# 기본 (소크라테스)
/reflect

# 렌즈 지정
/reflect --lens camus
/reflect-deep --lens stoic
/reflect-quick --lens camus 오늘 뭔가 허무하다
```

`--lens` 없으면 기본값 `socratic`. 향후 `config.md`에 `default_lens` 필드를 추가하여 사용자가 기본 렌즈를 변경할 수 있도록 한다 (초기 범위 외).

### 세션 내 렌즈 전환

Phase 2.5 리뷰 분기에 선택지 추가:

```
결정화가 완료되었습니다. 어떻게 할까요?

(1) 괜찮아요, 저장해주세요
(2) 수정하고 싶어요
(3) 새로운 생각이 떠올랐어요
(4) 다른 렌즈로 다시 탐색해볼래요
```

(4) 선택 시:
- 사용 가능한 렌즈 목록 + 한 줄 설명 표시
- 선택한 렌즈 에이전트로 Phase 1부터 재시작
- context: 원본 생각 + 현재 결정화 결과 + 새 렌즈의 perspective

### 세션 간 렌즈 전환 (reflect-review)

```bash
# 모든 렌즈 세션 통합 회고
/reflect-review

# 특정 렌즈로 필터링
/reflect-review --lens camus

# 특정 뿌리를 여러 렌즈로 비교
/reflect-review --root 과부하
```

`--root` 시 retrospective 에이전트가 해당 뿌리의 모든 perspectives를 읽어 크로스 렌즈 비교 분석을 제공한다.

**retrospective 에이전트 변경 필요:**
- 입력에 `perspectives/` 디렉토리의 관련 파일들을 추가로 전달
- `--lens` 모드: 해당 렌즈의 perspective만 로드하여 렌즈 관점에서 회고
- `--root` 모드: 해당 뿌리에 대한 모든 perspectives를 로드하여 렌즈 간 비교 출력 생성
- 비교 출력 형식: 뿌리별로 각 렌즈의 핵심 해석과 추이를 나란히 제시

### Cold Start (Bootstrap)

처음 사용하는 렌즈를 지정하면:

```
"카뮈 렌즈를 처음 사용합니다.
기존 뿌리들에 대한 초기 해석을 생성합니다..."

[roots.md의 활성 뿌리 + 최근 3개 세션을 읽고 perspectives/camus.md 생성]

"초기 해석이 완료되었습니다. 세션을 시작합니다."
```

Bootstrap 범위: 활성 뿌리만 (해소된 뿌리는 소급하지 않음).

**Bootstrap 수행 주체:** 커맨드(reflect.md 등)의 Pre-phase에서 수행한다. 해당 렌즈 에이전트를 "bootstrap 모드"로 호출하여, roots.md + 최근 세션을 읽고 perspectives/{lens}.md를 생성하게 한다.

### 렌즈 설명 (사용자 안내)

`/reflect-setup`에서:
> "렌즈란 같은 생각을 다른 철학적 관점으로 탐색하는 것입니다.
> 기본은 소크라테스(숨겨진 가정 찾기)이고, 카뮈(부조리와 반항), 스토아(통제 가능/불가능 분리) 등을 추가로 사용할 수 있습니다."

세션 중 첫 렌즈 전환 시: 렌즈 목록 + 각 렌즈 한 줄 설명 표시.

---

## 4. Phase Flow 변경점

### Pre-phase 추가: 렌즈 로드

```
config.md 읽기
  → roots.md 로드
  → perspectives/{lens}.md 로드 (신규)
  → 최근 세션 로드
```

perspective 파일이 없으면 → cold start bootstrap 실행.

### Phase 1 변경: 에이전트 라우팅

기존: 항상 `inner-compass-socratic` 호출
변경: `inner-compass-lens-{lens}` 호출

전달 context 추가:
```
[렌즈 해석 맥락]
{perspectives/{lens}.md 중 관련 뿌리의 해석}
```

### Phase 2 변경: frontmatter

세션 파일 frontmatter에 `lens` 필드 추가:
```yaml
lens: camus
```

### Phase 2.5 변경: 렌즈 전환 선택지

기존 (1)(2)(3)에 (4) 추가 (위 커맨드 인터페이스 섹션 참조).

### Phase 3 변경: perspective 업데이트

세션 저장 후 추가:
- roots.md 갱신 (기존과 동일)
- perspectives/{lens}.md에 이번 세션의 해석 추가/갱신 (커맨드가 담당)

### 모드별 차이

- `/reflect`, `/reflect-deep`: 렌즈 전체 적용, Phase 2.5에서 렌즈 전환 가능
- `/reflect-quick`: 렌즈 적용, perspective 업데이트는 간략 (핵심 해석 한 줄). Phase 2.5 없으므로 세션 내 렌즈 전환 불가
- `/reflect-review`: 렌즈 필터링 또는 크로스 렌즈 비교

---

## 5. 확장 구조

### 초기 범위 (v1)

1. **inner-compass-lens-socratic** — 기존 socratic 리네이밍 + 렌즈 포맷 적용
2. **inner-compass-lens-camus** — 신규

### 향후 렌즈 후보 (범위 외)

| 렌즈 | 핵심 렌즈 | 질문 예시 |
|------|----------|----------|
| stoic | 통제 가능 vs 불가능 분리 | "이 중 네가 바꿀 수 있는 건 뭐야?" |
| existential | 자유와 책임, 진정성 | "이 선택이 정말 네 것이야?" |
| nietzsche | 권력 의지, 영원 회귀 | "이 삶을 영원히 반복해도 괜찮겠어?" |
| buddhist | 집착과 고통의 관계 | "무엇에 집착하고 있는 거야?" |
| phenomenological | 체험 그 자체에 집중 | "판단을 빼고, 지금 뭘 경험하고 있어?" |
| pragmatist | 결과와 행동 중심 | "이 생각이 네 행동을 어떻게 바꿔?" |

### 기존 ontological-analysis 스킬

유지한다. "표면/본질 분리"는 범용 도구로서 여러 렌즈에서 활용 가능하다. socratic 렌즈에 흡수하지 않는다.

---

## 6. 마이그레이션

기존 사용자 데이터 마이그레이션:

1. roots.md에서 "추이" 필드를 `perspectives/socratic.md`로 이동
2. roots.md는 중립적 사실만 남김 (이름, 등장 횟수, 표면 변형, 상태, 관련 세션)
3. 기존 세션 파일: frontmatter에 `lens` 필드가 없으면 `socratic`으로 간주 (retroactive 수정하지 않음)
4. `agents/inner-compass-socratic.md` → `agents/inner-compass-lens-socratic.md` 리네이밍 + 렌즈 포맷 적용
5. `agents/inner-compass-crystallizer.md` 입력 설명 일반화 + `[perspective_update]` 출력 추가
6. 커맨드 파일들(`commands/*.md`)에서 `inner-compass-socratic` → `inner-compass-lens-socratic` 참조 변경 + perspective 갱신 로직 추가
7. `commands/reflect-setup.md`에 렌즈 설명 안내 + `perspectives/` 디렉토리 생성 추가
8. `agents/inner-compass-retrospective.md`에 perspectives 입력 및 크로스 렌즈 비교 로직 추가
9. `perspectives/` 디렉토리 생성은 `/reflect-setup` 또는 첫 세션의 Pre-phase에서 자동
