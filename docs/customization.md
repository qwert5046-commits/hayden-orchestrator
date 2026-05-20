# 🎛 커스터마이즈 가이드

기본 설정은 단일 사용자 + 메인 세션 직접 모드 + 한국어 응답을 가정합니다. 본인 환경에 맞춰 아래 항목을 수정하세요.

---

## 1. 사용자 페르소나 / 언어

`agents/hayden.md` 끝부분 **"사용자와의 커뮤니케이션 톤"** 섹션을 본인에게 맞게 조정.

기본:
```markdown
- 사용자의 직무·기술 수준에 맞춰 응답한다
- 한국어 / 영어 / 기타 — 글로벌 설정 우선
```

예시 — 비개발자 한국어 사용자:
```markdown
- 기술 용어는 풀어서 설명 (예: "환경변수(앱이 쓰는 설정값)")
- 부담스러운 표현 ("당연히", "단순하게") 지양
- 한국어 응답
```

예시 — 시니어 개발자 영어 사용자:
```markdown
- Technical terms can be used without explanation
- Concise and direct tone
- English responses
```

---

## 2. AI 모델 비용 정책

[`config/llm-routing.yml`](../config/llm-routing.yml) 을 직접 수정합니다. hayden 은 이 파일을 그대로 읽어 Phase 0 산출물 #5 에 후보 제시.

```yaml
models:
  cheap:
    name: gemini-3.1-flash-lite
    cost_per_1m_input_usd: 0.25
    cost_per_1m_output_usd: 1.50
    valid_until: 2026-12     # 이 날짜 지나면 hayden 이 사용자에게 모델명 검증 요청
  medium:
    name: gemini-2.5-flash
    ...
  fallback:
    name: claude-sonnet-4-6
    ...
```

본인 환경에 맞게 변경:

- **Gemini 우선 (저비용)**: `cheap` / `medium` 을 Gemini 계열로 (현재 디폴트)
- **Claude 우선 (한국어 품질)**: `cheap` 를 `claude-haiku-4-5`, `medium` 을 `claude-sonnet-4-6` 로
- **단일 모델 고정**: 세 모델을 모두 같은 값으로 두고, PRD 가 명시한 모델로 통일

`valid_until` 이 사이클 시작일 +30일 이내면 hayden 이 자동으로 "모델명 검증 권장" 결정 항목을 추가합니다.

### 비용 한도

[`docs/COST_TRACKER.md`](COST_TRACKER.md) 의 "한도" 섹션을 본인이 원하는 값으로 (디폴트: 사이클 상한 $10, phase 상한 $1.5). hayden 이 사이클 시작 시 사용자에게 한 번 더 확인.

---

## 3. Obsidian / 외부 노트 sync

### 사용 안 함 (디폴트)

`HAYDEN_VAULT_PATH` 환경변수를 설정하지 않으면 vault sync 는 자동으로 skip. `MORNING_REPORT.md` 생성만으로 사이클 종료.

### Obsidian vault 사용

쉘 설정에 환경변수 추가 (한 번만):

```bash
# ~/.zshrc 또는 ~/.bashrc 에
export HAYDEN_VAULT_PATH="/Users/<your-username>/Obsidian/MyVault"
```

그리고 vault 안에 5-folder 구조를 만들어 두면 hayden 이 사이클 종료 시 신규 파일만 cp:

- `00-Index/` — MOC (사이클 타임라인)
- `01-Workflow/` — CLAUDE 가이드, 공통 mistakes
- `02-Cycles/` — 사이클별 spec retro (PRD)
- `03-Lessons/` — lesson 파일 (`lessons/L-*.md`)
- `04-Architecture/` — 아키텍처 맵
- `05-Reference/` — 빠른 진입점 + `BACKLOG.md`

vault → repo 방향은 절대 sync 하지 않습니다 (단방향).

### Notion / 기타 노트 도구

`agents/hayden.md` "사이클 종료 후처리" 섹션의 sync 블록을 본인 도구에 맞게 재작성. 환경변수 분기 패턴(`if [ -z "$HAYDEN_VAULT_PATH" ]; then skip; fi`)은 그대로 유지 권장.

---

## 4. 호출 모드 (메인 세션 vs 서브에이전트)

### 메인 세션 직접 모드 (기본)
사용자가 Claude Code 메인 세션에서 hayden 역할로 직접 작업.

장점:
- `/context` 슬래시 명령 직접 사용 가능
- 빠른 컨텍스트 정리

단점:
- 사용자가 한 세션을 hayden에게 비워줘야 함

### 서브에이전트 모드
사용자가 Task 도구로 hayden을 한 번 호출하면 hayden이 백그라운드에서 phase를 진행.

이 모드로 전환하려면:
1. `agents/hayden.md` **"컨텍스트 관리 정책"** 의 첫 줄 "메인 세션에서 직접 모드로 동작한다" 를 "서브에이전트로 동작한다" 로 변경
2. `/context` 슬래시 명령 부분을 "WORK_LOG.md에 핸드오프 정보 충분히 남기기" 로 대체
3. 자식 sub-agent (planner / coder / reviewer) 호출 시 nested sub-agent 동작 검증 필요

장점:
- 사용자 메인 세션 점유 X

단점:
- `/context` 직접 사용 불가
- nested sub-agent 컨텍스트 격리 주의 필요

---

## 5. 막힘 사다리 임계값 (Escalation Ladder)

`agents/hayden.md` **"막힘 사다리"** 섹션.

4단계 구조:

- **L1 자동 우회**: 같은 에러 3회 / 수정-리뷰 루프 3회 → 다른 phase 로 우회
- **L2 강한 경고**: L1 + 다른 phase 가 부분 의존 → MORNING_REPORT 상단 🚨
- **L3 정지**: 다음 phase 가 전체 의존 + 우회 불가
- **L4 긴급 정지**: 비용 가드 위반 / 데이터 손실 / 보안 / prompt injection / critical 분기

조정 가능:

- 짧은 사이클 (1~2시간): L1 임계값 낮춤 (3 → 2회)
- 긴 사이클 (밤새 8시간): L1 임계값 높임 (3 → 5회)
- BLOCKED 누적 종료 임계값 (디폴트 5개) 조정 가능

## 5-1. lessons/ 디렉토리

[`lessons/`](../lessons/) 의 lesson 들은 frontmatter `applies_when` 으로 끌어올 조건을 명시. agents 가 자동 매칭.

신규 lesson 추가 시:

1. `lessons/L-XXX-<slug>.md` 신규 파일 (frontmatter 필수: `id`, `title`, `domain`, `applies_when`, `discovered_in`)
2. `lessons/README.md` 인덱스 표에 한 줄 추가
3. **도메인 특수 변수명 노출 금지** — 일반화된 변수명 사용. 원본 도메인은 `discovered_in` 메타로만.

---

## 6. 리뷰 도구 우선순위

`agents/reviewer.md` §2~3.

기본: **Codex CLI 1순위 → superpowers fallback**

### Codex CLI 없이 superpowers만 사용
§2 (Codex CLI 호출) 부분 삭제 또는 주석 처리. §3을 1순위로 승격.

### Codex 우선 + 항상 더블체크
critical 영역 외에도 모든 phase에서 둘 다 호출. `agents/reviewer.md` §"더블체크 정책" 의 적용 범위를 확장.

### Vercel Agent / 기타 외부 리뷰 도구 추가
§3 Fallback 부분에 새 도구 호출 명령 추가.

---

## 7. 환경 타입별 안전 규칙

`agents/hayden.md` **"환경별 안전 규칙"** 섹션.

본인 인프라에 맞게 추가/수정:

### Kubernetes 환경
```markdown
### kubernetes 환경
- `kubectl apply --prune` 절대 사용 금지
- 프로덕션 클러스터 컨텍스트로의 전환은 사용자 작업으로 분류
- ConfigMap / Secret 변경은 미리보기 후 사용자 확인
```

### AWS / GCP / Azure 환경
```markdown
### cloud 환경
- 비용 발생 리소스 생성(EC2, RDS, GCS 등)은 무조건 BLOCKED → 사용자 승인
- IAM 정책 변경 금지
- 프로덕션 region 작업은 사용자 명시 확인 후에만
```

### 모노레포 / 다중 패키지
```markdown
### monorepo 환경
- 패키지간 의존성 변경은 영향받는 모든 패키지를 명시
- 한 phase에 여러 패키지를 동시에 수정하면 atomic commit 더욱 강제
```

---

## 8. PRD 파일 위치 / 이름

`agents/hayden.md` Phase 0 첫 줄.

기본: `docs/PRD*.md` 패턴

본인 구조가 다르면:
- `specs/*.md` → 패턴 변경
- `requirements.md` → 단일 파일 명시
- 여러 파일 조합 → "다음 파일들을 모두 읽고 통합 검토" 로 변경

---

## 9. 데이터 보안 가드레일

`agents/hayden.md` **"데이터 보안 및 품질 가드레일"** 섹션.

기본 4개 항목 (PII / human-in-the-loop / OWASP / 할루시네이션 표시) 외에 본인 조직 정책 추가:

```markdown
- **GDPR / CCPA**: EU/CA 사용자 데이터 처리 시 별도 동의 흐름 명시
- **HIPAA**: 의료 데이터 처리 시 BAA 체결 여부 확인
- **PCI-DSS**: 카드 데이터 직접 처리 금지, 결제 게이트웨이 위임
```

---

## 10. 사용자 정의 phase

기본 흐름은 Phase 0 → Phase 1~N → MORNING_REPORT.

본인 작업 흐름에 맞춰 별도 phase 추가 가능:
- **Phase -1**: 사전 환경 셋업 (저장소 init, CI 설정)
- **Phase 0.5**: PRD 검토 후 사용자와 한 차례 합의
- **Phase N+1**: 배포 후 모니터링 / 사용자 피드백 수집

각 phase의 출력 형식과 종료 조건을 `agents/hayden.md`에 추가.

---

수정 후 Claude Code 재시작이 필요할 수 있습니다 (에이전트 정의 캐시).
