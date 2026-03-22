빠른 내면 탐색. 질문 1회로 간략하게 진단합니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

## Pre-phase: Context 로드
세션 저장 경로의 roots.md를 읽습니다. 없으면 빈 상태로 진행합니다.
가장 최근 세션 파일에서 나침반 + state를 추출합니다.
(마이그레이션 확인은 /reflect와 동일)

$ARGUMENTS를 첫 번째 생각으로 사용합니다. 없으면 하나만 입력받습니다.

## 플로우
1. 사용자 입력 + roots.md + 최근 나침반을 inner-compass-socratic 에이전트에 전달
2. 에이전트 질문 1개만 제시, 답변 1회
3. inner-compass-crystallizer 에이전트에 위임하여 간략 진단
   - roots.md 내용도 함께 전달
   - 모드: quick
4. 세션 저장 경로의 `YYYY-MM-DD-HHmm-quick.md`에 저장

간이 모드의 루프 적용:
- roots.md 로드 + 뿌리 인지 질문: O (1라운드)
- 표면→뿌리 맵: X (생략)
- 뿌리 매칭 + roots.md 갱신: O (본질 진단에서 뿌리 추출)
- 궤적 섹션: O (간략 — 반복 뿌리만 표시)
