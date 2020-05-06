[![Build and Deploy](https://github.com/irclogs/elm-0.19/workflows/Build%20and%20Deploy/badge.svg)](https://github.com/irclogs/elm-0.19/actions)

# `Irclog CouchApp`
### a web app to view irclogs (elm 0.19 edition)

The logs are stored in couchdb.

The single page web app is written in angular and stored as a
[couchapp](https://github.com/irclogs/couchapp)
in couchdb attachments.

## Quick start - for developers

Install elm, run `elm make src/Main.elm` and `elm reactor`.

> The public server has localhost:8000 allowed for CORS requests, so running on port 8000
> will make the api available

## Production

```
mkdir ./dist
elm make --optimize --output dist/index.html src/Main.elm
```
the release is in `./dist`
