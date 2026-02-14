#!/bin/bash

# Export script for Bangumi iOS archive
# Usage: ./export.sh [archive_path] [export_options_plist] [destination] [--keep-archive]

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$PROJECT_ROOT/.env" ]; then
  echo -e "${GREEN}Loading environment variables from .env${NC}"
  set -a
  source "$PROJECT_ROOT/.env"
  set +a
elif [ -f "$SCRIPT_DIR/.env" ]; then
  echo -e "${GREEN}Loading environment variables from .env${NC}"
  set -a
  source "$SCRIPT_DIR/.env"
  set +a
fi

KEEP_ARCHIVE=false
ARCHIVE_PATH=""
EXPORT_OPTIONS=""
DEST_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep-archive)
      KEEP_ARCHIVE=true
      shift
      ;;
    *)
      if [ -z "$ARCHIVE_PATH" ]; then
        ARCHIVE_PATH="$1"
      elif [ -z "$EXPORT_OPTIONS" ]; then
        EXPORT_OPTIONS="$1"
      elif [ -z "$DEST_DIR" ]; then
        DEST_DIR="$1"
      fi
      shift
      ;;
  esac
done

EXPORT_OPTIONS="${EXPORT_OPTIONS:-$SCRIPT_DIR/exportOptions.ios.plist}"
DEST_DIR="${DEST_DIR:-$PROJECT_ROOT/exports}"

if [ -z "$ARCHIVE_PATH" ]; then
  echo -e "${RED}Error: archive path is required${NC}" >&2
  echo "Usage: ./export.sh [archive_path] [export_options_plist] [destination] [--keep-archive]" >&2
  exit 1
fi

if [ ! -d "$ARCHIVE_PATH" ]; then
  echo -e "${RED}Error: archive not found at '$ARCHIVE_PATH'${NC}" >&2
  exit 1
fi

if [ ! -f "$EXPORT_OPTIONS" ]; then
  echo -e "${RED}Error: export options plist not found at '$EXPORT_OPTIONS'${NC}" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
EXPORT_PATH="$DEST_DIR/export_${TIMESTAMP}"

declare -a AUTH_ARGS=()
if [ -n "${APP_STORE_CONNECT_API_KEY_PATH:-}" ]; then
  if [ ! -f "$APP_STORE_CONNECT_API_KEY_PATH" ]; then
    echo -e "${RED}Error: API key file not found at '$APP_STORE_CONNECT_API_KEY_PATH'${NC}" >&2
    exit 1
  fi
  if [ -z "${APP_STORE_CONNECT_API_ISSUER_ID:-}" ] || [ -z "${APP_STORE_CONNECT_API_KEY_ID:-}" ]; then
    echo -e "${RED}Error: APP_STORE_CONNECT_API_ISSUER_ID and APP_STORE_CONNECT_API_KEY_ID are required${NC}" >&2
    exit 1
  fi
  AUTH_ARGS+=(
    -authenticationKeyPath "$APP_STORE_CONNECT_API_KEY_PATH"
    -authenticationKeyID "$APP_STORE_CONNECT_API_KEY_ID"
    -authenticationKeyIssuerID "$APP_STORE_CONNECT_API_ISSUER_ID"
  )
fi

echo -e "${GREEN}Starting export...${NC}"
echo "Archive: $ARCHIVE_PATH"
echo "Export options: $EXPORT_OPTIONS"
echo "Export path: $EXPORT_PATH"

echo -e "${YELLOW}Exporting archive...${NC}"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -quiet \
  "${AUTH_ARGS[@]}"

echo -e "${GREEN}[OK] Export completed successfully${NC}"

shopt -s nullglob
for file in "$EXPORT_PATH"/*.ipa; do
  if [ -e "$file" ]; then
    target="$EXPORT_PATH/Bangumi-iOS.ipa"
    if [ "$(basename "$file")" != "Bangumi-iOS.ipa" ]; then
      mv "$file" "$target"
      echo -e "${GREEN}Renamed $(basename "$file") -> Bangumi-iOS.ipa${NC}"
    fi
  fi
done
shopt -u nullglob

echo "Export location: $EXPORT_PATH"
ls -lh "$EXPORT_PATH"

if [ "$KEEP_ARCHIVE" = false ]; then
  echo -e "${YELLOW}Deleting archive...${NC}"
  rm -rf "$ARCHIVE_PATH"
  echo -e "${GREEN}[OK] Archive deleted${NC}"
else
  echo -e "${YELLOW}Archive kept at: $ARCHIVE_PATH${NC}"
fi
