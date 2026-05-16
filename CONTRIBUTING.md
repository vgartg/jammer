# Contributing to Jammer

Thanks for your interest in contributing! This document covers the basics for getting a development environment running and getting your changes merged.

## Local setup

```bash
git clone https://github.com/vgartg/jammer.git
cd jammer
bundle install
yarn install
bundle exec rake db:create
bundle exec rake db:migrate
```

Start the dev server with the client build in watch mode:

```bash
foreman start -f Procfile.dev
```

## Workflow

1. Fork the repository and create a feature branch off `master`:
   ```bash
   git checkout -b feat/short-description
   ```
2. Make focused commits with descriptive messages.
3. Before opening a pull request, run the same checks CI runs:
   ```bash
   bundle exec rails test
   bundle exec bundler-audit --update
   bundle exec brakeman -q
   bundle exec rubocop
   ```
4. Push your branch and open a pull request against `master`. Fill out the PR template.

## Style & conventions

- Ruby code is linted with [RuboCop](https://github.com/rubocop/rubocop); please keep the working tree clean.
- Follow standard Rails conventions for naming, file layout, and migrations.
- Keep migrations reversible.
- Add or update tests for any behavior change.

## Reporting bugs / requesting features

Use the [issue tracker](https://github.com/vgartg/jammer/issues) and pick the appropriate template. For security issues, see [SECURITY.md](SECURITY.md) — do **not** open a public issue.

## Code of Conduct

Participation in this project is governed by the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to abide by its terms.
