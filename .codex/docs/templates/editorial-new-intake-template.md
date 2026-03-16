# Editorial New Intake Template

## Objective

## Scope In

## Scope Out

## Validation Commands

## Gate Type

Choose exactly one:

- `PR_REQUIRED` for tasks that modify tracked repository files.
- `EVIDENCE_REQUIRED` for tasks that do not require a repository PR.

## Completion Gate

### If `PR_REQUIRED`

- [ ] PR created and linked to this issue
- [ ] PR moved to `In Review`
- [ ] Review completed (or explicit self-review recorded for solo flow)
- [ ] PR merged to `main`
- [ ] Only after merge: move issue to `Done`

### If `EVIDENCE_REQUIRED`

- [ ] Required evidence artifact(s) attached (screenshots, links, logs, or decision notes)
- [ ] Human verification/sign-off comment posted
- [ ] Scope acceptance criteria confirmed in comment
- [ ] Only after evidence is complete: move issue to `Done`

## Pickup Gate

## Missing For Pickup

## DoR

## DoD

- [ ] Completion gate satisfied for selected `Gate Type`
