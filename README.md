# Vincent's Profile App — Unit 8

This Flutter app contains Vincent John Tamaño's profile, pet, gallery, and
My Shelf features. My Shelf includes Contentful picks, Open Library book
search, and OMDb movie search.

## Local development

Run without secrets to use the app's local fallback data:

```bash
flutter pub get
flutter run
```

For live CMS and OMDb data, provide values at runtime:

```bash
flutter run \
  --dart-define=OMDB_KEY=your_omdb_key \
  --dart-define=CMS_SPACE_ID=your_contentful_space \
  --dart-define=CMS_TOKEN=your_contentful_delivery_token \
  --dart-define=CMS_ENV=master
```

Do not commit API keys or CMS tokens. Regenerate any credentials that were
previously shared in source code or chat.

## Checks

```bash
flutter test
flutter build web --release
```

For Android release evidence, use:

```bash
flutter build apk --release \
  --dart-define=OMDB_KEY=your_omdb_key \
  --dart-define=CMS_SPACE_ID=your_contentful_space \
  --dart-define=CMS_TOKEN=your_contentful_delivery_token \
  --dart-define=CMS_ENV=master
flutter build apk --debug
```

The Android Gradle path-check override is enabled because this project is
stored under a Windows path containing `ñ`. Moving the project to an
ASCII-only path is still the more reliable option for Android builds.

## GitHub Pages deployment

The workflow in `.github/workflows/deploy.yml` runs tests and deploys the
release web build on pushes to `main`.

Configure these GitHub Actions values before pushing:

- Secret: `OMDB_KEY`
- Secret: `CMS_TOKEN`
- Variable: `CMS_SPACE_ID`
- Variable: `CMS_ENV` (set to `master`)

Set GitHub Pages **Source** to **GitHub Actions**. The workflow supplies the
repository-specific base path automatically.

## Unit 8 release checklist

- Confirm the live web URL and test photos, sound, books, movies, and My Picks.
- Build the Android release and debug APKs with the same `--dart-define` values.
- Install the release APK on a phone and verify version `1.1.0`.
- Compare the generated APK sizes in
  `build/app/outputs/flutter-apk/`.
- Search the release JavaScript for the OMDb key and document why a client-side
  key is not secret; a server-side proxy is safer for production.

## Key security note

The OMDb key is passed into the web build, so it can be extracted from the
generated JavaScript by anyone who can access the site. Someone could use the
key against the OMDb API until its quota is exhausted or the key is revoked.
Regenerate exposed keys and restrict or monitor their usage where possible.
For production, call OMDb through a server-side proxy so the browser never
receives the key.
