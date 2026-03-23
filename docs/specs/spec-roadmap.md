# Inner Compass — 로드맵 및 참고 프로젝트

> 향후 확장 계획과 설계에 영향을 준 참고 프로젝트.

---

## 참고 프로젝트

### Ouroboros

https://github.com/Q00/ouroboros

소크라테스식 질문과 존재론적 분석으로 모호한 입력을 정제하는 철학적 프레임워크. Inner Compass의 핵심 탐색 방식(모호한 입력 → 질문 → 결정화)에 직접 영향을 줌.

주요 개념:
- Ambiguity ≤ 0.2 게이트 — 모호성이 충분히 낮아야 결정화 진행
- PAL Router — 입력 유형에 따라 처리 경로 분기
- Lateral Thinking Personas — 다각도 관점 전환

### oh-my-claudecode

https://github.com/yeachan-heo/oh-my-claudecode

Claude Code 위에서 동작하는 multi-agent orchestration 패턴. Inner Compass의 플러그인 구조(commands/, agents/, skills/)와 위임 방식의 직접적인 레퍼런스.

주요 개념:
- plugin manifest 기반 배포
- `agents/`, `commands/`, `skills/` 디렉토리 구조
- delegation-first 프로토콜 — 커맨드가 에이전트에 위임, 에이전트는 skill 활용
- model routing — 작업 복잡도에 따라 opus/sonnet 분기

### oh-my-openagent

https://github.com/code-yeongyu/oh-my-openagent

Claude + Codex + Gemini + Kimi를 지원하는 범용 agent harness. Inner Compass의 향후 범용화(v0.4) 시 참고할 `.agents/` 표준 구조를 제시함.

---

## 버전별 로드맵

### v0.2 — 뿌리 레지스트리 및 개인화

git log 기준 구현 완료 커밋:
- `feat(retrospective)`: patterns.md → roots.md 전환
- `feat(crystallizer)`: root matching, trajectory output, roots.md 갱신
- `feat(socratic)`: past-roots context awareness (과거 세션 기반 질문 개인화)
- `feat(crystallizer)`: correction mode 추가, 저장 책임 커맨드로 이전
- `feat(socratic)`: 2차 탐색 모드 (결정화 이후 재탐색)
- `feat: add review loop` — reflect, reflect-deep 양쪽에 결정화 후 리뷰 분기 구현

항목별 상태:

- [x] roots.md 뿌리 레지스트리 (patterns.md 대체)
- [x] 매 세션 자동 context 로드 (roots.md + 최근 세션 참조)
- [x] 과거 세션 기반 질문 개인화 (socratic 에이전트가 roots.md 참조)
- [x] 결정화 후 리뷰 분기 (수정 모드, 2차 탐색 모드, 저장 분기)
- [ ] /reflect-review 시계열 시각화 (텍스트 기반)

> 비고: 시계열 시각화를 제외한 v0.2 핵심 기능은 구현 완료. 리뷰 루프(correction mode + secondary exploration + review branch)는 init.md 원안에 없던 기능으로 v0.2 구현 중 추가됨.

---

### v0.3 — 에너지 추적 및 drift 감지

- [ ] 에너지 분배 시계열 추적 — 세션 간 에너지 분배 변화를 시간순으로 집계
- [ ] drift detection — 세션 진행 중 주제 이탈 자동 감지 및 알림
- [ ] Obsidian Daily Note 연동 — 당일 세션 결과를 데일리 노트에 자동 링크

---

### v0.4 — 3-layer memory 및 범용화

- [ ] 3-layer memory 구조 확장
  - `recent.md` — 최근 세션 요약 (단기)
  - `roots.md` — 반복 패턴 레지스트리 (중기, 현재 구현 중)
  - `growth.md` — 장기 성장 궤적 (장기)
- [ ] `~/.claude/` → `~/.agents/` 미러링 — OpenCode, Cursor 등과의 호환
- [x] Claude Code 플러그인 시스템으로 배포 (`/plugin marketplace add d0lim/inner-compass`)
- [ ] 도메인 특화 스킬팩 — 커리어 전환, 투자 판단, 사업 운영 등 특화 모듈
