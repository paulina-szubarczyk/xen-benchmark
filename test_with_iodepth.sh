#!/bin/bash

declare -a iodepths=('1' '4' '8' '64' '256')
declare -a bs=('512' '1k' '2k' '4k' '8k' '16k' '32k' '64k' '128k' '256k' '512k' '1024k' '2048k' '4096k')  

function warm_up {
    echo "warm up filename $FILENAME runtime $WARMUP_RUNTIME iodepth $IODEPTH"
    fio --time_based \
	    --clocksource=clock_gettime \
	    --rw=randread \
	    --random_distribution=pareto:0.9 \
	    --size=10g \
	    --direct='1' \
	    --ioengine=libaio \
	    --filename=$DEV \
	    --iodepth=$IODEPTH \
	    --bs='8k' \
	    --name='throw_away' \
	    --runtime=$RUNTIME > $FILENAME
}

function test_with_block_size {

    BS=$1
	NAME=test"$1"
    echo "block size $BS test name $NAME filename $FILENAME runtime $RUNTIME iodepth $IODEPTH"
    fio --time_based \
		--clocksource=clock_gettime \
		--rw=randread \
		--random_distribution=pareto:0.9 \
		--size=10g \
	    	--direct='1' \
	    	--ioengine=libaio \
		--filename=$DEV \
		--iodepth=$IODEPTH \
		--bs=$BS \
		--name=$NAME \
		--runtime=$RUNTIME >> $FILENAME
}

function format {

    cat $FILENAME | grep ' lat ([u,m]sec):' | grep -o 'avg= *[0-9]*.[0-9]*' > $LATENCY
    cat $FILENAME | grep -o 'aggrb=[0-9]*.[0-9]*[K,M,G]B' > $BANDWITH
    cat $FILENAME | grep -o 'iops=[0-9]*' > $IOPS

    sed -i 's/avg=//g' $LATENCY
    sed -i 's/aggrb=//g' $BANDWITH
    sed -i 's/MB//g' $BANDWITH
    sed -i 's/iops=//g' $IOPS
    
    sed -i '1d' $LATENCY
    sed -i '1d' $BANDWITH
    sed -i '1d' $IOPS
}

# Defaults for the original iometer jobfile
DEV="/dev/xvda"

WARMUP_RUNTIME=300
RUNTIME=60

for (( j = 0; j < ${#iodepths[@]}; j++)); do
    IODEPTH=${iodepths[j]}
    DIR='results/'$(date +%s)$RANDOM'_'$IODEPTH
    FILENAME=$DIR'/suse_grant_copy_with_buf'
    LATENCY=$FILENAME'_latency'
    BANDWITH=$FILENAME'_bandw'
    IO=$FILENAME'_io'
    IOPS=$FILENAME'_iops'
    echo "write to $FILENAME, $LATENCY, $BANDWITH, $IO, $IOPS"

    mkdir "$DIR"

    warm_up
    for (( i = 0; i < ${#bs[@]}; i++ )); do
        test_with_block_size ${bs[$i]}
    done
    format
done
