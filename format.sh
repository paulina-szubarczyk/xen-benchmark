#!/bin/bash

declare -a iodepths=('1' '4' '8' '64' '256')
declare -a format=('latency' 'iops' 'bandw')

DIR=results_new

for (( f=0; f < ${#format[@]}; f++ )); do
	RESULT=$DIR/${format[f]}
	
	echo "" > $RESULT
	for (( i=0; i < ${#iodepths[@]}; i++ )); do
		FILENAME=$DIR/${iodepths[i]}_${format[f]}
		RESULTS=$DIR/iodepth_${iodepths[i]}
		RESULTS_NAME="iodepth="${iodepths[i]}
		ls $DIR/*_${iodepths[i]}/*_${format[f]} > $FILENAME
		./collapse $FILENAME $RESULTS ${format[f]}
		rm $FILENAME
		echo $RESULTS_NAME >> $RESULT
		cat $RESULTS >> $RESULT
		rm $RESULTS
	done
done
