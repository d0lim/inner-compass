# Inner Compass — 아키텍처 명세

> Claude Code 플러그인 시스템 기반의 구조화된 내면 탐색 도구.
> 이 문서는 실제 파일시스템 구조를 기준으로 작성되었다.

---

## 1. 소스 구조

실제 리포지토리 파일시스템 구조:

```
inner-compass/
│
├── .claude-plugin/
│   ├── plugin.json                   # 플러그인 메타데이터 (name, version, description 등)
│   └── marketplace.json              # 자체 마켓플레이스 정의
│
├── commands/                         # Slash commands (5개)
│   ├── reflect.md                    # /reflect — 표준 탐색 세션
│   ├── reflect-quick.md              # /reflect-quick — 간이 모드
│   ├── reflect-deep.md               # /reflect-deep — 심층 모드
│   ├── reflect-review.md             # /reflect-review — 과거 회고
│   └── reflect-setup.md              # /reflect-setup — 초기 설정
│
├── agents/                               # Subagents (5개)
│   ├── inner-compass-collector.md        # 생각 수집
│   ├── inner-compass-lens-socratic.md    # 소크라테스 렌즈 (산파술)
│   ├── inner-compass-lens-camus.md       # 카뮈 렌즈 (부조리주의)
│   ├── inner-compass-crystallizer.md     # 상태 결정화 (렌즈 중립)
│   └── inner-compass-retrospective.md    # 과거 세션 회고 + 크로스 렌즈 비교
│
├── skills/                           # Auto-activating skills (3개)
│   ├── inner-compass-pattern-detect/
│   │   └── SKILL.md
│   ├── inner-compass-ontological-analysis/
│   │   └── SKILL.md
│   └── inner-compass-obsidian-export/
│       └── SKILL.md
│
├── install.sh                        # manual 설치 스크립트
├── uninstall.sh                      # manual 제거 스크립트
├── README.md
├── LICENSE
└── docs/
    ├── init.md                       # 전체 구현 가이드 (마스터 스펙)
    ├── specs/                        # 분리된 세부 명세 문서
    └── superpowers/                  # 설계 계획 및 기능 명세
        ├── plans/
        └── specs/
```

---

## 2. 네이밍 규칙

다른 플러그인과의 충돌 방지를 위한 일관된 접두사 체계를 사용한다.

| 구성 요소 | 접두사 | 예시 |
|---|---|---|
| Agent (일반) | `inner-compass-` | `inner-compass-collector.md` |
| Agent (렌즈) | `inner-compass-lens-` | `inner-compass-lens-socratic.md`, `inner-compass-lens-camus.md`, `inner-compass-lens-phenomenological.md` |
| Skill | `inner-compass-` | `inner-compass-pattern-detect/` |
| Command | `reflect-` | `reflect.md`, `reflect-quick.md` |

- **Agent / Skill**: 내부 시스템 구성 요소이므로 플러그인 이름 전체를 접두사로 사용
- **렌즈 Agent**: `inner-compass-lens-{name}` 규칙을 따릅니다. frontmatter에 `lens_id`, `lens_name` 필드를 포함합니다. 새 렌즈 추가 시 이 규칙을 따라 파일을 생성합니다.
- **Command**: 사용자가 직접 입력하므로 간결한 `reflect-` 접두사로 충분

> **참고**: 기존 `inner-compass-socratic.md`는 `inner-compass-lens-socratic.md`로 이름이 변경되었습니다.

---

## 3. 세션 저장 경로

### 기본 경로 (`~/.inner-compass/`)

```
~/.inner-compass/
├── config.md                         # 설정 파일 (vault 경로 등)
├── sessions/                         # 개별 세션 결과
│   └── YYYY-MM-DD-HHmm.md            # 세션 파일 (타임스탬프 기반)
├── roots.md                          # 뿌리 레지스트리 (렌즈 중립, 추이 없음)
├── perspectives/                     # 렌즈별 해석 저장
│   ├── socratic.md                    # 소크라테스 렌즈 해석
│   └── camus.md                       # 카뮈 렌즈 해석
└── patterns.md                       # (deprecated — roots.md로 대체됨)
```

### Obsidian vault 연동 시

`/reflect-setup`에서 vault 경로를 설정한 경우, 세션은 vault 내에 저장된다:

```
{obsidian_vault}/
└── Inner-Compass/
    ├── sessions/
    │   └── YYYY-MM-DD-HHmm.md
    ├── roots.md
    └── perspectives/
        ├── socratic.md
        └── camus.md
```

### 세션 파일명 규칙

| 커맨드 | 파일명 패턴 |
|---|---|
| `/reflect` | `YYYY-MM-DD-HHmm.md` |
| `/reflect-quick` | `YYYY-MM-DD-HHmm-quick.md` |
| `/reflect-deep` | `YYYY-MM-DD-HHmm-deep.md` |

수정이 발생한 경우 frontmatter에 `revised`, `revision_count`, `revision_history` 필드가 추가된다.

---

## 4. config.md 형식

파일 위치: `~/.inner-compass/config.md`

```markdown
---
sessions_dir: ~/.inner-compass/sessions
obsidian_vault: ~
---
```

| 필드 | 설명 | 기본값 |
|---|---|---|
| `sessions_dir` | 세션 저장 경로 | `~/.inner-compass/sessions` |
| `obsidian_vault` | Obsidian vault 루트 경로 | `~` (비어있으면 기본 경로 사용) |

**동작 로직:**

- `obsidian_vault`가 실제 경로로 설정된 경우: `{obsidian_vault}/Inner-Compass/sessions/`에 저장
- `obsidian_vault`가 비어있거나 `~`인 경우: `~/.inner-compass/sessions/`에 저장
- 이 파일은 `/reflect-setup`이 생성 및 수정한다
- 모든 reflect 커맨드는 실행 시 이 파일을 먼저 읽어 저장 경로를 확인한다

---

## 5. Claude Code 플러그인 규칙

Claude Code 플러그인 시스템에서 각 디렉토리와 파일의 역할은 다음과 같다.

### 5.1 `commands/` — Slash Command 정의

- **파일명이 커맨드명이 된다**: `reflect.md` → `/reflect`
- 사용자가 커맨드를 실행하면 해당 `.md` 파일의 내용이 Claude에게 지시로 전달된다
- `$ARGUMENTS` 변수로 커맨드 뒤에 입력한 텍스트를 받을 수 있다

### 5.2 `agents/` — Subagent 정의

- `Task()` tool(Agent tool)로 위임할 때 사용하는 전문 에이전트
- frontmatter에 `name`, `description`, `model`, `tools`를 정의한다
- 렌즈 에이전트는 추가로 `lens_id`, `lens_name` 필드를 포함한다
- 각 에이전트는 단일 책임을 갖는다 (수집 / 렌즈별 질문 / 결정화 / 회고)

### 5.3 `skills/` — Auto-activating Skill 정의

- **디렉토리명이 skill명**이 된다
- 각 skill 디렉토리 내부에 `SKILL.md`가 반드시 존재해야 한다
- Claude가 관련 작업을 수행할 때 자동으로 활성화된다

### 5.4 `.claude-plugin/` — 플러그인 메타데이터

- `plugin.json`: 플러그인 이름, 버전, 설명 등 메타데이터
- `marketplace.json`: Claude Code 마켓플레이스 등록 정의

### 5.5 배포 방식

```
/plugin marketplace add d0lim/inner-compass
/plugin install inner-compass
```

또는 manual 설치:

```bash
git clone https://github.com/d0lim/inner-compass.git
cd inner-compass && ./install.sh
```

글로벌 설치이므로 **어떤 디렉토리에서든 `/reflect` 사용 가능**하다.

---

## 6. Context 전달 방식

에이전트 간 컨텍스트는 Agent tool 호출 시 `prompt` 파라미터에 이전 결과를 직접 포함하여 전달한다. 별도의 상태 저장소나 파일 경유 없이 텍스트로 전달하는 단방향 파이프라인 구조다.

### 표준 세션 (`/reflect`) 파이프라인

```
사용자 입력 (--lens 파라미터 파싱)
    ↓
[Pre-phase: perspectives/{lens}.md 로드 / cold start bootstrap]
    ↓
[inner-compass-collector]
  → 수집된 생각 목록 반환
    ↓
[inner-compass-lens-{lens}]
  prompt: 수집된 생각 + roots.md + perspectives/{lens}.md
  → 질문/답변 대화 기록 반환
    ↓
[inner-compass-crystallizer]
  prompt: 원본 생각 + 전체 대화 기록 + 렌즈명 + perspectives/{lens}.md
  → 결정화 결과 + [roots_update] + [perspective_update] 반환 (파일 저장 안 함)
    ↓
[리뷰 분기 — command가 직접 처리]
  (1) 괜찮아요 → 저장 단계로
  (2) 수정 → crystallizer 수정 모드로 재위임
  (3) 새 생각 → lens-{lens} 2차 탐색 후 crystallizer 재실행
  (4) 다른 렌즈 → lens-{새렌즈}로 Phase 1부터 재시작
    ↓
[저장 — command가 직접 처리]
  세션 파일 저장 + roots.md 갱신 + perspectives/{lens}.md 갱신
```

### 핵심 원칙

- **파일 저장 책임**: crystallizer, 렌즈 에이전트 등은 파일을 저장하지 않는다. **저장은 최종 단계에서 command가 직접 수행한다.**
- **렌즈 중립성**: crystallizer는 렌즈 중립적으로 동작한다. 어떤 렌즈 에이전트의 결과든 받아서 결정화한다. roots.md도 렌즈 중립적이며, 추이는 perspectives/{lens}.md에서 렌즈별로 관리한다.
- **리뷰 루프**: 결정화 결과에 대한 리뷰 분기(수정/재탐색/렌즈 전환/승인)는 command 레벨에서 관리하며, 사용자가 만족할 때까지 반복할 수 있다 (횟수 제한 없음).
- **데이터 흐름**: 각 에이전트의 출력은 다음 에이전트의 `prompt`에 텍스트로 포함된다. 에이전트 간 공유 상태는 없다.
- **단방향**: collector → lens-{lens} → crystallizer 순서로 진행되며, 역방향 호출은 없다 (렌즈 전환 시에만 Phase 1로 재진입).
