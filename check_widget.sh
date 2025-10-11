#!/bin/bash
echo "=== ウィジェットのログをフィルタリング ==="
xcrun simctl spawn booted log stream --predicate 'process CONTAINS "Widget" OR process CONTAINS "PetWidget"' --level debug
