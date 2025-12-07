#!/bin/bash
# create-activity.sh - Create a new KDE activity

ACTIVITY_NAME="$1"
CUSTOM_SCRIPT=""

if [ -z "$ACTIVITY_NAME" ]; then
    echo "Usage: $0 <activity-name> [custom=/path/to/setup-script]"
    echo ""
    echo "Examples:"
    echo "  $0 \"Work\""
    echo "  $0 \"Work\" custom=./setup-firefox-hook.sh"
    exit 1
fi

# Parse custom= parameter
shift
for arg in "$@"; do
    case $arg in
        custom=*)
            CUSTOM_SCRIPT="${arg#custom=}"
            ;;
        *)
            echo "Unknown parameter: $arg"
            exit 1
            ;;
    esac
done

echo "Creating activity: $ACTIVITY_NAME"
ACTIVITY_ID=$(qdbus org.kde.ActivityManager /ActivityManager/Activities AddActivity "$ACTIVITY_NAME")

echo "Activity created with ID: $ACTIVITY_ID"

# Run custom setup script if provided
if [ -n "$CUSTOM_SCRIPT" ]; then
    if [ -f "$CUSTOM_SCRIPT" ]; then
        echo "Running custom setup script: $CUSTOM_SCRIPT"
        if [ -x "$CUSTOM_SCRIPT" ]; then
            "$CUSTOM_SCRIPT" "$ACTIVITY_NAME"
        else
            echo "Error: Custom script is not executable: $CUSTOM_SCRIPT"
            echo "Run: chmod +x \"$CUSTOM_SCRIPT\""
            exit 1
        fi
    else
        echo "Error: Custom script not found: $CUSTOM_SCRIPT"
        exit 1
    fi
else
    echo "Activity created. Switch to it with: ./switch-activity.sh"
fi
