# Data Artifacts

- `zoho/`
  - Saved payloads from Zoho Books (e.g., `unbilled_expenses_YYYY-MM-DD.json`).
  - One file per fetch so upstream processing can be replayed.
- `hostaway/`
  - Cache owner statement listings and detail payloads (e.g., `owner_statements_YYYY-MM-DD.json`, `owner_statement_<id>.json`).
  - Use these caches to avoid refetching unchanged Hostaway data during local runs.

All data files are ignored by git; keep only sanitized samples in documentation.
