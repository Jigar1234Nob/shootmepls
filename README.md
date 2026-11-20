# Shoot Me Pls

A Godot 4 tactical first-person survival shooter with keyboard/mouse, gamepad and touchscreen controls.

## Main menu
- Deploy starts a match.
- Controls opens a dedicated field-manual page.
- Main menu and controls page credit **Jigar Rai**.

## Keyboard and mouse
- **WASD** move.
- **Mouse** look around.
- **Hold left mouse button** to fire.
- **Right mouse button** release or recapture the cursor.
- **Space** jump.
- **Shift** sprint.
- **Escape** pause or resume.

## Controller
- **Left stick** move.
- **Right stick** aim.
- **A / Cross** jump.
- **Right shoulder (RB / R1)** or **X / Square** fire.
- **Left stick click (L3)** sprint.
- **Start / Options** pause or resume.
- Controller look sensitivity and deadzone can be changed in Settings.

## Settings
Press **Escape** or **Start / Options**, then choose **Settings**.
- Mouse sensitivity slider.
- Controller look sensitivity and stick deadzone sliders.
- Rebind keyboard/mouse actions and controller buttons.
- **Reset defaults** restores the original controls and sensitivity values.
- Settings are saved locally in `user://settings.cfg`.

## iPhone / touch
- Left virtual joystick moves.
- Drag the right side of the screen to aim.
- Hold **FIRE** to shoot.
- Tap **JUMP** to jump.
- Pause button opens the menu.

## Gameplay
- Featureless bean-shaped enemies: no eyes, mouths, faces or facial markings.
- Industrial yard with container stacks, concrete barriers, lane markings and cool blue daylight over a charcoal/grey environment.
- Projectiles visibly leave the rifle muzzle and travel toward the crosshair.
- Enemy health bars appear only after that enemy is hit.
- Clear every enemy to advance to the next wave.
- Enemy count and durability increase as waves progress.
- Every fifth wave (5, 10, 15, 20, ...) includes a boss with five times the base enemy health.
- Each wave supplies only a small, fixed number of ammo and medical pickups. Uncollected supplies are cleared when the next wave begins.
- Dying automatically restarts the match from wave 1.
- Choosing **Quit to Main Menu** from the in-game pause menu returns to the title screen.

This is an original game and does not use Counter-Strike assets, branding or maps. The project uses Godot's GL Compatibility renderer for mobile. iOS export still requires Godot export templates, Xcode, an Apple signing team and provisioning profile.

**Created by Jigar Rai.**


## Build an iOS IPA with GitHub Actions

The repository includes an iOS export preset and a macOS GitHub Actions workflow at `.github/workflows/build-ios-ipa.yml`. It exports the Godot project, archives it with Xcode, signs it for Ad Hoc installation, and uploads `ShootMePls-iOS.ipa` as a workflow artifact.

### One-time Apple signing setup

You need an active Apple Developer Program membership and an **Ad Hoc** provisioning profile for bundle ID `au.jigar.shootmepls`. The profile must include the UDIDs of the iPhones/iPads that will install the IPA.

Add these repository secrets under **Settings → Secrets and variables → Actions**:

- `APPLE_TEAM_ID`: your 10-character Apple Developer Team ID.
- `APPLE_CERTIFICATE_BASE64`: base64 contents of your Apple Distribution `.p12` certificate.
- `APPLE_CERTIFICATE_PASSWORD`: password used when exporting that `.p12`.
- `IOS_PROVISIONING_PROFILE_BASE64`: base64 contents of the Ad Hoc `.mobileprovision` profile.

On macOS, generate the base64 values with `base64 -i Certificate.p12 | pbcopy` and `base64 -i Profile.mobileprovision | pbcopy`, then paste each into its matching GitHub secret. Keep the certificate and profile private.

### Run it

1. Open the repository's **Actions** tab.
2. Select **Build iOS IPA**.
3. Choose **Run workflow** on `main`.
4. When the run finishes, open its summary and download the `ShootMePls-iOS-IPA` artifact.

The workflow also runs on relevant pushes to `main`. This is an Ad Hoc signed IPA, not an App Store submission. The provisioning profile must include the target device UDIDs. Godot's iOS exporter requires macOS/Xcode and matching export templates; see the [official Godot iOS export guide](https://docs.godotengine.org/en/4.3/tutorials/export/exporting_for_ios.html).


## Performance and visual polish update

- Reduced rendering overhead by disabling real-time directional shadows and removing the four dynamic point lights from the industrial yard.
- Perimeter posts and overhead bars now use bright emissive white materials.
- Enemy beans are featureless neon-red silhouettes with no facial details.
- Enemy steering refreshes on staggered short intervals instead of recalculating target direction in lockstep every physics frame. Beans pursue, strafe, and continue patrolling if the player is temporarily unavailable.
- Physics interpolation is enabled to improve perceived movement smoothness.
- Main menu, controls page, gameplay HUD, pause menu, and settings are rendered in screen-space UI layers so they remain attached to the display rather than the 3D world.

These are source-level changes. The project still needs to be opened and profiled in Godot on target hardware to confirm actual frame-time improvements.
