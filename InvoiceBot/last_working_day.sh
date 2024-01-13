#!/bin/bash

function isLastWorkingDayOfMonth() {
    last_day=$(date -j -f "%Y-%m-%d" -v +1m -v1d -v-1d "$1" +%Y-%m-%d)

    while true; do
        day_of_week=$(date -j -f "%Y-%m-%d" "$last_day" +%u)

        if [[ $day_of_week -eq 6 ]] || [[ $day_of_week -eq 7 ]]; then
            last_day=$(date -j -v-1d -f "%Y-%m-%d" "$last_day" +%Y-%m-%d)
        else
            if [[ "$last_day" == "$1" ]]; then
                return 0
            else
                return 1
            fi
        fi
    done
}