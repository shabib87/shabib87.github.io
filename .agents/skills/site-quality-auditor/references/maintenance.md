# Maintenance Audit Notes

- Check for remote dependencies that can make builds or checks brittle.
- Check repo workflow drift between Make targets, scripts, skills, prompts, and docs.
- Flag third-party scripts or assets that deserve periodic review.
- Note when a repo command depends on network access or cached state.
- Hand version-sensitive behavior to `official-doc-verifier` instead of guessing.
