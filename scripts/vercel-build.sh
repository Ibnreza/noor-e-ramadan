#!/usr/bin/env bash
set -euo pipefail

# Install Flutter in Vercel build environment (if not already available)
if ! command -v flutter >/dev/null 2>&1; then
  git clone --depth 1 https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
fi

flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release --base-href /
