#!/bin/bash

# Upload exported artifact to App Store Connect using App Store Connect API key.
# Usage: ./upload.sh <artifact_path> [platform]

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <artifact_path> [platform]" >&2
  exit 1
fi

ARTIFACT_PATH="$1"
PLATFORM="${2:-ios}"

if [ ! -f "$ARTIFACT_PATH" ]; then
  echo "Artifact not found at '$ARTIFACT_PATH'" >&2
  exit 1
fi

if [ -z "${APP_STORE_CONNECT_API_KEY_PATH:-}" ]; then
  echo "Error: APP_STORE_CONNECT_API_KEY_PATH is required" >&2
  exit 1
fi

if [ ! -f "$APP_STORE_CONNECT_API_KEY_PATH" ]; then
  echo "Error: API key file not found at '$APP_STORE_CONNECT_API_KEY_PATH'" >&2
  exit 1
fi

if [ -z "${APP_STORE_CONNECT_API_KEY_ID:-}" ] || [ -z "${APP_STORE_CONNECT_API_ISSUER_ID:-}" ]; then
  echo "Error: APP_STORE_CONNECT_API_KEY_ID and APP_STORE_CONNECT_API_ISSUER_ID are required" >&2
  exit 1
fi

UPLOAD_TYPE="ios"
case "$PLATFORM" in
  macOS|macos)
    UPLOAD_TYPE="macos"
    ;;
  tvOS|tvos)
    UPLOAD_TYPE="appletvos"
    ;;
  iOS|ios)
    UPLOAD_TYPE="ios"
    ;;
  *)
    echo "Unknown platform '$PLATFORM'; defaulting upload type to ios"
    ;;
esac

echo "Uploading $ARTIFACT_PATH ($PLATFORM) to App Store Connect..."

xcrun altool --upload-app \
  -f "$ARTIFACT_PATH" \
  -t "$UPLOAD_TYPE" \
  --api-key "$APP_STORE_CONNECT_API_KEY_ID" \
  --api-issuer "$APP_STORE_CONNECT_API_ISSUER_ID" \
  --p8-file-path "$APP_STORE_CONNECT_API_KEY_PATH"

echo "[OK] Upload completed for $ARTIFACT_PATH"
