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

`agents/hayden.md` Phase 0 산출물 **#5 (AI/LLM 모델 선택)** 부분.

본인의 비용 정책이 있다면 그쪽을 명시하세요. 예시:

### 옵션 A — Gemini 우선 (저비용 첫째)
```markdown
1순위: gemini-2.5-flash-lite (저비용)
2순위: gemini-2.5-flash
3순위: Claude / GPT 최신 모델 (fallback)
```

### 옵션 B — Claude 우선 (한국어 품질)
```markdown
1순위: claude-opus-4-7 (한국어/긴 컨텍스트 최상)
2순위: claude-haiku-4-5 (비용 중간)
3순위: gemini-flash (fallback)
```

### 옵션 C — 단일 모델 고정
PRD가 특정 모델을 명시한다면 결정 항목으로 띄우지 말고 그대로 사용.

---

## 3. Obsidian / 외부 노트 sync

`agents/hayden.md` **"사이클 종료 후처리"** 섹션.

### 사용 안 함
섹션 전체를 삭제하거나 주석 처리. `MORNING_REPORT.md` 생성으로 사이클 종료.

### Obsidian vault 사용
본인 vault 경로를 명시:
```markdown
<USER_VAULT_PATH> = /Users/<your-username>/Obsidian/MyVault
```

5-folder 구조:
- `00-Index/` — MOC (사이클 타임라인)
- `01-Workflow/` — CLAUDE 가이드, 공통 mistakes
- `02-Cycles/` — 사이클별 spec retro
- `03-Lessons/` — 메모리 파일
- `04-Architecture/` — 아키텍처 맵
- `05-Reference/` — 빠른 진입점

### Notion / 기타 노트 도구
hayden.md의 "사이클 종료 후처리" 섹션을 본인 도구에 맞게 재작성. 예: Notion API 호출, Confluence 페이지 작성 등.

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

## 5. 막힘 정책 임계값

`agents/hayden.md` **"막힘 정책"** 표.

기본 임계값:
- 같은 에러 3회 → BLOCKED
- 수정-리뷰 루프 3회 → BLOCKED
- BLOCKED 누적 5개 → 세션 종료

조정 가능:
- 짧은 사이클 (1~2시간): 임계값 낮춤 (각각 2회)
- 긴 사이클 (밤새 8시간): 임계값 높임 (각각 5회)

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
