# KDE Activity Switcher with Hooks

Simple scripts to manage KDE Plasma activities with automatic app launching via hooks.

## What This Does

- Create and switch between KDE Activities using `kactivities-cli`
- Auto-launch Firefox with dedicated profiles per activity
- Auto-launch terminals and other apps when switching activities
- Detects missing Firefox profiles and opens Profile Manager automatically

## Quick Start

```bash
# 1. Create an activity with Firefox hook
./create-activity.sh "Work" custom=./setup-firefox-hook.sh

# 2. Switch to the activity (interactive mode)
./switch-activity.sh

# Or switch directly by name
./switch-activity.sh "Work"

# Firefox and terminal launch automatically!
# If Firefox profile doesn't exist, Profile Manager opens automatically
```

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

The `custom=` parameter accepts a path to any setup script that receives the activity name as an argument.

### switch-activity.sh

Switch between existing activities. Automatically runs hook scripts to launch apps when switching.

**Usage:**
```bash
# Interactive mode - shows numbered list with quit option
./switch-activity.sh

# Direct mode - switch by name
./switch-activity.sh "Work"
```

In interactive mode, shows a numbered list of all activities. You can also pass the activity name directly to switch immediately. If a hook script exists for that activity, it runs automatically.

### setup-firefox-hook.sh

Setup script that creates a hook for launching Firefox with a dedicated profile.

**Usage:**
```bash
# Typically used with create-activity.sh
./create-activity.sh "Work" custom=./setup-firefox-hook.sh

# Can also be run standalone
./setup-firefox-hook.sh "Work"
```

This creates a hook script at `~/.config/kde-activities/hooks/Work.sh` that launches Firefox (with profile "work") and a terminal when switching to the activity.

**Firefox Profile Naming:** Activity name is converted to lowercase (e.g., "Work" → "work" profile)

### example-hook.sh

Template showing how to create custom hooks manually. Use this as a reference if you want to launch different applications or customize the hook behavior.

## Installation

```bash
# Clone this repo
git clone <repo-url>
cd kde-activity-switcher

# Make scripts executable
chmod +x create-activity.sh switch-activity.sh setup-firefox-hook.sh
```

Optionally, add to your PATH or create symlinks in `~/bin/`

## Auto-launching Apps with Hook Scripts

Hook scripts are automatically executed by `switch-activity.sh` when switching to an activity.

### Quick Setup

1. Create an activity with the Firefox setup script:
```bash
./create-activity.sh "Work" custom=./setup-firefox-hook.sh
```

2. Switch to your activity:
```bash
./switch-activity.sh "Work"
```

3. If Firefox profile doesn't exist, Profile Manager opens automatically. Create a profile named "work" (lowercase of activity name).

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
nano ~/.config/kde-activities/hooks/Work.sh
```

3. Edit the hook script to match your needs

### How It Works

- Hook scripts are stored in `~/.config/kde-activities/hooks/`
- Named after the activity: `<ActivityName>.sh`
- The script runs automatically when you switch to that activity using `switch-activity.sh`
- Apps only launch if they're not already running
- Each activity can have different apps/profiles

## Why Firefox Works Better for Activities

Firefox allows multiple instances with different profiles using `-P <profile> -no-remote`:
- Each profile's windows stay in their respective activity
- Complete isolation between activity contexts
- Chrome/Chromium resist this because they prefer a single process

## Managing Activities with kactivities-cli

Our scripts use `kactivities-cli` under the hood. You can also use it directly:

```bash
# List all activities
kactivities-cli --list-activities

# Create a new activity
kactivities-cli --create-activity "Research"

# Delete an activity
kactivities-cli --remove-activity <uuid>

# Cycle through activities
kactivities-cli --next-activity
kactivities-cli --previous-activity

# Get help
kactivities-cli --help
```

**Note:** Use our `switch-activity.sh` instead of `kactivities-cli --set-current-activity` if you want hooks to run automatically.

## Cleanup

To remove hooks:
```bash
# Remove a specific hook
rm ~/.config/kde-activities/hooks/Work.sh

# Or remove all hooks
rm -rf ~/.config/kde-activities/hooks/

# To delete an activity (use UUID from --list-activities)
kactivities-cli --remove-activity <uuid>
```

## Requirements

- KDE Plasma 5.27+ (tested on 5.27)
- `kactivities-cli` (from kactivities-bin package, usually pre-installed)
- Firefox (if using setup-firefox-hook.sh)

## Technical Note

KDE Plasma is said to have a built-in hook system at `~/.local/share/kactivitymanagerd/activities/<uuid>/activated`, but we could not get it to work in Plasma 5.27. This project implements its own hook system using name-based lookup at `~/.config/kde-activities/hooks/` which is more user-friendly and confirmed to work.
