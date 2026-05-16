# Security Policy

## Supported Versions

Only the latest commit on the `master` branch is actively maintained and receives security updates

## Reporting a Vulnerability

If you discover a security vulnerability in Jammer, **please do not open a public issue**.

Instead, report it privately by one of the following channels:

- Email: **jammer.website@internet.ru**

Please include as much of the following as you can:

- A clear description of the issue and its potential impact
- Steps to reproduce, a proof-of-concept, or the affected commit hash
- Your suggested fix, if any

### What to expect

- An initial acknowledgement within **5 business days**
- A triage update with severity assessment within **14 days**
- Coordinated disclosure: we will work with you on a fix and a public advisory before disclosing details

## Automated dependency auditing

The CI pipeline runs [`bundler-audit`](https://github.com/rubysec/bundler-audit) and [`brakeman`](https://github.com/presidentbeef/brakeman) on every push and pull request to `master`. See [`.github/workflows/rubyonrails.yml`](.github/workflows/rubyonrails.yml)

A failing audit blocks the merge, so security advisories against any listed gem will surface immediately
