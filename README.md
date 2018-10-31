# Plotsense
A bash script / program that records an output from lm_sensors (Temperature, RPM, Volts) into a file and/or the shell, with a configurable cycle duration &amp; total duration. Intended for benchmarking CPU temperatures, Fan speed, and Voltages. POSIX compatible, written in Bash.

# Usage
```
plotsense.sh [OPTION] [TARGET]
  -f [ARG],	Output log to file [ARG]
  -c [ARG],	Number of cycles, in [ARG] of cycles (Default: Infinite)
  -r [ARG],	Duration of each cycle, in [ARG] seconds (Default: 1)
  -s,		Do not print output to the terminal
  -S,		Do not print header if output to file
  -h,		Print usage information
  
[TARGET] is a name from lm_sensors, for instance 'fan6'.
It must also be the name for an RPM, V(olts), or °C value.
Number of cycles (-c) must be an integer.
Duration of each cycle can be a floating point number.
```
