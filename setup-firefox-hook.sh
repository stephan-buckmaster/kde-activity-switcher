#!/bin/bash
# setup-firefox-hook.sh - Setup script for creating activity hooks with Firefox support
# This script creates a hook that launches Firefox with a dedicated profile

ACTIVITY_NAME="$1"

if [ -z "$ACTIVITY_NAME" ]; then
    echo "Usage: $0 <activity-name>"
    echo "This script is typically called by create-activity.sh"
    exit 1
fi

# Convert activity name to lowercase for profile name
PROFILE_NAME=$(echo "$ACTIVITY_NAME" | tr '[:upper:]' '[:lower:]')

# Create hooks directory if it doesn't exist
HOOK_DIR="$HOME/.config/kde-activities/hooks"
mkdir -p "$HOOK_DIR"

# Create the hook script
HOOK_SCRIPT="$HOOK_DIR/${ACTIVITY_NAME}.sh"

echo "Creating hook script: $HOOK_SCRIPT"

cat > "$HOOK_SCRIPT" << EOF
#!/bin/bash
# Auto-generated hook script for activity: $ACTIVITY_NAME
# This script runs automatically when switching to this activity

FIREFOX_PROFILE="$PROFILE_NAME"

# Launch Firefox with specific profile if not already running
if ! pgrep -f "firefox.*-P \$FIREFOX_PROFILE" > /dev/null; then
    echo "Launching Firefox with profile: \$FIREFOX_PROFILE"
    firefox -P "\$FIREFOX_PROFILE" -no-remote &
    sleep 1
else
    echo "Firefox already running with profile: \$FIREFOX_PROFILE"
fi

# Launch terminal if not already running
if ! pgrep konsole > /dev/null; then
    echo "Launching terminal..."
    konsole &
else
    echo "Terminal already running"
fi
EOF

chmod +x "$HOOK_SCRIPT"

echo ""
echo "✓ Hook script created successfully!"
echo ""
echo "NEXT STEP: Create the Firefox profile '$PROFILE_NAME'"
echo ""
echo "Run this command to create the profile:"
echo "  firefox -ProfileManager -no-remote"
echo ""
echo "In the Profile Manager:"
echo "  1. Click 'Create Profile'"
echo "  2. Name it exactly: $PROFILE_NAME"
echo "  3. Exit the Profile Manager"
echo ""
echo "Then switch to your activity with: ./switch-activity.sh"
