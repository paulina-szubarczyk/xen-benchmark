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

function warm_up {
    echo "warm up filename $FILENAME runtime $WARMUP_RUNTIME"
    fio --time_based \
	    --clocksource=clock_gettime \
	    --rw=randread \
	    --random_distribution=pareto:0.9 \
	    --filename=$DEV \
	    --iodepth=$IODEPTH \
	    --size=$SIZE \
	    --bs='4k' \
	    --name='throw_away' \
	    --runtime=$RUNTIME > $FILENAME
}

function test_with_block_size {
	BS=$1
	NAME=test"$1"
	echo "block size $BS test name $NAME filename $FILENAME runtime $RUNTIME"
	fio --time_based \
		--clocksource=clock_gettime \
		--rw=randread \
		--random_distribution=pareto:0.9 \
		--filename=$DEV \
		--iodepth=$IODEPTH \
		--size=$SIZE \
		--bs=$BS \
		--name=$NAME \
		--runtime=$RUNTIME >> $FILENAME
}

function format {

    cat $FILENAME | grep ' lat (usec):' | grep -o 'avg= *[0-9]*.[0-9]*' > $LATENCY
    cat $FILENAME | grep -o 'aggrb=[0-9]*.[0-9]*[K,M]B' > $BANDWITH
    cat $FILENAME | grep -o 'READ: io=[0-9]*.[0-9]*[K,M]B' > $IO
    cat $FILENAME | grep -o 'iops=[0-9]*' > $IOPS

    sed -i 's/avg=//g' $LATENCY
    sed -i 's/aggrb=//g' $BANDWITH
    sed -i 's/MB//g' $BANDWITH
    sed -i 's/READ: io=//g' $IO
    sed -i 's/MB//g' $IO
    sed -i 's/iops=//g' $IOPS
    
    sed -i '1d' $LATENCY
    sed -i '1d' $BANDWITH
    sed -i '1d' $IO
    sed -i '1d' $IOPS
}

# Defaults for the original iometer jobfile
DEV="/dev/xvda"

LOAD=${1-moderate}
SIZE=${2-4g}
IODEPTH=$(get_iodepth_from_load $LOAD)
echo "Running with $LOAD load (iodepth $IODEPTH) and size $SIZE"

DIR='results/'$(date +%s)$RANDOM'_'$IODEPTH
FILENAME=$DIR'/suse'
LATENCY=$FILENAME'_latency'
BANDWITH=$FILENAME'_bandw'
IO=$FILENAME'_io'
IOPS=$FILENAME'_iops'
echo "write to $FILENAME, $LATENCY, $BANDWITH, $IO, $IOPS"

mkdir "$DIR"

WARMUP_RUNTIME=300
RUNTIME=60
warm_up

for (( i = 0; i < ${#bs[@]}; i++ )); do
    test_with_block_size ${bs[$i]}
done

format 
