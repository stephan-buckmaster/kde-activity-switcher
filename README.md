# KDE Activity Switcher

Simple scripts to manage KDE Plasma activities from the command line.

## Scripts

### create-activity.sh
Creates a new KDE activity, optionally with a custom setup script.

**Usage:**
```bash
# Create a basic activity
./create-activity.sh "Work"

# Create an activity with Firefox auto-launch setup
./create-activity.sh "Work" custom=./setup-firefox-hook.sh
```

The `custom=` parameter accepts a path to any setup script. The script receives the activity name as an argument and can set up hooks or other configuration.

### switch-activity.sh
Switch between existing activities. Automatically runs hook scripts to launch apps when switching.

**Usage:**
```bash
# Interactive mode - shows numbered list with quit option
./switch-activity.sh

# Direct mode - switch by name
./switch-activity.sh "Work"
```

In interactive mode, shows a numbered list of all activities with a quit option. You can also pass the activity name directly as an argument to switch immediately. If a hook script exists for that activity, it will run automatically.

### setup-firefox-hook.sh
Setup script that creates a hook for launching Firefox with a dedicated profile.

**Usage:**
```bash
# Typically used with create-activity.sh
./create-activity.sh "Work" custom=./setup-firefox-hook.sh

# Can also be run standalone
./setup-firefox-hook.sh "Work"
```

This creates a hook script that launches Firefox (with profile "work") and a terminal when switching to the activity.

## Installation

1. Clone this repo
2. Make scripts executable:
```bash
chmod +x create-activity.sh switch-activity.sh setup-firefox-hook.sh
```

3. Optionally, add to your PATH or create symlinks in `~/bin/`

## Auto-launching Apps with Hook Scripts

`switch-activity.sh` automatically runs hook scripts when switching to an activity. This lets you launch Firefox (with specific profiles), terminals, and other apps automatically.

### Quick Setup with setup-firefox-hook.sh

The easiest way to set up Firefox auto-launching:

1. Create an activity with the Firefox setup script:
```bash
./create-activity.sh "Work" custom=./setup-firefox-hook.sh
```

2. Create the Firefox profile when prompted:
```bash
firefox -ProfileManager -no-remote
# Create profile named "work" (lowercase of activity name)
```

3. Switch to your activity:
```bash
./switch-activity.sh
# Select "Work" - Firefox and terminal launch automatically!
```

### Manual Hook Setup

You can also create hooks manually for more control:

1. Create the hooks directory:
```bash
mkdir -p ~/.config/kde-activities/hooks
```

2. Copy the example hook and customize it:
```bash
cp example-hook.sh ~/.config/kde-activities/hooks/Work.sh
chmod +x ~/.config/kde-activities/hooks/Work.sh
```

3. Edit the hook script to match your needs

### How It Works

- Hook scripts are named after the activity: `<ActivityName>.sh`
- The script runs automatically when you switch to that activity
- Apps only launch if they're not already running
- Each activity can have different apps/profiles

### Why Firefox Works Better

Firefox works better than Chrome for activity isolation because:
- Firefox allows multiple instances with different profiles using `-P <profile> -no-remote`
- Each profile's windows stay in their respective activity
- Chrome prefers a single process managing all windows

## Requirements

- KDE Plasma 5.x or 6.x
- `qdbus` (usually pre-installed with KDE)
