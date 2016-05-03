#!/bin/bash

declare -a loads=('linear' 'lighter' 'light' 'moderate' 'heavy')
declare -a iodepths=('1' '4' '8' '64' '256')
declare -a bs=('256' '512' '1k' '2k' '4k' '8k' '16k' '32k' '64k' '128k' '256k' '512k' '1024k' '2048k' '4096k')  

function get_iodepth_from_load {
	for (( i = 0; i < ${#loads[@]}; i++ )); do
		if [ "${loads[$i]}" = "$1" ]; then
			echo ${iodepths[$i]}
		fi
	done
}

# Defaults for the original iometer jobfile
LOAD=${1-linear}
SIZE=${2-4g}

IODEPTH=$(get_iodepth_from_load $LOAD)
echo "Running with $LOAD load (iodepth $IODEPTH) and size $SIZE"

fio --time_based \
	--clocksource=clock_gettime \
	--rw=randread \
	--random_distribution=pareto:0.9 \
	--size=10g \
	--filename=/dev/ram0 \
	--iodepth=$IODEPTH \
	--size=$SIZE \
	--bs='8k' \
	--name='throw_away' \
	--runtime=300

for (( i = 0; i < ${#bs[@]}; i++ )); do
	BS=${bs[$i]}
	NAME=test${bs[$i]}
	fio --time_based \
		--clocksource=clock_gettime \
		--rw=randread \
		--random_distribution=pareto:0.9 \
		--size=10g \
		--filename=/dev/ram0 \
		--iodepth=$IODEPTH \
		--size=$SIZE \
		--bs=$BS \
		--name=$NAME \
		--runtime=60
done