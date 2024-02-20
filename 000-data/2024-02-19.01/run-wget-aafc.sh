#!/bin/bash

AAFC_FILES=( \
    # Terrestrial Ecoprovinces of Canada - Pre-packaged GeoJSON files
    "https://agriculture.canada.ca/atlas/data_donnees/nationalEcologicalFramework/data_donnees/geoJSON/ep/nef_ca_ter_ecoprovince_v2_2.geojson" \
    )

for tempfile in "${AAFC_FILES[@]}"
do
    echo
    echo downloading: ${tempfile}
    wget ${tempfile}
done
echo
