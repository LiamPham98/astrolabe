# Issue tracker: Orrery

Issues and specs for this repo live as notes in Orrery, read and written through the Orrery MCP tools (`note_create`, `note_read`, `note_edit`, `note_update`, `note_search`, `folder_list`).

- Space: `{{space}}`
- Root folder: `{{repo}}/features/`

## Conventions

- One feature per folder: `{{repo}}/features/<feature-slug>/`
- The spec is the note `spec.md` in that folder, with frontmatter `type: spec`, `repo: {{repo}}`, `feature: <feature-slug>`
- Implementation issues are one note per ticket at `{{repo}}/features/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, never a single combined tickets note; frontmatter `type: ticket`
- Triage state is recorded as a `Status:` line near the top of each issue note (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the note under a `## Comments` heading, with `note_edit` and `op: append`
- Every edit passes the `base_revision` just read; on `conflict`, read again, merge, and retry

## When a skill says "publish to the issue tracker"

Create a new note under `{{repo}}/features/<feature-slug>/` with `note_create` (folders are created as needed). Report the note's `ref` and `revision_no`.

## When a skill says "fetch the relevant ticket"

Read the note with `note_read` by path and name. The user will normally pass the path or the issue number directly.

## When the session has no Orrery tools

Write the same files under `.scratch/<feature-slug>/` in this repo, and say that they need to be synced to Orrery in a later session (`/astrolabe:flow` does the sync).

## Wayfinding operations

Used by `/wayfinder`. Same rules as above, with notes in place of files:

- **Map**: `{{repo}}/features/<effort>/map.md`.
- **Child ticket**: `{{repo}}/features/<effort>/issues/NN-<slug>.md`, with `Type:` and `Status:` lines as in the local-markdown convention.
- **Blocking**: a `Blocked by: NN, NN` line near the top.
- **Frontier**: `folder_list` on `{{repo}}/features/<effort>/issues/` for notes that are open, unblocked, and unclaimed; first by number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set `Status: resolved`, then append a context pointer (gist + wikilink) to Decisions-so-far in `map.md`.
