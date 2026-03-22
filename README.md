# Inner Compass

> 산발적인 내면의 생각을 체계적으로 정제하여 자기 상태를 진단하는 Claude Code 플러그인

터미널에서 코딩하다가, `/reflect` 한 번이면 내면 탐색이 시작됩니다.

## How it works

```
/reflect "요즘 이것저것 너무 많이 벌려놓은 것 같다"
```

1. **수집** — 머릿속 생각을 자유롭게 쏟아냅니다
2. **탐색** — 소크라테스식 질문으로 본질에 접근합니다
3. **결정화** — 내면 상태를 하나의 진단으로 응축합니다
4. **저장** — 마크다운으로 기록됩니다 (Obsidian 연동 가능)

## Install

### Plugin (추천)

Claude Code 세션에서 **한 줄씩** 실행하세요:

```
/plugin marketplace add d0lim/inner-compass
```
```
/plugin install inner-compass
```

### Manual

```bash
git clone https://github.com/d0lim/inner-compass.git
cd inner-compass
./install.sh
```

### 설치 후

```
/reflect-setup    # Obsidian vault 경로 설정 (선택)
/reflect          # 탐색 세션 시작
```

## Commands

| Command | Description |
|---------|-------------|
| `/reflect` | 표준 세션 — 수집 → 질문 2-3라운드 → 진단 |
| `/reflect-quick` | 간이 모드 — 질문 1회, 핵심만 |
| `/reflect-deep` | 심층 모드 — 질문 5회+, 가치관 충돌 맵 포함 |
| `/reflect-review` | 과거 세션 회고 — 장기 패턴 분석 |
| `/reflect-setup` | 초기 설정 — Obsidian vault 연동 등 |

## Output

세션 결과는 `~/.inner-compass/sessions/`에 저장됩니다 (Obsidian vault 설정 시 vault 내 저장).

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

## Architecture

```
/reflect
  ├─ collector (sonnet)      # 생각 수집
  ├─ socratic (opus)         # 소크라테스식 질문
  ├─ crystallizer (opus)     # 상태 결정화 + 저장
  └─ retrospective (sonnet)  # 과거 회고 (/reflect-review)
```

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

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Claude Max subscription

**Optional:** [Obsidian](https://obsidian.md/) — 세션 결과를 vault에 직접 저장하여 그래프 뷰, 백링크, 검색 등을 활용할 수 있습니다. `/reflect-setup`에서 vault 경로를 설정하면 됩니다.

## Inspired by

- [Ouroboros](https://github.com/Q00/ouroboros) — Socratic questioning + ontological analysis
- [oh-my-claudecode](https://github.com/yeachan-heo/oh-my-claudecode) — Multi-agent orchestration for Claude Code

## License

MIT
