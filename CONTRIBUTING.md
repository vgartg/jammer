# Contributing to Jammer

## Local setup

```bash
git clone https://github.com/vgartg/jammer.git
cd jammer
bundle install
yarn install
bundle exec rake db:create db:migrate
foreman start -f Procfile.dev
```

Starts the Rails server and asset build in watch mode. App is at [localhost:3000](http://localhost:3000).

Dev/test uses PostgreSQL — make sure it's running before `db:create`.

## Workflow

Fork the repo and create a branch off `master`:

```bash
git checkout -b short-description
```

Keep commits small and focused. Before opening a PR, run what CI runs:

```bash
bundle exec rails test
bundle exec bundler-audit --update
bundle exec brakeman -q
bundle exec rubocop
```

Then open a PR against `master` and describe what you changed and why.

## Conventions

- RuboCop handles code style. CI rejects linting failures.
- Migrations should be reversible.
- Cover new logic with tests. Untested behavior changes are hard to merge.
- Follow standard Rails conventions for naming and file layout.

## Bugs and feature requests

Use the [issue tracker](https://github.com/vgartg/jammer/issues). For security issues, check [SECURITY.md](SECURITY.md) first — those should not be public issues.
