{
  description = "Screenshot utility using hyprshot and swappy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        swappy-config = pkgs.writeText "swappy-config" ''
          [Default]
          save_dir=$HOME/Pictures/screenshots
          save_filename_format=%Y-%m-%d_%H-%M-%S_edited.png
        '';

        screenshot-script = pkgs.writeShellScriptBin "screenshot" ''
          # Create screenshots directory if it doesn't exist
          SCREENSHOT_DIR="$HOME/Pictures/screenshots"
          mkdir -p "$SCREENSHOT_DIR"

          # Create swappy config directory and config file
          SWAPPY_CONFIG_DIR="$HOME/.config/swappy"
          mkdir -p "$SWAPPY_CONFIG_DIR"
          cat > "$SWAPPY_CONFIG_DIR/config" <<EOF
          [Default]
          save_dir=$HOME/Pictures/screenshots
          save_filename_format=%Y-%m-%d_%H-%M-%S_edited.png
          EOF

          # Generate ISO timestamp filename
          TIMESTAMP=$(date -u +"%Y-%m-%d_%H-%M-%S")
          FILENAME="$SCREENSHOT_DIR/$TIMESTAMP.png"

          # Take screenshot with hyprshot
          ${pkgs.hyprshot}/bin/hyprshot -m region -o "$SCREENSHOT_DIR" -f "$TIMESTAMP.png" 2>/dev/null || exit 0

          # Wait a moment for file to be written
          sleep 0.2

          # Check if file exists
          if [ ! -f "$FILENAME" ]; then
            exit 1
          fi

          echo "Screenshot saved: $FILENAME"

          # Open in swappy for editing
          ${pkgs.swappy}/bin/swappy -f "$FILENAME" 2>/dev/null

          # Check if an edited version was saved
          EDITED_FILES=$(find "$SCREENSHOT_DIR" -name "*_edited.png" -newer "$FILENAME" 2>/dev/null)
          if [ -n "$EDITED_FILES" ]; then
            echo "Edited version saved: $EDITED_FILES"
          fi
        '';
      in {
        packages.default = screenshot-script;

        apps.default = {
          type = "app";
          program = "${screenshot-script}/bin/screenshot";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.hyprshot
            pkgs.swappy
          ];
        };
      }
    );
}
