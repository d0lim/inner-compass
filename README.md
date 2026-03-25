# Inner Compass

> 흩어진 생각을 차분히 정리해 지금 내 상태를 짚어보는 Claude Code 플러그인

터미널에서 작업하다가 문득 머릿속이 복잡해질 때가 있습니다.  
Inner Compass는 그 순간 `/reflect` 한 번으로 생각을 모으고, 질문을 따라가고, 지금의 상태를 한 장의 기록으로 남기게 해줍니다.

## 이런 순간에 잘 맞습니다

- 이것저것 벌려놓았는데 뭐부터 정리해야 할지 모르겠을 때
- 막연히 불안하거나 답답한데 이유를 말로 붙잡기 어려울 때
- 코딩 흐름을 완전히 끊지 않고 짧게 내 상태를 점검하고 싶을 때
- 생각 기록을 Obsidian에 쌓아두고 나중에 다시 돌아보고 싶을 때

## 왜 Inner Compass인가

- **터미널 안에서 바로 전환** — 작업 흐름을 크게 끊지 않고 곧바로 탐색을 시작할 수 있습니다.
- **질문으로 파고듦** — 막연한 생각을 바로 결론 내리지 않고, 질문을 통해 조금씩 정리합니다.
- **한 번으로 끝나지 않음** — 저장 전에 수정하거나, 새 생각을 더하거나, 다른 렌즈로 다시 볼 수 있습니다.
- **기록이 남음** — 세션 결과가 Markdown으로 저장되어 나중에 다시 읽고 회고할 수 있습니다.
- **Obsidian과 잘 맞음** — vault에 바로 저장해 그래프 뷰, 백링크, 검색 흐름에 자연스럽게 붙일 수 있습니다.

## 1분 시작

### Plugin 설치 (추천)

Claude Code 세션에서 **한 줄씩** 실행하세요.

```
/plugin marketplace add d0lim/inner-compass
```
```
/plugin install inner-compass
```

### Manual 설치

```bash
git clone https://github.com/d0lim/inner-compass.git
cd inner-compass
./install.sh
```

### 설치 후 첫 실행

```
/reflect-setup                # 최초 1회 필수: 저장 경로 설정
/reflect                      # 기본 소크라테스 렌즈로 시작
/reflect --lens camus         # 다른 렌즈로 다시 탐색
```

`/reflect-setup`은 처음 한 번은 꼭 실행해야 합니다. Obsidian vault를 쓰지 않더라도 기본 저장 경로를 만들고 `config.md`를 준비해야 이후 커맨드가 정상적으로 동작합니다.

## 세션은 이렇게 흘러갑니다

```
/reflect "요즘 이것저것 너무 많이 벌려놓은 것 같다"
```

기본 렌즈는 `socratic`입니다. 필요하면 `/reflect --lens camus`처럼 다른 렌즈로 다시 들여다볼 수도 있습니다.

1. **수집** — 머릿속 생각을 자유롭게 꺼냅니다
2. **탐색** — 선택한 렌즈가 질문을 이어가며 생각의 결을 따라갑니다
3. **결정화** — 흩어져 있던 상태를 하나의 진단으로 모읍니다
4. **리뷰** — 저장하기 전에 수정하거나, 새 생각을 더하거나, 렌즈를 바꿔 다시 볼 수 있습니다
5. **저장** — Markdown으로 남기고 다음 세션의 맥락으로 이어집니다

## 렌즈 소개

기본 렌즈는 `socratic`이지만, 같은 생각도 어떤 관점으로 보느냐에 따라 전혀 다른 질문이 나옵니다.

- **socratic** — 소크라테스식 질문과 존재론적 분석으로 생각의 본질을 탐색합니다.
- **camus** — 카뮈의 부조리 철학으로 기대와 현실 사이의 간극을 들여다봅니다.
- **phenomenological** — 판단을 잠시 멈추고, 있는 그대로의 체험에 집중합니다.
- **pragmatist** — 생각이 실제 행동과 결과를 어떻게 바꾸는지 살핍니다.
- **buddhist** — 집착과 고통의 관계를 보고, 무엇을 놓아줄 수 있는지 탐색합니다.
- **existential** — 자유, 책임, 진정성의 관점에서 지금의 선택을 다시 묻습니다.
- **stoic** — 통제할 수 있는 것과 없는 것을 나눠 마음의 중심을 찾습니다.
- **nietzsche** — 자기 극복과 가치 창조의 관점에서 지금의 삶을 돌아봅니다.

예를 들어 같은 고민이라도 `/reflect --lens stoic`, `/reflect --lens pragmatist`, `/reflect --lens buddhist`처럼 바꿔 보면 질문의 방향이 달라집니다.

## 저장 결과 예시

```markdown
# 「 확장 전 응축기 」

## 본질
여러 방향으로 뻗어가고 싶은 욕구와, 하나도 제대로 마무리하지 못하는
불안이 충돌하고 있다...

## 나침반
> [!compass]
> **◆ 지금 필요한 것**: 하나를 골라 끝까지 가보는 경험
> **◇ 놓아줘도 되는 것**: 모든 것을 동시에 해야 한다는 압박
> **▸ 다음 한 걸음**: 오늘 하루, 딱 하나만 선택해서 30분 집중하기
```

## Commands

| Command | Description |
|---------|-------------|
| `/reflect` | 표준 세션 — 수집 → 질문 2-3라운드 → 결정화 → 리뷰 → 저장 |
| `/reflect-quick` | 간이 모드 — 질문 1회로 빠르게 상태를 짚습니다 |
| `/reflect-deep` | 심층 모드 — 질문 5회+, 시간축 분석·가치관 충돌 맵 포함 |
| `/reflect-review` | 과거 세션 회고 — 렌즈별 / 뿌리별 장기 패턴 분석 |
| `/reflect-setup` | 초기 설정 — 저장 경로 / Obsidian vault / perspectives 디렉토리 준비 |

## 어디에 저장되나

기본 저장 경로는 `~/.inner-compass/`입니다. `/reflect-setup`을 마치면 `config.md`, 세션 파일, `roots.md`, 렌즈별 `perspectives/`가 이 아래에서 함께 관리됩니다.

- 기본 세션 파일: `~/.inner-compass/sessions/`
- Obsidian 연동 시: `{vault}/Inner-Compass/` 아래에 `sessions/`, `roots.md`, `perspectives/` 저장
- 렌즈별 해석: `perspectives/{lens}.md`
- 뿌리 레지스트리: `roots.md`

저장되는 파일 이름은 모드에 따라 달라집니다.

- `/reflect` → `YYYY-MM-DD-HHmm.md`
- `/reflect-quick` → `YYYY-MM-DD-HHmm-quick.md`
- `/reflect-deep` → `YYYY-MM-DD-HHmm-deep.md`

리뷰 단계에서 수정이 한 번이라도 일어나면 저장된 세션 frontmatter에 revision metadata가 추가됩니다.

## 어떻게 돌아가나

```text
/reflect command
  ├─ inner-compass-collector         # 생각 수집
  ├─ inner-compass-lens-{lens}       # 렌즈별 탐색 (socratic, camus, ...)
  ├─ inner-compass-crystallizer      # 상태 결정화
  ├─ review branch in command        # 수정 / 새 생각 / 렌즈 전환 / 저장
  └─ inner-compass-retrospective     # 과거 회고 (/reflect-review)
```

전체 흐름과 저장은 **command가 맡고**, 각 에이전트는 수집·탐색·결정화·회고를 나눠서 담당합니다. 결정화 에이전트는 결과만 돌려주고 파일은 직접 저장하지 않습니다. 최종 저장과 `roots.md`, `perspectives/{lens}.md` 갱신은 command 단계에서 처리됩니다.

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Claude Max subscription

**Optional:** [Obsidian](https://obsidian.md/) — 세션 결과를 vault에 바로 저장해 그래프 뷰, 백링크, 검색을 함께 활용할 수 있습니다. `/reflect-setup`에서 vault 경로를 잡아주면 됩니다.

## Uninstall

Plugin으로 설치한 경우:
```
/plugin remove inner-compass
```

Manual로 설치한 경우:
```bash
./uninstall.sh
```

세션 데이터(`~/.inner-compass/`)는 보존됩니다. 삭제하려면:

```bash
rm -rf ~/.inner-compass/
```

## Inspired by

- [Ouroboros](https://github.com/Q00/ouroboros) — Socratic questioning + ontological analysis
- [oh-my-claudecode](https://github.com/yeachan-heo/oh-my-claudecode) — Multi-agent orchestration for Claude Code

## License

MIT
