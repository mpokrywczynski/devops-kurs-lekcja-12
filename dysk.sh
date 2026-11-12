#!/usr/bin/env bash

set -euo pipefail

prog=85
gadatliwy=0

while getopts "p:vh" opcja; do
    case "$opcja" in
        p) prog="$OPTARG" ;;
        v) gadatliwy=1 ;;
        h) echo "Użycie: $0 [-p PROCENT] [-v] [-h]"; exit 0 ;;
        *) echo "Użycie: $0 [-p PROCENT] [-v] [-h]" >&2; exit 2 ;;
    esac
done

if [[ ! "$prog" =~ ^[0-9]+$ ]]; then
    echo "Błąd: próg musi być liczbą" >&2
    exit 2
fi

kod=0
while read -r procent punkt; do
    procent="${procent%\%}"
    if [[ "$gadatliwy" -eq 1 ]]; then
        echo "$punkt: $procent%"
    fi
    if [[ "$procent" -ge "$prog" ]]; then
        echo "UWAGA: $punkt zajęty w $procent% (próg $prog%)" >&2
        kod=1
    fi
done < <(df -P -x tmpfs -x devtmpfs -x squashfs -x overlay -x fuse.snapfuse -x 9p | awk 'NR > 1 {print $5, $6}')

exit "$kod"
