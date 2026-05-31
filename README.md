# Jammer

[![Ruby on Rails CI](https://github.com/vgartg/jammer/actions/workflows/rubyonrails.yml/badge.svg)](https://github.com/vgartg/jammer/actions/workflows/rubyonrails.yml)
[![Ruby](https://img.shields.io/badge/ruby-3.3.4-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/rails-8.0-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.txt)

Платформа для геймджемов и дистрибуции игр. Работает на [jammer.website](https://jammer.website).

Создаёшь джем, настраиваешь критерии голосования, зовёшь жюри или открываешь для всех — дальше принимаешь заявки и следишь за таблицей результатов. Поверх этого работают профили, команды, уведомления и социальный слой.

---

Победитель акселератора **SFedU SBS Creative 2024**, грант от **Фонда содействия инновациям**.

---

## Что умеет

**Джемы** — гибкое расписание (регистрация / прием работ / голосование — отдельные даты), несколько критериев с разными режимами (звёздный рейтинг или «один голос за игру»), жюри и публика голосуют независимо, номинации с победителями.

**Игры** — публикация, теги, обложки, рейтинги от сообщества, подача на модерацию.

**Команды** — создание команды, приглашения, заявки на вступление, роли участников.

**Профили** — персональные страницы `/u/username`, достижения, статистика активности, история участия в джемах.

**Ассеты** — загрузка и раздача файлов (звуки, графика, шрифты) с возможностью скачивания.

**Социальный слой** — друзья, уведомления внутри приложения, заморозка/разморозка аккаунтов с логом администратора.

**Авторизация** — email + подтверждение, сброс пароля, OAuth через GitHub и Google, постоянные сессии.

## Стек

- Ruby 3.3.4 / Rails 8, Sidekiq для фоновых задач
- Hotwire (Turbo + Stimulus) + Tailwind CSS + esbuild — без отдельного SPA
- PostgreSQL в dev/test, SQLite 3 + ICU в проде
- Kamal + Docker для деплоя, Thruster как reverse proxy

## Запустить локально

Нужны Ruby 3.3.4, PostgreSQL 11+, Node.js с Yarn и `foreman`.

```bash
git clone https://github.com/vgartg/jammer.git
cd jammer
bundle install
yarn install
bundle exec rake db:create db:migrate
foreman start -f Procfile.dev
```

Открывай [localhost:3000](http://localhost:3000).

## Участие в разработке

PR приветствуются. Детали — в [CONTRIBUTING.md](CONTRIBUTING.md). Уязвимости — на [SECURITY.md](SECURITY.md), не в публичный issue.
