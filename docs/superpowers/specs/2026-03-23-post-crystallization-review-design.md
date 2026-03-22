# Post-Crystallization Review Design

## Summary

결정화(crystallization) 완료 후 사용자가 결과를 검토하고, 필요시 수정하거나 추가 탐색할 수 있는 리뷰 분기를 추가한다.

## Problem

현재 결정화가 완료되면 결과가 바로 저장되고 세션이 종료된다. 사용자는:
- 결정화 결과가 자신의 느낌과 맞지 않아도 수정할 기회가 없다
- 결정화 결과를 보고 새로운 생각이 떠올라도 이어서 대화할 방법이 없다

## Design

### 흐름 변경

```
기존: 수집 → 소크라테스 탐색 → 결정화 → 저장 → 종료

변경: 수집 → 소크라테스 탐색 → 결정화 → 리뷰 분기 → 저장 → 종료
                                          ↑              |
                                          └──── 수정/탐색 ←┘
```

### 리뷰 분기 동작

1. crystallizer가 결과를 생성하면, 메인 커맨드(`reflect.md`)가 결과를 사용자에게 보여준다.
2. 선택지를 제시한다:
   - **"괜찮아요"** → 저장 후 종료
   - **"수정하고 싶어요"** → crystallizer를 수정 모드로 다시 호출
   - **"새로운 생각이 떠올랐어요"** → socratic을 2차 탐색 모드로 호출, 탐색 후 다시 결정화
3. 수정/재결정화 후 다시 리뷰 분기로 돌아온다 (제한 없이 반복).

### 에이전트 변경

#### crystallizer — 수정 모드 추가

기존 역할(대화 전문을 받아 결정화 결과 생성)에 수정 모드를 추가한다:
- 이전 결정화 결과 + 사용자 피드백을 입력으로 받는다.
- 사용자가 지적한 부분만 수정한다 (전체 재생성이 아님).
- 수정된 결과를 동일한 포맷으로 출력한다.

#### socratic — 2차 탐색 모드 추가

기존 역할(수집된 생각을 기반으로 탐색)에 2차 탐색 모드를 추가한다:
- 결정화 결과 + 새로 떠오른 생각을 컨텍스트로 받아 탐색한다.
- 2차 탐색 후에는 기존과 동일하게 결정화로 넘어간다.

#### reflect.md (메인 커맨드)

현재 crystallizer 호출 후 바로 저장하는 부분에 리뷰 루프를 추가한다:
- 결정화 결과를 사용자에게 보여주고 선택지를 제시한다.
- 선택에 따라 crystallizer 또는 socratic을 재호출한다.
- "괜찮아요" 선택 시 저장을 진행한다.

### 저장 및 메타데이터

수정이 발생한 세션의 frontmatter에 다음 필드를 추가한다:

```yaml
revised: true
revision_count: 2
revision_history:
  - type: correction  # 또는 exploration
    trigger: "나침반 방향이 맞지 않는 것 같아요"
  - type: exploration
    trigger: "새로운 생각이 떠올랐어요"
```

- `revised`: 수정 여부 (boolean)
- `revision_count`: 총 수정 횟수
- `revision_history`: 각 수정의 유형(`correction` | `exploration`)과 사용자가 말한 계기 요약

저장 동작:
- 수정 없이 "괜찮아요" → 기존과 동일하게 저장 (추가 필드 없음)
- 수정 후 "괜찮아요" → 최종 결과로 덮어쓰기 + 위 메타데이터 추가
- roots.md 업데이트는 최종 결과 기준으로 한 번만 수행

### 모드별 적용

| 모드 | 리뷰 분기 | 이유 |
|------|-----------|------|
| standard (`/reflect`) | 적용 | 기본 탐색 흐름에 자연스럽게 어울림 |
| deep (`/reflect-deep`) | 적용 | 깊은 탐색이므로 더 자연스러움 |
| quick (`/reflect-quick`) | 미적용 | 빠른 진단이 목적. 수정 필요시 `/reflect` 재실행 |
| retrospective (`/reflect-review`) | 변경 없음 | 별도 분석 도구로 해당 없음 |

## Affected Files

- `commands/reflect.md` — 리뷰 루프 오케스트레이션 추가
- `agents/inner-compass-crystallizer.md` — 수정 모드 프롬프트 추가
- `agents/inner-compass-socratic.md` — 2차 탐색 모드 프롬프트 추가
- `docs/init.md` — 스펙 문서 업데이트
