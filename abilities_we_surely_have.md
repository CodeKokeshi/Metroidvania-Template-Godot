Developed Movements / Abilities we surely have.

By default or at the start we have to ensure that the player only has these:
1. The ability to move around horizontally (walk)
2. The ability to jump (the player can only jump once, no double jumps. Double jumps will never be a thing in this game, we want to focus on alternative double jumps such as pogoing and recoil jumps.)
3. The ability to slash (attack only horizontally)
4. The ability to climb ladders.

Abilities to be unlocked but already developed (basically abilities that the player doesn't start with):
1. Pogoing / Vertical Slashing
2. Gun / Ranged Attack along side Recoil Jumps
3. Dashing horizontal and diagonal (no vertical dashes. We already have falling and jumping for vertical movement.)

-- put your works here copilot --

## Player Ability Audit (April 2, 2026)

### Core movement and traversal developed
- Horizontal movement with ground/air acceleration and deceleration is implemented.
- Jump is implemented with coyote time, jump buffer, jump-cut, apex/fall gravity shaping.
- Default extra-air-jump count is 0 (`max_air_jumps = 0`), so no traditional double jump by default.
- Ladder traversal is implemented via contact detection.
- On ladder: left/right movement works, up/down movement works, gravity is cancelled, jump detaches from ladder, and dash can be refreshed while on ladder.
- Ladder animation behavior: walk animation is driven by up/down input; otherwise idle.

### Combat abilities developed
- Sword slash attack is implemented.
- Slash direction supports horizontal plus vertical pitch (up/down) through attack pitch logic.
- Alt attack is implemented as forced downward slash/down-shot shortcut.
- Sword hitbox and slash animation callbacks are implemented.
- Sword pogo is implemented on downward slash contact, with upward bounce and dash reset behavior.
- Sword hit pause manager integration is implemented.
- Sword hit FX pool is implemented.

### Gun and ranged systems developed
- Gun mode exists and can be switched with `switch_weapon`.
- Bullet pooling is implemented (magazine-sized pool).
- Gun fire cooldown, magazine ammo, reload timer, and bullet recall on reload are implemented.
- Gun recoil feedback visuals are implemented (weapon recoil + player recoil squash/offset).
- Gun recoil movement effects are implemented:
	- horizontal push recoil on side shots,
	- upward boost on down-shots,
	- downward drop on up-shots.
- Reload expression sprite behavior is implemented.

### Dash system developed
- Dash is implemented with directional control based on facing + up/down input.
- Behavior is horizontal or diagonal only (no pure vertical dash).
- Dash has isolated movement state, duration, release slowdown, brief hang, and post-dash jump grace.
- Air-dash limitation/reset logic is implemented (`can_air_dash`).
- Dash trail and distortion FX are implemented.

### Health, trap, and respawn systems developed
- Player health API wrapper is implemented in player script (damage/heal/get/set).
- Global health manager autoload is implemented (`HealthManager`).
- Status UI health bar sync is implemented via manager signal.
- Trap detection by physics layer 4 is implemented through hurtbox callback.
- Safe respawn point buffering is implemented with periodic validation:
	- must be grounded,
	- no significant vertical movement,
	- not overlapping hazards,
	- minimum distance from previous safe point.
- Trapped state is implemented: player control locked while trapped animation plays.
- Checkpoint respawn state is implemented: after teleport to safe point, control remains locked until `checkpoint_respawn` animation ends.
- Weapon visuals are hidden during trapped animation and restored after respawn sequence.

### Important reality check vs intended progression in this document
- The intended "start-only" set is not currently enforced by unlock flags.
- The following abilities are currently available in code without unlock gating:
	- vertical slashing,
	- pogo,
	- gun/ranged attacks,
	- recoil jumps,
	- dash.
- The intended rule "slash only horizontally at start" is not currently true in runtime behavior.

### Suggested next step (for progression correctness)
- Add explicit unlock booleans (example: `unlock_vertical_slash`, `unlock_pogo`, `unlock_gun`, `unlock_dash`) and guard input/state transitions with them.

-- do it the next task here --

By default or at the start we only have these:
1. Walk (horizontal movement only) for normal exploration and positioning.
2. Single jump only. No double jump system in this game. Air mobility upgrades will come from alternative jumps (pogo/recoil), not a classic double jump.
3. Horizontal slash only. This is for close enemies and nearby obstacles.
4. Ladder climb for vertical traversal between platforms and rooms.

Abilities to unlock next (separated per upgrade):
1. Vertical slashing upgrade (includes pogo by default).
2. Horizontal ranged shooting upgrade only (no recoil jump included yet).
3. Recoil jump + vertical shooting upgrade.
4. Dash upgrade (horizontal + diagonal only, no pure vertical dash).

Shooting purpose in progression:
1. Early ranged unlock lets the player interact with distant enemies.
2. It also enables distant puzzles, triggers, and obstacles.