#!/usr/bin/env bash
# Снимает скриншоты сторов: script/store_shots.sh <udid> <outdir> [locale]
# Требует integration_test/store_shots_test.dart (временный, не в git).
set -euo pipefail
UDID=$1; OUT=$2; LOC=${3:-en}
mkdir -p "$OUT"
xcrun simctl status_bar "$UDID" override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4
flutter test integration_test/store_shots_test.dart -d "$UDID" --flavor prod \
  --dart-define=environment=prod --dart-define=shotLocale="$LOC" 2>&1 | while read -r line; do
  case "$line" in
    *"SHOT "*) n=${line##*SHOT }; n=${n%%[^0-9]*}; sleep 1.5
      xcrun simctl io "$UDID" screenshot "$OUT/$n.png" >/dev/null 2>&1 && echo "shot $n";;
    *"WARM "*|*"All tests passed"*|*"Some tests failed"*|*"Expected"*|*"Actual"*|*"reason"*) echo "$line";;
  esac
done
