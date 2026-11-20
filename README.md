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
