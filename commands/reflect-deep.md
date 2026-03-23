심층 내면 탐색. 질문 5회 이상으로 깊이 파고듭니다.

먼저 ~/.inner-compass/config.md를 읽어 세션 저장 경로를 확인합니다.
설정 파일이 없으면 "/reflect-setup을 먼저 실행해주세요."라고 안내합니다.

$ARGUMENTS에서 `--lens {name}` 파라미터를 파싱합니다.
지정되지 않으면 기본값 `socratic`을 사용합니다.

## Pre-phase: Context 로드
세션 저장 경로의 roots.md를 읽습니다. 없으면 빈 상태로 진행합니다.
가장 최근 세션 파일에서 나침반 + state를 추출합니다.
(마이그레이션 확인은 /reflect와 동일)

### perspectives/{lens}.md 로드
세션 저장 경로의 perspectives/{lens}.md를 읽습니다.
파일이 없으면 cold start bootstrap을 실행합니다:
- inner-compass-lens-{lens} 에이전트를 bootstrap 모드로 호출
- roots.md의 활성 뿌리 + 최근 3개 세션을 전달
- 반환된 결과를 perspectives/{lens}.md로 저장
perspectives/ 디렉토리가 없으면 생성합니다.
(마이그레이션 확인은 /reflect와 동일)

## 플로우
1. inner-compass-collector 에이전트로 생각 수집 (최소 5개 권장)
2. inner-compass-lens-{lens} 에이전트로 5라운드 이상 대화
   - roots.md + 최근 나침반 + perspectives/{lens}.md 내용을 함께 전달
   - 매 라운드마다 존재론적 분석 강화
   - "이것이 증상인가 원인인가?" 계열 질문 집중
   - 과거 뿌리 반복 시 더 깊이 파고듦
3. inner-compass-crystallizer 에이전트로 심층 진단
   - roots.md 내용 함께 전달, 렌즈: {lens}, 모드: deep
   - perspectives/{lens}.md 내용 함께 전달
   - 표준 진단에 추가로: 시간축 분석(과거→현재→미래), 가치관 충돌 맵
   - 궤적 섹션: 전체 + 시간축 분석 포함
   - crystallizer가 결과와 뿌리 매칭 분석을 반환 (파일 저장 안 함)
4. 리뷰 분기 (/reflect와 동일한 구조)
   - 결정화 결과를 사용자에게 보여주고 선택지 제시
   - (1) 괜찮아요 → 저장, (2) 수정 → crystallizer 수정 모드, (3) 새 생각 → lens-{lens} 2차 탐색 (5+라운드)
   - (4) 다른 렌즈로 다시 탐색 → 새 렌즈 에이전트로 Phase 1부터 재시작 (5+라운드)
   - 수정/탐색 후 다시 리뷰 분기로 반복
5. 저장 및 완료
   - 세션 저장 경로의 `YYYY-MM-DD-HHmm-deep.md`에 저장
   - 수정 발생 시 frontmatter에 revised, revision_count, revision_history 추가
   - perspectives/{lens}.md 갱신 ([perspective_update] 기반)
   - roots.md 갱신 (최종 결과 기준으로 한 번만, 추이 제거, 중립 사실만 갱신)
   - 저장 완료 안내
