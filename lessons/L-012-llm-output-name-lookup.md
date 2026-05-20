---
id: L-012
title: LLM 인용 데이터 환각 — 권위 lookup 으로 코드 단 강제 교체
domain: [llm]
applies_when: LLM 이 입력 데이터(시트 / DB row / 사용자 식별자 등)를 인용해 출력하는 모든 phase
discovered_in: financial_assistant Cycle 2 hotfix
---

# L-012 — LLM 인용 환각: 권위 lookup 강제 교체

LLM(Gemini / Claude / GPT 등) 이 입력 데이터(시트 row, DB 레코드, 사용자 식별자, 날짜 등) 를 인용해 출력할 때 **인용 값(식별자 / 카테고리 / 라벨 등) 환각**이 자주 발생한다. 대표적으로 직전 항목의 식별자를 다음 항목에도 carry-over 인용하는 패턴. system_prompt 자연어 지시만으로는 막기 어렵다.

## 처방 우선순위

| 우선 | 처방 | 근거 |
|---|---|---|
| 1 | 코드 단 강제 교체 — 입력 소스의 권위 lookup(`{label: canonical_id}`)을 만들어 LLM 출력 파서에 주입. label 매칭 시 LLM 값 무시하고 lookup 값으로 override. | 100% 신뢰 가능, 격리 우수 |
| 2 | system_prompt 보강 | 효과 불확실 + prompt diff 보존 정책 위반 가능 |
| 3 | 사후 검증 후 경고 | 사용자에게 노출돼 신뢰도 손상 (false positive UX 위험) |

## 코드 패턴 (도메인 중립 의사 코드)

```python
def parse_llm_output(
    body: str,
    *,
    source_records: list[dict] | None = None,
) -> dict:
    # 입력 소스에서 권위 lookup 구축
    label_to_canonical = build_label_to_canonical(source_records or [])

    # LLM 출력 파싱
    for section in iter_sections(body):
        label = section.label
        canonical_id = section.id_field

        # label 매칭되면 LLM 값 무시하고 lookup 으로 override
        if label_to_canonical and label in label_to_canonical:
            canonical_id = label_to_canonical[label]

        yield {"label": label, "id": canonical_id, ...}
```

## 적용 트리거

- 새 LLM 호출 모듈이 시트 / DB 데이터를 인용하는 모든 경로 (식별자, 라벨, 카테고리, 위험도, 사용자 식별자, 날짜 등)
- mismatch 가능성을 의심하고 권위 lookup override 추가
- label 매칭 실패 시 LLM 값 유지 (안전한 기본값) — 기존 동작 호환

## 한계 (운영 모니터링 항목)

- 입력 소스에 없는 label 을 LLM 이 환각 생성하면 override 불가 → 운영 1~2 개월 후 정확성 모니터링 필요 (`BACKLOG.md` 등록)
- 다른 도메인 (다이어트 앱 음식 이름, 채용 ATS 지원자 ID, 학원 학생 코드 등) 에도 같은 패턴 적용 가능

## 적용 제외

LLM 이 입력 데이터를 인용하지 않고 자유 생성만 하는 경우(번역 / 요약 / 일반 대화 등) 끌어오지 않는다.
