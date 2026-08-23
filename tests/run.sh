#!/bin/sh
# Runs a test binary in QEMU and reports its result.
#
# Usage: tests/run.sh <test.elf> <qemu command...>
#
# The tests never exit (there is no poweroff yet), so QEMU is stopped as soon
# as the test prints its summary line, or after $TIMEOUT seconds (default 10).
# Exit code: 0 if the summary reports no failed tests, 1 otherwise.

elf=$1
shift
timeout=${TIMEOUT:-10}
out=$(mktemp)

"$@" -kernel "$elf" </dev/null >"$out" 2>&1 &
qemu=$!

ticks=$((timeout * 5))
while [ $ticks -gt 0 ]; do
    if grep -q '^Run [0-9]* tests' "$out"; then
        break
    fi
    if ! kill -0 $qemu 2>/dev/null; then
        break
    fi
    sleep 0.2
    ticks=$((ticks - 1))
done

kill $qemu 2>/dev/null
wait $qemu 2>/dev/null

tr -d '\r' <"$out" | grep -v '^qemu-system-riscv32: terminating on signal'
summary=$(grep '^Run [0-9]* tests' "$out" | tail -1)
rm -f "$out"

case "$summary" in
    *" 0 tests failed,"*) exit 0 ;;
    "") echo "FAILED: no test summary (crashed or timed out after ${timeout}s)"; exit 1 ;;
    *) exit 1 ;;
esac
