#!/bin/bash
# create-activity.sh - Create a new KDE activity

ACTIVITY_NAME="$1"

if [ -z "$ACTIVITY_NAME" ]; then
    echo "Usage: $0 <activity-name>"
    exit 1
fi

echo "Creating activity: $ACTIVITY_NAME"
ACTIVITY_ID=$(qdbus org.kde.ActivityManager /ActivityManager/Activities AddActivity "$ACTIVITY_NAME")

echo "Activity created with ID: $ACTIVITY_ID"
echo "Now switch to it and set it up with Firefox profile and apps"
