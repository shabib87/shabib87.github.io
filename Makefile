SHELL := /bin/bash

.PHONY: help setup hooks-install lint security codex-check site-audit qa-local validate-draft qa-publish publish-draft start-work check create-pr finalize-merge skill-audit skill-vendor

ifneq (,$(filter skill-audit skill-vendor,$(firstword $(MAKECMDGOALS))))
SKILL_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(foreach arg,$(SKILL_ARGS),$(eval $(arg):;@:))
endif

help:
	@echo "Available targets:"
	@echo ""
	@echo "Setup:"
	@echo "  make setup"
	@echo "  make hooks-install"
	@echo ""
	@echo "Editorial:"
	@echo "  make validate-draft PATH=_drafts/post.md"
	@echo "  make qa-publish PATH=_drafts/post.md"
	@echo "  make publish-draft PATH=_drafts/post.md DATE=YYYY-MM-DD"
	@echo ""
	@echo "Site Quality:"
	@echo "  make site-audit AUDIT=seo TARGET=site"
	@echo ""
	@echo "QA:"
	@echo "  make lint"
	@echo "  make security"
	@echo "  make codex-check"
	@echo "  make check"
	@echo "  make qa-local"
	@echo ""
	@echo "Repo Flow:"
	@echo "  make start-work TOPIC=\"...\" TYPE=chore"
	@echo "  make create-pr TYPE=feat"
	@echo "  make finalize-merge PR=123"
	@echo ""
	@echo "Skill Governance:"
	@echo "  make skill-audit NAME=example SOURCE=https://github.com/org/repo/tree/main/path"
	@echo "  make skill-audit example"
	@echo "  make skill-vendor SOURCE=https://github.com/org/repo/tree/main/path NAME=example"
	@echo "  make skill-vendor https://github.com/org/repo/tree/main/path example"

setup:
	@./scripts/setup-dev.sh

hooks-install:
	@./scripts/setup-hooks.sh

lint:
	@./scripts/run-lint.sh

security:
	@./scripts/run-security-checks.sh

codex-check:
	@./scripts/run-codex-checks.sh

site-audit:
	@/usr/bin/env AUDIT='$(AUDIT)' TARGET='$(TARGET)' /bin/bash -lc './scripts/site-audit.sh'

qa-local:
	@./scripts/run-local-qa.sh

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
	@./scripts/audit-skill.sh $(SKILL_ARGS)

skill-vendor:
	@./scripts/vendor-skill.sh $(SKILL_ARGS)
