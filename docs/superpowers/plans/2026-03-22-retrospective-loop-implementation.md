# Retrospective Loop Framework Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update all agent, command, and install files to implement the root-centric retrospective loop — every session automatically loads past context, matches roots, and tracks trajectory.

**Architecture:** Modify existing markdown prompt files (agents, commands) to incorporate roots.md loading, root matching, trajectory output, and migration logic. No code compilation — all changes are prompt engineering in markdown files.

**Tech Stack:** Claude Code (slash commands, agents, skills), Markdown prompts

**Spec:** `docs/superpowers/specs/2026-03-22-retrospective-loop-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `src/commands/reflect.md` | Modify | Add roots.md + recent session loading before Phase 0, migration check |
| `src/commands/reflect-quick.md` | Modify | Add roots.md + recent session loading |
| `src/commands/reflect-deep.md` | Modify | Add roots.md + recent session loading |
| `src/commands/reflect-review.md` | Modify | Switch from patterns.md to roots.md reference |
| `src/agents/inner-compass-socratic.md` | Modify | Add past-roots context handling + new question types |
| `src/agents/inner-compass-crystallizer.md` | Modify | Add root matching, roots.md update, trajectory section |
| `src/agents/inner-compass-retrospective.md` | Modify | Switch from patterns.md to roots.md |
| `install.sh` | Modify | No functional change needed (copies files by glob) |
| `~/.claude/commands/reflect*.md` | Overwrite | Updated by install.sh |
| `~/.claude/agents/inner-compass-*.md` | Overwrite | Updated by install.sh |

Files NOT changed: `src/agents/inner-compass-collector.md`, `src/commands/reflect-setup.md`, all skill files.

---

### Task 1: Update `/reflect` command — add context loading + migration

**Files:**
- Modify: `src/commands/reflect.md`

- [ ] **Step 1: Rewrite reflect.md with retrospective loop pre-phase**

Replace the entire content of `src/commands/reflect.md` with:

```markdown
Inner Compass 탐색 세션을 시작합니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

## Pre-phase: Context 로드

### 마이그레이션 확인
세션 저장 경로에서:
- roots.md가 없고 patterns.md가 있으면 → patterns.md를 roots.md로 변환
  - 패턴명 → 뿌리 이름, 설명 → 메모, 관련 세션 수 → 등장 횟수
  - 표면 변형은 빈 리스트, 추이는 "관찰 중"으로 초기화
  - 변환 후 patterns.md는 보존 (삭제하지 않음)
- roots.md와 patterns.md 둘 다 있으면 → roots.md만 사용
- 둘 다 없으면 → 첫 세션, 빈 상태로 진행

### roots.md 로드
세션 저장 경로의 roots.md를 읽습니다. 없으면 빈 상태로 진행합니다.
파싱 불가능하면 빈 상태로 취급하고, 세션 파일에 경고를 기록합니다.

### 최근 세션 로드
세션 저장 경로에서 가장 최근 세션 파일 1개를 읽습니다.
- 모드 무관하게 가장 최근 파일 선택
- 나침반 섹션이 없는 경우 그 다음 최근 파일로 폴백
- 추출 대상: 나침반 섹션 + state(상태 명명)

## Phase 0: 수집
inner-compass-collector 에이전트에 위임하여 사용자의 생각 조각을 수집합니다.
$ARGUMENTS가 있다면 첫 번째 생각으로 사용합니다.

사용자에게 다음과 같이 안내합니다:
"지금 머릿속을 떠도는 생각, 걱정, 감정을 자유롭게 말해주세요.
정리할 필요 없습니다. 떠오르는 대로 하나씩."

최소 3개의 생각이 모이면 다음 단계를 제안합니다.
사용자가 "됐어", "이 정도면", "다 적었어" 등의 신호를 주면 수집을 종료합니다.

## Phase 1: 탐색
inner-compass-socratic 에이전트에 위임합니다. 다음 형식으로 전달합니다:

"다음은 수집된 생각 조각들입니다:
1. ...
2. ...

[과거 맥락]
{roots.md 내용, 없으면 이 섹션 생략}

[최근 세션 나침반]
{최근 세션의 state + 나침반 섹션, 없으면 이 섹션 생략}

이 생각들을 분석하고 소크라테스식 질문을 생성해주세요.
과거 맥락이 있다면 반복되는 뿌리나 변화에 대한 질문도 포함해주세요."

에이전트가 반환하는 질문 중 사용자에게 2-3개를 제시합니다.
사용자 답변 → 통찰 반영 → 후속 질문을 2-3라운드 진행합니다.

## Phase 2: 결정화
inner-compass-crystallizer 에이전트에 위임합니다. 다음 형식으로 전달합니다:

"다음은 전체 탐색 기록입니다:

[원본 생각]
1. ...

[대화 기록]
Q: ...
A: ...

[과거 맥락]
{roots.md 내용, 없으면 이 섹션 생략}

[저장 설정]
세션 저장 경로: {경로}
모드: standard

이 전체 맥락을 종합하여 상태를 결정화해주세요.
roots.md의 기존 뿌리와 매칭하고, roots.md를 갱신해주세요."

crystallizer가 세션 파일 저장 + roots.md 갱신을 모두 수행합니다.

## Phase 3: 완료
저장 완료를 사용자에게 알립니다.
궤적 섹션에서 반복 중인 뿌리가 있으면 간략히 언급합니다.
```

- [ ] **Step 2: Verify file is well-formed**

```bash
cat src/commands/reflect.md | head -5
```
Expected: "Inner Compass 탐색 세션을 시작합니다."

- [ ] **Step 3: Commit**

```bash
git add src/commands/reflect.md
git commit -m "feat(reflect): add context loading pre-phase and migration check"
```

---

### Task 2: Update `/reflect-quick` command

**Files:**
- Modify: `src/commands/reflect-quick.md`

- [ ] **Step 1: Rewrite reflect-quick.md with context loading**

Replace entire content with:

```markdown
빠른 내면 탐색. 질문 1회로 간략하게 진단합니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

## Pre-phase: Context 로드
세션 저장 경로의 roots.md를 읽습니다. 없으면 빈 상태로 진행합니다.
가장 최근 세션 파일에서 나침반 + state를 추출합니다.
(마이그레이션 확인은 /reflect와 동일)

$ARGUMENTS를 첫 번째 생각으로 사용합니다. 없으면 하나만 입력받습니다.

## 플로우
1. 사용자 입력 + roots.md + 최근 나침반을 inner-compass-socratic 에이전트에 전달
2. 에이전트 질문 1개만 제시, 답변 1회
3. inner-compass-crystallizer 에이전트에 위임하여 간략 진단
   - roots.md 내용도 함께 전달
   - 모드: quick
4. 세션 저장 경로의 `YYYY-MM-DD-HHmm-quick.md`에 저장

간이 모드의 루프 적용:
- roots.md 로드 + 뿌리 인지 질문: O (1라운드)
- 표면→뿌리 맵: X (생략)
- 뿌리 매칭 + roots.md 갱신: O (본질 진단에서 뿌리 추출)
- 궤적 섹션: O (간략 — 반복 뿌리만 표시)
```

- [ ] **Step 2: Commit**

```bash
git add src/commands/reflect-quick.md
git commit -m "feat(reflect-quick): add context loading and root matching"
```

---

### Task 3: Update `/reflect-deep` command

**Files:**
- Modify: `src/commands/reflect-deep.md`

- [ ] **Step 1: Rewrite reflect-deep.md with context loading**

Replace entire content with:

```markdown
심층 내면 탐색. 질문 5회 이상으로 깊이 파고듭니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

## Pre-phase: Context 로드
세션 저장 경로의 roots.md를 읽습니다. 없으면 빈 상태로 진행합니다.
가장 최근 세션 파일에서 나침반 + state를 추출합니다.
(마이그레이션 확인은 /reflect와 동일)

## 플로우
1. inner-compass-collector 에이전트로 생각 수집 (최소 5개 권장)
2. inner-compass-socratic 에이전트로 5라운드 이상 대화
   - roots.md + 최근 나침반을 함께 전달
   - 매 라운드마다 존재론적 분석 강화
   - "이것이 증상인가 원인인가?" 계열 질문 집중
   - 과거 뿌리 반복 시 더 깊이 파고듦
3. inner-compass-crystallizer 에이전트로 심층 진단
   - roots.md 내용 함께 전달, 모드: deep
   - 표준 진단에 추가로: 시간축 분석(과거→현재→미래), 가치관 충돌 맵
   - 궤적 섹션: 전체 + 시간축 분석 포함
4. 세션 저장 경로의 `YYYY-MM-DD-HHmm-deep.md`에 저장
```

- [ ] **Step 2: Commit**

```bash
git add src/commands/reflect-deep.md
git commit -m "feat(reflect-deep): add context loading and enhanced trajectory"
```

---

### Task 4: Update `/reflect-review` command

**Files:**
- Modify: `src/commands/reflect-review.md`

- [ ] **Step 1: Rewrite reflect-review.md to use roots.md**

Replace entire content with:

```markdown
과거 탐색 세션들을 회고합니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

## 플로우
1. 세션 저장 경로의 세션 파일들과 roots.md를 읽습니다
2. $ARGUMENTS가 있으면 필터링합니다:
   - 날짜: "이번 달", "최근 3개", "3월" 등
   - 키워드: "커리어", "불안" 등
   - 뿌리 이름: roots.md의 뿌리명으로 필터링
   - 없으면 최근 5개 세션
3. inner-compass-retrospective 에이전트에 위임하여 분석합니다:
   - 세션 파일들 + roots.md를 함께 전달
   - 시간에 따른 상태 변화 추적
   - 뿌리 단위로 장기 패턴 분석
   - 표면 변형의 시간순 변화 추적
4. 장기적 인사이트를 사용자에게 제시합니다
```

- [ ] **Step 2: Commit**

```bash
git add src/commands/reflect-review.md
git commit -m "feat(reflect-review): switch from patterns.md to roots.md"
```

---

### Task 5: Update socratic agent — add past-roots context

**Files:**
- Modify: `src/agents/inner-compass-socratic.md`

- [ ] **Step 1: Add past-roots context section to socratic agent**

Add after the "### readiness 판단" subsection's closing line (`"충분히 깊이 탐색한 것 같아요. 지금까지의 대화를 종합해서 정리해볼까요?"`) and before `## 금기사항`. This makes it a new `###` subsection under `## 행동 규칙`:

```markdown

### 과거 맥락 활용 (roots.md가 전달된 경우)

과거 뿌리 레지스트리(roots.md)와 최근 세션 나침반이 입력에 포함될 수 있습니다.
첫 세션이거나 roots.md가 비어있으면 이 섹션은 무시하고 기존 방식으로 진행합니다.

roots.md가 있을 때 추가 질문 레이어:

| 트리거 | 질문 예시 |
|--------|----------|
| 뿌리 반복 감지 (현재 생각이 기존 뿌리와 유사) | "이전에도 '과부하'가 등장했어요. 그때와 지금, 뭐가 달라졌나요?" |
| 표면 변형 감지 (다른 표현이지만 같은 뿌리) | "말은 다르지만 비슷한 패턴이 보여요. 혹시 연결된다고 느끼시나요?" |
| 시간 간격이 큼 (최근 세션이 7일+ 전) | "지난번에 '다음 한 걸음'으로 OO를 제안받았는데, 해보셨나요?" |
| 해소된 뿌리와 유사한 주제 | "예전에 OO는 해소되었는데, 그때 뭐가 도움이 됐나요?" |

이 질문들은 기존 소크라테스식 질문에 추가되는 레이어입니다.
과거 맥락 질문은 초기 분석에서 1-2개, 후속 대화에서 필요 시 활용합니다.
과거 맥락을 강요하지 않습니다 — 사용자가 새로운 주제를 탐색하고 싶어하면 따릅니다.
```

- [ ] **Step 2: Verify the file structure is coherent**

```bash
grep "^##" src/agents/inner-compass-socratic.md
```
Expected sections: 분석 프레임워크, 행동 규칙, 금기사항 (with 과거 맥락 활용 as ### under 행동 규칙)

- [ ] **Step 3: Commit**

```bash
git add src/agents/inner-compass-socratic.md
git commit -m "feat(socratic): add past-roots context awareness"
```

---

### Task 6: Update crystallizer agent — add root matching + trajectory

**Files:**
- Modify: `src/agents/inner-compass-crystallizer.md`

This is the largest change. The crystallizer gains three new responsibilities:
1. Root matching against existing roots.md
2. Trajectory section in session output
3. roots.md file update

- [ ] **Step 1: Add root matching section**

After the existing "## 입력" section (line ~8), modify it to include roots.md:

Replace:
```
## 입력
- 원본 생각 조각 목록
- inner-compass-socratic 에이전트와의 전체 대화 기록
- 세션 저장 경로 (config에서 전달됨)
```

With:
```
## 입력
- 원본 생각 조각 목록
- inner-compass-socratic 에이전트와의 전체 대화 기록
- 세션 저장 경로 (config에서 전달됨)
- 모드: standard | quick | deep
- roots.md 내용 (없으면 빈 상태)
```

- [ ] **Step 2: Add trajectory section to output structure**

The existing output sections are numbered 1-6. 궤적 is inserted between 에너지 분배(4) and 나침반(5), so renumber: 에너지 분배=4, **궤적=5**, 나침반=6, 비유=7. After the existing "### 4. 에너지 분배도" section, add the new section. Then renumber 나침반 from `### 5.` to `### 6.` and 비유 from `### 6.` to `### 7.`:

```markdown

### 5. 궤적 (roots.md가 있는 경우)
이번 세션에서 감지된 뿌리와 기존 뿌리의 관계를 정리합니다.
Obsidian callout `> [!timeline]` 형식으로 출력합니다.

포함 항목:
- **반복 중**: 기존 뿌리와 매칭된 경우. 등장 횟수, 표면 변형의 시간순 변화, 추이
- **새로 감지**: 이번 세션에서 처음 감지된 뿌리
- **지난 나침반 점검**: 이전 세션의 "다음 한 걸음"에 대한 점검 (최근 세션이 전달된 경우)

배치 순서: 에너지 분배 → **궤적** → 나침반 → 비유

첫 세션(roots.md 없음)이면 궤적 섹션은 생략합니다.

모드별 차이:
- standard: 전체 궤적
- quick: 간략 — 반복 뿌리만 한 줄로 표시
- deep: 전체 궤적 + 시간축 분석(과거→현재→미래)
```

- [ ] **Step 3: Add root matching mechanism section**

After the new trajectory section, add:

```markdown

## 뿌리 매칭 및 roots.md 갱신

세션 진단 생성 후, roots.md를 갱신합니다.

### 매칭 절차
1. 이번 세션의 표면→뿌리 맵에서 뿌리들을 추출합니다
   (quick 모드는 본질 진단에서 핵심 뿌리를 추출)
2. 각 뿌리를 roots.md의 기존 뿌리와 비교합니다:
   - 본질적으로 같다고 판단 → 기존 뿌리에 표면 변형 추가, 추이 갱신, 등장 횟수 증가
   - 다르다고 판단 → 새 뿌리로 등록 (추이: "관찰 중")
   - 애매하면 → 세션 파일 frontmatter에 `연관 가능: {뿌리명}` 표시
3. 해소됨 판단: 사용자가 "이건 이제 괜찮아" 류 언급 시 확인 질문 후 확정

### 애매한 연관의 생명주기
- 2회 연속 세션에서 같은 연관이 감지되면 → 매칭으로 승격
- 3회 세션 동안 재등장하지 않으면 → 연관 표시 삭제

### 추이 판단 가이드라인
- 표면이 더 강렬해짐 → 악화
- 비슷한 강도로 반복 → 유지
- 표면이 약해지거나 구체적 해결 시도 언급 → 개선
- 1회만 등장, 판단 근거 부족 → 관찰 중
- 사용자 확인 후 → 해소됨 (해소된 뿌리 섹션으로 이동, 해소 계기 기록)

### roots.md 갱신 방식
roots.md 전체를 읽고, 업데이트된 버전을 구성한 뒤 전체 파일을 다시 씁니다.
roots.md가 손상되었거나 파싱 불가능하면 빈 상태로 취급하고 세션 파일에 경고를 기록합니다.
세션 종료 시 정상적인 roots.md를 새로 생성합니다.
```

- [ ] **Step 4: Update the session file template frontmatter**

In the existing markdown template (the frontmatter section), add after `question_rounds: N`:

```yaml
matched_roots: []
new_roots: []
```

- [ ] **Step 5: Update the session file template body**

In the existing markdown template body, add the trajectory section between 에너지 분배 and 나침반:

```markdown

## 궤적
> [!timeline]
> (반복 중인 뿌리, 새로 감지된 뿌리, 지난 나침반 점검)

```

- [ ] **Step 6: Verify the file structure is coherent**

```bash
grep "^##" src/agents/inner-compass-crystallizer.md
```
Expected: 입력, 출력 구조, 저장 형식, 뿌리 매칭 및 roots.md 갱신 (plus subsections)

- [ ] **Step 7: Commit**

```bash
git add src/agents/inner-compass-crystallizer.md
git commit -m "feat(crystallizer): add root matching, trajectory output, and roots.md update"
```

---

### Task 7: Update retrospective agent — switch to roots.md

**Files:**
- Modify: `src/agents/inner-compass-retrospective.md`

- [ ] **Step 1: Update retrospective agent**

Replace all references to `patterns.md` with `roots.md`. Update the analysis framework to be root-centric. Specifically:

In the "### 2. 패턴 분석" section, replace:
```
- **미해결 패턴**: 여러 세션에 걸쳐 반복되는 표면→뿌리 쌍
```
with:
```
- **미해결 패턴**: 여러 세션에 걸쳐 반복되는 표면→뿌리 쌍
- **뿌리별 표면 변형 추이**: roots.md의 각 뿌리가 시간에 따라 어떤 표면으로 나타났는지
- **해소된 뿌리 리뷰**: 과거에 해소된 뿌리들에서 배울 수 있는 패턴
```

Replace the entire "### 4. 패턴 파일 업데이트" section **including the code fence block that follows it** (from `### 4. 패턴 파일 업데이트` through the closing ` ``` ` of the patterns.md format example, to the end of the file) with:
```
### 4. roots.md 검증
분석 결과를 roots.md와 대조합니다:
- 분석에서 발견된 패턴이 roots.md에 누락되어 있으면 추가를 제안합니다
- roots.md의 추이 판단이 실제 세션 데이터와 불일치하면 수정합니다
- 장기 미해결 뿌리(3개월+)에 대해 별도 인사이트를 제공합니다
```

- [ ] **Step 2: Commit**

```bash
git add src/agents/inner-compass-retrospective.md
git commit -m "feat(retrospective): switch from patterns.md to roots.md"
```

---

### Task 8: Reinstall updated files to ~/.claude/

**Files:**
- Run: `install.sh`

- [ ] **Step 1: Run install script**

```bash
./install.sh
```
Expected: "✓ Inner Compass installed!" (config already exists, should skip)

- [ ] **Step 2: Verify key changes are in place**

```bash
grep "roots.md" ~/.claude/commands/reflect.md
grep "과거 맥락 활용" ~/.claude/agents/inner-compass-socratic.md
grep "뿌리 매칭" ~/.claude/agents/inner-compass-crystallizer.md
grep "roots.md" ~/.claude/agents/inner-compass-retrospective.md
```
Expected: All four greps return matches.

- [ ] **Step 3: Commit (no changes to install.sh, just verification)**

No commit needed — install.sh copies existing src/ files.

---

### Task 9: Update init.md spec to reflect new architecture

**Files:**
- Modify: `docs/init.md`

- [ ] **Step 1: Update init.md**

Key changes to sync with the new retrospective loop:
- Section 2.2: Add `roots.md` to directory structure, note that `patterns.md` is deprecated
- Section 5.2 (socratic): Add note about past-roots context
- Section 5.3 (crystallizer): Add note about root matching + trajectory
- Section 5.4 (retrospective): Update patterns.md → roots.md
- Section 8 (Phase Flow): Update context passing diagram to include roots.md
- Section 10 (향후 확장): Move v0.2 items that are now implemented, add Approach C reference

- [ ] **Step 2: Commit**

```bash
git add docs/init.md
git commit -m "docs: sync init.md spec with retrospective loop implementation"
```

---

### Task 10: Push all changes

- [ ] **Step 1: Review all commits**

```bash
git log --oneline -10
```

- [ ] **Step 2: Push**

```bash
git push
```
