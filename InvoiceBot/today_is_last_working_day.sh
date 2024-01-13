#!/bin/bash

source ./last_working_day.sh

today=$(date +%Y-%m-%d)

if getLastWorkingDayOfMonth "$today"; then
  open -b com.kapobajza.InvoiceBot
fi