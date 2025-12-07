# KDE Activity Switcher

Simple scripts to manage KDE Plasma activities from the command line.

## Scripts

### create-activity.sh
Creates a new KDE activity.

**Usage:**
```bash
./create-activity.sh "Work"
./create-activity.sh "Research"
```

### switch-activity.sh
Interactive script to switch between existing activities.

**Usage:**
```bash
./switch-activity.sh
```

Shows a numbered list of all activities and lets you select which one to switch to.

## Installation

1. Clone this repo
2. Make scripts executable:
```bash
chmod +x create-activity.sh switch-activity.sh
```

3. Optionally, add to your PATH or create symlinks in `~/bin/`

## Tips for Activity Isolation

### Using Firefox with Activities
Firefox works better than Chrome for activity isolation. Launch Firefox with separate profiles per activity:

```bash
firefox -P activity1 -no-remote &
```

The `-no-remote` flag allows multiple Firefox instances to run simultaneously.

Create profiles first:
```bash
firefox -ProfileManager -no-remote
```

### Auto-launching Apps per Activity
You can enhance the switch script to automatically launch Firefox and terminal for each activity by checking if they're already running:

```bash
# Launch Firefox only if not already running with this profile
if ! pgrep -f "firefox.*-P work" > /dev/null; then
    firefox -P work -no-remote &
fi

# Launch terminal
if ! pgrep konsole > /dev/null; then
    konsole &
fi
```

## Requirements

- KDE Plasma 5.x or 6.x
- `qdbus` (usually pre-installed with KDE)
