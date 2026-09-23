#!/bin/bash
# Export the Raspberry Pi throttling flags as Prometheus metrics.
# Writes to the node_exporter textfile directory; run it from cron every minute.
set -eu

OUT=/var/lib/node_exporter/rpi_throttled.prom
RAW=$(vcgencmd get_throttled)          # e.g. throttled=0x50005
VALUE=$((${RAW#throttled=}))

bit() { echo $(( (VALUE >> $1) & 1 )); }

{
  echo "# HELP rpi_throttled_flags Raw value of vcgencmd get_throttled."
  echo "# TYPE rpi_throttled_flags gauge"
  echo "rpi_throttled_flags $VALUE"
  echo "# HELP rpi_throttled_state Raspberry Pi throttling state, 1 = active."
  echo "# TYPE rpi_throttled_state gauge"
  echo "rpi_throttled_state{state=\"under_voltage\"} $(bit 0)"
  echo "rpi_throttled_state{state=\"frequency_capped\"} $(bit 1)"
  echo "rpi_throttled_state{state=\"throttled\"} $(bit 2)"
  echo "rpi_throttled_state{state=\"soft_temp_limit\"} $(bit 3)"
  echo "# HELP rpi_throttled_since_boot Raspberry Pi throttling events since boot, 1 = occurred."
  echo "# TYPE rpi_throttled_since_boot gauge"
  echo "rpi_throttled_since_boot{state=\"under_voltage\"} $(bit 16)"
  echo "rpi_throttled_since_boot{state=\"frequency_capped\"} $(bit 17)"
  echo "rpi_throttled_since_boot{state=\"throttled\"} $(bit 18)"
  echo "rpi_throttled_since_boot{state=\"soft_temp_limit\"} $(bit 19)"
} > "$OUT.tmp"

mv "$OUT.tmp" "$OUT"
