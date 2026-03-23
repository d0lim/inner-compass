# Inner Compass — 스펙 개요

> 산발적인 내면의 생각을 체계적으로 정제하여 자기 상태를 진단하는 Claude Code 플러그인.

---

## 핵심 컨셉

[Ouroboros](https://github.com/Q00/ouroboros) 프레임워크의 철학을 내면 탐색에 적용:

- **모호한 입력 → 소크라테스식 질문 → 결정화(Seed)**
- 인간의 생각은 ambiguous, incomplete, contradictory, surface-level — 직접 실행하면 GIGO이므로 먼저 정제해야 한다

[oh-my-claudecode](https://github.com/yeachan-heo/oh-my-claudecode)의 agent orchestration 패턴을 차용:

- slash command로 진입
- 전문 에이전트에 위임 (delegation-first)
- skill 자동 활성화
- 결과를 파일로 persist

---

## 사용 시나리오

| 커맨드 | 설명 |
|---|---|
| `/reflect` | 표준 세션 — 소크라테스식 질문 → 결정화 |
| `/reflect-quick` | 간이 모드 — 빠른 상태 진단 |
| `/reflect-deep` | 심층 모드 — 확장 탐색 |
| `/reflect-review` | 과거 세션 회고 |
| `/reflect-setup` | 초기 설정 (1회) |

```
# 기본 사용
> /reflect

# 첫 생각과 함께 진입
> /reflect 요즘 이것저것 너무 많이 벌려놓은 것 같다

# 간이 모드
> /reflect-quick 오늘 불안한데 이유를 모르겠어
```

---

## 왜 Claude Code인가

- 터미널에서 코딩 중 바로 사색 전환 가능
- **글로벌 설치** — 어떤 디렉토리에서든 `/reflect` 사용 가능
- `.md` 파일로 저장 → Obsidian vault와 직접 연동
- Claude의 full context window 활용 (stateless API가 아님)
- 추가 비용 없음 (Claude Max 구독 내)
- slash command, agent, skill 등 Claude Code 네이티브 기능 활용

---

## 설치 방법

**Plugin (추천):**

```
/plugin marketplace add d0lim/inner-compass
/plugin install inner-compass
```

**Manual (개발용):**

```bash
git clone https://github.com/d0lim/inner-compass.git
cd inner-compass && ./install.sh
```

---

## 제약사항

- **실행 위치 제약 없음**: 플러그인으로 설치되므로 어디서든 사용 가능
- **필요 조건**: Claude Code CLI 설치, Claude Max 구독
- **초기 설정**: `/reflect-setup` 1회 실행 (Obsidian vault 경로 설정, 선택사항)

---

## 테스트

1. **설정**: `/reflect-setup` 실행 → `~/.inner-compass/config.md` 생성 확인
2. **탐색**: `/reflect` 또는 `/reflect-quick` 실행 → 소크라테스식 질문 흐름 확인
3. **저장 확인**: 세션 종료 후 `~/.inner-compass/sessions/` 또는 설정된 Obsidian vault 경로에 `.md` 파일 생성 확인
