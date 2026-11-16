# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase. The domain docs live in Orrery, not in the repo.

- Space: `{{space}}`
- Folder: `{{repo}}/`

## Before exploring, read these

Read with the Orrery MCP tools (`note_read`, `folder_list`, `note_search`):

- **`{{repo}}/GLOSSARY.md`**, or
- **`{{repo}}/GLOSSARY-MAP.md`** if it exists: it points at one `GLOSSARY.md` per context under `{{repo}}/contexts/<context>/`. Read each one relevant to the topic.
- **`{{repo}}/adr/`**: read ADRs that touch the area you're about to work in.

Also read `GLOSSARY.md` and `docs/adr/` in the repo if they exist: they are new entries not yet synced to Orrery.

If none of these exist, **proceed silently**. Don't flag their absence; don't suggest creating them upfront.

## Where new entries go

`/domain-modeling` writes `GLOSSARY.md` and `docs/adr/` in the repo. That is expected: `/astrolabe:flow` syncs them to `{{repo}}/` in Orrery after each grilling session, through a changeset another person approves.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in the glossary. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal: either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).
