# init.md 분할 및 CLAUDE.md 반영 설계

## 배경

`docs/init.md`는 프로젝트 초기에 작성된 전체 스펙 문서(~893줄)로, 이후 실제 구현이 진화하면서 상당한 drift가 발생했다. 실제 구현 상태를 반영하는 새 spec 파일들을 만들고, init.md는 제거한다.

## 결정 사항

- **분할 단위**: 기능 단위 (commands, agents, skills, session format 등)
- **소스 우선순위**: 실제 구현 파일 > init.md (drift가 있으면 구현이 ground truth)
- **init.md 처리**: 삭제 (git history에서 참조 가능)
- **CLAUDE.md**: 최소 포인터 + "작업 완료 시 문서 최신화" 규칙
- **spec 위치**: `docs/specs/` (superpowers 설계 문서와 분리)

## 파일 구조

```
docs/specs/
├── index.md                 # 인덱스 — 전체 스펙 목록 + 한 줄 설명 + 링크
├── spec-overview.md         # 프로젝트 개요, 핵심 컨셉, 설치, 제약사항
├── spec-architecture.md     # 디렉토리 구조, 플러그인 규칙, 에이전트 간 context 전달
├── spec-commands.md         # /reflect, /reflect-quick, /reflect-deep, /reflect-review, /reflect-setup
├── spec-agents.md           # collector, socratic, crystallizer, retrospective
├── spec-skills.md           # pattern-detect, ontological-analysis, obsidian-export
├── spec-session-format.md   # 세션 파일 포맷, frontmatter, roots.md 구조, config.md
├── spec-phase-flow.md       # 전체 phase flow 상세 (Phase 0~3 + 리뷰 분기)
└── spec-roadmap.md          # 향후 확장 계획 (v0.3, v0.4) + 참고 프로젝트
```

## 각 파일의 내용 소스

| 파일 | 소스 |
|------|------|
| index.md | 새로 작성. 아래 모든 파일의 목록 + 한 줄 설명 + 상대 링크 |
| spec-overview.md | init.md 섹션 1 + 섹션 7 (설치/테스트) |
| spec-architecture.md | init.md 섹션 2 + 실제 디렉토리 구조 대조 |
| spec-commands.md | **실제 `commands/*.md` 파일 5개** (reflect, reflect-quick, reflect-deep, reflect-review, reflect-setup) 기준. init.md는 참고만 |
| spec-agents.md | **실제 `agents/*.md` 파일 4개** (collector, socratic, crystallizer, retrospective) 기준 |
| spec-skills.md | **실제 `skills/*/SKILL.md` 파일 3개** (pattern-detect, ontological-analysis, obsidian-export) 기준 |
| spec-session-format.md | init.md 섹션 5.3 출력 구조 + 실제 crystallizer 구현 기준 |
| spec-phase-flow.md | **실제 `commands/reflect.md`** 기준 (가장 drift가 큰 부분) |
| spec-roadmap.md | init.md 섹션 9, 10 |

## 구현 순서

1. `docs/specs/` 디렉토리 생성 및 모든 spec 파일 작성
2. `CLAUDE.md` 생성
3. `docs/init.md` 삭제
4. 단일 커밋으로 처리 (부분 완료 상태 방지)

## CLAUDE.md

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
