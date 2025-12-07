#!/bin/bash
# Example hook script for an activity
# Copy this to: ~/.config/kde-activities/hooks/<ActivityName>.sh
# Make it executable: chmod +x ~/.config/kde-activities/hooks/<ActivityName>.sh
#
# This script runs automatically when switching to the activity

ACTIVITY_NAME="Work"  # Change this to match your activity name
FIREFOX_PROFILE="work"  # Change this to your Firefox profile name

# Launch Firefox with specific profile if not already running
if ! pgrep -f "firefox.*-P $FIREFOX_PROFILE" > /dev/null; then
    echo "Launching Firefox with profile: $FIREFOX_PROFILE"
    firefox -P "$FIREFOX_PROFILE" -no-remote &
    sleep 1  # Give Firefox time to start
else
    echo "Firefox already running with profile: $FIREFOX_PROFILE"
fi

# Launch terminal if not already running
if ! pgrep konsole > /dev/null; then
    echo "Launching terminal..."
    konsole &
else
    echo "Terminal already running"
fi

# You can add more applications here as needed
# Example:
# if ! pgrep kate > /dev/null; then
#     kate &
# fi
