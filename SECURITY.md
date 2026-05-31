# Security Policy

## Supported versions

Only the latest commit on `master` is maintained. No versioned releases with separate security support windows.

## Reporting a vulnerability

Don't open a public GitHub issue — that exposes the problem before it's fixed.

Email **jammer.website@internet.ru** instead. Include:

- What the issue is and what an attacker could do with it
- Steps to reproduce or a proof-of-concept
- The affected commit hash if you know it
- Your suggested fix, if you have one

You'll get an acknowledgement within 5 business days and a severity assessment within 14. We'll sort out the disclosure timeline with you before anything goes public.

## Automated checks

Every push and PR to `master` runs [`bundler-audit`](https://github.com/rubysec/bundler-audit) and [`brakeman`](https://github.com/presidentbeef/brakeman) via GitHub Actions. A failing audit blocks the merge. Config is in [`.github/workflows/rubyonrails.yml`](.github/workflows/rubyonrails.yml).
