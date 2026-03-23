# Multi-Philosophy Lens System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a multi-philosophy lens system to Inner Compass, allowing users to explore thoughts through different philosophical perspectives (Socratic, Camus, etc.) with separated memory layers.

**Architecture:** Rename existing socratic agent to lens format, create Camus lens agent, update crystallizer for lens-neutral output with `[perspective_update]`, modify all commands to support `--lens` parameter with perspective loading/updating, and redesign memory into roots.md (neutral facts) + perspectives/ (lens-specific interpretations).

**Tech Stack:** Markdown only. Claude Code plugin (agents, commands, skills).

**Spec:** `docs/superpowers/specs/2026-03-23-philosophy-lens-design.md`

**Parallelism:** Tasks 1-2 are independent. Task 3 depends on new agent names. Tasks 4-7 depend on Tasks 1-3. Task 8 (reflect-setup)은 독립적. Task 9 (spec docs)는 전체 완료 후.

**변경 불필요 확인:** `agents/inner-compass-collector.md`는 렌즈-중립이므로 변경 불필요.

---

### Task 1: Rename socratic agent to lens format

**Files:**
- Delete: `agents/inner-compass-socratic.md`
- Create: `agents/inner-compass-lens-socratic.md`

이 작업은 기존 socratic 에이전트를 렌즈 포맷으로 변환합니다. 행동 규칙 등 기존 내용을 유지하면서 렌즈 필수 섹션(철학적 프레임워크, 질문법, 해석 축, 추이 판단, 한 줄 설명)을 추가하고, frontmatter에 `lens_id`, `lens_name` 필드를 추가합니다.

- [ ] **Step 1: Create `agents/inner-compass-lens-socratic.md`**

기존 `agents/inner-compass-socratic.md`의 전체 내용을 기반으로 새 파일을 작성합니다.

변경점:
- frontmatter: `name: inner-compass-lens-socratic`, `lens_id: socratic`, `lens_name: 소크라테스 (산파술)` 추가
- 기존 "분석 프레임워크" 섹션을 렌즈 필수 섹션 구조로 재구성:
  - "철학적 프레임워크" — 기존 소크라테스식 질문 + 존재론적 분석을 핵심 개념으로
  - "질문법" — 기존 질문 예시들을 그대로 유지
  - "해석 축" — 가정 탐색, 표면/본질 분리, 전제 의문화
  - "추이 판단" — 기존 추이 가이드라인을 소크라테스 관점으로 재해석 (무의식 → 가정 인식 → 가정 의문화 → 가정 해체)
  - "한 줄 설명" — "숨겨진 가정을 드러내고 본질에 접근하는 질문으로 탐색합니다."
- 기존 행동 규칙(초기 분석, 후속 대화, readiness 판단, 과거 맥락 활용, 2차 탐색 모드, 금기사항) 모두 유지
- 과거 맥락 활용 섹션: `roots.md` 대신 `roots.md + perspectives/socratic.md`를 참조하도록 변경. perspective에서 자기 렌즈의 해석과 추이를 활용
- 2차 탐색 모드의 입력에 `perspectives/socratic.md` 추가
- bootstrap 모드 섹션 추가: "bootstrap 모드로 명시되면 활성화. roots.md의 활성 뿌리 + 최근 3개 세션을 읽고, 각 뿌리에 대한 소크라테스적 초기 해석을 생성하여 반환."
  - 반환 형식: perspectives/{lens}.md와 동일한 마크다운 형식 (커맨드가 이를 그대로 파일로 저장)
  ```
  ## {뿌리명}
  - 핵심 해석: {초기 해석}
  - 추이: 관찰 중
  - 세션별 변화:
    - {bootstrap 날짜}: 초기 해석 생성
  ```

- [ ] **Step 2: Delete `agents/inner-compass-socratic.md`**

```bash
rm agents/inner-compass-socratic.md
```

- [ ] **Step 3: Commit**

```bash
git add agents/inner-compass-lens-socratic.md
git rm agents/inner-compass-socratic.md
git commit -m "feat: rename socratic agent to lens format

- inner-compass-socratic → inner-compass-lens-socratic
- Add lens-specific sections: framework, interpretation axes, trend stages
- Add bootstrap mode for cold start
- Add perspective file reference in past context usage"
```

---

### Task 2: Create Camus lens agent

**Files:**
- Create: `agents/inner-compass-lens-camus.md`

스펙의 렌즈 에이전트 예시(섹션 2)를 기반으로 카뮈 렌즈 에이전트를 작성합니다. 행동 규칙(초기 분석, 후속 대화, readiness 판단, 2차 탐색, 과거 맥락, 금기사항)은 socratic과 동일한 구조를 따르되, 질문 스타일과 해석 관점을 카뮈 철학에 맞게 작성합니다.

- [ ] **Step 1: Create `agents/inner-compass-lens-camus.md`**

frontmatter:
```yaml
---
name: inner-compass-lens-camus
description: 카뮈의 부조리 철학으로 내면 상태를 탐색
model: opus
tools: Read, Edit
lens_id: camus
lens_name: 카뮈 (부조리주의)
---
```

렌즈 필수 섹션:
- 철학적 프레임워크: 부조리, 반항, 시지프스의 행복 (스펙 섹션 2 예시 참조)
- 질문법: 스펙의 4개 질문 예시 + 추가 2개 (총 6개)
- 해석 축: 부조리 감지, 반항 여부, 자유 인식
- 추이 판단: 수용 전 → 인식 → 반항 → 시지프스의 행복
- 한 줄 설명: "부조리와 반항 — 의미 없음을 알면서도 계속하는 자세를 탐색합니다."

행동 규칙: socratic의 구조를 따르되 카뮈 관점으로:
- 초기 분석: 생각에서 "기대와 현실의 간극(부조리)", "의미 추구 vs 무의미 감지", "굴복 vs 반항 신호"를 찾음
- 후속 대화: 부조리의 자각을 촉진하는 질문
- readiness 판단: 사용자가 부조리를 인식하거나, 반항/수용의 태도를 언어화한 경우
- 과거 맥락: roots.md + perspectives/camus.md 참조
- 2차 탐색: perspectives/camus.md 포함
- bootstrap 모드: socratic과 동일한 구조, 카뮈 관점으로 초기 해석
- 금기사항: socratic과 동일

- [ ] **Step 2: Commit**

```bash
git add agents/inner-compass-lens-camus.md
git commit -m "feat: add Camus absurdism lens agent

- Philosophy: absurdity, revolt, Sisyphean happiness
- Interpretation axes: absurdity detection, revolt, freedom recognition
- Trend stages: pre-acceptance → recognition → revolt → Sisyphean happiness"
```

---

### Task 3: Update crystallizer for lens support

**Files:**
- Modify: `agents/inner-compass-crystallizer.md`

crystallizer를 렌즈-중립으로 업데이트합니다.

- [ ] **Step 1: Modify `agents/inner-compass-crystallizer.md`**

변경점:

1. **입력 섹션** (line 12-16):
   - `inner-compass-socratic 에이전트와의 전체 대화 기록` → `렌즈 에이전트(inner-compass-lens-{name})와의 전체 대화 기록`
   - `렌즈: {사용된 렌즈 이름}` 입력 추가

2. **출력 형식 frontmatter** (line 98-108):
   - `lens: {렌즈명}` 필드 추가 (date, state, tags 사이에)

3. **[roots_update] 형식 변경** (line 170-177):
   - matched 항목에서 `갱신할 추이` 제거 → 중립 사실만 (표면 변형 추가, 등장 횟수 증가)
   - new 항목에서 `추이: "관찰 중"` 제거

4. **[perspective_update] 블록 추가** (line 177 뒤):
   - `[roots_update]` 바로 뒤에 `[perspective_update]` 추가
   - 형식:
   ```
   [perspective_update]
   - lens: {사용된 렌즈}
   - interpretations:
     - root: {뿌리명}
       interpretation: {핵심 해석}
       trend: {추이}
       observation: {이번 세션 관찰}
   ```

5. **추이 판단 가이드라인** (line 164-168):
   - "추이 판단 가이드라인" → "추이 판단 가이드라인 (perspective_update용)"으로 제목 변경
   - "이 추이는 렌즈별 perspective에 기록됩니다. roots.md에는 기록하지 않습니다." 안내 추가
   - 가이드라인 내용은 범용적이므로 유지 (각 렌즈가 자체 추이 기준이 있으나, crystallizer는 대화 내용에서 추론)

6. **궤적 섹션** (line 75-91):
   - "추이" 표시 부분에서 roots.md의 추이 대신 전달받은 perspective의 추이를 사용하도록 변경
   - "입력에 perspectives/{lens}.md 내용이 포함될 수 있습니다" 안내 추가

- [ ] **Step 2: Commit**

```bash
git add agents/inner-compass-crystallizer.md
git commit -m "feat: make crystallizer lens-neutral

- Generalize input to accept any lens agent conversation
- Add lens field to session frontmatter
- Remove trend from [roots_update] (now neutral facts only)
- Add [perspective_update] output block for lens-specific interpretations
- Trajectory section uses perspective trends instead of roots.md trends"
```

---

### Task 4: Add roots.md migration logic to reflect.md Pre-phase

**Files:**
- Modify: `commands/reflect.md`

기존 사용자의 roots.md에는 "추이" 필드가 있다. 이를 perspectives/socratic.md로 마이그레이션하는 로직을 Pre-phase에 추가한다 (기존 patterns.md → roots.md 마이그레이션과 동일한 패턴).

- [ ] **Step 1: Add migration logic to reflect.md Pre-phase**

roots.md 로드 직후, perspectives 로드 전에 마이그레이션 확인을 추가:

```
### roots.md → perspectives 마이그레이션 확인
roots.md에 "추이" 필드가 있고 perspectives/socratic.md가 없으면:
- perspectives/ 디렉토리 생성
- roots.md의 각 뿌리에서 추이 필드를 추출하여 perspectives/socratic.md 생성
  - 뿌리명 → 섹션 헤더
  - 추이 → 추이 필드
  - 핵심 해석: "마이그레이션됨 — 다음 세션에서 갱신 예정"
- roots.md에서 추이 필드를 제거하고 중립적 사실만 남김
- 마이그레이션 후 roots.md를 다시 씀
perspectives/socratic.md가 이미 있으면 마이그레이션 생략.
```

- [ ] **Step 2: Commit**

```bash
git add commands/reflect.md
git commit -m "feat: add roots.md trend migration to perspectives/socratic.md

- Pre-phase migration: extract trends from roots.md to perspectives/socratic.md
- Neutralize roots.md (remove trend fields)
- Same migration pattern as patterns.md → roots.md"
```

---

### Task 5: Update reflect.md for full lens support

**Files:**
- Modify: `commands/reflect.md`

`/reflect` 커맨드에 렌즈 지원을 추가합니다.

- [ ] **Step 1: Modify `commands/reflect.md`**

변경점:

1. **상단** (Pre-phase 이전):
   - `$ARGUMENTS`에서 `--lens {name}` 파싱을 추가합니다. `$ARGUMENTS`는 현재 line 29에서 참조됩니다. 렌즈 파싱은 Pre-phase 시작 전에 수행하여 변수로 보관합니다. 없으면 기본값 `socratic`.

2. **Pre-phase 추가: 렌즈 로드** (roots.md 로드 뒤):
   ```
   ### perspectives/{lens}.md 로드
   세션 저장 경로의 perspectives/{lens}.md를 읽습니다.
   파일이 없으면 cold start bootstrap을 실행합니다:
   - inner-compass-lens-{lens} 에이전트를 bootstrap 모드로 호출
   - roots.md의 활성 뿌리 + 최근 3개 세션을 전달
   - 반환된 결과를 perspectives/{lens}.md로 저장
   - "렌즈를 처음 사용합니다. 기존 뿌리들에 대한 초기 해석을 생성합니다..." 안내
   perspectives/ 디렉토리가 없으면 생성합니다.
   ```

3. **Phase 1** (line 38-55):
   - `inner-compass-socratic` → `inner-compass-lens-{lens}` 호출
   - context 전달에 추가:
   ```
   [렌즈 해석 맥락]
   {perspectives/{lens}.md 중 관련 뿌리의 해석}
   ```
   - `소크라테스식 질문을 생성해주세요` → `이 생각들을 분석하고 질문을 생성해주세요`

4. **Phase 2** (line 57-80):
   - crystallizer 전달에 `렌즈: {lens}` 추가
   - perspective 내용도 함께 전달:
   ```
   [렌즈 해석 맥락]
   {perspectives/{lens}.md 내용, 없으면 생략}
   ```

5. **Phase 2.5** (line 82-138):
   - 선택지에 (4) 추가:
   ```
   (4) 다른 렌즈로 다시 탐색해볼래요
   ```
   - (4) 선택 시 처리:
   ```
   ### 사용자가 (4)를 선택한 경우
   사용 가능한 렌즈 목록을 보여줍니다:
   agents/ 디렉토리에서 inner-compass-lens-*.md 파일을 찾아
   각 파일의 frontmatter에서 lens_name과 한 줄 설명을 추출하여 표시합니다.

   사용자가 렌즈를 선택하면:
   - 새 렌즈의 perspectives/{lens}.md를 로드 (없으면 bootstrap)
   - inner-compass-lens-{새 렌즈} 에이전트로 Phase 1부터 재시작
   - context: 원본 생각 + 현재 결정화 결과 + 새 렌즈의 perspective
   - 결정화 후 다시 리뷰 분기(Phase 2.5)로
   ```
   - (3) 기존 처리에서 `inner-compass-socratic` → `inner-compass-lens-{lens}`

6. **Phase 3** (line 140-172):
   - roots.md 갱신 로직에서 추이 관련 부분 제거:
     - matched: "추이 갱신" 제거
     - new: `추이: "관찰 중"` 제거
   - perspective 갱신 로직 추가:
   ```
   ### perspectives/{lens}.md 갱신
   crystallizer가 반환한 [perspective_update] 구조를 기반으로 perspectives/{lens}.md를 갱신합니다.
   - 기존 뿌리: 핵심 해석과 추이를 업데이트, 세션별 변화에 이번 관찰 추가
   - 새 뿌리: 새 섹션으로 추가
   ```

- [ ] **Step 2: Commit**

```bash
git add commands/reflect.md
git commit -m "feat: add lens support to /reflect command

- Parse --lens parameter (default: socratic)
- Pre-phase: load perspectives/{lens}.md with cold start bootstrap
- Phase 1: route to inner-compass-lens-{lens} agent
- Phase 2: pass lens info to crystallizer
- Phase 2.5: add option (4) for lens switching
- Phase 3: update perspectives/{lens}.md from [perspective_update]
- Remove trend from roots.md updates (now in perspectives)"
```

---

### Task 6: Update reflect-deep.md for lens support

**Files:**
- Modify: `commands/reflect-deep.md`

- [ ] **Step 1: Modify `commands/reflect-deep.md`**

변경점 (reflect.md와 동일한 패턴):

1. `$ARGUMENTS`에서 `--lens {name}` 파싱 추가, 기본값 `socratic`
2. Pre-phase: `perspectives/{lens}.md` 로드 + cold start bootstrap 추가
3. 플로우 항목 2: `inner-compass-socratic` → `inner-compass-lens-{lens}`, perspective 전달 추가
4. 플로우 항목 3: crystallizer에 `렌즈: {lens}` + perspective 전달
5. 리뷰 분기: (4) 렌즈 전환 선택지 추가. (3)의 socratic 참조 → lens-{lens}
6. 저장: roots.md 갱신에서 추이 제거 + perspectives/{lens}.md 갱신 추가

- [ ] **Step 2: Commit**

```bash
git add commands/reflect-deep.md
git commit -m "feat: add lens support to /reflect-deep command"
```

---

### Task 7: Update reflect-quick.md for lens support

**Files:**
- Modify: `commands/reflect-quick.md`

- [ ] **Step 1: Modify `commands/reflect-quick.md`**

변경점:

1. `$ARGUMENTS`에서 `--lens {name}` 파싱 추가, 기본값 `socratic`
2. Pre-phase: `perspectives/{lens}.md` 로드 + cold start bootstrap 추가
3. 플로우 항목 1: `inner-compass-socratic` → `inner-compass-lens-{lens}`, perspective 전달
4. 플로우 항목 3: crystallizer에 `렌즈: {lens}` + perspective 전달
5. 저장 후: roots.md 갱신에서 추이 제거 + perspectives/{lens}.md 간략 갱신 (핵심 해석 한 줄만)
6. Phase 2.5 없으므로 렌즈 전환 선택지 없음 (명시적으로 기술)

- [ ] **Step 2: Commit**

```bash
git add commands/reflect-quick.md
git commit -m "feat: add lens support to /reflect-quick command"
```

---

### Task 8: Update reflect-review.md for lens support

**Files:**
- Modify: `commands/reflect-review.md`
- Modify: `agents/inner-compass-retrospective.md`

- [ ] **Step 1: Modify `commands/reflect-review.md`**

변경점:

1. `$ARGUMENTS`에서 `--lens {name}` 및 `--root {뿌리명}` 파싱 추가
2. 플로우 항목 1: roots.md + perspectives/ 디렉토리 로드
3. 플로우 항목 2: 필터링에 렌즈 필터 추가 (세션 frontmatter의 lens 필드)
4. 플로우 항목 3: retrospective 에이전트에 전달 시:
   - `--lens` 모드: 해당 렌즈의 perspective 파일 + 해당 렌즈 세션들만 전달
   - `--root` 모드: 해당 뿌리에 대한 모든 perspectives를 전달, 크로스 렌즈 비교 요청
   - 기본 모드 (인자 없음): 모든 perspectives + 최근 5개 세션 (기존과 동일 + perspective 추가)

- [ ] **Step 2: Modify `agents/inner-compass-retrospective.md`**

변경점:

1. 입력에 `perspectives/ 디렉토리의 관련 파일들` 추가
2. 패턴 분석(섹션 2)에 렌즈별 분석 추가:
   - **렌즈별 해석 변화**: 같은 뿌리가 렌즈별로 어떻게 해석되는지 추이
   - **렌즈 간 공통점/차이점**: 여러 렌즈가 동의하는 해석 vs 다르게 보는 부분
3. 출력 형식에 렌즈 관련 섹션 추가:
   - 크로스 렌즈 비교 출력 (--root 모드):
   ```
   ### 렌즈별 비교: 「{뿌리명}」
   | 렌즈 | 핵심 해석 | 추이 |
   |------|----------|------|
   | 소크라테스 | ... | ... |
   | 카뮈 | ... | ... |
   ```
4. roots.md 검증(섹션 4)에서 추이 불일치 검증 제거 (추이는 이제 perspectives에 있음)

- [ ] **Step 3: Commit**

```bash
git add commands/reflect-review.md agents/inner-compass-retrospective.md
git commit -m "feat: add lens support to /reflect-review and retrospective agent

- Support --lens and --root parameters
- Retrospective agent reads perspectives/ for cross-lens comparison
- Add cross-lens comparison output format
- Remove trend validation from roots.md (now in perspectives)"
```

---

### Task 9: Update reflect-setup.md for lens support

**Files:**
- Modify: `commands/reflect-setup.md`

- [ ] **Step 1: Modify `commands/reflect-setup.md`**

변경점:

1. Step 3 (디렉토리 생성)에 `perspectives/` 디렉토리 추가
2. Step 5 (완료 안내)에 렌즈 설명 추가:
   ```
   💡 렌즈란 같은 생각을 다른 철학적 관점으로 탐색하는 것입니다.
   기본은 소크라테스(숨겨진 가정 찾기)이고,
   /reflect --lens camus 처럼 다른 렌즈를 지정할 수 있습니다.
   ```

- [ ] **Step 2: Commit**

```bash
git add commands/reflect-setup.md
git commit -m "feat: add lens explanation and perspectives/ dir to reflect-setup"
```

---

### Task 10: Update spec docs and commit

**Files:**
- Modify: `docs/specs/spec-commands.md`
- Modify: `docs/specs/spec-agents.md`
- Modify: `docs/specs/spec-session-format.md`
- Modify: `docs/specs/spec-phase-flow.md`
- Modify: `docs/specs/spec-architecture.md`

모든 구현이 끝난 후 spec 문서들을 현재 구현 상태에 맞게 업데이트합니다 (CLAUDE.md 규칙: "작업 완료 시 관련 spec 문서가 변경 사항을 반영하는지 확인하고, 필요하면 최신화할 것").

- [ ] **Step 1: Update spec-agents.md**

- inner-compass-socratic → inner-compass-lens-socratic 반영
- inner-compass-lens-camus 추가
- crystallizer 변경 반영 ([perspective_update], 입력 일반화, frontmatter lens 필드)
- retrospective 변경 반영 (perspectives 입력, 크로스 렌즈 비교)

- [ ] **Step 2: Update spec-commands.md**

- 모든 커맨드에 --lens 파라미터 반영
- reflect, reflect-deep에 Phase 2.5 렌즈 전환 선택지 반영
- reflect-review에 --lens, --root 파라미터 반영
- reflect-setup에 perspectives/ + 렌즈 설명 반영

- [ ] **Step 3: Update spec-session-format.md**

- frontmatter에 lens 필드 추가
- roots.md에서 추이 제거 반영
- perspectives/{lens}.md 형식 추가
- [perspective_update] 형식 추가

- [ ] **Step 4: Update spec-phase-flow.md**

- Pre-phase에 perspectives 로드 + cold start bootstrap 추가
- Phase 1 에이전트 라우팅 변경
- Phase 2.5 렌즈 전환 선택지 추가
- Phase 3 perspective 갱신 추가

- [ ] **Step 5: Update spec-architecture.md**

- 세션 저장 경로에 perspectives/ 디렉토리 추가
- 에이전트 네이밍에 lens- 접두사 규칙 추가

- [ ] **Step 6: Commit**

```bash
git add docs/specs/
git commit -m "docs: update specs to reflect multi-philosophy lens system

- Agent naming: inner-compass-lens-{name} convention
- Memory: roots.md (neutral) + perspectives/ (lens-specific)
- Commands: --lens parameter, Phase 2.5 lens switching
- Session format: lens frontmatter, [perspective_update] output
- Architecture: perspectives/ directory, lens naming convention"
```
