#!/bin/bash
# Example hook script for KDE Activities
#
# Location: ~/.local/share/kactivitymanagerd/activities/<activity-uuid>/activated
# This script runs automatically when KDE switches to this activity
#
# Use setup-firefox-hook.sh to create this automatically, or:
# 1. Find your activity UUID: kactivities-cli --list-activities
# 2. Create directory: mkdir -p ~/.local/share/kactivitymanagerd/activities/<uuid>
# 3. Copy this file to: ~/.local/share/kactivitymanagerd/activities/<uuid>/activated
# 4. Make it executable: chmod +x ~/.local/share/kactivitymanagerd/activities/<uuid>/activated

ACTIVITY_NAME="Work"  # Your activity name (for reference only)
FIREFOX_PROFILE="work"  # Your Firefox profile name

# Check if Firefox profile exists
PROFILES_INI="$HOME/.mozilla/firefox/profiles.ini"
PROFILE_EXISTS=false

if [ -f "$PROFILES_INI" ]; then
    if grep -q "Name=$FIREFOX_PROFILE" "$PROFILES_INI"; then
        PROFILE_EXISTS=true
    fi
fi

# Launch Firefox with specific profile if not already running
if ! pgrep -f "firefox.*-P $FIREFOX_PROFILE" > /dev/null; then
    if [ "$PROFILE_EXISTS" = true ]; then
        echo "Launching Firefox with profile: $FIREFOX_PROFILE"
        firefox -P "$FIREFOX_PROFILE" -no-remote &
        sleep 1
    else
        echo "Firefox profile '$FIREFOX_PROFILE' does not exist!"
        echo "Opening Firefox Profile Manager to create it..."
        echo "Please create a profile named: $FIREFOX_PROFILE"
        firefox -ProfileManager -no-remote &
    fi
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
