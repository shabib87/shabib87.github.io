# CWS-89: Remove dead .cursor/rules/ directory

- Linear: <https://linear.app/codewithshabib/issue/CWS-89>
- Parent: CWS-88
- Branch: `cws/89-remove-dead-cursor-rules`
- Status: In Progress

## Objective

Remove the `.cursor/rules/` directory from the repo. Cursor is not an active execution platform.
The directory creates ambiguity about which platform configs are live.

## Acceptance Criteria

1. `.cursor/` directory no longer exists in the repo
2. No functional references to `.cursor/` paths in config, scripts, or docs
3. `make qa-local` passes

## Scope

- Delete `.cursor/rules/` and its contents
- Remove `.cursor/` parent directory if empty after deletion
- Verify no config/script files reference `.cursor/` paths

## Out of Scope

- No migration of Cursor rules content
- Blog post editorial mentions of Cursor as a product are not affected
