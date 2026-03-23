과거 탐색 세션들을 회고합니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

$ARGUMENTS에서 `--lens {name}` 및 `--root {뿌리명}` 파라미터를 파싱합니다.
나머지 $ARGUMENTS는 기존과 동일하게 필터링 기준으로 사용합니다.

## 플로우
1. 세션 저장 경로의 세션 파일들과 roots.md, perspectives/ 디렉토리를 읽습니다
2. $ARGUMENTS가 있으면 필터링합니다:
   - 날짜: "이번 달", "최근 3개", "3월" 등
   - 키워드: "커리어", "불안" 등
   - 뿌리 이름: roots.md의 뿌리명으로 필터링
   - 렌즈: `--lens` 지정 시 해당 렌즈의 세션만 필터 (frontmatter의 lens 필드 기준)
   - 뿌리: `--root` 지정 시 해당 뿌리 관련 세션만 필터
   - 없으면 최근 5개 세션
3. inner-compass-retrospective 에이전트에 위임하여 분석합니다:
   - 세션 파일들 + roots.md + perspectives/ 관련 파일을 함께 전달
   - `--lens` 모드: 해당 렌즈의 perspective만 전달, 렌즈 관점에서 회고 요청
   - `--root` 모드: 해당 뿌리에 대한 모든 perspectives를 전달, 크로스 렌즈 비교 분석 요청
   - 기본 모드: 모든 perspectives + 최근 5개 세션
   - 시간에 따른 상태 변화 추적
   - 뿌리 단위로 장기 패턴 분석
   - 표면 변형의 시간순 변화 추적
4. 장기적 인사이트를 사용자에게 제시합니다
