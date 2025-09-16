#!/bin/bash

echo "Running Flutter tests..."
cd /home/daniel/work/lost-and-tossed
flutter test --reporter compact 2>&1
