#!/usr/bin/env bash
# Helper script to set energy_performance_preference on all CPUs.
# Intended to be called via pkexec (runs as root).
# Usage: pkexec /path/to/set-epp.sh <epp_value>

EPP="$1"
if [[ -z "$EPP" ]]; then
    echo "Usage: $0 <epp_value>" >&2
    exit 1
fi

for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo "$EPP" > "$f"
done
