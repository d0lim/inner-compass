# Post-Crystallization Review Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 결정화 후 사용자가 결과를 검토하고 수정/추가 탐색할 수 있는 리뷰 분기를 추가한다.

**Architecture:** crystallizer가 결과만 반환하도록 변경하고, reflect.md가 리뷰 루프를 관리하며 최종 저장을 담당한다. 사용자 선택에 따라 crystallizer(수정)나 socratic(2차 탐색)을 재호출하고, 수락 시 저장한다.

**Tech Stack:** Claude Code plugin (markdown prompt files), Agent orchestration

---

### Task 1: crystallizer에 수정 모드 추가 및 저장 책임 분리

**Files:**
- Modify: `agents/inner-compass-crystallizer.md:74-161`

**변경 내용:**
- 모든 모드에서 파일 저장과 roots.md 갱신을 수행하지 않도록 변경 (호출 커맨드가 담당)
- 수정 모드 섹션 추가: 이전 결과 + 사용자 피드백을 받아 부분 수정 후 결과만 반환
- 뿌리 매칭 분석 결과를 구조화된 형식으로 반환하도록 변경

- [ ] **Step 1: crystallizer.md에 수정 모드 섹션 추가**

`agents/inner-compass-crystallizer.md`의 `## 입력` 섹션 아래에 다음을 추가:

```markdown
## 모드

### 일반 모드 (기본)
기존과 동일하게 전체 대화를 종합하여 결정화 결과를 생성합니다.
결과를 반환만 하고, 파일 저장이나 roots.md 갱신은 수행하지 않습니다.

### 수정 모드
호출 시 "수정 모드"로 명시되면 활성화됩니다.

입력:
- 이전 결정화 결과 (전체 마크다운)
- 사용자 피드백 (수정 요청 내용)

행동:
- 사용자가 지적한 부분만 수정합니다 (전체 재생성 아님)
- 수정되지 않은 섹션은 그대로 유지합니다
- 수정된 결과를 동일한 포맷으로 반환합니다
- 파일 저장과 roots.md 업데이트를 수행하지 않습니다
```

- [ ] **Step 2: `## 저장 형식` 섹션을 `## 출력 형식`으로 전체 교체**

`agents/inner-compass-crystallizer.md`의 `## 저장 형식` 섹션(line 74-133)을 통째로 다음으로 교체합니다. 기존 마크다운 템플릿(파일 구조)은 유지하되, 파일 저장 관련 지시를 모두 제거합니다:

```markdown
## 출력 형식

생성한 진단을 다음 형식의 마크다운으로 반환합니다.
파일 저장은 수행하지 않습니다 — 호출한 커맨드(reflect.md 등)가 저장을 담당합니다.
```

이 헤더 아래에 기존 마크다운 템플릿(frontmatter + 섹션 구조)은 그대로 유지합니다. 단, 다음 문장들은 삭제합니다:
- line 77: "저장 경로는 입력으로 전달받은 세션 저장 경로를 사용합니다." → 삭제
- line 79: "파일명: `YYYY-MM-DD-HHmm.md` (현재 날짜와 시간 사용)" → 삭제
- line 127: "세션 저장 디렉토리가 없으면 먼저 생성합니다." → 삭제

- [ ] **Step 3: `## 뿌리 매칭 및 roots.md 갱신` 섹션을 `## 뿌리 매칭 분석`으로 전체 교체**

`agents/inner-compass-crystallizer.md`의 `## 뿌리 매칭 및 roots.md 갱신` 섹션(line 134-161)을 통째로 다음으로 교체합니다. 매칭 절차와 추이 판단 가이드라인은 유지하되, roots.md 직접 갱신 지시를 제거하고 구조화된 분석 결과 반환으로 변경합니다:

```markdown
## 뿌리 매칭 분석

세션 진단 생성 시, roots.md와의 매칭 분석을 수행하고 결과에 포함합니다.
roots.md 파일 갱신은 수행하지 않습니다 — 호출한 커맨드가 담당합니다.

### 매칭 절차
1. 이번 세션의 표면→뿌리 맵에서 뿌리들을 추출합니다
   (quick 모드는 본질 진단에서 핵심 뿌리를 추출)
2. 각 뿌리를 roots.md의 기존 뿌리와 비교합니다:
   - 본질적으로 같다고 판단 → matched
   - 다르다고 판단 → new
   - 애매하면 → ambiguous
3. 해소됨 판단: 사용자가 "이건 이제 괜찮아" 류 언급 시 → resolved

### 추이 판단 가이드라인
- 표면이 더 강렬해짐 → 악화
- 비슷한 강도로 반복 → 유지
- 표면이 약해지거나 구체적 해결 시도 언급 → 개선
- 1회만 등장, 판단 근거 부족 → 관찰 중

### 분석 결과 반환 형식
결정화 결과 마크다운 끝에 다음 형식으로 매칭 분석을 추가합니다:

[roots_update]
- matched: [{뿌리명, 추가할 표면 변형, 갱신할 추이, 증가할 등장 횟수}]
- new: [{뿌리명, 표면 변형 리스트, 추이: "관찰 중"}]
- ambiguous: [{뿌리명, 연관 가능 뿌리}]
- resolved: [{뿌리명, 해소 계기}]
```

기존 `### 갱신 방식` 하위 섹션(line 158-161: "roots.md 전체를 읽고..." 이하)은 삭제합니다. 이 로직은 Task 3에서 reflect.md의 Phase 3으로 이전됩니다.

- [ ] **Step 4: 커밋**

```bash
git add agents/inner-compass-crystallizer.md
git commit -m "feat: add correction mode to crystallizer, separate save responsibility"
```

---

### Task 2: socratic에 2차 탐색 모드 추가

**Files:**
- Modify: `agents/inner-compass-socratic.md:66-82`

**변경 내용:**
- 2차 탐색 모드 섹션 추가: 결정화 결과를 바탕으로 추가 탐색

- [ ] **Step 1: socratic.md에 2차 탐색 모드 섹션 추가**

`agents/inner-compass-socratic.md`의 `### 과거 맥락 활용` 섹션 뒤, `## 금기사항` 앞에 다음을 추가:

```markdown
### 2차 탐색 모드 (결정화 이후 재탐색)

호출 시 "2차 탐색 모드"로 명시되면 활성화됩니다.
사용자가 결정화 결과를 본 뒤 새로운 생각이 떠올랐을 때 사용됩니다.

입력:
- 원본 생각 조각 (1차 수집 결과)
- 1차 소크라테스 대화 이력
- 결정화 결과 (현재까지의 진단)
- 새로 떠오른 생각 (사용자가 추가로 말한 내용)
- roots.md (기존과 동일하게 로드)

행동:
- 1차 대화 이력을 참고하여 이미 탐색한 질문을 반복하지 않습니다
- 결정화 결과와 새로운 생각 사이의 연결점이나 긴장을 탐색합니다
- "결정화 결과에서 OO라고 나왔는데, 새로 떠오른 생각과 어떻게 연결되나요?" 계열 질문 활용
- 라운드 수는 호출 시 전달된 모드 설정을 따릅니다 (standard: 2-3회, deep: 5+회)
- readiness 판단은 기존과 동일한 기준을 적용합니다
- 과거 맥락 활용 규칙(### 과거 맥락 활용 섹션)은 2차 탐색에서도 동일하게 적용합니다
```

- [ ] **Step 2: 커밋**

```bash
git add agents/inner-compass-socratic.md
git commit -m "feat: add secondary exploration mode to socratic agent"
```

---

### Task 3: reflect.md에 리뷰 루프 추가

**Files:**
- Modify: `commands/reflect.md:57-84`

**변경 내용:**
- Phase 2 결정화 후 리뷰 분기 추가
- Phase 3에서 세션 파일 저장 + roots.md 갱신 담당

- [ ] **Step 1: Phase 2 변경 — crystallizer 호출 텍스트와 결과 처리 수정**

`commands/reflect.md`의 Phase 2에서 두 군데를 수정합니다:

**(a)** crystallizer 호출 프롬프트 마지막 줄(line 76-77)을 변경:

기존:
```
이 전체 맥락을 종합하여 상태를 결정화해주세요.
roots.md의 기존 뿌리와 매칭하고, roots.md를 갱신해주세요.
```

변경:
```
이 전체 맥락을 종합하여 상태를 결정화해주세요.
roots.md의 기존 뿌리와 매칭 분석을 포함해주세요.
```

**(b)** Phase 2 마지막 부분(line 79)을 변경:

기존:
```
crystallizer가 세션 파일 저장 + roots.md 갱신을 모두 수행합니다.
```

변경:
```
crystallizer가 결정화 결과와 뿌리 매칭 분석을 반환합니다.
파일 저장이나 roots.md 갱신은 수행하지 않습니다.
```

- [ ] **Step 2: Phase 2.5 리뷰 분기 섹션 추가**

Phase 2와 Phase 3 사이에 다음 섹션을 삽입:

```markdown
## Phase 2.5: 리뷰 분기

crystallizer가 반환한 결정화 결과를 사용자에게 보여줍니다.

그 후 다음과 같이 안내합니다:
"결정화가 완료되었습니다. 어떻게 할까요?

(1) 괜찮아요, 저장해주세요
(2) 수정하고 싶어요
(3) 새로운 생각이 떠올랐어요"

### 사용자가 (1)을 선택한 경우
Phase 3으로 진행합니다.

### 사용자가 (2)를 선택한 경우
사용자에게 수정하고 싶은 부분을 물어봅니다.
inner-compass-crystallizer 에이전트를 수정 모드로 호출합니다:

"수정 모드로 전환합니다.

[이전 결정화 결과]
{결정화 결과 전체}

[사용자 피드백]
{사용자가 말한 수정 요청}

이전 결과에서 사용자가 지적한 부분만 수정해주세요."

수정된 결과를 받아 다시 리뷰 분기(Phase 2.5)로 돌아갑니다.

### 사용자가 (3)을 선택한 경우
사용자에게 새로 떠오른 생각을 자유롭게 말하게 합니다.
inner-compass-socratic 에이전트를 2차 탐색 모드로 호출합니다:

"2차 탐색 모드로 전환합니다.

[원본 생각]
{1차 수집 결과}

[1차 대화 이력]
{Phase 1의 전체 대화}

[결정화 결과]
{현재 결정화 결과}

[새로운 생각]
{사용자가 추가로 말한 내용}

[과거 맥락]
{roots.md 내용, 없으면 생략}

결정화 결과를 바탕으로 새로운 생각을 탐색해주세요.
이미 1차에서 다룬 질문은 반복하지 마세요."

2차 탐색이 완료되면 다시 Phase 2(결정화)로 돌아갑니다.
이때 crystallizer에 전달하는 대화 기록에 2차 탐색 내용도 포함합니다.
결정화 후 다시 리뷰 분기(Phase 2.5)로 돌아갑니다.
```

- [ ] **Step 3: Phase 3 변경 — 저장 및 roots.md 갱신 담당**

`commands/reflect.md`의 Phase 3을 다음으로 교체:

```markdown
## Phase 3: 저장 및 완료

### 세션 파일 저장
결정화 결과를 세션 파일로 저장합니다.
파일명: `YYYY-MM-DD-HHmm.md` (현재 날짜와 시간)
저장 경로: config에서 확인한 세션 저장 경로

리뷰 분기에서 수정이 발생한 경우 frontmatter에 다음을 추가합니다:
```yaml
revised: true
revision_count: {수정 횟수}
revision_history:
  - type: correction | exploration
    trigger: "{사용자가 말한 수정/탐색 계기 요약}"
```

### roots.md 갱신
crystallizer가 반환한 `[roots_update]` 구조화된 분석을 기반으로 roots.md를 기계적으로 갱신합니다.
갱신은 최종 수락된 결과 기준으로 한 번만 수행합니다.

갱신 방식 (crystallizer의 분석 결과를 그대로 적용):
- roots.md 전체를 읽고 업데이트된 버전을 구성한 뒤 전체 파일을 다시 씁니다
- matched 항목: 해당 뿌리에 표면 변형 추가, 추이 갱신, 등장 횟수 증가, 관련 세션 링크 추가
- new 항목: 새 뿌리로 등록 (추이: "관찰 중")
- ambiguous 항목: 세션 frontmatter에 `연관 가능: {뿌리명}` 표시
  - 2회 연속 세션에서 같은 연관 감지 시 → 매칭으로 승격
  - 3회 세션 동안 재등장하지 않으면 → 연관 표시 삭제
- resolved 항목: 해소된 뿌리 섹션으로 이동, 해소 계기 기록
- roots.md가 손상되었거나 파싱 불가능하면 빈 상태로 취급, 세션 파일에 경고 기록

### 완료 안내
저장 완료를 사용자에게 알립니다.
궤적 섹션에서 반복 중인 뿌리가 있으면 간략히 언급합니다.
```

- [ ] **Step 4: 커밋**

```bash
git add commands/reflect.md
git commit -m "feat: add review loop and save responsibility to reflect command"
```

---

### Task 4: reflect-deep.md에 리뷰 루프 추가

**Files:**
- Modify: `commands/reflect-deep.md:18-22`

**변경 내용:**
- 결정화 후 리뷰 분기 추가 (reflect.md와 동일한 구조)
- 저장 책임을 reflect-deep.md로 이전

- [ ] **Step 1: reflect-deep.md의 플로우 섹션을 변경**

`commands/reflect-deep.md`의 플로우 섹션(line 11-22)을 다음으로 교체합니다. 항목 1-2는 기존과 동일하며, 항목 3-5가 변경/추가됩니다:

```markdown
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
   - crystallizer가 결과와 뿌리 매칭 분석을 반환 (파일 저장 안 함)
4. 리뷰 분기 (/reflect와 동일한 구조)
   - 결정화 결과를 사용자에게 보여주고 선택지 제시
   - (1) 괜찮아요 → 저장, (2) 수정 → crystallizer 수정 모드, (3) 새 생각 → socratic 2차 탐색 (5+라운드)
   - 수정/탐색 후 다시 리뷰 분기로 반복
5. 저장 및 완료
   - 세션 저장 경로의 `YYYY-MM-DD-HHmm-deep.md`에 저장
   - 수정 발생 시 frontmatter에 revised, revision_count, revision_history 추가
   - roots.md 갱신 (최종 결과 기준으로 한 번만)
   - 저장 완료 안내
```

- [ ] **Step 2: 커밋**

```bash
git add commands/reflect-deep.md
git commit -m "feat: add review loop to reflect-deep command"
```

---

**참고:** `commands/reflect-quick.md`는 변경하지 않습니다. quick 모드는 빠른 진단이 목적이므로 리뷰 분기를 적용하지 않는 것이 설계 의도입니다.

---

### Task 5: docs/init.md 스펙 문서 업데이트

**Files:**
- Modify: `docs/init.md`

**변경 내용:**
- 파이프라인 흐름도에 리뷰 분기 추가
- crystallizer 저장 책임 변경 반영
- 리뷰 분기 동작 설명 추가

- [ ] **Step 1: init.md 수정 — 아래 섹션들을 업데이트**

수정이 필요한 init.md 섹션들:

**(a) `### 4.1 /reflect (표준 세션)` (line 208):**
- Phase 흐름에 "Phase 2.5: 리뷰 분기" 추가
- crystallizer 호출 설명에서 저장 책임 제거
- Phase 3을 "저장 및 완료"로 변경, 세션 파일 저장 + roots.md 갱신 담당 명시

**(b) `### 4.3 /reflect-deep (심층 모드)` (line 271):**
- 리뷰 분기 추가, 저장 책임 변경 (4.1과 동일한 구조)

**(c) `### 5.3 inner-compass-crystallizer.md` (line 442):**
- 저장 형식 → 출력 형식으로 변경
- 뿌리 매칭 및 roots.md 갱신 → 뿌리 매칭 분석으로 변경
- 수정 모드 설명 추가

**(d) `### 5.2 inner-compass-socratic.md` (line 364):**
- 2차 탐색 모드 설명 추가

**(e) `## 8. Phase Flow 상세` (line 752):**
- 흐름도에 리뷰 분기 단계 추가
- crystallizer 저장 책임 변경 반영

핵심 반영 사항:
- 흐름: 수집 → 탐색 → 결정화 → **리뷰 분기** → 저장 → 종료
- crystallizer: 결과만 반환, 파일 저장 안 함
- 리뷰 분기: 괜찮아요 / 수정 / 새 탐색 선택지
- 저장: reflect.md/reflect-deep.md가 담당
- quick 모드는 리뷰 분기 미적용
- 수정 시 frontmatter에 revised, revision_count, revision_history 추가

- [ ] **Step 2: 커밋**

```bash
git add docs/init.md
git commit -m "docs: update init.md spec with post-crystallization review flow"
```
