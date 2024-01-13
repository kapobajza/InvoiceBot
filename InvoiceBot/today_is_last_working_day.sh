#!/bin/bash

source ./last_working_day.sh

today=$(date +%Y-%m-%d)

if isLastWorkingDayOfMonth "$today"; then
  open -b com.kapobajza.InvoiceBot
fi