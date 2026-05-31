# Участие в разработке

## Настройка

```bash
git clone https://github.com/vgartg/jammer.git
cd jammer
bundle install
yarn install
bundle exec rake db:create db:migrate
foreman start -f Procfile.dev
```

Запускает Rails-сервер и сборку ассетов в режиме watch. Приложение будет на [localhost:3000](http://localhost:3000).

База данных для dev/test — PostgreSQL. Убедись, что он запущен и доступен до `db:create`.

## Как работать

Форкни репо, создай ветку от `master`:

```bash
git checkout -b short-description
```

Коммиты делай небольшими и по одному изменению за раз. Перед PR прогони то же, что запускает CI:

```bash
bundle exec rails test
bundle exec bundler-audit --update
bundle exec brakeman -q
bundle exec rubocop
```

Потом открывай PR в `master` с описанием что и зачем поменял.

## Правила

- Стиль кода — RuboCop. Если линтер ругается, CI не пропустит.
- Миграции должны быть обратимы.
- Новую логику покрывай тестами. Без тестов скорее всего не заведём.
- Придерживайся стандартных Rails-конвенций по именованию и структуре файлов.

## Баги и идеи

Через [issue tracker](https://github.com/vgartg/jammer/issues). Для уязвимостей — сначала [SECURITY.md](SECURITY.md), в публичный issue уязвимости не пиши.
