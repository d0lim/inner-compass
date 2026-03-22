빠른 내면 탐색. 질문 1회로 간략하게 진단합니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

$ARGUMENTS를 첫 번째 생각으로 사용합니다. 없으면 하나만 입력받습니다.

## 플로우
1. 사용자 입력을 바로 inner-compass-socratic 에이전트에 전달 (수집 단계 생략)
2. 에이전트 질문 1개만 제시, 답변 1회
3. inner-compass-crystallizer 에이전트에 위임하여 간략 진단
4. 세션 저장 경로의 `YYYY-MM-DD-HHmm-quick.md`에 저장

간이 모드는 full 진단의 축약 버전입니다:
- 상태 명명 + 본질 진단 + 나침반만 포함
- 표면→뿌리 맵, 에너지 분배는 생략
