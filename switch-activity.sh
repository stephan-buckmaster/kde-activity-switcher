#!/bin/bash
# switch-activity.sh - Interactive activity switcher for KDE Plasma
# Uses kactivities-cli and runs hooks from ~/.config/kde-activities/hooks/

ACTIVITY_NAME_ARG="$1"

# Get list of activities
ACTIVITY_LIST=$(kactivities-cli --list-activities)

if [ -z "$ACTIVITY_LIST" ]; then
    echo "No activities found!"
    exit 1
fi

SELECTED_NAME=""

# If activity name provided as argument, switch directly
if [ -n "$ACTIVITY_NAME_ARG" ]; then
    # Check if activity exists
    if echo "$ACTIVITY_LIST" | grep -q " $ACTIVITY_NAME_ARG "; then
        SELECTED_NAME="$ACTIVITY_NAME_ARG"
    else
        echo "Error: Activity '$ACTIVITY_NAME_ARG' not found!"
        echo ""
        echo "Available activities:"
        echo "$ACTIVITY_LIST" | awk '{for(i=3;i<NF;i++) printf $i" "; print $(NF-1)}' | sed 's/ ($//'
        exit 1
    fi
else
    # Interactive mode - display activities with numbers
    echo "Available Activities:"
    echo "-------------------"

    declare -A ACTIVITY_MAP
    i=1

    while IFS= read -r line; do
        # Parse: [STATUS] UUID Name (extra)
        STATUS=$(echo "$line" | awk '{print $1}' | tr -d '[]')
        NAME=$(echo "$line" | awk '{for(i=3;i<NF;i++) printf $i" "; print $(NF-1)}' | sed 's/ ($//')

        if [ "$STATUS" = "CURRENT" ]; then
            echo "$i) $NAME (current)"
        else
            echo "$i) $NAME"
        fi

        ACTIVITY_MAP[$i]="$NAME"
        ((i++))
    done <<< "$ACTIVITY_LIST"

    echo "-------------------"
    echo "0) Quit"
    echo "-------------------"
    read -p "Select activity number (0-$((i-1))): " selection

    # Check for quit
    if [ "$selection" = "0" ]; then
        echo "Cancelled."
        exit 0
    fi

    # Validate input
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -ge $i ]; then
        echo "Invalid selection!"
        exit 1
    fi

    SELECTED_NAME="${ACTIVITY_MAP[$selection]}"
fi

echo "Switching to activity: $SELECTED_NAME"
kactivities-cli --set-current-activity "$SELECTED_NAME"

# Check for and run hook script if it exists
HOOK_DIR="$HOME/.config/kde-activities/hooks"
HOOK_SCRIPT="$HOOK_DIR/${SELECTED_NAME}.sh"

if [ -f "$HOOK_SCRIPT" ]; then
    echo "Running hook script..."
    if [ -x "$HOOK_SCRIPT" ]; then
        "$HOOK_SCRIPT"
    else
        echo "Warning: Hook script exists but is not executable: $HOOK_SCRIPT"
        echo "Run: chmod +x \"$HOOK_SCRIPT\""
    fi
fi
