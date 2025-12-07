#!/bin/bash
# switch-activity.sh - Interactive activity switcher for KDE Plasma

# Get list of activity IDs
ACTIVITY_IDS=$(qdbus org.kde.ActivityManager /ActivityManager/Activities ListActivities)

# Convert to array
IFS=$'\n' read -r -d '' -a ACTIVITIES <<< "$ACTIVITY_IDS"

# If no activities found
if [ ${#ACTIVITIES[@]} -eq 0 ]; then
    echo "No activities found!"
    exit 1
fi

# Display activities with numbers
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
read -p "Select activity number (1-${#ACTIVITIES[@]}): " selection

# Validate input
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#ACTIVITIES[@]} ]; then
    echo "Invalid selection!"
    exit 1
fi

# Switch to selected activity
SELECTED_ID=${ACTIVITY_MAP[$selection]}
echo "Switching to activity..."
qdbus org.kde.ActivityManager /ActivityManager/Activities SetCurrentActivity "$SELECTED_ID"
echo "Switched to: $(qdbus org.kde.ActivityManager /ActivityManager/Activities ActivityName "$SELECTED_ID")"
