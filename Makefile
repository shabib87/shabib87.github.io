SHELL := /bin/bash

.PHONY: help setup hooks-install lint security validate-draft qa-publish publish-draft start-work check create-pr finalize-merge skill-audit skill-vendor

help:
	@echo "Available targets:"
	@echo "  make setup"
	@echo "  make hooks-install"
	@echo "  make lint"
	@echo "  make security"
	@echo "  make validate-draft PATH=_drafts/post.md"
	@echo "  make qa-publish PATH=_drafts/post.md"
	@echo "  make publish-draft PATH=_drafts/post.md DATE=YYYY-MM-DD"
	@echo "  make start-work TOPIC=\"...\" TYPE=chore"
	@echo "  make check"
	@echo "  make create-pr TYPE=feat"
	@echo "  make finalize-merge PR=123"
	@echo "  make skill-audit NAME=example SOURCE=https://github.com/org/repo/tree/main/path"
	@echo "  make skill-vendor SOURCE=https://github.com/org/repo/tree/main/path NAME=example"

setup:
	@./scripts/setup-dev.sh

hooks-install:
	@./scripts/setup-hooks.sh

lint:
	@./scripts/run-lint.sh

security:
	@./scripts/run-security-checks.sh

validate-draft:
	@/usr/bin/env DRAFT_PATH='$(PATH)' /bin/bash -lc './scripts/validate-draft.sh "$$DRAFT_PATH"'

qa-publish:
	@/usr/bin/env DRAFT_PATH='$(PATH)' /bin/bash -lc './scripts/qa-publish.sh "$$DRAFT_PATH"'

publish-draft:
	@/usr/bin/env DRAFT_PATH='$(PATH)' DATE='$(DATE)' SLUG='$(SLUG)' /bin/bash -lc './scripts/publish-draft.sh'

start-work:
	@./scripts/start-work.sh

check:
	@./scripts/run-checks.sh

create-pr:
	@./scripts/create-pr.sh

finalize-merge:
	@./scripts/finalize-merge.sh

skill-audit:
	@./scripts/audit-skill.sh

skill-vendor:
	@./scripts/vendor-skill.sh
