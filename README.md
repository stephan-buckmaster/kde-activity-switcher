# KDE Activity Hooks

Hook management tools for KDE Plasma Activities. Auto-launch Firefox with dedicated profiles, terminals, and other apps when switching activities.

## What This Does

KDE Activities already has a built-in hook system at `~/.local/share/kactivitymanagerd/activities/<uuid>/activated`, but it's not well-documented and requires working with UUIDs. This tool makes it easy to set up hooks using activity names.

## Quick Start

```bash
# 1. Create an activity (using KDE's official tool)
kactivities-cli --create-activity "Work"

# 2. Set up Firefox hook for that activity
./setup-firefox-hook.sh "Work"

# 3. Switch to the activity
kactivities-cli --set-current-activity "Work"

# Firefox and terminal launch automatically!
# If Firefox profile doesn't exist, Profile Manager opens automatically
```

## Scripts

### setup-firefox-hook.sh

Creates a hook that auto-launches Firefox with a dedicated profile and a terminal when you switch to an activity.

**Usage:**
```bash
./setup-firefox-hook.sh "Work"
```

This:
1. Looks up the activity UUID from the name
2. Creates `~/.local/share/kactivitymanagerd/activities/<uuid>/activated`
3. Generates a hook that launches Firefox (profile "work") and konsole
4. Detects if Firefox profile exists; if not, opens Profile Manager

**Firefox Profile Naming:** Activity name is converted to lowercase (e.g., "Work" → "work" profile)

### example-hook.sh

Template showing how to create custom hooks manually. Use this as a reference if you want to:
- Launch different applications
- Create hooks for deactivated/started/stopped events
- Customize the hook behavior

## Managing Activities

Use KDE's official `kactivities-cli` tool for activity management:

```bash
# List all activities
kactivities-cli --list-activities

# Create a new activity
kactivities-cli --create-activity "Research"

# Switch to an activity (by name)
kactivities-cli --set-current-activity "Research"

# Delete an activity
kactivities-cli --remove-activity <uuid>

# Cycle through activities
kactivities-cli --next-activity
kactivities-cli --previous-activity

# Get help
kactivities-cli --help
```

## How the Hook System Works

KDE's Activity Manager automatically runs scripts in these locations:

```
~/.local/share/kactivitymanagerd/activities/<activity-uuid>/
├── activated      - Runs when switching TO this activity
├── deactivated    - Runs when switching AWAY from this activity
├── started        - Runs when activity starts
└── stopped        - Runs when activity stops
```

Our `setup-firefox-hook.sh` creates the `activated` hook for you, using the activity name to look up the UUID.

## Installation

```bash
# Clone this repo
git clone <repo-url>
cd kde-activity-switcher

# Make scripts executable
chmod +x setup-firefox-hook.sh
```

Optionally, add to your PATH or create symlinks in `~/bin/`

## Why Firefox Works Better for Activities

Firefox allows multiple instances with different profiles using `-P <profile> -no-remote`:
- Each profile's windows stay in their respective activity
- Complete isolation between activity contexts
- Chrome/Chromium resist this because they prefer a single process

## Advanced: Manual Hook Setup

If you want full control:

```bash
# 1. Find your activity UUID
kactivities-cli --list-activities

# 2. Create hook directory
mkdir -p ~/.local/share/kactivitymanagerd/activities/<uuid>

# 3. Create your custom hook
cp example-hook.sh ~/.local/share/kactivitymanagerd/activities/<uuid>/activated
chmod +x ~/.local/share/kactivitymanagerd/activities/<uuid>/activated

# 4. Edit to customize
nano ~/.local/share/kactivitymanagerd/activities/<uuid>/activated
```

## Requirements

- KDE Plasma 5.x or 6.x
- `kactivities-cli` (from kactivities-bin package)
- Firefox (if using setup-firefox-hook.sh)

## Cleanup

To remove hooks:
```bash
# Find activity UUID
kactivities-cli --list-activities

# Remove hook directory
rm -rf ~/.local/share/kactivitymanagerd/activities/<uuid>

# Or delete the entire activity
kactivities-cli --remove-activity <uuid>
```
