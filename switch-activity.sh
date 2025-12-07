#!/bin/bash
# switch-activity.sh - Interactive activity switcher for KDE Plasma

ACTIVITY_NAME_ARG="$1"

# Get list of activity IDs
ACTIVITY_IDS=$(qdbus org.kde.ActivityManager /ActivityManager/Activities ListActivities)

# Convert to array
IFS=$'\n' read -r -d '' -a ACTIVITIES <<< "$ACTIVITY_IDS"

# If no activities found
if [ ${#ACTIVITIES[@]} -eq 0 ]; then
    echo "No activities found!"
    exit 1
fi

SELECTED_ID=""
SELECTED_NAME=""

# If activity name provided as argument, find it
if [ -n "$ACTIVITY_NAME_ARG" ]; then
    for activity_id in "${ACTIVITIES[@]}"; do
        NAME=$(qdbus org.kde.ActivityManager /ActivityManager/Activities ActivityName "$activity_id")
        if [ "$NAME" = "$ACTIVITY_NAME_ARG" ]; then
            SELECTED_ID="$activity_id"
            SELECTED_NAME="$NAME"
            break
        fi
    done

    if [ -z "$SELECTED_ID" ]; then
        echo "Error: Activity '$ACTIVITY_NAME_ARG' not found!"
        echo ""
        echo "Available activities:"
        for activity_id in "${ACTIVITIES[@]}"; do
            NAME=$(qdbus org.kde.ActivityManager /ActivityManager/Activities ActivityName "$activity_id")
            echo "  - $NAME"
        done
        exit 1
    fi
else
    # Interactive mode - display activities with numbers
    echo "Available Activities:"
    echo "-------------------"
    i=1
    declare -A ACTIVITY_MAP

    for activity_id in "${ACTIVITIES[@]}"; do
        # Get activity name
        NAME=$(qdbus org.kde.ActivityManager /ActivityManager/Activities ActivityName "$activity_id")

        # Check if this is the current activity
        CURRENT=$(qdbus org.kde.ActivityManager /ActivityManager/Activities CurrentActivity)
        if [ "$activity_id" = "$CURRENT" ]; then
            echo "$i) $NAME (current)"
        else
            echo "$i) $NAME"
        fi

        ACTIVITY_MAP[$i]=$activity_id
        ((i++))
    done

    echo "-------------------"
    echo "0) Quit"
    echo "-------------------"
    read -p "Select activity number (0-${#ACTIVITIES[@]}): " selection

    # Check for quit
    if [ "$selection" = "0" ]; then
        echo "Cancelled."
        exit 0
    fi

    # Validate input
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#ACTIVITIES[@]} ]; then
        echo "Invalid selection!"
        exit 1
    fi

    # Switch to selected activity
    SELECTED_ID=${ACTIVITY_MAP[$selection]}
    SELECTED_NAME=$(qdbus org.kde.ActivityManager /ActivityManager/Activities ActivityName "$SELECTED_ID")
fi

echo "Switching to activity..."
qdbus org.kde.ActivityManager /ActivityManager/Activities SetCurrentActivity "$SELECTED_ID"
echo "Switched to: $SELECTED_NAME"

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
