froem # Jammer

Проект по созданию сервиса для проведения гейм-джемов и дистрибуции ассетов и игр.

## Инструкции по установке

* Версия Ruby - 3.3.5

Чтобы подготовить проект к запуску локально, нужно сделать следующее:

```bash
bundle install
yarn install
bundle exec rake db:create
bundle exec rake db:migrate
```

Для запуска web-сервера и сборки клиента нужно выполнить:
```bash
foreman start -f Procfile.dev
```

Для cборки клиента без запуска сервера нужно выполнить:
```bash
foreman start -f Procfile.front
```
