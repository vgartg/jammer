# Contributing to Jammer

Glad you want to contribute. Here's everything you need to get set up and get your changes into `master`.

## Local setup

```bash
git clone https://github.com/vgartg/jammer.git
cd jammer
bundle install
yarn install
bundle exec rake db:create
bundle exec rake db:migrate
foreman start -f Procfile.dev
```

This starts the Rails server alongside the asset build in watch mode. The app should be at [localhost:3000](http://localhost:3000).

## Workflow

1. Fork the repo and create a branch off `master`:
   ```bash
   git checkout -b short-description
   ```
2. Make focused commits with clear messages - one logical change per commit.
3. Before opening a PR, run what CI runs:
   ```bash
   bundle exec rails test
   bundle exec bundler-audit --update
   bundle exec brakeman -q
   bundle exec rubocop
   ```
4. Push and open a pull request against `master`. Fill in the PR description.

## Conventions

- RuboCop handles Ruby style. Keep the working tree clean - CI will reject a linting failure.
- Follow standard Rails conventions for naming, file layout, and migrations.
- Migrations should be reversible.
- Add or update tests for any behavior change. We don't merge untested logic.

## Bugs and feature requests

Use the [issue tracker](https://github.com/vgartg/jammer/issues) and pick the right template. If it's a security issue, check [SECURITY.md](SECURITY.md) first - those should not be public issues.

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating, you agree to abide by its terms.
