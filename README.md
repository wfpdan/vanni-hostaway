# WorkflowPal Hostaway Integration

Repository layout keeps the root tidy with only high-level docs and env files. Everything else lives in structured subfolders so automation agents know where to read/write artifacts.

## Directory map

```
.
├── AGENTS.md             # System prompt & automation runbook
├── README.md             # You are here
├── .env                  # Local secrets (ignored)
├── .env.example          # Template for required env vars
├── data/                 # Runtime artifacts & API snapshots
│   ├── zoho/             # Zoho responses (unbilled expenses, etc.)
│   └── hostaway/         # Hostaway caches (owner statements/detail payloads)
├── logs/                 # Request/response logs for destructive API calls
└── ops/
    └── scripts/          # Operational scripts (token refresh, etc.)
```

Keep raw API responses inside `data/`; do not drop JSON into the repo root. Place all helper scripts under `ops/scripts`. Log every POST/PUT/PATCH/DELETE request+response under `logs/` for traceability.

## Data & logging guidelines

- **Zoho snapshots:** save to `data/zoho/…` with date-stamped filenames so runs can be replayed.
- **Hostaway caches:** when downloading owner statement listings or detail payloads, store them under `data/hostaway/` (e.g., `owner_statements_2025-11-10.json`, `owner_statement_628715.json`).
- **Destructive call logs:** whenever you perform POST/PUT/PATCH/DELETE requests (especially to Hostaway), write a log file under `logs/` capturing timestamp, endpoint, payload, and response. Example filename: `logs/2025-11-10_hostaway_expenses_post.log`.

## Common tasks

- **Refresh Zoho OAuth token:** `./ops/scripts/refresh_zoho_token.sh`
- **Fetch Zoho unbilled expenses:** follow the steps in `AGENTS.md`, saving output into `data/zoho`.

## Environment setup

Copy `.env.example` to `.env` and fill in values. Never commit `.env`.
