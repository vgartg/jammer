# Jammer

[![Ruby on Rails CI](https://github.com/vgartg/jammer/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/vgartg/jammer/actions/workflows/rubyonrails.yml)
[![Ruby](https://img.shields.io/badge/ruby-3.3.4-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/rails-8.0-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.txt)

A platform for running game jams and distributing games and assets. Winner of the **SFedU SBS Creative 2024** accelerator. Grant from the **Foundation for Assistance to Small Innovative Enterprises**.
Live at [jammer.website](https://jammer.website).

You set up a jam, configure voting criteria, invite judges or open it to everyone, then collect submissions and watch the leaderboard fill in. Profiles, teams, achievements, and friend connections work on top of that.

---

## Jammer Graph

<img width="1280" height="755" alt="image" src="https://github.com/user-attachments/assets/8af3827b-914d-46b0-9441-d28ea53c6656" />

---

## Features

**Game jams** — separate dates for registration, submissions, and voting. Multiple criteria with different modes (star ratings or "one vote per game"). Jury and audience vote independently. Nominations with winners.

**Games** — publish your game, add tags and a cover, collect community ratings, submit for moderation.

**Teams** — create a team, send invites, accept join requests, manage member roles.

**Profiles** — personal pages at `/u/username`, earned achievements, activity stats, jam history.

**Assets** — upload and share files (sounds, sprites, fonts) with public download links.

**Social** — friend requests, in-app notifications, account freeze/unfreeze with admin audit log.

**Auth** — email + confirmation, password reset, OAuth via GitHub and Google, persistent sessions.

## Stack

- Ruby 3.3.4 / Rails 8, Sidekiq for background jobs
- Hotwire (Turbo + Stimulus) + Tailwind CSS + esbuild — no separate SPA
- PostgreSQL in dev/test, SQLite 3 + ICU in production
- Kamal + Docker for deployment, Thruster as reverse proxy

## Getting started

You need Ruby 3.3.4, PostgreSQL 11+, Node.js with Yarn, and `foreman`.

```bash
git clone https://github.com/vgartg/jammer.git
cd jammer
bundle install
yarn install
bundle exec rake db:create db:migrate
foreman start -f Procfile.dev
```

Open [localhost:3000](http://localhost:3000).

## Contributing

Pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup and workflow. Security issues go to [SECURITY.md](SECURITY.md) — not a public GitHub issue.
