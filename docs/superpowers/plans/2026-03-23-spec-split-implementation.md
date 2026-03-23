# init.md Spec Split Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split `docs/init.md` into granular spec files under `docs/specs/`, create `CLAUDE.md`, and delete `docs/init.md`.

**Architecture:** 8 spec files + 1 index file under `docs/specs/`, each documenting a functional area. Implementation files (`commands/`, `agents/`, `skills/`) are the primary source of truth. `CLAUDE.md` at project root provides minimal pointers. All changes committed atomically.

**Tech Stack:** Markdown only. No code changes.

**Spec:** `docs/superpowers/specs/2026-03-23-spec-split-design.md`

**Parallelism:** Task 1~8은 서로 독립적이므로 병렬 실행 가능. Task 9(index)는 Task 1~8 완료 후. Task 10(CLAUDE.md + init.md 삭제 + 커밋)은 마지막.

**Cross-reference 전략:** `/reflect`의 상세 phase flow는 `spec-phase-flow.md`가 canonical. `spec-commands.md`에서는 각 커맨드의 고유 동작만 기술하고 공통 흐름은 phase-flow를 참조.

---

### Task 1: spec-overview.md

**Files:**
- Create: `docs/specs/spec-overview.md`

**Source:** init.md 섹션 1 (개요) + 섹션 7 (설치/테스트). 구현과 차이 없는 정적 내용이므로 init.md에서 가져온다.

- [ ] **Step 1: Create spec-overview.md**

내용 구성:
1. 핵심 컨셉 — Ouroboros 철학 적용, oh-my-claudecode orchestration 패턴 차용
2. 사용 시나리오 — `/reflect`, `/reflect-quick`, `/reflect-deep`, `/reflect-review`, `/reflect-setup` 예시
3. 왜 Claude Code인가 — 터미널 전환, 글로벌 설치, Obsidian 연동, context window 등
4. 설치 방법 — Plugin(추천) + Manual
5. 제약사항 — 실행 위치, 필요 조건, 초기 설정
6. 테스트 — 설정, 탐색, 저장 확인 순서

---

### Task 2: spec-architecture.md

**Files:**
- Create: `docs/specs/spec-architecture.md`

**Source:** init.md 섹션 2 + 실제 디렉토리 구조 대조.

- [ ] **Step 0: 실제 디렉토리 구조 확인**

```bash
ls -R --ignore=.git --ignore=node_modules .
```

실제 구조와 init.md가 다르면 실제 구조 우선.

- [ ] **Step 1: Create spec-architecture.md**

내용 구성:
1. 플러그인 소스 구조 — `commands/`, `agents/`, `skills/`, `.claude-plugin/`, `docs/` 트리
2. 네이밍 규칙 — `inner-compass-` 접두사(agent, skill), `reflect-` 접두사(command)
3. 세션 저장 경로 — `~/.inner-compass/` 구조 (config.md, sessions/, roots.md)
4. Obsidian vault 연동 시 경로
5. 설정 파일 (`config.md`) 형식 및 동작
6. Claude Code 플러그인 규칙 — commands, agents, skills, plugin.json 역할
7. Context 전달 방식 — Agent tool로 호출, 이전 에이전트 출력을 prompt에 포함

---

### Task 3: spec-commands.md

**Files:**
- Create: `docs/specs/spec-commands.md`

**Source:** 실제 `commands/*.md` 파일 5개가 primary source.

- [ ] **Step 1: Create spec-commands.md**

각 커맨드별로 현재 구현 상태를 문서화:

1. `/reflect` (표준 세션) — `commands/reflect.md` 기준
   - 각 Phase의 요약만 기술하고, 상세 흐름은 `spec-phase-flow.md`를 참조하도록 cross-reference
   - 고유 동작: Pre-phase 마이그레이션 확인, roots.md 갱신, revision frontmatter

2. `/reflect-quick` (간이 모드) — `commands/reflect-quick.md` 기준
   - Pre-phase context 로드 (마이그레이션 포함)
   - 수집 생략, 질문 1회, quick 모드 결정화
   - 간이 루프 적용 범위

3. `/reflect-deep` (심층 모드) — `commands/reflect-deep.md` 기준
   - 수집 최소 5개, 5+ 라운드 대화
   - 심층 진단 (시간축 분석, 가치관 충돌 맵)
   - 리뷰 분기 (reflect와 동일)

4. `/reflect-review` (과거 회고) — `commands/reflect-review.md` 기준
   - roots.md 함께 로드, 필터링 기준, retrospective 에이전트 위임

5. `/reflect-setup` (초기 설정) — `commands/reflect-setup.md` 기준
   - Step 1~5 플로우

---

### Task 4: spec-agents.md

**Files:**
- Create: `docs/specs/spec-agents.md`

**Source:** 실제 `agents/*.md` 파일 4개가 primary source.

- [ ] **Step 1: Create spec-agents.md**

각 에이전트별로 현재 구현 상태를 문서화:

1. **inner-compass-collector** — `agents/inner-compass-collector.md` 기준
   - model: sonnet, tools: Read, Edit
   - 역할, 행동 규칙, 출력 형식

2. **inner-compass-socratic** — `agents/inner-compass-socratic.md` 기준
   - model: opus, tools: Read, Edit
   - 분석 프레임워크 (소크라테스식 질문 + 존재론적 분석)
   - 초기 분석, 후속 대화, readiness 판단
   - 과거 맥락 활용 (roots.md 트리거 테이블)
   - 2차 탐색 모드

3. **inner-compass-crystallizer** — `agents/inner-compass-crystallizer.md` 기준
   - model: opus, tools: Read, Edit, Bash
   - 입력, 모드 (일반/수정)
   - 출력 구조 7개 섹션 (상태 명명, 본질 진단, 표면→뿌리 맵, 에너지 분배도, 나침반, 비유, 궤적)
   - 출력 형식 (frontmatter 포함)
   - quick/deep 모드 차이
   - 뿌리 매칭 분석 ([roots_update] 형식)

4. **inner-compass-retrospective** — `agents/inner-compass-retrospective.md` 기준
   - model: sonnet, tools: Read, Edit, Bash, Glob
   - 세션 수집, 패턴 분석, 출력 형식, roots.md 검증
   - 주의: init.md에서는 patterns.md 참조 — 실제 구현이 roots.md를 사용하는지 확인할 것

---

### Task 5: spec-skills.md

**Files:**
- Create: `docs/specs/spec-skills.md`

**Source:** 실제 `skills/*/SKILL.md` 파일 3개가 primary source.

- [ ] **Step 1: Create spec-skills.md**

각 스킬별로 현재 구현 상태를 문서화:

1. **inner-compass-pattern-detect** — `skills/inner-compass-pattern-detect/SKILL.md` 기준
   - triggers, 감지 항목 5가지, 사용 맥락

2. **inner-compass-ontological-analysis** — `skills/inner-compass-ontological-analysis/SKILL.md` 기준
   - triggers, 증상 vs 원인 분리, 본질 추출 질문법, 3층 출력

3. **inner-compass-obsidian-export** — `skills/inner-compass-obsidian-export/SKILL.md` 기준
   - triggers, Obsidian 호환 규칙 5가지, 파일명 규칙

---

### Task 6: spec-session-format.md

**Files:**
- Create: `docs/specs/spec-session-format.md`

**Source:** 실제 `agents/inner-compass-crystallizer.md`의 출력 형식 섹션 + `commands/reflect.md`의 저장 로직.

- [ ] **Step 1: Create spec-session-format.md**

내용 구성:
1. 세션 파일 형식 — frontmatter (date, state, tags, mode, thought_count, question_rounds, matched_roots, new_roots) + 본문 섹션
2. 본문 섹션 목록 — 상태 명명, 본질, 표면→뿌리, 에너지 분배, **궤적 (`[!timeline]` callout)**, 나침반 (`[!compass]` callout), 비유
3. 모드별 차이 — standard(전체), quick(축약: 표면→뿌리, 에너지 분배 생략), deep(전체 + 시간축)
4. 파일명 규칙 — `YYYY-MM-DD-HHmm.md`, `-quick.md`, `-deep.md`
5. revision 메타데이터 — revised, revision_count, revision_history
6. roots.md 구조 — 뿌리 레지스트리 형식 (이름, 표면 변형, 추이, 등장 횟수, 관련 세션)
7. roots.md 갱신 방식 — matched/new/ambiguous/resolved 처리
8. patterns.md → roots.md 마이그레이션 — patterns.md는 deprecated, 마이그레이션 로직은 spec-phase-flow.md의 Pre-phase 참조
9. config.md 형식 — sessions_dir, obsidian_vault
10. Obsidian 호환 규칙 — callout, wikilink, frontmatter tags

---

### Task 7: spec-phase-flow.md

**Files:**
- Create: `docs/specs/spec-phase-flow.md`

**Source:** 실제 `commands/reflect.md`가 primary source (init.md 섹션 8보다 상세하고 최신).

- [ ] **Step 1: Create spec-phase-flow.md**

내용 구성:
1. ASCII 다이어그램 — config 읽기 → collector → socratic → crystallizer → 리뷰 분기 → 저장
2. Pre-phase: Context 로드 — 마이그레이션 확인, roots.md 로드, 최근 세션 로드
3. Phase 0: 수집 — collector 위임, $ARGUMENTS 활용, 최소 3개
4. Phase 1: 탐색 — socratic 위임, context 전달 형식 (생각 + roots.md + 최근 나침반)
5. Phase 2: 결정화 — crystallizer 위임, context 전달 형식 (생각 + 대화 + roots.md + 모드)
6. Phase 2.5: 리뷰 분기 — (1) 저장, (2) 수정 모드, (3) 2차 탐색
7. Phase 3: 저장 및 완료 — 세션 파일 저장, roots.md 갱신, 완료 안내
8. 모드별 변형 — quick(수집 생략, 1라운드), deep(5+ 라운드, 심층 진단)

---

### Task 8: spec-roadmap.md

**Files:**
- Create: `docs/specs/spec-roadmap.md`

**Source:** init.md 섹션 9 (참고 프로젝트) + 섹션 10 (향후 확장).

- [ ] **Step 1: Create spec-roadmap.md**

내용 구성:
1. 참고 프로젝트 — Ouroboros, oh-my-claudecode, oh-my-openagent (URL + 설명)
2. v0.2 상태 — git log로 실제 완료 항목 확인 후 체크. 미완료: /reflect-review 시계열 시각화
3. v0.3 계획 — 에너지 시계열, drift detection, Obsidian Daily Note 연동
4. v0.4 계획 — 3-layer memory, 범용화, 도메인 특화 스킬팩

---

### Task 9: index.md

**Files:**
- Create: `docs/specs/index.md`

**Source:** 새로 작성. Task 1~8에서 만든 파일 목록.

- [ ] **Step 1: Create index.md**

형식:
```markdown
# Inner Compass Spec Index

| 문서 | 설명 |
|------|------|
| [spec-overview](spec-overview.md) | 프로젝트 개요, 핵심 컨셉, 설치, 제약사항 |
| [spec-architecture](spec-architecture.md) | 디렉토리 구조, 플러그인 규칙, context 전달 |
| [spec-commands](spec-commands.md) | /reflect, /reflect-quick, /reflect-deep, /reflect-review, /reflect-setup |
| [spec-agents](spec-agents.md) | collector, socratic, crystallizer, retrospective |
| [spec-skills](spec-skills.md) | pattern-detect, ontological-analysis, obsidian-export |
| [spec-session-format](spec-session-format.md) | 세션 파일/roots.md/config.md 형식 |
| [spec-phase-flow](spec-phase-flow.md) | Phase 0~3 + 리뷰 분기 상세 흐름 |
| [spec-roadmap](spec-roadmap.md) | 참고 프로젝트 + 향후 확장 계획 |
```

---

### Task 10: CLAUDE.md + init.md 삭제 + 커밋

**Files:**
- Create: `CLAUDE.md`
- Delete: `docs/init.md`

- [ ] **Step 1: Create CLAUDE.md**

```markdown
# Inner Compass

산발적인 내면의 생각을 체계적으로 정제하여 자기 상태를 진단하는 Claude Code 플러그인.

## 스펙 문서

프로젝트 스펙은 `docs/specs/index.md`를 참조하세요.

## 규칙

- 작업 완료 시 관련 spec 문서가 변경 사항을 반영하는지 확인하고, 필요하면 최신화할 것
- `docs/specs/`: 프로젝트 구현 스펙 (ground truth)
- `docs/superpowers/specs/`: brainstorming 과정의 설계 문서 (작업 이력)
```

- [ ] **Step 2: Delete docs/init.md**

```bash
rm docs/init.md
```

- [ ] **Step 3: Commit all changes atomically**

```bash
git add docs/specs/ CLAUDE.md
git rm docs/init.md
git commit -m "docs: split init.md into granular specs, add CLAUDE.md

- Create 8 spec files + index under docs/specs/
- Create CLAUDE.md with minimal pointers and doc freshness rule
- Remove docs/init.md (preserved in git history)"
```
