#!/usr/bin/env bash
#
# Generate CSV of volumes and QA PDF

# Defaults
export out_dir=/OUTPUTS
export label="Unknown scan"

# Parse inputs
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --out_dir)
        export out_dir="$2"; shift; shift;;
    --label)
        export label="$2"; shift; shift;;
    *)
		echo "Unknown argument $key"; shift;;
  esac
done

# Work in the outputs directory
cd "${out_dir}"

# Reformat volumes to single CSV
reformat_vols.sh

# Find center of mass of left thalamus
com=$(fslstats left/1-THALAMUS -c)
XYZ=(${com// / })

# Views
for sl in -7 -4 -1 2 5 8; do
    fsleyes render -of slice_${sl}.png \
        --scene ortho \
        --worldLoc ${XYZ[0]} ${XYZ[1]} $(echo ${XYZ[2]} + ${sl} | bc -l) \
        --layout horizontal --hideCursor --hideLabels --hidex --hidey \
        left/crop_t1 --overlayType volume \
        right/crop_t1 --overlayType volume \
        left/1-THALAMUS --overlayType label --lut random --outline --outlineWidth 1 \
        right/1-THALAMUS --overlayType label --lut random --outline --outlineWidth 1 \
        left/thomas --overlayType label --lut random --outline --outlineWidth 2 \
        right/thomasr --overlayType label --lut random --outline --outlineWidth 2
done

# Combine into single image
montage -mode concatenate \
    slice_-7.png slice_-4.png slice_-1.png slice_2.png slice_5.png slice_8.png \
    -tile 2x3 -trim -quality 100 -background black -gravity center \
    -border 20 -bordercolor black slices.png

# Resize and add text annotations. We choose a large but not ridiculous
# pixel size for the full page.
convert \
    -size 2600x3365 xc:white \
    -gravity center \( slices.png -resize x2900 \) -composite \
    -gravity NorthEast -pointsize 48 -annotate +100+100 "THOMAS Segmentation (radiological view)" \
    -gravity SouthEast -pointsize 48 -annotate +100+100 "$(date)" \
    -gravity NorthWest -pointsize 48 -annotate +100+100 "${label}" \
    page1.png

# Convert to PDF
convert page1.png thomas.pdf


