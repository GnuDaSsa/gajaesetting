# OAuth DB (`agent.db`) — 다른 PC에서 연동하기

GJC는 OAuth·API 키 메타를 **로컬 SQLite**에 둡니다. `gajaesetting`의 YAML/`.env`만으로는 **로그인 상태는 복사되지 않습니다.**

## 파일 위치

| 파일 | 역할 |
|------|------|
| `~/.gjc/agent/agent.db` | `auth_credentials` 테이블 (refresh token, access, projectId 등) |
| `~/.gjc/agent/.env` | `MINDLOGIC_GATEWAY_API_KEY` 등 (gateway 전용) |
| `~/.gjc/agent/config.yml` | 역할·모델 (`install.sh`로 복사) |

**절대 git에 올리지 마세요** (refresh token = 계정 접근).

## 방법 A — 권장: PC마다 OAuth 다시 로그인

`gajaesetting` 설치 후:

```bash
gjc auth-broker status
gjc auth-broker login grok-build
gjc auth-broker login openai-codex
gjc auth-broker login google-antigravity
```

- 터미널에서만 (TUI 채팅에 `login` 치지 않기).
- `which gjc` → `~/.local/bin/gjc` (wrapper) 이어야 `status`/`login`이 프롬프트로 안 들어감.

## 방법 B — 같은 사용자, DB 파일 복사 (1인 1머신 동시 사용)

한 Mac에서 이미 로그인돼 있을 때:

```bash
# 보내는 쪽 (이 Mac)
scp ~/.gjc/agent/agent.db otherhost:~/.gjc/agent/agent.db

# 또는 압축 백업 (USB 등)
sqlite3 ~/.gjc/agent/agent.db ".backup ~/.gjc/agent/agent.db.backup"
```

받는 쪽:

```bash
mkdir -p ~/.gjc/agent
cp agent.db.backup ~/.gjc/agent/agent.db
gjc auth-broker status
./scripts/smoke-roles.sh
```

주의:

- **두 PC에서 동시에** 같은 OAuth refresh를 쓰면 토큰 로테이션 충돌 가능 → 한쪽만 쓰거나 A 방식 권장.
- `agent.db`만 복사하고 `config.yml` / `models.yml` / `.env`도 `install.sh`로 맞출 것.

## 방법 C — 중앙 Auth Broker (여러 클라이언트가 한 저장소)

로컬 DB를 **원격 broker**에 올리고, 다른 머신은 broker URL로 읽게 할 수 있습니다 (팀/고정 서버용).

1. 서버에 broker 설정 (`auth.broker.url`, 토큰 — GJC 문서 `auth-broker-gateway` 참고).
2. 이 Mac에서 ( **wrapper가 아닌** 실제 CLI):

```bash
# 예: 환경변수 또는 ~/.gjc/agent/config.yml 의 auth.broker.*
export GJC_AUTH_BROKER_URL=https://your-broker:port
export GJC_AUTH_BROKER_TOKEN=...

~/.bun/bin/gjc auth-broker migrate --from-local --include-oauth
```

3. 다른 PC: 같은 `auth.broker.*` 설정 → 로컬 `agent.db` 없이 broker 스냅샷 사용.

`~/.local/bin/gjc` wrapper는 **login/logout/status만** 지원. `import`/`migrate`/`serve`는:

```bash
~/.bun/bin/gjc auth-broker import ...
~/.bun/bin/gjc auth-broker migrate --from-local --include-oauth
```

## 방법 D — CLIProxyAPI JSON 가져오기

OpenClaw/CLIProxy 형식 JSON 디렉터리가 있으면:

```bash
~/.bun/bin/gjc auth-broker import ~/.cliproxy/auth
# 또는 단일 파일
```

Antigravity **IDE** `state.vscdb` 토큰은 GJC와 **호환되지 않음** — 반드시 `gjc auth-broker login google-antigravity`.

## 확인

```bash
sqlite3 ~/.gjc/agent/agent.db \
  "SELECT provider, identity_key FROM auth_credentials ORDER BY provider;"

gjc auth-broker status
./scripts/smoke-roles.sh
```

## 요약

| 목적 | 추천 |
|------|------|
| 집/회사 Mac 각각 | **A** 재로그인 + `gajaesetting` install |
| Mac 하나 더, 가끔만 | **B** `agent.db` 복사 (동시 사용 X) |
| 팀 공용 credential | **C** auth broker migrate |
| cliproxy 이미 있음 | **D** import |