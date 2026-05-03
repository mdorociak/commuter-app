# Commuter App

An iOS commuter companion for the Brzeg → Wrocław/Opole train commute. Combines Koleje Dolnośląskie (KD) train schedules and real-time delays with MPK Wrocław city transit connections, so you can see not just when the next train leaves but whether you'll still catch your tram at the other end.

Portfolio project. The goal is to demonstrate architectural maturity (enum-based navigation, domain/API model separation, closure-based DI, tiered caching) and a proper testing story (unit tests alongside features, integration tests on the backend, Maestro UI tests on the app).

## Repo layout

```
commuter-app/
├── backend/   FastAPI service that parses GTFS and exposes a normalized REST API
└── ios/       SwiftUI app (coming in milestone 2)
```

## Status

Milestone 1 in progress: backend skeleton + KD static GTFS parsing.

See `backend/README.md` for running the backend locally.
