#!/usr/bin/env bash
set -euo pipefail

# Requires ImageMagick and Liberation Sans. The portrait is never generated.
artwork_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(cd -- "$artwork_dir/../.." && pwd)
render_tmp=$(mktemp -d)
trap 'rm -rf -- "$render_tmp"' EXIT

# Trace the photograph's silhouette by hand; feather only its boundary.
magick -size 660x1050 xc:black -fill white -stroke none -draw \
  "path 'M 225,130 C 225,100 246,86 262,78 L 276,60 L 284,38 L 310,27 L 340,32 C 365,35 389,53 397,81 L 408,110 L 405,148 L 398,175 L 398,210 L 388,243 L 377,263 L 383,288 C 415,307 481,306 507,332 C 530,375 532,427 541,480 L 553,551 L 558,655 L 560,773 L 554,850 L 552,898 C 549,940 521,969 490,973 L 490,1050 L 152,1050 L 153,988 C 130,982 109,966 99,943 L 98,906 L 106,858 L 105,804 L 108,720 L 119,656 L 132,586 L 132,505 L 141,424 L 152,367 C 160,344 178,344 202,337 L 250,314 L 271,292 L 270,265 L 255,240 L 249,209 L 237,202 L 234,175 Z'" \
  -blur 0x2 "$render_tmp/outline.png"
magick -size 660x1050 gradient:white-black \
  -fx 'j < 760 ? 1 : max(0,1-(j-760)/260)' "$render_tmp/fade.png"
magick "$render_tmp/outline.png" "$render_tmp/fade.png" \
  -compose Multiply -composite "$render_tmp/mask.png"

# Ordinary grayscale/duotone and Lanczos resizing preserve the recorded face,
# expression, clothing and scan imperfections. No AI restoration or retouching.
magick -size 1x256 gradient:'#27241f-#e1d5c2' "$render_tmp/palette.png"
magick "$artwork_dir/source.jpg" -crop 660x1050+790+920 +repage \
  -colorspace Gray -colorspace sRGB "$render_tmp/palette.png" -clut \
  "$render_tmp/mask.png" -alpha off -compose CopyOpacity -composite \
  -filter Lanczos -resize 2100x3341 "$render_tmp/portrait.png"
magick "$artwork_dir/background.png" -filter Lanczos -resize 6144x4096! \
  "$render_tmp/portrait.png" -geometry +2022+290 -compose Over -composite \
  -font Liberation-Sans-Bold -pointsize 210 -fill '#1d1b17' \
  -gravity northwest -annotate +285+3550 'GRACE HOPPER' \
  -font Liberation-Sans -pointsize 48 -kerning 15 -fill '#7a6c5b' \
  -annotate +292+3870 'EARLY COMPUTING  •  COMPILERS  •  COBOL' \
  -sampling-factor 4:4:4 -quality 95 \
  "$artwork_dir/photographic-composite.jpg"
