#!/bin/bash

# Release script for Bangumi iOS
# Usage: ./release.sh [--show-in-organizer] [--skip-export] [--skip-upload]

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

SHOW_IN_ORGANIZER=false
SKIP_EXPORT=false
SKIP_UPLOAD=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --show-in-organizer)
      SHOW_IN_ORGANIZER=true
      shift
      ;;
    --skip-export)
      SKIP_EXPORT=true
      shift
      ;;
    --skip-upload)
      SKIP_UPLOAD=true
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}" >&2
      echo "Usage: ./release.sh [--show-in-organizer] [--skip-export] [--skip-upload]" >&2
      exit 1
      ;;
  esac
done

ARCHIVES_DIR="$PROJECT_ROOT/archives"
EXPORTS_DIR="$PROJECT_ROOT/exports"
EXPORT_OPTIONS_IOS="$SCRIPT_DIR/exportOptions.ios.plist"

if [ "$SKIP_EXPORT" = false ] && [ ! -f "$EXPORT_OPTIONS_IOS" ]; then
  echo -e "${RED}Error: export options plist not found at '$EXPORT_OPTIONS_IOS'${NC}" >&2
  exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Bangumi iOS Release${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "${GREEN}Step 1: Archive${NC}"
TEMP_OUTPUT=$(mktemp)

if [ "$SHOW_IN_ORGANIZER" = true ]; then
  "$SCRIPT_DIR/archive.sh" --show-in-organizer 2>&1 | tee "$TEMP_OUTPUT"
else
  "$SCRIPT_DIR/archive.sh" "$ARCHIVES_DIR" 2>&1 | tee "$TEMP_OUTPUT"
fi

ARCHIVE_PATH=$(grep "Archive location:" "$TEMP_OUTPUT" | sed 's/.*Archive location: //' | tail -n 1 | tr -d '\r')
rm -f "$TEMP_OUTPUT"

if [ -z "$ARCHIVE_PATH" ] || [ ! -d "$ARCHIVE_PATH" ]; then
  SEARCH_DIR="$ARCHIVES_DIR"
  if [ "$SHOW_IN_ORGANIZER" = true ]; then
    SEARCH_DIR="$HOME/Library/Developer/Xcode/Archives/$(date +"%Y-%m-%d")"
  fi
  ARCHIVE_PATH=$(find "$SEARCH_DIR" -maxdepth 1 -type d -name "Bangumi-iOS_*.xcarchive" | sort | tail -n 1 || true)
fi

if [ -z "$ARCHIVE_PATH" ] || [ ! -d "$ARCHIVE_PATH" ]; then
  echo -e "${RED}Error: unable to locate generated archive${NC}" >&2
  exit 1
fi

echo -e "${GREEN}[OK] Archive ready: $ARCHIVE_PATH${NC}"

if [ "$SKIP_EXPORT" = true ]; then
  echo -e "${YELLOW}Skipping export and upload by request${NC}"
  exit 0
fi

echo -e "${GREEN}Step 2: Export${NC}"
"$SCRIPT_DIR/export.sh" "$ARCHIVE_PATH" "$EXPORT_OPTIONS_IOS" "$EXPORTS_DIR" --keep-archive

if [ "$SKIP_UPLOAD" = true ]; then
  echo -e "${YELLOW}Skipping upload by request${NC}"
  exit 0
fi

ARTIFACT_FILE=$(find "$EXPORTS_DIR" -type f -name "Bangumi-iOS.ipa" | sort | tail -n 1 || true)
if [ -z "$ARTIFACT_FILE" ]; then
  ARTIFACT_FILE=$(find "$EXPORTS_DIR" -type f -name "*.ipa" | sort | tail -n 1 || true)
fi

if [ -z "$ARTIFACT_FILE" ] || [ ! -f "$ARTIFACT_FILE" ]; then
  echo -e "${RED}Error: exported ipa not found in '$EXPORTS_DIR'${NC}" >&2
  exit 1
fi

echo -e "${GREEN}Step 3: Upload${NC}"
"$SCRIPT_DIR/upload.sh" "$ARTIFACT_FILE" "iOS"

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Release Summary${NC}"
echo "  Archive: $ARCHIVE_PATH"
echo "  Export dir: $EXPORTS_DIR"
echo "  Uploaded artifact: $ARTIFACT_FILE"
echo -e "${GREEN}[OK] Release process completed${NC}"
