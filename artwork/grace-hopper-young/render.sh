#!/usr/bin/env bash
set -euo pipefail

# Export the retained AI-refined plate with exact series typography.
# Requires ImageMagick and Liberation Sans; this does not call a model.
artwork_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$artwork_dir/../.." && pwd)
magick "$artwork_dir/refined.png" -filter Lanczos -resize 6144x4096! \
  -font Liberation-Sans-Bold -pointsize 210 -fill '#1d1b17' \
  -gravity northwest -annotate +285+3550 'GRACE HOPPER' \
  -font Liberation-Sans -pointsize 48 -kerning 15 -fill '#7a6c5b' \
  -annotate +292+3870 'EARLY COMPUTING  •  COMPILERS  •  COBOL' \
  -sampling-factor 4:4:4 -quality 95 \
  "$repo_dir/backgrounds/16-grace-hopper-young.jpg"
