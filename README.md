# App

## Getting started

You need to have [Elm](http://elm-lang.org/) 0.18 installed on your machine.

Compile:

    elm make src/Main.elm --output public/main.js

Make resources available offline:

    sw-precache --config=sw-precache.json

## TODOS

- touchstart + touchmove filtered by **RxJS** ...then sendto Elm port
  https://github.com/Reactive-Extensions/RxJS/blob/master/doc/gettingstarted/querying.md

- info-page if not authorized/active (instead of alert)
- access user's DB node from Elm and render liste

- pass something more useful than Bool into Elm (Flags)
- on-/offline events into Elm + reload without cache; update to 0.18: https://github.com/stoeffel/elm-online
