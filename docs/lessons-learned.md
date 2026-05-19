# Lessons Learned — 실제 사이클 학습 모음

> hayden 오케스트레이터를 실제 야간 사이클에 사용하면서 발견된 교훈을 보존합니다.
> 새 사이클 시작 전 hayden / planner / coder / reviewer 가 이 문서를 1회 훑으면 같은 실수를 반복하지 않습니다.

---

## L-001 — Codex CLI는 trust_level 등록 필요

**증상**: `codex review` 호출 시 응답이 멈추거나 0 line 반환. exit code는 0이라 reviewer가 "통과"로 잘못 처리.

**원인**: `~/.codex/config.toml` 의 trusted_projects 리스트에 현재 프로젝트 경로가 등록되지 않으면 sandbox가 `read-only`로 떨어져 codex가 정상 응답을 stream하지 못함.

**대응**:

- reviewer Step 1 (사전 점검)에서 `grep -A1 "$(pwd)" ~/.codex/config.toml` 로 등록 여부 확인.
- 미등록이면 BLOCKED.md에 "Codex trust_level 미등록"으로 기록하고 사용자에게 보고. 직접 ~/.codex/config.toml 수정은 사용자만 가능.
- 등록 후 sandbox=workspace-write로 동작.

---

## L-002 — self-review는 도메인 quirk를 놓친다

**증상**: 코드 작성자가 직접 self-review로 코드 검수해도 다음 도메인 이슈는 잡지 못함:

- `^TNX`(미국 10년물 금리) 값이 yfinance에서 10배로 반환되는 관습 → 정규화 필요
- 빈 환경변수 `DRY_RUN=`이 `not None` 검사에서 truthy로 떨어져 안전 모드 꺼짐
- 안전 검수가 단위 접미사 mismatch로 정상 입력값을 환각으로 잘못 분류

**원인**: self-review는 문법/패턴 이슈에만 강하며, 라이브러리 표기 관습 / deprecation / 안전 정책 우회 가능 코드 같은 도메인 quirk는 외부 시각이 필요.

**대응**:

- critical 영역(보안 경계, 인증/권한, 외부 API 신규 도입, 결제, DB 마이그레이션) 변경에는 **반드시 외부 LLM 리뷰**(Codex 또는 superpowers code-reviewer)를 거친다.
- Codex 인프라가 일시 불가하면 BLOCKED 기록 후 복구 후 재검증.

---

## L-003 — Codex `--base` 옵션과 `[PROMPT]` 인자는 mutex

**증상**: `codex review --base <SHA> "review this carefully"` 호출 시 mutex 충돌 에러.

**대응** (v0.125.0 기준):

- `--base` 만 주고 `[PROMPT]`는 생략 → codex가 default 리뷰 prompt 사용
- 추가 지시가 필요하면 `codex review "<self-prompt>"` 로 옵션 없이 호출 (변경 자동 감지)
- `--title "..."` 는 옵션과 prompt 양쪽 모두에서 사용 가능

---

## L-004 — 외부 LLM 위험도 라벨 ≠ 시스템 안전 정책

**증상**: Codex가 P2(Minor) / P3(Trivial)로 라벨한 항목이 실제로는 사용자 운영에 큰 영향을 줌:

- 정상 입력값을 환각으로 잘못 분류 → 매 발송에 ⚠️ 경고 배지 (사용자 신뢰도 훼손)
- 두 데이터 소스 union 직렬화로 분류·정확성 손상 (사용자 의사결정 영향)
- 템플릿 + LLM 본문 섹션 중복 (모든 이메일 100% 재현, 즉시 인지)

**원인**: 외부 LLM의 위험도 라벨은 "코드 품질" 관점이며, "시스템 안전 정책 / 사용자 신뢰도" 관점과 다름.

**대응**: reviewer.md "안전 재분류" 표 적용. 다음 패턴이면 Major/Critical로 격상:

- 안전 안전장치 우회 가능 → Critical
- 데이터 파괴 가능 → Critical
- 시크릿 노출 가능 → Critical
- 안전 검수 false positive (사용자 신뢰도 훼손) → Major
- 데이터 분류·정확성 손상 → Major
- 모든 산출물에 100% 재현되는 가시적 결함 → Major

---

## L-005 — 회사·개인 GitHub 계정 분리 (gh CLI active 점검)

**증상**: 사용자가 push 요청. `git push` 실행 시 `Repository not found` (private 레포는 인증 실패도 not found로 응답).

**원인**: gh CLI에 회사 계정(`<회사>-datarize`)과 개인 계정(`<개인>`) 둘 다 로그인되어 있고, **회사 계정이 active**. 이 상태로 개인 레포에 push 시도 → 권한 없음. PRD §0.4 (회사·개인 자원 분리) 정면 위반.

**대응**: push 전 반드시 다음 절차:

```bash
gh auth status                        # 두 계정 + active 확인
gh auth switch -u <개인계정명>         # 잘못된 active면 전환
gh auth status                        # 전환 후 다시 확인
```

push 명령 자체는 안전(non-destructive)이지만, active 계정 잘못 설정은 정책 위반. hayden.md "GitHub / Git push 안전 점검" 섹션 따른다.

---

## L-006 — `/compact`는 Claude가 직접 호출 못한다

**증상**: 컨텍스트가 무거워졌을 때 Claude 스스로 `/compact` 호출 시도 → 동작 안 함.

**원인**: 슬래시 명령(`/context`, `/compact` 등)은 사용자 키 입력만 트리거. Claude의 도구 함수로는 호출 불가.

**대응**:

- 자동 컨텍스트 압축은 한도 도달 시 시스템이 처리 (Claude 액션 아님).
- Claude의 책무는 슬래시 명령 호출이 아니라 **외부 파일 핸드오프**. 매 phase 완료 직후 `WORK_LOG.md` / `BLOCKED.md` / `DECISIONS.md` 에 핵심 정보 저장 → 자동 압축 후에도 다음 응답이 이어받을 수 있음.
- 사용자가 깨어있고 컨텍스트 무거워졌을 때 응답에 `/compact 권장. 핸드오프는 WORK_LOG에 있어 안전합니다` 한 줄만 안내. 멈추지 않음.

---

## L-007 — AI/LLM SDK 즉시 교체 패턴 (비용 정책 충돌 발견 시)

**증상**: 사이클 중 / 검증 중에 LLM API 호출 실패. 사용자가 결제 미진행 또는 글로벌 비용 정책 1순위 모델로 전환 결정.

**대응**: coder.md "AI/LLM SDK 교체 표준 절차" 따른다. 6개 위치 동시 수정:

1. `requirements.txt` (SDK 의존성)
2. `src/config.py` (환경변수명 + Config 필드 + `_REQUIRED_VARS`)
3. LLM 호출 모듈 (`src/analyzer.py` 등 — import / 모델 ID / 호출 시그니처 / 응답 추출 / usage / safety / 예외 분기)
4. `src/main.py` (import + 호출부 + 키워드 인자명)
5. `.github/workflows/*.yml` (시크릿 매핑)
6. README / manual_test / DECISIONS (API 발급 URL + 비용 표 + 명령어 + 전환 이력)

코드 안전 패턴:

- 모델 ID `os.environ.get("<PROVIDER>_MODEL", "<1순위>")` 환경변수 노출
- 404/`not found`/unknown model 패턴만 자동 폴백 트리거 (인증/할당/타임아웃은 즉시 raise)
- 후방 호환 alias 라인 (`generate_report_with_<old> = <new>`)

사용자 액션 안내: (A) 신규 API 키 발급 URL, (B) `.env` 수정, (C) GitHub Secrets 갱신, (D) `pip install -r requirements.txt`.

---

## L-008 — 사이클 외 follow-up Codex 리뷰 (MORNING_REPORT 이후)

**증상**: hayden 사이클이 MORNING_REPORT로 종결된 후 사용자가 "전체 코드 리뷰 추가로 돌려줘" 요청.

**대응**: hayden.md "사이클 외 Follow-up 처리" 섹션 따른다. reviewer 서브에이전트 호출 없이 hayden 직접 처리 가능 (단일 작업이라 격리 불필요). 단:

- 응답 검증, 안전 재분류, 자동 수정 루프 등 reviewer.md 정책은 그대로 차용
- 결과 `docs/reviews/full-review.md`로 저장
- Major/Critical 즉시 자동 수정 (사용자에게 묻지 않음)
- 수정 commit + MORNING_REPORT.md 끝에 "🔁 추가 Codex 사이클" 섹션 append

---

## L-009 — 사용자 venv 환경 흔히 막히는 부분

**증상**: 비개발자 사용자가 manual_test.md 따라 venv 검증 중 막힘.

**자주 발생하는 시나리오**:

1. **macOS 기본 `python3`가 3.9.6** — `python3 -m venv .venv`로 만들면 3.9가 잡혀 PEP 585 generic 문법에서 부분 동작 안 됨.
   - 대응: `python3.11 -m venv .venv` 명시. `brew install python@3.11` 안내.
2. **`python src/main.py` 직접 실행** — `from src.config import ...` ModuleNotFoundError.
   - 대응: `python -m src.main` 모듈 방식 강제. GitHub Actions yml도 동일 패턴.
3. **`GOOGLE_SHEETS_CREDENTIALS_JSON` JSON 줄바꿈 그대로 `.env`에 붙여넣음** — dotenv 파싱 실패.
   - 대응: `jq -c . service-account.json` 으로 한 줄 압축 명시. manual_test.md 단계 1에 굵게 명시.

manual_test.md / README.md / coder.md "사용자 venv 검증 안내" 섹션에 위 3개 명시되어 있어야 함.

---

## L-010 — 사용자에게 묻기 절대 금지 정책 강화

**증상**: 초기 hayden은 phase 종료 시 사용자에게 "다음 phase 진입할까요?" 묻고 멈춤. 야간 자율 진행 의미 상실.

**대응**: hayden.md "Phase 자동 진입 정책 — 매우 중요" 섹션의 절대 금지 패턴 4가지:

- "다음으로 무엇을 할까요?" / "어느 옵션이 좋을까요?" / "Phase X 진입할까요?" 질문 금지
- 리뷰 결과 `[USER]` 태그도 멈추지 말 것 — DECISIONS.md에 큐로 추가
- "압축 후 이어가시려면 한마디 주세요" 같은 대기 안내 금지
- 사용자가 답할 선택지(1/2/3) 응답 끝에 나열 금지

**올바른 패턴**: 모든 결정은 너 스스로. 리뷰가 자동 수정 권장이면 즉시 coder 재호출. 사용자 결정 필요 항목은 DECISIONS.md에 큐만 추가 후 다음 phase.
