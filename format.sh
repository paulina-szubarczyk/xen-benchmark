#!/bin/bash

declare -a iodepths=('1' '4' '8' '64' '256')
declare -a format=('latency' 'iops' 'bandw')

for (( f=0; f < ${#format[@]}; f++ )); do
	RESULT=results/${format[f]}
	
	echo "" > $RESULT
	for (( i=0; i < ${#iodepths[@]}; i++ )); do
		FILENAME=results/${iodepths[i]}_${format[f]}
		RESULTS=results/iodepth_${iodepths[i]}
		RESULTS_NAME="iodepth="${iodepths[i]}
		ls results/*_${iodepths[i]}/*_${format[f]} > $FILENAME
		./collapse $FILENAME $RESULTS ${format[f]}
		rm $FILENAME
		echo $RESULTS_NAME >> $RESULT
		cat $RESULTS >> $RESULT
		rm $RESULTS
	done
done
