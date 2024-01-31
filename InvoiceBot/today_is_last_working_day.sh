#!/bin/bash

# Get the directory of the script
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$dir/last_working_day.sh"

today=$(date +%Y-%m-%d)

if isLastWorkingDayOfMonth "$today"; then
  open -b com.kapobajza.InvoiceBot
fi