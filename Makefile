SHELL := /bin/bash

.PHONY: help setup ci-setup hooks-install lint security workflow-check site-audit qa-local validate-draft qa-publish publish-draft publish-draft-tests start-work start-phase check create-pr finalize-merge rollout-audit rollout-tests skill-audit skill-vendor

ifneq (,$(filter skill-audit skill-vendor,$(firstword $(MAKECMDGOALS))))
SKILL_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(foreach arg,$(SKILL_ARGS),$(eval $(arg):;@:))
endif

help:
	@echo "Available targets:"
	@echo ""
	@echo "Setup:"
	@echo "  make setup"
	@echo "  make ci-setup"
	@echo "  make hooks-install"
	@echo ""
	@echo "Editorial:"
	@echo "  make validate-draft PATH=_drafts/post.md"
	@echo "  make qa-publish PATH=_drafts/post.md"
	@echo "  make publish-draft PATH=_drafts/post.md DATE=YYYY-MM-DD [KEEP_DRAFT=1]"
	@echo "  make publish-draft-tests"
	@echo ""
	@echo "Site Quality:"
	@echo "  make site-audit AUDIT=seo TARGET=site"
	@echo ""
	@echo "QA:"
	@echo "  make lint"
	@echo "  make security"
	@echo "  make workflow-check"
	@echo "  make rollout-tests"
	@echo "  make check"
	@echo "  make qa-local"
	@echo ""
	@echo "Repo Flow:"
	@echo "  make start-work TOPIC=\"...\" TYPE=chore"
	@echo "  make start-phase PLAN=... PHASE=1 TOPIC=\"...\" TYPE=feat"
	@echo "  make create-pr TYPE=feat"
	@echo "  make finalize-merge PR=123"
	@echo "  make rollout-audit"
	@echo ""
	@echo "Skill Governance:"
	@echo "  make skill-audit NAME=example SOURCE=https://github.com/org/repo/tree/main/path"
	@echo "  make skill-audit example"
	@echo "  make skill-vendor SOURCE=https://github.com/org/repo/tree/main/path NAME=example"
	@echo "  make skill-vendor https://github.com/org/repo/tree/main/path example"

setup:
	@./scripts/setup-dev.sh

ci-setup:
	@./scripts/setup-ci.sh

hooks-install:
	@./scripts/setup-hooks.sh

lint:
	@./scripts/run-lint.sh

security:
	@./scripts/run-security-checks.sh

workflow-check:
	@./scripts/run-workflow-checks.sh

site-audit:
	@/usr/bin/env AUDIT='$(AUDIT)' TARGET='$(TARGET)' /bin/bash -lc './scripts/site-audit.sh'

qa-local:
	@./scripts/run-local-qa.sh

validate-draft:
	@/usr/bin/env DRAFT_PATH='$(PATH)' /bin/bash -lc './scripts/validate-draft.sh "$$DRAFT_PATH"'

qa-publish:
	@/usr/bin/env DRAFT_PATH='$(PATH)' /bin/bash -lc './scripts/qa-publish.sh "$$DRAFT_PATH"'

publish-draft:
	@/usr/bin/env DRAFT_PATH='$(PATH)' DATE='$(DATE)' SLUG='$(SLUG)' KEEP_DRAFT='$(KEEP_DRAFT)' /bin/bash -lc './scripts/publish-draft.sh'

publish-draft-tests:
	@./scripts/run-publish-draft-tests.sh

start-work:
	@./scripts/start-work.sh

start-phase:
	@./scripts/start-phase.sh

check:
	@./scripts/run-checks.sh

create-pr:
	@./scripts/create-pr.sh

finalize-merge:
	@./scripts/finalize-merge.sh

rollout-audit:
	@./scripts/rollout-audit.sh

rollout-tests:
	@./scripts/run-rollout-governance-tests.sh

skill-audit:
	@./scripts/audit-skill.sh $(SKILL_ARGS)

skill-vendor:
	@./scripts/vendor-skill.sh $(SKILL_ARGS)
