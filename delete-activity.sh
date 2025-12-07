#!/bin/bash
# delete-activity.sh - Delete a KDE activity and its hooks

ACTIVITY_NAME="$1"

if [ -z "$ACTIVITY_NAME" ]; then
    echo "Usage: $0 <activity-name>"
    echo ""
    echo "Example:"
    echo "  $0 \"Work\""
    echo ""
    echo "This deletes the activity and removes any associated hooks."
    exit 1
fi

# Get list of activities and find the UUID
ACTIVITY_LIST=$(kactivities-cli --list-activities)
ACTIVITY_UUID=""

while IFS= read -r line; do
    # Parse line format: [STATUS] UUID Name (extra)
    # Extract name by removing [STATUS] UUID at start and (extra) at end
    NAME=$(echo "$line" | sed 's/^\[[^]]*\] [^ ]* //' | sed 's/ ([^)]*)$//')
    if [ "$NAME" = "$ACTIVITY_NAME" ]; then
        ACTIVITY_UUID=$(echo "$line" | awk '{print $2}')
        break
    fi
done <<< "$ACTIVITY_LIST"

if [ -z "$ACTIVITY_UUID" ]; then
    echo "Error: Activity '$ACTIVITY_NAME' not found!"
    echo ""
    echo "Available activities:"
    echo "$ACTIVITY_LIST" | sed 's/^\[[^]]*\] [^ ]* /  - /' | sed 's/ ([^)]*)$//'
    exit 1
fi

echo "Found activity: $ACTIVITY_NAME (UUID: $ACTIVITY_UUID)"
echo ""

# Check if there's a hook file
HOOK_FILE="$HOME/.config/kde-activities/hooks/${ACTIVITY_NAME}.sh"
HAS_HOOK=false

if [ -f "$HOOK_FILE" ]; then
    HAS_HOOK=true
    echo "Found hook file: $HOOK_FILE"
fi

# Confirm deletion
echo ""
read -p "Delete activity '$ACTIVITY_NAME' and its hook? [y/N]: " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

# Delete the activity
echo ""
echo "Deleting activity..."
kactivities-cli --remove-activity "$ACTIVITY_UUID"

if [ $? -eq 0 ]; then
    echo "✓ Activity '$ACTIVITY_NAME' deleted successfully"

    # Remove hook file if it exists
    if [ "$HAS_HOOK" = true ]; then
        rm "$HOOK_FILE"
        echo "✓ Hook file removed: $HOOK_FILE"
    fi
else
    echo "Error: Failed to delete activity"
    exit 1
fi
