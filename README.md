# ICSTSI

Flutter app scaffolded by agent-pm. **No host Flutter SDK needed** — the included `docker-compose.yml` runs `.flutter-watch.sh` inside the ghcr.io/cirruslabs/flutter:stable image. The script does `flutter build web --release` and then watches `lib/` + `pubspec.yaml` — every change triggers an incremental rebuild, so Developer-agent edits show up after a browser refresh.

## Run web preview

```bash
cp .env.example .env
# fill in real values
docker compose up
```

Open http://localhost:8080. Initial build is ~60–90s; incremental rebuilds ~5–15s.

## Wired data layer

- Direct Supabase via `supabase_flutter` — see `lib/main.dart`.

## iOS / Android

Run `flutter create --platforms=ios,android .` locally (requires Xcode / Android SDK) to regenerate the platform folders, then `flutter run -d ios` or `flutter run -d android`.
