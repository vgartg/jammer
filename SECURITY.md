# Security Policy

## Supported versions

Only the latest commit on `master` is maintained. There are no versioned releases with separate security support windows.

## Reporting a vulnerability

If you find a security issue in Jammer, please don't open a public GitHub issue. That exposes the problem before it's fixed.

Instead, email **jammer.website@internet.ru** directly. Include:

- What the issue is and what an attacker could do with it
- Steps to reproduce or a proof-of-concept
- The affected commit hash if you know it
- Your suggested fix, if you have one

### What happens next

- You'll get an acknowledgement within **5 business days**
- A severity assessment within **14 days**
- We'll coordinate the fix and disclosure timeline with you before anything goes public

## Automated checks

Every push and PR to `master` runs [`bundler-audit`](https://github.com/rubysec/bundler-audit) and [`brakeman`](https://github.com/presidentbeef/brakeman) via GitHub Actions. A failing audit blocks the merge. So if a gem you depend on picks up a CVE, it surfaces immediately - not weeks later.

See [`.github/workflows/rubyonrails.yml`](.github/workflows/rubyonrails.yml) for the full pipeline config.
