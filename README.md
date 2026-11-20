# Shoot Me Pls

A Godot 4 first-person bean survival shooter.

## Desktop controls
- **WASD** move.
- **Mouse** look around. The cursor is captured automatically when the game starts.
- **Left mouse button** hold to fire.
- **Right mouse button** release or recapture the cursor.
- **Space** jump.
- **Shift** sprint.
- **Escape** pause or resume.

If the cursor is released, click the game window to recapture it and continue aiming.

## iPhone / touch controls
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
- Damage feedback, weapon movement, and a redesigned pause panel make the game feel more responsive.

The project uses Godot's GL Compatibility renderer for mobile. iOS export still requires Godot export templates, Xcode, an Apple signing team and provisioning profile.
