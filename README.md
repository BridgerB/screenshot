# Screenshot Utility

A Nix flake that provides a convenient screenshot workflow using hyprshot and
swappy.

## Features

- Takes region-based screenshots using `hyprshot`
- Automatically saves to `~/Pictures/screenshots/`
- Filenames use ISO timestamp format: `YYYY-MM-DD_HH-MM-SS.png`
- Automatically opens captured screenshot in `swappy` for editing/annotation
- Edited screenshots save to the same directory with `_edited` suffix
- Auto-configures swappy to use the screenshots directory

## Requirements

- Nix with flakes enabled
- Hyprland (for hyprshot to work)

## Usage

### Run directly

```bash
nix run
```

### Build and run

```bash
nix build
./result/bin/screenshot
```

### Add to your NixOS configuration

```nix
{
  inputs.screenshot.url = "github:yourusername/screenshot";
  # or use path if local: inputs.screenshot.url = "path:/path/to/screenshot";
}
```

Then add to your packages:

```nix
environment.systemPackages = [
  inputs.screenshot.packages.${pkgs.system}.default
];
```

### Use in a development shell

```bash
nix develop
```

## How it works

1. Creates `~/Pictures/screenshots/` directory if it doesn't exist
2. Auto-configures swappy to save to the screenshots directory
3. Runs `hyprshot -m region` to let you select a screen region
4. Saves the screenshot with an ISO timestamp filename
5. Automatically opens the screenshot in swappy for editing
6. When you save in swappy, the edited version is saved to the same directory

## Example filenames

**Original screenshot:**

```
2025-10-18_14-30-45.png
```

**After editing and saving in swappy:**

```
2025-10-18_14-30-45_edited.png
```

Both files are saved in `~/Pictures/screenshots/`

## Keybinding suggestion

Add this to your Hyprland config to bind the screenshot tool:

```
bind = $mainMod SHIFT, S, exec, /path/to/result/bin/screenshot
# or if installed system-wide:
bind = $mainMod SHIFT, S, exec, screenshot
```
