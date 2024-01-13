#!/bin/bash

source ./last_working_day.sh

function assertTrue() {
  $1
  local status=$?
  
  if [[ "$status" -eq 0 ]]; then
    echo "Test case $2 passed"
  else
    echo "Test case $2 failed: ${BASH_SOURCE[1]}:${BASH_LINENO[0]}"
  fi
}

function assertFalse() {
  $1
  local status=$?
  
  if [[ "$status" -ne 0 ]]; then
    echo "Test case $2 passed"
  else
    echo "Test case $2 failed: ${BASH_SOURCE[1]}:${BASH_LINENO[0]}"
  fi
}

assertFalse "getLastWorkingDayOfMonth 2023-11-04" "1"
assertFalse "getLastWorkingDayOfMonth 2023-12-02" "2"
assertTrue "getLastWorkingDayOfMonth 2023-12-29" "3"
assertTrue "getLastWorkingDayOfMonth 2023-11-30" "4"
assertTrue "getLastWorkingDayOfMonth 2023-02-28" "5"
assertFalse "getLastWorkingDayOfMonth 2023-12-31" "6"
assertFalse "getLastWorkingDayOfMonth 2023-11-29" "7"
assertFalse "getLastWorkingDayOfMonth 2023-11-28" "8"
