#!/bin/bash

# Prepare iOS release artifact for GitHub Release
# Usage: ./artifacts.sh [source_dir] [dest_dir] [platform]

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE_DIR="${1:-$PROJECT_ROOT/exports}"
DEST_DIR="${2:-$PROJECT_ROOT/artifacts}"
PLATFORM="${3:-ios}"

if [ "$PLATFORM" != "ios" ]; then
  echo -e "${RED}Error: only ios platform is supported in Bangumi artifacts script${NC}" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"

echo -e "${BLUE}Preparing iOS release artifact...${NC}"

ARTIFACT_FILE=$(find "$SOURCE_DIR" -type f -name "Bangumi-iOS.ipa" | sort | tail -n 1 || true)
if [ -z "$ARTIFACT_FILE" ]; then
  ARTIFACT_FILE=$(find "$SOURCE_DIR" -type f -name "*.ipa" | sort | tail -n 1 || true)
fi

if [ -z "$ARTIFACT_FILE" ] || [ ! -f "$ARTIFACT_FILE" ]; then
  echo -e "${RED}No .ipa artifact found in $SOURCE_DIR${NC}" >&2
  exit 1
fi

TARGET_PATH="$DEST_DIR/Bangumi-iOS.ipa"
cp "$ARTIFACT_FILE" "$TARGET_PATH"

echo -e "${GREEN}[OK] Copied $(basename "$ARTIFACT_FILE") -> Bangumi-iOS.ipa${NC}"
ls -lh "$DEST_DIR"
