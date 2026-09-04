#!/bin/bash
# Runs the imgui-godot test suite.
#
#   tests/run_tests.sh                  everything (visual tests flash a window)
#   tests/run_tests.sh --headless-only  skip the windowed visual tests
#   GODOT=/path/to/godot tests/run_tests.sh   override the Godot binary
set -u
GODOT="${GODOT:-/Applications/Godot 4.7.1.app/Contents/MacOS/Godot}"
cd "$(dirname "$0")/.."

failures=0

filter() { grep -vE "^Godot Engine|^Metal|^$" || true; }

echo "=== script check ==="
out=$("$GODOT" --headless --path . --check-only --script res://imgui.gd 2>&1 | filter)
if [ -n "$out" ]; then
	echo "FAIL - imgui.gd:"
	echo "$out"
	failures=$((failures + 1))
else
	echo "  ok - imgui.gd parses"
fi

echo "=== scene smoke tests (headless; any output is a failure) ==="
for f in main.tscn test_scenes/*.tscn; do
	out=$("$GODOT" --headless --path . "res://$f" --quit-after 20 2>&1 | filter)
	if [ -n "$out" ]; then
		echo "FAIL - $f:"
		echo "$out"
		failures=$((failures + 1))
	else
		echo "  ok - $f"
	fi
done

run_test() {
	local mode="$1" name="$2"
	local out
	if [ "$mode" = "headless" ]; then
		out=$("$GODOT" --headless --path . -s "tests/$name.gd" --quit-after 900 2>&1 | filter)
	else
		out=$("$GODOT" --path . -s "tests/$name.gd" --quit-after 900 2>&1 | filter)
	fi
	if echo "$out" | grep -q "^PASS$"; then
		echo "  ok - $name"
	else
		echo "FAIL - $name:"
		echo "$out"
		failures=$((failures + 1))
	fi
}

echo "=== behavior tests (headless) ==="
for t in test_widgets test_embed test_nested test_toplevel_prune test_radio test_composite_widgets; do
	run_test headless "$t"
done

if [ "${1:-}" != "--headless-only" ]; then
	echo "=== visual tests (a window will flash briefly) ==="
	for t in test_redraw test_containment test_input_capture; do
		run_test windowed "$t"
	done
fi

echo
if [ "$failures" -eq 0 ]; then
	echo "All tests passed."
else
	echo "$failures test(s) FAILED."
	exit 1
fi
