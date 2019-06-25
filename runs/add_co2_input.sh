#!/bin/bash

for dir in */; do
	cd $dir
	sed -i '/Wet Deposition/a Turn on CO2 Effect?     : F\nCO2 level               : 600.0\nReference CO2 level     : 380.0' input.geos.template
	cd ..
done
