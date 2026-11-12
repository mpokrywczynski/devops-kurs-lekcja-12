#!/usr/bin/env bash

set -euo pipefail

prog=85
prog_zrodlo="domyślne"
gadatliwy=0
gadatliwy_zrodlo="domyślne"
pokaz=0

if [[ -f ~/.config/dysk.conf ]]; then
    while IFS='=' read -r klucz wartosc; do
        case "$klucz" in "" | "#"*) ;;
            prog)
                prog="$wartosc"
                prog_zrodlo="plik" ;;
            gadatliwy)
                gadatliwy="$wartosc"
                gadatliwy_zrodlo="plik" ;;
            *)
                echo "UWAGA: nieznany klucz: $klucz" >&2 ;;
        esac
    done < ~/.config/dysk.conf
fi

if [[ -n "${DYSK_PROG:-}" ]]; then
    prog="$DYSK_PROG"
    prog_zrodlo="środowisko"
fi

if [[ -n "${DYSK_GADATLIWY:-}" ]]; then
    gadatliwy="$DYSK_GADATLIWY"
    gadatliwy_zrodlo="środowisko"
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p)
            if [[ $# -lt 2 ]]; then
                echo "Błąd: -p wymaga wartości" >&2
                exit 2
            fi
            prog="$2"
            prog_zrodlo="wiersz poleceń"
            shift 2 ;;
        -v)
            gadatliwy=1
            gadatliwy_zrodlo="wiersz poleceń"
            shift ;;
        --pokaz-konfiguracje)
            pokaz=1
            shift ;;
        -h)
            echo "Użycie: $0 [-p PROCENT] [-v] [--pokaz-konfiguracje] [-h]"
            exit 0 ;;
        *)
            echo "Błąd: nieznana opcja $1" >&2
            exit 2 ;;
    esac
done

if [[ "$pokaz" -eq 1 ]]; then
    echo "prog = $prog ($prog_zrodlo)"
    echo "gadatliwy = $gadatliwy ($gadatliwy_zrodlo)"
    exit 0
fi

if [[ ! "$prog" =~ ^[0-9]+$ ]]; then
    echo "Błąd: próg musi być liczbą ($prog_zrodlo)" >&2
    exit 2
fi

kod=0
while read -r procent punkt; do
    if [[ "$gadatliwy" == "1" ]]; then
        echo "$punkt: $procent%"
    fi
    if [[ "$procent" -ge "$prog" ]]; then
        echo "UWAGA: $punkt zajęty w $procent% (próg $prog%)" >&2
        kod=1
    fi
done < <(df -P -x tmpfs -x devtmpfs -x squashfs -x overlay -x fuse.snapfuse -x 9p | awk 'NR > 1 {print $5, $6}' | tr -d '%')

exit "$kod"
