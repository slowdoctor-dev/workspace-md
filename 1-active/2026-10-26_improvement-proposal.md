# workspace.md 개선안 — 2026-10 LLM·에이전트 환경 기준

> 대상: `WORKSPACE.md` v0.1.2 (2026-06-03). 기준일: 2026-10-26.
> 성격: **제안(proposal)**. T2 영역(`3-control/`)을 바꾸는 항목이 다수이므로
> Owner 비준(ratification) 전까지는 `1-active/` 초안으로 둔다.
> 근거는 §6 Sources. 벤더 문서는 변동이 빠르므로 적용 시 재확인.

---

## 0. 요약 (TL;DR)

v0.1.2는 2026년 5~6월의 가정 위에 서 있다. 그 사이 네 가지가 바뀌었다.

| # | 환경 변화 (2026-10) | 스펙에 미치는 영향 | 우선순위 |
|---|---|---|---|
| 1 | Claude Code가 `AGENTS.md`를 **네이티브로 읽음** (v2.1.277+); Gemini CLI는 2026-06-18 **서비스 종료** | 루트 symlink(`CLAUDE.md`, `GEMINI.md`) 전략과 Windows 제약 서술이 구식 | **P0** |
| 2 | 호스티드 모델 전부 **1M context** (Claude 5 계열 전체, Haiku 5.5 포함); 로컬 모델도 128K+ 보편 | `effective_context` 기반 tier 도출이 변별력 상실. 병목은 context 크기가 아니라 attention 품질·비용·캐시 | **P0** |
| 3 | **Context engineering / progressive disclosure**가 표준 관행 (Thoughtworks Radar "Adopt", ETH 연구: README형 지시문은 성능 저하) | 7-item 세션 시작 로드(~19K tok)가 과대. 스펙 본문(`WORKSPACE.md`, `PRINCIPLE.md`)을 매 세션 로드하는 구조 재검토 | **P0** |
| 4 | **병렬·비동기 에이전트** 일상화: worktree 격리, subagent, 클라우드/스케줄 세션, compaction 훅 | R2 "세션 경계"와 journal `NNN`·`NEXT.md` 단일 파일 모델이 동시성에 취약. T2 비준이 headless에서 불가 | **P1** |

여기에 (5) 하네스 자체 메모리(Claude Code auto memory 등)와의 관계 정의, (6) 스킬 공급망 보안(OWASP Agentic Skills Top 10)이 **P1~P2**로 따라온다.

**권고 버전 전략**: 위 P0 세 건은 breaking이므로 **v0.2.0**으로 묶는다. P1은 v0.2.x, P2는 v0.3.

---

## 1. 진단 — 무엇이 바뀌었나

### 1.1 Entry file 표준화가 끝났다
- AAIF(Agentic AI Foundation, Linux Foundation 산하, 2025-12 출범)가 `AGENTS.md`·MCP·goose를 관장. `AGENTS.md`는 루트 레벨 약 9.7만 리포(2026-06 추정).
- **Claude Code 공식 문서**: `CLAUDE.md`가 없으면 `AGENTS.md`를 직접 읽음. "A `CLAUDE.md` symlinked to `AGENTS.md`: nothing, or **delete the symlink**." 설정값 `claude-md-and-agents-md`로 둘 다 로드도 가능.
- Gemini CLI: 2026-06-18 free/Pro/Ultra 종료 → Antigravity CLI(`agy`)가 `AGENTS.md` + `GEMINI.md`를 그대로 읽음. 즉 `GEMINI.md` symlink는 레거시 호환용으로만 의미.

### 1.2 Skill 포맷도 표준화됐다 — 단, 경로는 아직 갈라져 있다
- Agent Skills(agentskills.io) 오픈 표준: `SKILL.md` + YAML frontmatter. 40+ 클라이언트 채택.
- **경로**: Claude Code `.claude/skills/`, Codex `.agents/skills/`(공식), Antigravity `.agents/skills/`. 현재 리포는 `.agents/skills` symlink만 있어 **Claude Code는 lifecycle skill을 발견하지 못한다**.
- 이식성: Claude Code 밖(Skills API, claude.ai 업로드)에서는 frontmatter 6필드만 허용 — `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`. 그 외 필드는 **hard error**.
- Codex·Claude Code 모두 metadata(name/description)만 먼저 읽고 본문은 선택 시 로드 → 스펙의 "skills (invoked by description match)" 가정은 정확히 맞아떨어짐.

### 1.3 Context는 더 커졌지만, 로드는 더 줄이는 쪽으로 수렴했다
- Claude 5 계열은 Haiku 5.5까지 1M context. GPT·Gemini도 유사. 로컬도 Qwen3/Llama 4 계열 128K+가 기본.
- 반대로 관행은 "적게 넣기": Claude Code 문서는 `CLAUDE.md` **200줄 이하** 권고, "imports는 context 비용을 줄이지 않음", path-scoped `.claude/rules/`로 필요할 때만 로드. ETH Zurich 138리포 연구(2026)는 README형 `AGENTS.md`가 성능을 약간 **떨어뜨리고** 토큰 비용을 올리며, 빌드 명령·함정·검증 절차 같은 **추론 불가능한 좁은 지시**만 도움이 된다고 보고.
- Letta MemFS: git 기반 markdown 메모리, `system/` 아래만 매 턴 로드, 나머지는 on-demand. workspace.md의 `essential/` vs 나머지 garden 구분과 **동형** — 설계 방향 자체는 검증된 셈.

### 1.4 세션의 모양이 바뀌었다
- Claude Code hooks: `SessionStart`는 `startup | resume | clear | compact | fork` 소스를 가지며 **compaction 후에도 다시 실행**. `PreCompact`/`PostCompact`, `SessionEnd`, `Stop`, `SubagentStart/Stop`, `WorktreeCreate`, `TeammateIdle` 이벤트 존재.
- worktree가 병렬 에이전트의 표준 격리 단위로 수렴. Claude Code `--worktree`, subagent `isolation: worktree`, Codex subagent도 자동 worktree.
- 클라우드 세션·스케줄 실행(headless)이 보편. "Owner가 터미널 앞에 있다"는 T2 비준 가정이 깨짐.
- Claude Code **auto memory**: 리포별, worktree 간 공유, 매 세션 앞 200줄/25KB 로드, 위치는 리포 **밖**(`~/.claude/projects/...`). subagent별 auto memory도 가능. 즉 스펙이 모르는 두 번째 메모리 저장소가 이미 동작 중.

### 1.5 공급망 보안이 실제 사고로 나타났다
- 리포가 제어하는 `.claude/settings.json`이 trust 다이얼로그 전에 셸 명령을 실행한 CVE; 프로젝트 설정 조작으로 API 키 탈취.
- Snyk(2026-02) ClawHub 3,984 스킬 감사: 36.8% 결함, 76건 악성 페이로드. CSA는 "자연어 페이로드는 정적 분석으로 안 잡힌다"고 경고. OWASP Agentic Skills Top 10 v0.5: 해시 고정, "Prerequisites" 실행 전 명시적 리뷰 권고.

---

## 2. 개선안 (우선순위순)

각 항목: **문제 → 제안 → 영향 파일 → 근거**.

### P0-A. Entry-file 전략 재정립 — "symlink 3종"에서 "AGENTS.md 단일 + 네이티브 경로 최소"로

**문제**
- `CLAUDE.md → AGENTS.md` symlink는 Claude Code v2.1.277+에서 중복(공식 문서가 삭제 가능이라 명시). Windows 제약(§Known limitations 1번)과 `sed -i` symlink 파손(2번)의 상당 부분이 이 symlink 때문에 존재.
- `GEMINI.md`는 종료된 하네스용. Antigravity는 `AGENTS.md` 직접 읽음.
- 반면 **진짜 필요한** 네이티브 경로가 빠져 있다: `.claude/skills/` (Claude Code는 `.agents/skills`를 읽지 않음).

**제안**
1. `AGENTS.md`를 유일한 entry로 선언. `CLAUDE.md`·`GEMINI.md` symlink는 **삭제** — 단 "구버전 Claude Code(<2.1.277) 또는 Bedrock 등 AGENTS.md 미지원 세션"을 위한 선택적 fallback으로 `adoption.md`에 1문단 남긴다(`CLAUDE.md` 안에 `@AGENTS.md` import 한 줄).
2. `.claude/skills → 2-mind/forge/act/skill/` symlink 추가(`.agents/skills`와 동형). "symlink-alias policy"가 두 경로를 다룬다고 `WORKSPACE.md §Layout`에 기재.
3. §Per-runtime entry 표를 **"AGENTS.md 네이티브 읽음 / fallback 필요"** 2열로 재작성: Codex, Claude Code(2.1.277+), Antigravity, Cursor, Copilot, Jules, Zed… 는 네이티브. 열거는 "illustrative"로 유지.
4. §Known limitations 1·2번을 축소 재작성(남는 symlink는 `.mcp.json`, `.agents/skills`, `.claude/skills`뿐).

**영향 파일**: `AGENTS.md`, `WORKSPACE.md`(§Layout, §Known limitations), `adoption.md`, `init/SKILL.md` §4, `detect-runtime/SKILL.md`(discovery-file 휴리스틱), `audit/SKILL.md`(symlink check 대상), `README.md`.

**근거**: Claude Code memory 문서 §AGENTS.md; Codex skills 문서; Google 전환 공지.

---

### P0-B. 세션 시작 로드 다이어트 — 7-item ≈19K tok → "hot 5-item" ≈6–8K tok

**문제**
- 7-item 중 #2 `WORKSPACE.md`(199줄)·#3 `PRINCIPLE.md`(170줄)는 **스펙 본문**이다. 매 세션 행동을 바꾸는 지시가 아니라 참고 문서. ETH 연구가 "성능 저하"로 지목한 README형 콘텍스트에 정확히 해당.
- Claude Code 200줄 권고 대비, 현재 로드만 ~600줄 이상.
- R2 Part B가 "로드가 context에 맞는가"를 묻는데, 1M context 시대에는 항상 맞는다. 질문이 틀렸다 — 물어야 할 것은 **"이 로드가 attention을 희석하지 않는가"**.

**제안**
1. 읽기 순서를 두 층으로 나눈다.
   - **Hot load (매 세션)**: `AGENTS.md` → `3-control/foundation/SOUL.md` → `USER.md` → `NEXT.md` → 최근 journal. 5 items.
   - **Reference (on-demand)**: `WORKSPACE.md`, `PRINCIPLE.md`, `use-driven-memory.md`, `runtime-flexibility.md`. 스킬이 필요할 때 인용해서 읽음(`dream`·`audit`가 캡 표를 읽는 식).
2. `AGENTS.md`를 **"operational card"** 로 재정의: 80줄 캡 유지, 내용은 ①hot 읽기 순서 ②T1/T2 한 줄 규칙 ③"스펙 본문은 `WORKSPACE.md`, 필요 시 읽어라" 포인터 ④세션 종료 의무(journal + NEXT). 지금처럼 "이 리포는 스펙을 정의한다…"로 시작하는 설명형 문장은 `README.md`로 이동.
3. Claude Code 사용자를 위한 선택 사항: 토폴로지·규칙을 `.claude/rules/*.md`의 **path-scoped rule**로 노출(예: `paths: ["2-mind/garden/**"]`에 R1/R3 요약). 스펙 자체는 runtime-neutral이므로 `3-control/rule/`이 canonical, `.claude/rules/`는 symlink(Claude Code가 `.claude/rules/` symlink 지원 명시).
4. R2 Part B 문구 교체: "fits runtime budget" → "**fits the attention budget**: hot load ≤ ~8K tokens at `standard`; raw context size is not the constraint".
5. 세션 시작 예산 표(lean 15K / standard 19K / extended 29K) 재산정. 참고: hot 5-item은 AGENTS 80줄 + SOUL 56줄 + USER ≤800tok + NEXT ≤240tok + journal ≤2000tok ≈ 5–6K.

**영향 파일**: `use-driven-memory.md` §Read order(canonical) + §R2, `AGENTS.md`, `session-start/SKILL.md` §2, `init/SKILL.md` §5, `runtime-flexibility.md`(예산 표), `README.md`.

**근거**: Claude Code memory 문서 "target under 200 lines", "imports don't reduce context cost"; Thoughtworks Radar progressive context disclosure; ETH Zurich AGENTS.md 연구; Letta MemFS `system/` 분리.

---

### P0-C. Tier 시스템 재정의 — `effective_context` 축을 버리고 "model class" 축으로

**문제**
- 도출 규칙 `>64K → extended`는 호스티드 모델 전부가 통과(1M). `≤16K → lean`은 Ollama 기본 4K 설정 같은 **설정 실수**에서만 발생. 결과적으로 tier가 "hosted = extended, local = standard"의 2값으로 퇴화.
- 알려진 상수표(`last_verified: 2026-05-17`)는 "Claude Sonnet/Opus 4.x 200K", "GPT-4 family"로 이미 한 세대 뒤. 6개월 freshness 룰에 11월이면 걸린다. 벤더 상수를 스펙에 박아 두는 방식 자체가 유지비가 높다.
- `detect-runtime/SKILL.md` 289줄 + `detect-runtime.sh` 221줄 = 스펙에서 가장 큰 덩어리가 변별력 잃은 축을 측정하는 데 쓰인다.

**제안**
1. 도출 입력을 **model class**(4값)로 교체. 호스티드 frontier(Opus/Fable/GPT-5급/Gemini Pro급) → `extended`; 호스티드 small(Haiku/Flash/mini) → `standard`; 로컬 30B+ → `standard`; 로컬 ≤13B → `lean`. `effective_context`는 **sanity check**로만 남김(hot load보다 작으면 경고).
2. 알려진 상수표 **삭제**. 대신 "조회 가능하면 조회"(Anthropic Models API `max_input_tokens`, OpenAI 호환 `/v1/models`), 아니면 Owner 선언. 스펙은 숫자를 들고 다니지 않는다.
3. `detect-runtime`를 **harness 탐지 + model class 선언**으로 축소(목표 ≤120줄). 셸 스크립트는 로컬 엔드포인트 probe만 남기거나 삭제.
4. `profile.md` 필드: `effective_context` → `model_class`(필수) + `effective_context`(선택, 참고용). `active_tier`는 유지.
5. 캡 숫자 자체(500/800/1600 …)는 **그대로**. 바뀌는 건 tier를 고르는 이유다.

**영향 파일**: `runtime-flexibility.md`(§Tier-derivation rule, §Freshness discipline, §Detection mechanism), `detect-runtime/SKILL.md`, `detect-runtime.sh`, `profile.example.md`, `init/SKILL.md` §2–3, `session-start/SKILL.md` §1, `audit/SKILL.md`(freshness scan 대상 축소).

**근거**: Anthropic 모델 표(2026-10 기준 전 모델 1M); Codex/Claude Code 문서가 context 크기 아닌 지시문 **길이**를 제약으로 다룸.

---

### P0-D. Gemini CLI 퇴역 반영 + Antigravity 재검증

**문제**: `WORKSPACE.md`, `README.md`, `PRINCIPLE.md`, `profile.example.md`, `session-end` slug 레지스트리, `detect-runtime` 표가 Gemini CLI를 현역 3대 CLI로 서술. `antigravity-cli.md`의 `last_verified: 2026-05-24`는 다음 달 6개월 만기.

**제안**
- "three major hooked CLIs" → "Claude Code, Codex CLI, Antigravity CLI". Gemini CLI는 "Enterprise/Code Assist 한정 레거시"로 한 줄.
- slug `gemini`는 레지스트리에 **legacy** 표기로 유지(기존 journal 파일명 호환).
- `antigravity-cli.md` 재검증 후 `last_verified` 갱신; 모델 자동선택·`--model` 제거 등 세부는 "verify before relying" 원칙 유지.

**영향 파일**: 위 열거 + `AGENTS.md` §Per-runtime entry.

---

### P1-E. R2 "세션 경계" 재정의 — compaction·resume·fork를 경계로 인정

**문제**: 스펙의 세션 = 터미널 수명. 그러나 하네스는 compaction 시 context를 요약·교체하고, `SessionStart(source=compact)`를 **다시** 발화한다. 이때 hot load가 재주입되면 R2 Part A("쓰기는 다음 세션에 나타남")가 뜻밖에 깨진다(이 세션에서 쓴 USER.md가 compaction 직후 로드됨). 반대로 PreCompact에 NEXT 체크포인트를 안 쓰면 handoff를 잃는다.

**제안**
1. 용어 정의 추가: **session = one context-window lifetime**. `startup`은 full session-start; `compact`/`resume`/`fork`는 **re-entry**(hot load만 재주입, `NEXT.md` 소비·클리어는 하지 않음, 브리핑·방향 확인 생략).
2. `PreCompact` → **checkpoint**: `NEXT.md` *Outstanding* 블록만 갱신(journal은 쓰지 않음). `SessionEnd`/`Stop` → `session-end` 트리거 후보.
3. `2-mind/forge/cue/`에 **canonical hook spec** 1파일(`cue/lifecycle.md`: 이벤트 → 스킬 매핑, runtime-neutral)을 두고, 하네스별 포맷(`.claude/settings.json` hooks, Codex hooks, `agy` hooks)은 **렌더링 산출물**로 취급(MCP `url→serverUrl` 렌더 패턴과 동일). `cue/`는 현재 "triggers (optional)"로 이름만 있고 포맷 정의가 없다.
4. 하네스 네이티브 "메모리 저장" 기능이 아니라 **R2 쓰기 경계를 하네스 훅이 보장**한다는 점을 `runtime-flexibility.md §Graceful degradation`에 한 줄: hook-less 하네스는 기존대로 선언적 폴백.

**영향 파일**: `use-driven-memory.md` §R2, `session-start/SKILL.md`(re-entry 모드 추가), `session-end/SKILL.md`, 신규 `2-mind/forge/cue/lifecycle.md`, `WORKSPACE.md` §Layout(cue 설명), `runtime-flexibility.md`.

**근거**: Claude Code hooks 레퍼런스(SessionStart source 5종, PreCompact/PostCompact/SessionEnd).

---

### P1-F. 동시성 모델 — worktree·subagent·병렬 세션

**문제**
- journal 파일명 `<date>-<runtime>-<NNN>`: 두 세션이 동시에 `001`을 계산하면 충돌. `session-end`의 "check existing entries"는 비원자적.
- `NEXT.md` 단일 파일: merge protocol(Contributors 라인)이 있지만 git 병합 시 같은 블록 충돌이 잦다.
- worktree 세션이 `2-mind/garden/`에 쓰면 그 브랜치에만 남고, 브랜치가 버려지면 메모리도 사라진다. 메모리 쓰기가 **어느 브랜치에 속하는가**를 스펙이 말하지 않는다.
- `forge/role/<agent>/AGENTS.md`는 Claude Code `.claude/agents/<name>.md`, Antigravity subagent 스펙과 **매핑이 없다**(antigravity-cli.md에 한 단락만).

**제안**
1. journal 파일명에 **세션 식별자** 도입: `<YYYY-MM-DD>-<runtime>-<sid>.md`, `sid` = 하네스 세션 ID 앞 6자 또는 `$(date +%H%M%S)`. `NNN`은 단일 세션 워크플로의 **허용 변형**으로 남긴다(기존 파일 호환). R3 인용 포맷 `(journal <filename-stem>)`으로 일반화.
2. `NEXT.md`를 **append-only 블록** 포맷으로 규정: 블록 헤더 `### <runtime>/<sid> @ <ISO time>` 아래 3섹션. `session-start`는 전체 소비 후 비움. git 병합이 블록 단위로 깨끗하게 된다. 캡(240 tok)은 **소비 시점 총량** 기준으로 재해석.
3. **"Memory lives on the integration branch"** 규칙(R2 Part C 또는 새 R5): `2-mind/garden/` 쓰기는 ①primary checkout에서, 또는 ②worktree 세션이면 별도 커밋으로 분리하고 PR 설명에 `memory:` 접두어 — `audit`이 머지 안 된 브랜치의 garden 변경을 스캔. 가장 단순한 실무 지침은 "worktree 세션은 journal만 쓰고 `dream`은 primary에서만 돈다".
4. `forge/role/<name>/` → 하네스 네이티브 subagent 파일로 **렌더/symlink**(`.claude/agents/<name>.md` 등). 역할 스펙은 canonical 한 곳(forge), 포맷은 하네스별. subagent의 auto memory는 §G 규칙을 따른다.
5. `dream`·`audit`는 **forked subagent**로 실행 권고(Claude Code `context: fork`; 6필드 이식성 위반이므로 **SKILL.md 본문 지침**으로 쓰고 frontmatter에는 넣지 않음). 메인 세션의 cache prefix를 건드리지 않아 R2 Part A와 정합.

**영향 파일**: `use-driven-memory.md`(§7 stores 경로, §R3 인용 포맷, 신규 규칙), `session-end/SKILL.md` §3–4, `session-start/SKILL.md` §3, `dream/SKILL.md`, `audit/SKILL.md`(브랜치 스캔), `ENTRY-TEMPLATE.md`, `NEXT.md` 시드, `WORKSPACE.md` §Conventions(filename), `antigravity-cli.md` §Subagents.

**근거**: worktree 수렴(Claude Code `--worktree`, subagent `isolation: worktree`, Codex subagent); Claude Code auto memory "shared across worktrees"(하네스는 이미 worktree 간 공유를 전제로 설계).

---

### P1-G. 하네스 네이티브 메모리와의 관계 — "workspace is canonical, harness memory is an inbox"

**문제**: Claude Code auto memory(리포 밖, 매 세션 로드), Letta MemFS, Codex memories 등 하네스가 **자기 메모리**를 쓴다. 스펙은 transcript를 "pre-consolidation trace"로만 언급. 두 저장소가 같은 사실을 다르게 기억하면 R3(source monitoring)가 깨지고, One canonical home 위반.

**제안**
1. `use-driven-memory.md §7 stores` 아래 **"Harness-native memory"** 소절 추가: 정의(하네스가 리포 밖에 쓰는 자율 메모), 지위(**T0 — inbox**: canonical 아님, 세션 시작 로드 대상 아님), 처리(`dream`이 ingest → `USER.md`/`garden/<topic>.md`로 승격, 인용 `(auto-memory <runtime> <YYYY-MM-DD>)`; ingest된 항목은 하네스 메모리에서 제거 가능).
2. 어댑터 노트: Claude Code는 auto memory를 끄거나(`autoMemoryEnabled` 등 설정 — 적용 시 확인) `MEMORY.md` 상단에 "canonical은 `2-mind/garden/`; 여기엔 세션 임시 메모만" 한 줄을 두는 두 가지 선택을 `3-control/runtime/claude-code.md`(신규, 선택)에.
3. R3 출처 종류 확장: `journal`, `auto-memory`, `owner`(직접 진술) 세 가지.

**영향 파일**: `use-driven-memory.md`, `dream/SKILL.md` §1(gather 소스에 harness memory 추가), `audit/SKILL.md`(중복 스캔 범위), 신규 `3-control/runtime/claude-code.md`(선택).

**근거**: Claude Code memory 문서(auto memory 위치·로드량·worktree 공유·subagent memory); Letta MemFS.

---

### P1-H. Headless 비준 — "ratify = merge": PR 기반 T2 승인

**문제**: 클라우드 세션·스케줄 실행·CI에서 `dream`이 T2 제안을 만들어도 비준할 Owner가 없다. 현 스펙은 "assume standard, flag for next interactive session"으로 **미룬다**. 제안이 쌓이면 유실.

**제안**
1. T2 제안의 **영구 큐**: `1-active/proposals/<YYYY-MM-DD>_<slug>.md`(lazy — 첫 headless 제안 때 생성). 포맷: 대상 파일, diff, 근거 journal 인용, 상태(`proposed | ratified | declined`).
2. **비준 채널 2종**: ①대화형(현행) ②**PR 리뷰** — headless 세션은 `3-control/` 변경을 별도 브랜치·PR로 올리고, Owner의 merge가 비준. `adoption.md`에 "Owner가 GitHub에서 리뷰하는 것이 가장 자연스러운 T2 UI"로 서술. 에이전트가 PR을 여는 관행과 정합.
3. slug 레지스트리에 `cloud`(원격 대화형)와 `ci` 추가(`cron`은 유지).

**영향 파일**: `use-driven-memory.md` §2 write-tiers, `dream/SKILL.md` §4–5, `runtime-flexibility.md` §Graceful degradation, `session-end/SKILL.md` slug 표, `adoption.md`.

---

### P2-I. 최소 신뢰 모델 — `3-control/rule/trust.md` 템플릿

**문제**: §Known limitations "authorization not modeled". 2026년엔 그냥 두기 어렵다 — 리포 제어 설정 파일 CVE, 스킬 공급망 사고가 실제로 났다.

**제안** (스펙은 여전히 권한 **시스템**을 만들지 않는다. 다만 **데이터 신뢰 등급**과 **실행 파일의 티어**만 명시한다.)
1. `0-storage/` 콘텐츠와 외부에서 받은 파일은 **untrusted data** — 지시로 해석하지 않는다(R0 또는 PRINCIPLE §0-storage에 한 문장).
2. **실행되는 설정은 T2**: `.claude/settings.json`(hooks), `.codex/config.toml`, `.agents/mcp_config.json`, `registry.json`은 "runtime-native path이지만 **Owner-ratified**"로 명시. 현재 이들은 "native path에 직접 커밋"이라고만 되어 있어 티어가 비어 있다.
3. 외부 스킬 도입 규칙: `forge/act/skill/`에 들여온 서드파티 스킬은 출처 URL + **콘텐츠 해시**를 `metadata:`에 기록(OWASP 권고); `audit`이 해시 변경을 flag.
4. `USER.md`는 **개인정보**임을 헤더에 명시; 공개 리포 adopter를 위해 "`garden/essential/` private remote 또는 gitignore" 선택지를 `adoption.md`에.

**영향 파일**: 신규 `3-control/rule/trust.md`(템플릿, lazy), `PRINCIPLE.md` §0-storage·§3-control, `use-driven-memory.md` §2, `audit/SKILL.md`(해시 스캔), `USER.md` 시드, `adoption.md`, `WORKSPACE.md` §Known limitations.

**근거**: OWASP Agentic Skills Top 10 v0.5; Snyk/CSA 보고; Claude Code 설정 파일 CVE.

---

### P2-J. SKILL.md 이식성 규칙 + `audit` 검사

- lifecycle 6스킬은 **이식 6필드만** 사용(현재 `name`/`description`만이라 이미 준수). 이를 `WORKSPACE.md §Conventions §Metadata`에 명문화하고 `audit`에 "비이식 필드 flag" 1줄 추가.
- `description`은 1,536자에서 잘림(Claude Code) — `audit` 스킬의 description(약 400자)은 안전하지만 상한을 적어 둔다.
- 하네스 확장 필드(`context: fork`, `paths:` 등)가 필요하면 **본문 지침**으로 쓰거나 하네스별 wrapper 스킬을 `3-control/runtime/<harness>/`에 두는 패턴 제시.

### P2-K. `token-count.sh` 현행화
- 폴백 tokenizer `tiktoken cl100k_base`(GPT-4 세대) → `o200k_base`가 현세대 토크나이저에 더 근접. Anthropic 백엔드면 `count_tokens` API 우선. 스펙 문장 "advisory rough estimate" 유지.

### P2-L. 캡 숫자의 경험적 검증 루프
- README가 "empirically not validated… adopter workloads will surface"라고 쓰면서 **측정 장치가 없다**. `audit`이 매 실행 때 journal 끝에 4줄 메트릭(USER/NEXT 토큰, consolidate 횟수, archive 건수)을 남기면 1년 뒤 캡 조정 근거가 생긴다. 비용 거의 0.

---

## 3. 자기 일관성 점검 (제안 반영 시 함께 볼 것)

- `WORKSPACE.md` 199줄 — spec cap 200줄에 **1줄 여유**. P0-A·D로 §Known limitations가 줄어들어 여유 생김. P1-E/F 추가분은 `use-driven-memory.md`(현재 299/300)로 가면 **즉시 초과** → P0-C로 `runtime-flexibility.md`가 줄어드는 만큼 R2 상세를 거기로 이동하거나, 캡을 v0.2에서 재산정.
- "7-item"이라는 숫자가 `AGENTS.md`, `README.md`, `use-driven-memory.md`, `session-start`, `init`, `adoption.md`, `runtime-flexibility.md`에 산재. P0-B 적용 시 `audit`의 convenience-summary drift 스캔을 먼저 돌려 목록을 뽑는다.
- `detect-runtime` 축소(P0-C)는 `init` §2–3, `session-start` §1, `audit` freshness scan, `profile.example.md` 필드 레퍼런스에 연쇄.

## 4. 하지 않을 것 (non-goals)

- 데몬·게이트웨이·바이너리 도입 — "The agent runs it" 원칙 유지.
- 벤더별 기능 추적(모델 상수표 같은 것) — P0-C가 오히려 **제거**하는 방향.
- 권한 시스템 설계 — P2-I는 데이터 신뢰 등급과 티어 표기까지만.
- 메모리 저장소 이름 변경(`MEMORY.md` 등 유행 따라가기) — 매핑만 정의.

## 5. 제안 로드맵

| 버전 | 묶음 | 성격 |
|---|---|---|
| **v0.2.0** | P0-A, P0-B, P0-C, P0-D | breaking: entry file·read order·tier 도출 변경 |
| v0.2.1 | P1-E, P1-F | 세션 경계·동시성 (파일명 변형은 하위 호환) |
| v0.2.2 | P1-G, P1-H | 하네스 메모리·headless 비준 |
| v0.3.0 | P2-I ~ P2-L | 신뢰 모델·이식성·측정 |

v0.2.0 작업 순서 권고: **P0-C(축소) → P0-B(로드 재편) → P0-A/D(entry·하네스 표) → `audit` 전체 drift 스캔 → 버전 범프**. 축소를 먼저 해야 캡 여유가 생긴다.

---

## 6. Sources

공식 문서
- Claude Code — How Claude remembers your project (AGENTS.md 네이티브 지원, 200줄 권고, `.claude/rules/`, auto memory): <https://code.claude.com/docs/en/memory>
- Claude Code — Hooks reference (SessionStart source, PreCompact, SessionEnd 등): <https://code.claude.com/docs/en/hooks>
- Claude Code — Skills (`.claude/skills/`, 이식 6필드): <https://code.claude.com/docs/en/skills>
- OpenAI Codex — Agent Skills (`.agents/skills` 탐색): <https://developers.openai.com/codex/skills>
- Agent Skills 오픈 표준: <https://agentskills.io/>
- Google — Transitioning Gemini CLI to Antigravity CLI: <https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/>
- Letta MemFS (git 기반 markdown 메모리, `system/` 상시 로드): <https://docs.letta.com/concepts/memfs>
- OWASP Agentic Skills Top 10 v0.5: <https://owasp.org/www-project-agentic-skills-top-10/docs/OWASP-Agentic-Skills-Top10-v0.5.pdf>

2차 자료 (수치는 근사치로 취급)
- AAIF 출범·AGENTS.md 채택: <https://infoq.com/news/2025/12/agentic-ai-foundation/>, <https://agentmarketcap.ai/blog/2026/04/17/agents-md-60k-adoption-aaif-donation-standards-floor>
- AGENTS.md 효과 연구(ETH Zurich) 요약: <https://rywalker.com/research/agents-md-standard>
- Thoughtworks Radar — Progressive context disclosure / Context engineering: <https://www.thoughtworks.com/radar/techniques/progressive-context-disclosure>
- Worktree 병렬 에이전트 관행: <https://noqta.tn/en/blog/git-worktrees-parallel-ai-coding-agents-guide-2026>, <https://codex.danielvaughan.com/2026/03/26/codex-cli-worktree-parallel-development/>
- 스킬 공급망 보안: <https://snyk.io/blog/snyk-vercel-securing-agent-skill-ecosystem/>, <https://labs.cloudsecurityalliance.org/research/csa-research-note-skill-md-agent-context-poisoning-20260506>
- Gemini CLI 종료 후속 보도: <https://thenewstack.io/gemini-cli-antigravity-replacement/>
