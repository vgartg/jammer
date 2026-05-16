# Jammer

[![Ruby on Rails CI](https://github.com/vgartg/jammer/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/vgartg/jammer/actions/workflows/rubyonrails.yml)
[![Ruby](https://img.shields.io/badge/ruby-3.3.5-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/rails-8.0-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)

A platform for hosting game jams and distributing assets and games

## Awards & Recognition

- Winner of the **SFedU SBS Creative 2024** accelerator
- Recipient of a grant from the **Foundation for Assistance to Small Innovative Enterprises** (Innovation Promotion Fund)

## Requirements

- Ruby **3.3.5**

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
