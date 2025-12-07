#!/bin/bash
# setup-firefox-hook.sh - Setup script for creating activity hooks with Firefox support
# This script creates a hook that launches Firefox with a dedicated profile

ACTIVITY_NAME="$1"

if [ -z "$ACTIVITY_NAME" ]; then
    echo "Usage: $0 <activity-name>"
    echo ""
    echo "Example:"
    echo "  $0 \"Work\""
    echo ""
    echo "This creates a hook that auto-launches Firefox with a dedicated profile"
    echo "when you switch to the activity using ./switch-activity.sh"
    exit 1
fi

# Convert activity name to lowercase for profile name
PROFILE_NAME=$(echo "$ACTIVITY_NAME" | tr '[:upper:]' '[:lower:]')

# Verify activity exists
ACTIVITY_LIST=$(kactivities-cli --list-activities)
if ! echo "$ACTIVITY_LIST" | grep -q " $ACTIVITY_NAME "; then
    echo "Error: Activity '$ACTIVITY_NAME' not found!"
    echo ""
    echo "Available activities:"
    echo "$ACTIVITY_LIST" | awk '{for(i=3;i<NF;i++) printf $i" "; print $(NF-1)}' | sed 's/ ($//'
    echo ""
    echo "Create it first with:"
    echo "  ./create-activity.sh \"$ACTIVITY_NAME\""
    exit 1
fi

# Create hooks directory
HOOK_DIR="$HOME/.config/kde-activities/hooks"
mkdir -p "$HOOK_DIR"

# Create the hook script
HOOK_SCRIPT="$HOOK_DIR/${ACTIVITY_NAME}.sh"

# Check if hook already exists
if [ -f "$HOOK_SCRIPT" ]; then
    echo "Error: Hook script already exists at:"
    echo "  $HOOK_SCRIPT"
    echo ""
    echo "To replace it, first remove the existing hook:"
    echo "  rm \"$HOOK_SCRIPT\""
    echo ""
    echo "Or to view the existing hook:"
    echo "  cat \"$HOOK_SCRIPT\""
    exit 1
fi

echo "Creating hook script: $HOOK_SCRIPT"

cat > "$HOOK_SCRIPT" << 'EOF'
#!/bin/bash
# Auto-generated hook script for activity: $ACTIVITY_NAME
# This script runs automatically when switching to this activity

FIREFOX_PROFILE="$PROFILE_NAME"

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
        echo ""
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
EOF

# Replace placeholders in the script
sed -i "s/\$ACTIVITY_NAME/$ACTIVITY_NAME/g" "$HOOK_SCRIPT"
sed -i "s/\$PROFILE_NAME/$PROFILE_NAME/g" "$HOOK_SCRIPT"

chmod +x "$HOOK_SCRIPT"

echo ""
echo "✓ Hook script created successfully at:"
echo "  $HOOK_SCRIPT"
echo ""
echo "The hook will automatically run when you switch to '$ACTIVITY_NAME'"
echo "using ./switch-activity.sh"
echo ""
echo "NEXT STEP: Create the Firefox profile '$PROFILE_NAME'"
echo ""
echo "You can either:"
echo "  1. Run: firefox -ProfileManager -no-remote"
echo "  2. Or just switch to the activity - the hook will prompt you!"
echo ""
echo "Switch to activity with:"
echo "  ./switch-activity.sh \"$ACTIVITY_NAME\""
