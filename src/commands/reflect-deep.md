심층 내면 탐색. 질문 5회 이상으로 깊이 파고듭니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

## Pre-phase: Context 로드
세션 저장 경로의 roots.md를 읽습니다. 없으면 빈 상태로 진행합니다.
가장 최근 세션 파일에서 나침반 + state를 추출합니다.
(마이그레이션 확인은 /reflect와 동일)

## 플로우
1. inner-compass-collector 에이전트로 생각 수집 (최소 5개 권장)
2. inner-compass-socratic 에이전트로 5라운드 이상 대화
   - roots.md + 최근 나침반을 함께 전달
   - 매 라운드마다 존재론적 분석 강화
   - "이것이 증상인가 원인인가?" 계열 질문 집중
   - 과거 뿌리 반복 시 더 깊이 파고듦
3. inner-compass-crystallizer 에이전트로 심층 진단
   - roots.md 내용 함께 전달, 모드: deep
   - 표준 진단에 추가로: 시간축 분석(과거→현재→미래), 가치관 충돌 맵
   - 궤적 섹션: 전체 + 시간축 분석 포함
4. 세션 저장 경로의 `YYYY-MM-DD-HHmm-deep.md`에 저장
