# Inner Compass — 세션 데이터 형식 스펙

> 세션 파일, roots.md, config.md의 구체적인 형식과 갱신 규칙을 정의합니다.

---

## 1. 세션 파일 형식

### 1-1. 파일명 규칙

| 모드 | 파일명 형식 |
|------|------------|
| standard | `YYYY-MM-DD-HHmm.md` |
| quick | `YYYY-MM-DD-HHmm-quick.md` |
| deep | `YYYY-MM-DD-HHmm-deep.md` |

`HHmm`은 세션 저장 시점의 로컬 24시간제 시각입니다.

---

### 1-2. Frontmatter 필드

```yaml
---
date: YYYY-MM-DDTHH:MM
state: "(상태 명명)"
tags: [주제1, 주제2, 주제3]
mode: standard | quick | deep
lens: {렌즈명}
thought_count: N
question_rounds: N
matched_roots: []
new_roots: []
---
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `date` | ISO 8601 문자열 | 세션 저장 일시 (`YYYY-MM-DDTHH:MM`) |
| `state` | 문자열 | 상태 명명 (「 」괄호 없이 값만 기록) |
| `tags` | 문자열 배열 | 세션 주제 키워드 (Obsidian 태그 호환) |
| `mode` | 열거형 | `standard` / `quick` / `deep` 중 하나 |
| `lens` | 문자열 | 사용된 렌즈 식별자 (예: `socratic`, `camus`, `phenomenological`) |
| `thought_count` | 정수 | 수집된 생각 조각 수 |
| `question_rounds` | 정수 | 렌즈 에이전트 질문 라운드 수 |
| `matched_roots` | 문자열 배열 | 이번 세션에서 기존 뿌리와 매칭된 뿌리명 목록 |
| `new_roots` | 문자열 배열 | 이번 세션에서 새로 감지된 뿌리명 목록 |

**ambiguous 처리 시 추가 필드:**

```yaml
연관 가능: 뿌리명
```

ambiguous로 분류된 뿌리는 frontmatter에 위 필드를 추가하여 표시합니다.
2회 연속 같은 연관이 감지되면 matched로 승격하고, 3회 세션 동안 재등장하지 않으면 필드를 삭제합니다.

---

### 1-3. 본문 섹션 구조 및 전체 템플릿

아래 순서대로 섹션을 배치합니다. 모드에 따라 일부 섹션이 생략됩니다 (2절 참조).

```markdown
---
date: YYYY-MM-DDTHH:MM
state: "(상태 명명)"
tags: [주제1, 주제2, 주제3]
mode: standard | quick | deep
lens: {렌즈명}
thought_count: N
question_rounds: N
matched_roots: []
new_roots: []
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

## 궤적
> [!timeline]
> (반복 중인 뿌리, 새로 감지된 뿌리, 지난 나침반 점검)

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

#### 각 섹션 설명

| 섹션 | 내용 |
|------|------|
| **상태 명명** | 현재 상태를 한 단어 또는 짧은 구절로 명명. `「 」` 괄호로 감쌈. 추상적이되 구체적 이미지를 떠올릴 수 있어야 함. |
| **본질** | 모든 생각의 뿌리가 되는 핵심 상태를 3-4문장으로 설명. 개별 생각이 아닌 전체를 관통하는 하나의 맥락. |
| **표면 → 뿌리** | 각 생각 조각의 표면적 형태와 본질적 욕구/두려움을 매핑하는 표. 3-5개 항목. |
| **에너지 분배** | 현재 정신적 에너지가 흐르는 영역, 비율(%), 성질(productive/draining/neutral). 전체 합 100%, 3-5개 영역. |
| **궤적** | `[!timeline]` callout. 반복 중인 뿌리, 새로 감지된 뿌리, 지난 나침반 점검을 포함. roots.md가 없는 첫 세션은 생략. |
| **나침반** | `[!compass]` callout. 지금 가장 필요한 것 / 놓아줘도 되는 것 / 가장 작은 다음 한 걸음을 제시. |
| **비유** | 현재 상태를 이미지가 선명하게 표현한 한 문장. 이탤릭 처리. |

---

## 2. 모드별 섹션 차이

| 섹션 | standard | quick | deep |
|------|----------|-------|------|
| 상태 명명 | O | O | O |
| 본질 | O | O | O |
| 표면 → 뿌리 | O | **생략** | O |
| 에너지 분배 | O | **생략** | O |
| 궤적 | 전체 | 간략 (반복 뿌리만 한 줄) | 전체 + 시간축 분석 |
| 나침반 | O | O | O |
| 비유 | O | O | O |

**모드별 특이사항:**

- **standard**: 기본값. 전체 섹션 포함. 소크라테스 질문 2-3라운드.
- **quick**: 표면→뿌리 맵과 에너지 분배 섹션을 생략. 질문 1회. 뿌리 매칭은 본질 진단에서 핵심 뿌리를 추출하여 수행. 궤적은 간략 — 반복 뿌리만 한 줄로 표시.
- **deep**: 전체 섹션 포함. 소크라테스 질문 5라운드 이상. 궤적에 시간축 분석(과거→현재→미래)과 가치관 충돌 맵 추가.

---

## 3. Revision 메타데이터

리뷰 분기(Phase 2.5)에서 수정이 발생한 경우, 세션 파일 frontmatter에 다음 필드를 추가합니다.

```yaml
revised: true
revision_count: {수정 횟수}
revision_history:
  - type: correction | exploration
    trigger: "{사용자가 말한 수정/탐색 계기 요약}"
```

| 필드 | 설명 |
|------|------|
| `revised` | 수정 여부. 수정이 한 번이라도 발생하면 `true`. |
| `revision_count` | 수정 총 횟수 (correction + exploration 합산). |
| `revision_history` | 수정 이력 배열. |
| `type` | `correction` — 사용자가 결과물을 직접 수정 요청. `exploration` — 새 생각 추가로 2차 탐색 후 재결정화. |
| `trigger` | 수정/탐색의 계기를 한 줄 요약. |

수정 이력은 시간 순서대로 append합니다. 최종 저장은 최종 수락된 결과 기준으로 한 번만 수행합니다.

---

## 4. roots.md 구조

뿌리 레지스트리. 세션 저장 경로에 `roots.md` 파일 하나로 관리합니다. roots.md는 **렌즈 중립적**이며, 추이(trend)는 포함하지 않습니다. 추이는 렌즈별 `perspectives/{lens}.md`에서 관리합니다.

```markdown
# 뿌리 레지스트리

## {뿌리명}
- **표면 변형**: [{변형1}, {변형2}, ...]
- **등장 횟수**: N
- **관련 세션**: [[YYYY-MM-DD-HHmm]], [[YYYY-MM-DD-HHmm-deep]], ...

## {뿌리명2}
...

---

## 해소된 뿌리

### {뿌리명}
- **해소 계기**: {계기 설명}
- **등장 횟수**: N
- **관련 세션**: [[YYYY-MM-DD-HHmm]], ...
```

| 필드 | 설명 |
|------|------|
| **뿌리명** | 뿌리를 나타내는 이름. crystallizer가 이번 세션 분석에서 도출. |
| **표면 변형** | 각 세션에서 이 뿌리가 드러난 구체적 생각 표현들의 목록. |
| **등장 횟수** | 이 뿌리가 감지된 세션 수. |
| **관련 세션** | Obsidian wikilink 형식의 세션 파일 링크 목록. |

> **참고**: 이전 버전의 roots.md에는 `추이` 필드가 포함되어 있었으나, 멀티 렌즈 시스템 도입으로 추이는 perspectives/{lens}.md로 이전되었습니다. 마이그레이션은 Pre-phase에서 자동 수행됩니다.

---

## 5. roots.md 갱신 방식

crystallizer가 반환하는 `[roots_update]` 분석 결과를 기반으로, 커맨드(reflect.md)가 roots.md를 기계적으로 갱신합니다. 갱신은 최종 수락된 결과 기준으로 한 번만 수행합니다. roots.md에는 렌즈 중립적 사실만 기록합니다.

roots.md 전체를 읽고 업데이트된 버전을 구성한 뒤 전체 파일을 다시 씁니다.

### matched 처리
- 해당 뿌리 섹션에 이번 세션의 표면 변형을 추가합니다.
- 등장 횟수를 1 증가합니다.
- 관련 세션 링크를 추가합니다.

### new 처리
- 새 뿌리 섹션을 생성합니다.
- 표면 변형, 등장 횟수(1), 관련 세션을 기록합니다.

### ambiguous 처리
- roots.md는 변경하지 않습니다.
- 해당 세션 파일 frontmatter에 `연관 가능: {뿌리명}` 필드를 추가합니다.
- **승격 조건**: 2회 연속 세션에서 같은 연관 감지 시 → matched로 승격.
- **삭제 조건**: 3회 세션 동안 재등장하지 않으면 연관 표시 삭제.

### resolved 처리
- 해당 뿌리를 활성 목록에서 제거하고 `## 해소된 뿌리` 섹션으로 이동합니다.
- 해소 계기를 기록합니다.

### 오류 처리
- roots.md가 손상되었거나 파싱 불가능하면 빈 상태로 취급합니다.
- 세션 파일 본문에 경고를 기록합니다.

---

## 5-1. perspectives/{lens}.md 구조

렌즈별 해석을 저장하는 파일입니다. 세션 저장 경로의 `perspectives/` 디렉토리 내에 렌즈별로 하나씩 관리합니다 (예: `perspectives/socratic.md`, `perspectives/camus.md`, `perspectives/phenomenological.md`).

```markdown
## {뿌리명}
- **핵심 해석**: {렌즈 관점에서의 해석}
- **추이**: 관찰 중 | 개선 | 유지 | 악화
- **세션별 변화**:
  - YYYY-MM-DD: {이번 세션에서의 관찰}
  - YYYY-MM-DD: {이전 세션에서의 관찰}

## {뿌리명2}
...
```

| 필드 | 설명 |
|------|------|
| **뿌리명** | roots.md의 뿌리명과 동일. |
| **핵심 해석** | 해당 렌즈의 철학적 관점에서 본 뿌리의 해석. |
| **추이** | 이 렌즈 관점에서의 시간에 따른 변화 방향. `관찰 중` / `개선` / `유지` / `악화`. |
| **세션별 변화** | 각 세션에서의 관찰 기록. 날짜순으로 append. |

**추이 판단 기준 (렌즈별):**

| 추이 | 조건 |
|------|------|
| 악화 | 표면이 더 강렬해짐 |
| 유지 | 비슷한 강도로 반복 |
| 개선 | 표면이 약해지거나 구체적 해결 시도 언급 |
| 관찰 중 | 1회만 등장, 판단 근거 부족 |

---

## 5-2. perspectives/{lens}.md 갱신 방식

crystallizer가 반환하는 `[perspective_update]` 분석 결과를 기반으로, 커맨드가 perspectives/{lens}.md를 갱신합니다.

```
[perspective_update]
- lens: {사용된 렌즈}
- interpretations:
  - root: {뿌리명}
    interpretation: {핵심 해석}
    trend: {추이}
    observation: {이번 세션 관찰}
```

### 기존 뿌리
- 핵심 해석과 추이를 업데이트합니다.
- 세션별 변화에 이번 관찰을 추가합니다.

### 새 뿌리
- 새 섹션으로 추가합니다.

perspectives/{lens}.md 전체를 읽고 업데이트된 버전을 다시 씁니다.

---

## 5-3. roots.md → perspectives 마이그레이션

이전 버전의 roots.md에 포함되어 있던 `추이` 필드를 perspectives/socratic.md로 마이그레이션합니다.

| 조건 | 처리 |
|------|------|
| roots.md에 "추이" 필드 있음 + perspectives/socratic.md 없음 | 마이그레이션 실행 |
| perspectives/socratic.md 이미 있음 | 마이그레이션 생략 |

**마이그레이션 절차:**
1. perspectives/ 디렉토리를 생성합니다.
2. roots.md의 각 뿌리에서 추이 필드를 추출하여 perspectives/socratic.md를 생성합니다.
   - 뿌리명 → 섹션 헤더
   - 추이 → 추이 필드
   - 핵심 해석: "마이그레이션됨 — 다음 세션에서 갱신 예정"
3. roots.md에서 추이 필드를 제거하고 중립적 사실만 남깁니다.

---

## 6. patterns.md → roots.md 마이그레이션

`patterns.md`는 이전 버전에서 사용하던 패턴 레지스트리로, **deprecated** 상태입니다.

마이그레이션 조건 및 처리 방식은 `/reflect` Pre-phase (`spec-phase-flow.md`의 Pre-phase 참조)에서 수행합니다. 요약:

| 조건 | 처리 |
|------|------|
| roots.md 없음 + patterns.md 있음 | patterns.md를 roots.md로 변환 후 진행 |
| roots.md 있음 + patterns.md 있음 | roots.md만 사용, patterns.md 무시 |
| 둘 다 없음 | 첫 세션, 빈 상태로 진행 |

**변환 규칙:**

| patterns.md 필드 | roots.md 필드 |
|------------------|---------------|
| 패턴명 | 뿌리명 |
| 설명 | 메모 (별도 필드) |
| 관련 세션 수 | 등장 횟수 |
| — | 표면 변형: 빈 리스트로 초기화 |
| — | 추이: `관찰 중`으로 초기화 |

변환 후 `patterns.md`는 보존합니다 (삭제하지 않음).

---

## 7. config.md 형식

`~/.inner-compass/config.md`에 저장되는 설정 파일입니다.

```markdown
---
sessions_dir: {세션 저장 절대 경로}
obsidian_vault: {Obsidian vault 절대 경로}
---
```

| 필드 | 설명 | 기본값 |
|------|------|--------|
| `sessions_dir` | 세션 파일과 roots.md가 저장될 디렉토리 절대 경로 | `~/.inner-compass/sessions/` |
| `obsidian_vault` | Obsidian vault 루트 절대 경로. 설정 시 `{vault}/Inner-Compass/sessions/`를 sessions_dir로 사용. | 없음 (선택사항) |

`obsidian_vault`가 설정된 경우 `sessions_dir`은 `{obsidian_vault}/Inner-Compass/sessions/`로 자동 결정됩니다.

---

## 8. Obsidian 호환 규칙

Inner Compass 세션 파일은 Obsidian vault에 직접 저장될 수 있으며, 다음 형식 규칙을 따릅니다.

### Callout

Obsidian callout 문법을 사용합니다.

```markdown
> [!timeline]
> 내용

> [!compass]
> 내용
```

- `[!timeline]`: 궤적 섹션에서 사용. Obsidian에서 타임라인 스타일로 렌더링됩니다.
- `[!compass]`: 나침반 섹션에서 사용. Obsidian에서 강조 블록으로 렌더링됩니다.

### Wikilink

세션 파일 간 연결 및 roots.md의 관련 세션 링크에 Obsidian wikilink 형식을 사용합니다.

```markdown
[[YYYY-MM-DD-HHmm|이전 세션: 상태명]]
[[YYYY-MM-DD-HHmm]]
```

- 세션 파일 마지막에 이전 세션 링크를 배치합니다 (이전 세션이 있는 경우).
- roots.md의 `관련 세션` 필드에 wikilink 목록을 사용합니다.

### Frontmatter tags

```yaml
tags: [주제1, 주제2, 주제3]
```

- Obsidian 표준 frontmatter 형식을 따릅니다.
- 태그는 배열 형식으로 기록합니다.
- `#` prefix 없이 값만 기록합니다 (Obsidian이 자동 처리).

### 파일 인코딩 및 줄바꿈

- 인코딩: UTF-8
- 줄바꿈: LF (`\n`)
- 확장자: `.md`
