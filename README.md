# Jammer

[![Ruby on Rails CI](https://github.com/vgartg/jammer/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/vgartg/jammer/actions/workflows/rubyonrails.yml)
[![Ruby](https://img.shields.io/badge/ruby-3.3.5-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/rails-8.0-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A platform for hosting game jams and distributing assets and games

## Awards & Recognition

- Winner of the **SFedU SBS Creative 2024** accelerator
- Recipient of a grant from the **Foundation for Assistance to Small Innovative Enterprises** (Innovation Promotion Fund)

---

<img width="1424" height="735" alt="image" src="https://github.com/user-attachments/assets/eb324acf-299d-411e-85f0-3e5ce506488c" />

---

## Features

- **Game jams** — create and run themed jams, submit entries, vote with multi-criterion judging
- **Game distribution** — publish games, collect ratings and reviews from the community
- **Social layer** — friendships, in-app notifications, user profiles
- **Moderation tools** — admin and moderator dashboards, content reporting workflow
- **Account essentials** — email confirmation, password reset, session management

## Tech Stack

- **Backend** — Ruby on Rails 8 with Sidekiq for background jobs
- **Frontend** — Hotwire (Turbo + Stimulus), Tailwind via cssbundling-rails, jsbundling-rails
- **Database** — PostgreSQL 11+
- **Mail & jobs** — Sidekiq, `whenever` for cron, `letter_opener` in development
- **Deploy** — Kamal, Thruster, Docker

## Requirements

- Ruby **3.3.5**
- PostgreSQL **11+**
- Node.js with Yarn
- `foreman` (`gem install foreman`)

## Getting Started

Clone the repository and install dependencies:

```bash
bundle install
yarn install
bundle exec rake db:create
bundle exec rake db:migrate
```

Start the web server together with the client build:

```bash
foreman start -f Procfile.dev
```

Or build the client without starting the server:

```bash
foreman start -f Procfile.front
```

## Contributing

Bug reports and pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for setup, workflow, and conventions. For security issues, please follow [SECURITY.md](SECURITY.md) instead of opening a public issue
