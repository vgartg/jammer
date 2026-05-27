# Jammer

[![Ruby on Rails CI](https://github.com/vgartg/jammer/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/vgartg/jammer/actions/workflows/rubyonrails.yml)
[![Ruby](https://img.shields.io/badge/ruby-3.3.4-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/rails-8.0-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Jammer is a platform for running game jams and distributing games. You set up a jam, configure voting criteria, invite judges or open it to everyone - then collect submissions and watch the leaderboard take shape. Profiles, notifications, and friend connections work on top of that.

Live at [jammer.website](https://jammer.website).

## Recognition

- Winner of the **SFedU SBS Creative 2024** accelerator
- Grant from the **Foundation for Assistance to Small Innovative Enterprises** (Innovation Promotion Fund)

---

<img width="1424" height="735" alt="Jammer platform screenshot" src="https://github.com/user-attachments/assets/eb324acf-299d-411e-85f0-3e5ce506488c" />

---

## Features

- **Game jams** - custom criteria, jury + audience voting modes, nomination awards, flexible scheduling
- **Game distribution** - publish your game, collect ratings and community feedback
- **Social layer** - friend requests, in-app notifications, personal profiles with custom subdomains
- **Moderation** - admin and moderator dashboards, content reports, user freeze/unfreeze with audit logs
- **Auth** - email confirmation, password reset, OAuth via GitHub and Google, persistent sessions

## Stack

- **Ruby 3.3.4 / Rails 8** with Sidekiq for background jobs
- **Hotwire** (Turbo + Stimulus) + Tailwind CSS + esbuild - no separate SPA
- **PostgreSQL** in dev/test, **SQLite 3 + ICU extension** in production
- **Kamal** + Docker for deployment, Thruster as a reverse proxy

## Getting started

You need Ruby 3.3.4, PostgreSQL 11+, Node.js with Yarn, and `foreman` (`gem install foreman`).

```bash
git clone https://github.com/vgartg/jammer.git
cd jammer
bundle install
yarn install
bundle exec rake db:create
bundle exec rake db:migrate
foreman start -f Procfile.dev
```

Open [localhost:3000](http://localhost:3000). That's it.

## Contributing

Pull requests are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) for setup details and workflow. Security issues go to [SECURITY.md](SECURITY.md) - not a public GitHub issue.
