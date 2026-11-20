# Shoot Me Pls

A Godot 4 first-person bean survival shooter with keyboard/mouse, gamepad and touchscreen controls.

## Keyboard and mouse
- **WASD** move.
- **Mouse** look around. The cursor is captured when the game starts.
- **Hold left mouse button** to fire.
- **Right mouse button** release or recapture the cursor.
- **Space** jump.
- **Shift** sprint.
- **Escape** pause or resume.

If the cursor is released, click the game window to recapture it.

## Controller
- **Left stick** move.
- **Right stick** aim.
- **A / Cross** jump.
- **Right shoulder (RB / R1)** or **X / Square** fire.
- **Left stick click (L3)** sprint.
- **Start / Options** pause or resume.

Standard Godot gamepad mappings are used. The game reads the first connected controller.

## iPhone / touch
- Left virtual joystick moves.
- Drag the right side of the screen to aim.
- Hold **FIRE** to shoot.
- Tap **JUMP** to jump.
- Pause button opens the menu.

## Gameplay
- Four walls enclose the grass arena.
- Enemy beans chase and damage the player.
- Ammo pickups add 30 rounds; medkits restore 35 HP.
- Player health starts at 100.
- The HUD shows health, a live health bar, and ammunition.

The project uses Godot's GL Compatibility renderer for mobile. iOS export still requires Godot export templates, Xcode, an Apple signing team and provisioning profile.
