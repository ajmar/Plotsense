#!/bin/bash
cycles=0

while getopts ":f:sc:r:Sh" opt; do
	case $opt in
		s)
			silent=1
			;;
		h)
			echo "Usage: simpleplot.sh [OPTION]"
			echo " -f [ARG],	Output log to file [ARG]"
			echo " -c [ARG],	Number of cycles, in [ARG] of cycles"
			echo " -r [ARG],	Duration of each cycle, in [ARG] seconds (Default: 1)"
			echo " -s,		Do not print output to the terminal"
			echo " -S,		Do not print header if output to file"
			echo " -h,		Print this usage information"
			printf "\nNumber of cycles (-c) must be an integer.\nDuration of each cycle can be a floating point number.\n"
			exit
			;;
		S)
			filefluff=1
			;;
		f)
			outputfile=$OPTARG
			;;
		r)
			spacetime=$OPTARG
			;;
		c)
			durationvar=$OPTARG
			[[ $OPTARG =~ ^-?[0-9]+$ ]] || (echo "$OPTARG Is not a integer." & kill $$)
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			kill $$
			;;
		:)
			echo "-$OPTARG Requires an argument." >&2
			kill $$
			;;
	esac
done

[ -z "$spacetime" ] && spacetime=1 # Sets the default time between samples
[ -w "$outputfile" ] && rm "$outputfile" || ([ -e "$outputfile" ] && (echo "$outputfile" not writable. ; kill $$))
[ -z $silent ] && (echo "Starting log:")

if [ -n "$filefluff" ] ; then
echo "# Made with simpleplot.sh" >> $outputfile
echo "# Number of cycles: $durationvar" >> $outputfile
echo "# Cycle duration: ${spacetime}s" >> $outputfile
printf "\nCycles	Value\n" >> $outputfile
fi

while true
do
	[ -n "$durationvar" ] && [ "$cycles" -eq "$durationvar" ] && kill $$ # Once cycles are up, terminate
	value=$(sensors | awk '/^SMBUSMASTER/{print $3}' | sed 's/+//g') # Grab value from lm_sensors
	[ -n "$outputfile" ] && echo "$cycles	$value" >> "$outputfile" # Append value to file
	if [ -z "$silent" ] ; then
		[ "$cycles" -eq 0 ] && echo "Cycles	Value"
		echo "$cycles	$value"
	fi
	let cycles="$cycles"+1
	sleep "$spacetime"s
done &

while read -sn 1 QUIT && [[ $QUIT != 'q' ]];
do
	true
done

kill %1
