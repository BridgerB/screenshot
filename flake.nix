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
                    set -x

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

                    echo "Screenshot directory: $SCREENSHOT_DIR"

                    # Generate ISO timestamp filename
                    TIMESTAMP=$(date -u +"%Y-%m-%d_%H-%M-%S")
                    FILENAME="$SCREENSHOT_DIR/$TIMESTAMP.png"

                    echo "Target filename: $FILENAME"

                    # Take screenshot with hyprshot
                    echo "Running hyprshot..."
                    ${pkgs.hyprshot}/bin/hyprshot -m region -o "$SCREENSHOT_DIR" -f "$TIMESTAMP.png" || true
                    HYPRSHOT_EXIT=$?
                    echo "Hyprshot exit code: $HYPRSHOT_EXIT"

                    # Wait a moment for file to be written
                    sleep 0.2

                    # Check if file exists and open in swappy
                    echo "Checking if file exists..."
                    ls -lh "$SCREENSHOT_DIR" | tail -3

                    if [ -f "$FILENAME" ]; then
                      echo "File found! Opening in swappy..."
                      ${pkgs.swappy}/bin/swappy -f "$FILENAME"
                    else
                      echo "Error: Screenshot file not found at $FILENAME"
                      if [ $HYPRSHOT_EXIT -ne 0 ]; then
                        echo "Hyprshot failed or was cancelled (exit code: $HYPRSHOT_EXIT)"
                      fi
                      echo "Contents of screenshot directory:"
                      ls -lh "$SCREENSHOT_DIR"
                      exit 1
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
