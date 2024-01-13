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

assertFalse "isLastWorkingDayOfMonth 2023-11-04" "1"
assertFalse "isLastWorkingDayOfMonth 2023-12-02" "2"
assertTrue "isLastWorkingDayOfMonth 2023-12-29" "3"
assertTrue "isLastWorkingDayOfMonth 2023-11-30" "4"
assertTrue "isLastWorkingDayOfMonth 2023-02-28" "5"
assertFalse "isLastWorkingDayOfMonth 2023-12-31" "6"
assertFalse "isLastWorkingDayOfMonth 2023-11-29" "7"
assertFalse "isLastWorkingDayOfMonth 2023-11-28" "8"
