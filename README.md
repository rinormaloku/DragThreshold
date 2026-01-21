# Drag Threshold Plugin for [OpenTabletDriver](https://github.com/OpenTabletDriver/OpenTabletDriver)

Prevents accidental cursor movement during pen clicks by defining a movement threshold that must be exceeded before cursor movement is registered as a drag.

## Drag Threshold:

**Threshold:** The distance in pixels the pen must move before it is considered a drag. Movement below this threshold will keep the cursor stationary, helping prevent accidental drags during clicks.

- **Default Action:** When the pen tip goes down, the cursor position is locked at the initial contact point. The cursor will not move until the pen moves beyond the set **Threshold** distance.

- **Smooth Transition:** When enabled, the cursor will start moving from the anchor point rather than jumping to the pen's actual position when the threshold is exceeded. This prevents a visual "jump" when the drag begins.

## Use Case:

This plugin is particularly useful for Linux users on Wayland (GNOME/KDE) where compositors often lack a configurable deadzone for tablet input, leading to "jittery" clicks that register as tiny drags. The Drag Threshold plugin provides precise control over when movement should be considered an intentional drag versus a click.

## Building and Testing Locally:

### Prerequisites:
- [.NET 6.0 SDK](https://dotnet.microsoft.com/download/dotnet/6.0) or later
- [OpenTabletDriver](https://github.com/OpenTabletDriver/OpenTabletDriver) installed and running

### Build Steps:

1. **Clone the repository with submodules:**
   ```bash
   git clone --recurse-submodules https://github.com/YOUR_USERNAME/DragThreshold.git
   cd DragThreshold
   ```

   **If you already cloned without submodules, initialize them:**
   ```bash
   git submodule update --init --recursive
   ```

2. **Build the plugin:**
   ```bash
   dotnet build -c Release
   ```

3. **Locate the compiled plugin files:**
   The built files will be located at:
   ```
   DragThreshold/bin/Release/net6.0/DragThreshold.dll
   DragThreshold/bin/Release/net6.0/DragThreshold.deps.json
   ```

### Testing Locally:

#### Method 1: Using the Plugin Manager (Easiest - All Platforms)

1. **Open OpenTabletDriver GUI**
   - Launch the OpenTabletDriver application

2. **Access Plugin Manager:**
   - In the menu bar, click **Plugins** → **Open Plugin Manager** (or **Plugin Directory**)
   - This opens a file manager window to your plugins folder

3. **Install the plugin:**
   - Drag and drop the **entire `DragThreshold` folder** from `DragThreshold/bin/Release/net6.0/` into the plugin directory
   - Alternatively, create a subfolder and copy both files:
     ```bash
     # The plugin directory structure should be:
     # ~/.config/OpenTabletDriver/Plugins/DragThreshold/
     #   ├── DragThreshold.dll
     #   └── DragThreshold.deps.json
     ```

4. **Restart OpenTabletDriver:**
   - Close and reopen the application, or
   - On Linux: `systemctl --user restart opentabletdriver`
   - On Windows: Restart from system tray icon

5. **Enable the plugin:**
   - Go to the **Filters** tab
   - Click **Add Filter**
   - Select **Drag Threshold** from the list
   - Configure the **Threshold** value (default: 5px)
   - Optionally enable **Smooth Transition**
   - Click **Apply** to save settings

6. **Test the plugin:**
   - Use your pen tablet to make short taps (clicks)
   - The cursor should remain stationary during small movements
   - Move the pen beyond the threshold to trigger dragging

#### Method 2: Manual Installation (Linux)

1. **Copy the plugin files to OpenTabletDriver's plugin directory:**
   ```bash
   mkdir -p ~/.config/OpenTabletDriver/Plugins/DragThreshold
   cp DragThreshold/bin/Release/net6.0/DragThreshold.dll ~/.config/OpenTabletDriver/Plugins/DragThreshold/
   cp DragThreshold/bin/Release/net6.0/DragThreshold.deps.json ~/.config/OpenTabletDriver/Plugins/DragThreshold/
   ```

2. **Restart OpenTabletDriver:**
   ```bash
   systemctl --user restart opentabletdriver
   ```

3. **Follow steps 5-6 from Method 1 above**

**Important Notes:**
- The plugin must be in a **subdirectory** (e.g., `Plugins/DragThreshold/`) with both the `.dll` and `.deps.json` files
- Simply copying the DLL to the root Plugins folder will not work
- On Windows, the plugin directory is typically `%localappdata%\OpenTabletDriver\Plugins\`

### Adjusting Settings:

- **Threshold (px):** Start with 5px and adjust based on your preference. Lower values (2-3px) provide more sensitivity, while higher values (7-10px) require more intentional movement to drag.
- **Smooth Transition:** Enable this to prevent cursor "jumping" when you exceed the threshold.

## Contributing:

To contribute this plugin to the OpenTabletDriver ecosystem:

1. **As a Plugin Repository (Recommended):**
   - Create your own GitHub repository for this plugin
   - Submit a PR to [OpenTabletDriver/Plugin-Repository](https://github.com/OpenTabletDriver/Plugin-Repository) to have it listed in the official Plugin Manager

2. **To Core Driver:**
   - If you believe this should be a core feature, submit a PR to [OpenTabletDriver/OpenTabletDriver](https://github.com/OpenTabletDriver/OpenTabletDriver)
   - Note: Maintainers generally prefer keeping specialized input processing as plugins
