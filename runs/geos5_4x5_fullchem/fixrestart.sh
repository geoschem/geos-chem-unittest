#!/bin/bash

# Replace time s
ncap2 -O -h -s 'time[time]={184080,249792}; time@standard_name="Time"; time@long_name="Time"; time@units="hours since 1985-01-01 00:00:00"; time@calendar="standard"' $1 tmp.nc


# Compress and rename file
nccopy -d1 tmp.nc $1

exit 0
