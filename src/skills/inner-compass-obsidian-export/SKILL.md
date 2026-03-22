---
name: inner-compass-obsidian-export
description: 세션 결과를 Obsidian 호환 마크다운으로 최적화
triggers: ["저장", "obsidian", "내보내기", "노트"]
---

## 역할
crystallizer의 출력을 Obsidian에서 최적으로 활용 가능한 형태로 보장합니다.

## Obsidian 호환 규칙
1. YAML frontmatter 필수 (date, state, tags, mode 등)
2. 태그는 frontmatter의 tags 배열로 (인라인 #태그 아닌)
3. 관련 세션 연결은 [[wikilink]] 형식
4. 나침반은 Obsidian callout 문법 사용: `> [!compass]`
5. 비유는 이탤릭 인용 형식: `*"비유 문장"*`

## 파일명 규칙
`YYYY-MM-DD-HHmm.md` (24시간 형식)
quick 모드: `YYYY-MM-DD-HHmm-quick.md`
deep 모드: `YYYY-MM-DD-HHmm-deep.md`
