#!/bin/bash
cycles=0

while getopts ":f:sc:r:Sh" opt; do
	case "$opt" in
		s)
			silent=1
			;;
		h)
			echo "Usage: plotsense.sh [OPTION] [TARGET]"
			echo " -f [ARG],	Output log to file [ARG]"
			echo " -c [ARG],	Number of cycles, in [ARG] of cycles"
			echo " -r [ARG],	Duration of each cycle, in [ARG] seconds (Default: 1)"
			echo " -s,		Do not print output to the terminal"
			echo " -S,		Do not print header if output to file"
			echo " -h,		Print this usage information"
			printf "\n[TARGET] is a name from lm_sensors, for instance 'fan6'.\nIt must also be the name for an RPM, V(olts), or °C value.\nNumber of cycles (-c) must be an integer.\nDuration of each cycle can be a floating point number.\n"
			exit
			;;
		S)
			filefluff=1
			;;
		f)
			outputfile="$OPTARG"
			;;
		r)
			spacetime="$OPTARG"
			;;
		c)
			durationvar="$OPTARG"
			[[ "$OPTARG" =~ ^-?[0-9]+$ ]] || (echo "[ERROR]: "$OPTARG" Is not a integer." && exit 1)
			[[ $? != 0 ]] && exit $?
			;;
		\?)
			echo "Invalid option: -"$OPTARG"" >&2
			exit
			;;
		:)
			echo "-"$OPTARG" Requires an argument." >&2
			exit
			;;
	esac
done
shift $((OPTIND - 1))
[ "$#" = 0 ] && echo "[ERROR]: No arguments were supplied. Try -h for a list of acceptable syntax." && exit

targetarg="$1"
function measurementfield1 {
	sensors | awk -v targetarg="$targetarg" '$0 ~ targetarg{print}' | awk -F: '//{print $2}' | awk '//{print $1}' | sed 's/+//g'
}
function awkvalue {
	sensors | awk -v targetarg="$targetarg" '$0 ~ targetarg{print}' | awk -F: '//{print $2}' | awk '//{print $1" "$2}' | sed 's/+//g'
}
function measurementlastchar {
	echo "$(awkvalue)" | sed -e 's/\(^.*\)\(.$\)/\2/'
}

nonrpmvmeasurement=$(measurementfield1 | awk '{print substr($0,length($0),1)}')
if [ "$nonrpmvmeasurement" = 'C' ] ; then
	function awkvalue {
		measurementfield1
	}
elif [ "$(measurementlastchar)" = 'M' ] ; then
	true
elif [ "$(measurementlastchar)" = 'V' ] ; then
	true
else
	echo "[ERROR]: Multiple, or invalid target(s)."
	exit
fi

[ -z "$spacetime" ] && spacetime=1
[ -w "$outputfile" ] && rm "$outputfile" || ([ -e "$outputfile" ] && (echo "$outputfile" not writable. ; kill $$))
[ -z $silent ] && (echo "Starting log:")

if [ -n "$filefluff" ] && [ -n "$outputfile" ] ; then
echo "# Made with plotsense.sh" >> "$outputfile"
echo "# Target was: "$targetarg"" >> "$outputfile"
[ -n "$durationvar" ] && echo "# Number of cycles: "$durationvar"" >> "$outputfile"
echo "# Cycle duration: "${spacetime}"s" >> "$outputfile"
printf "\nCycles	Value\n" >> "$outputfile"
fi

while true
do
	[ -n "$durationvar" ] && [ "$cycles" -eq "$durationvar" ] && echo "Completed final cycle." && exit
	value=$(awkvalue)
	[ -n "$outputfile" ] && echo "$cycles	$value" >> "$outputfile"
	if [ -z "$silent" ] ; then
		[ "$cycles" -eq 0 ] && echo "Cycles	Value"
		echo "$cycles	$value"
	fi
	let cycles="$cycles"+1
	sleep "$spacetime"s
done &

while read -sn 1 QUIT && [[ "$QUIT" != 'q' ]];
do
	true
done

kill %1
