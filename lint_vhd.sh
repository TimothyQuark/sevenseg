#!/bin/bash

# Run VSG (VHDL Style Guide) linter on all VHDL files in src/ directory

for file in src/*.vhd; do
    if [ -f "$file" ]; then
        echo "Linting $file..."
        vsg -f "$file" -c ~/Documents/git/swissknife/vsg.json --fix
    fi
done

echo "VSG linting complete!"
