# Shoot Me Pls

A Godot 4 tactical first-person survival shooter with keyboard/mouse, gamepad and touchscreen controls.

## Starting screen\n- The game opens on a tactical main menu with **Deploy / Start Match**, **Controls**, and **Quit**.\n- Select **Deploy / Start Match** to load into the combat arena.\n\n## Keyboard and mouse
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

## Settings
Press **Escape** or **Start / Options**, then choose **Settings**.
- Mouse look sensitivity slider.
- Controller look sensitivity and stick deadzone sliders.
- Rebind keyboard and mouse actions by selecting a bind and pressing the replacement key or mouse button.
- Rebind controller jump, fire, alternate fire, sprint and pause by selecting a bind and pressing a controller button.
- **Reset defaults** restores the original controls and sensitivity values.

## iPhone / touch
- Left virtual joystick moves.
- Drag the right side of the screen to aim.
- Hold **FIRE** to shoot.
- Tap **JUMP** to jump.
- Pause button opens the menu.

## Visual direction\n- Counter-Strike-inspired tactical presentation: restrained military-industrial palette, compact menu typography, mission briefing and direct match entry.\n- This is an original game and does not use Counter-Strike assets, branding or maps.
- Muted industrial training yard with concrete cover, steel structures and subdued lighting.
- Enemy beans are featureless bean-shaped silhouettes with no eyes, pupils, mouths or facial markings.
- The first-person weapon is a dark low-profile rifle assembled from procedural 3D parts.
- The HUD uses restrained charcoal and muted olive tones rather than bright arcade colours.

## Gameplay
- Concrete perimeter walls and waist-high cover form the combat arena.
- Enemy beans pursue and damage the player.
- Ammo pickups add 30 rounds; medkits restore 35 HP.
- Player health starts at 100.
- The HUD shows health, a live health bar, and ammunition.

The project uses Godot's GL Compatibility renderer for mobile. iOS export still requires Godot export templates, Xcode, an Apple signing team and provisioning profile.
