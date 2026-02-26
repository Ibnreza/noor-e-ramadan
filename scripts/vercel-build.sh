#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.27.0}"
FLUTTER_DIR="$HOME/flutter"

# Install a pinned Flutter SDK in Vercel build environment.
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release --base-href / --no-wasm-dry-run
