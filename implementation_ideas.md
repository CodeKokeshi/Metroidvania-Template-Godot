# Metroidvania Idea Stack (Structured, Asset-Driven, Scope-Safe)

## 1. Core Direction (Do Not Break These Rules)
- Small game target: small connected world, 1 boss max, clear ability gating.
- Animation constraint: player has 2 frames only (ground + hop). Use squash/stretch, weapon FX, and hit effects for action feel.
- No-hand advantage: player body stays simple while combat is fully carried by a separate floating weapon actor.
- No animation-heavy movement systems (no wall climb, no ledge shimmy, no complex weapon combos).
- Every new idea must answer:
  - What existing asset does this reuse?
  - What gate does this unlock?
  - Is this S or M effort? (If L, park it.)

## 2. Player Kit Expansion (No-Hand Advantage -> Distinct Identity)

### 2.1 Base Combat/Movement (Must Have)
1. Floating Weapon Rig (core architecture) -> Done
- Weapon is a separate node attached to player pivot. -> Done
- Same rig can swap behavior: sword slash mode and gun mode. -> Done
- This is the main identity: body does movement, floating weapon does combat animation. -> Done
- Gate role: enables all combat interactions without adding body animation debt. -> Done
- Effort: S.

2. Slash (short range arc) -> Done
- Use floating sword sprite/effect, not body animation. -> Done
- Can break fragile obstacles and damage enemies. -> Not Yet
- Gate role: opens soft-block paths. -> Not Yet
- Effort: S.

3. Dash (cooldown burst)
- Horizontal only (left/right), no vertical dash.
- Movement + i-frames window + hitbox while dashing.
- Can be chained into slash for "dash cut".
- Gate role: pass dash barriers and avoid timed hazards.
- Effort: S-M.

4. Pogo (down-slash bounce) -> Done
- Trigger only on enemy/trap hit from above (no free mid-air pogo). -> Done
- Pogo is consistent and simple: one bounce strength for all valid pogo contacts. -> Done
- Gate role: vertical routing without double jump. -> Done
- Effort: S.

5. Gun (floating sidearm mode) -> Done
- Fire from floating weapon, independent of player body animation. -> Done
- Start simple: 8 shots, (0.5 sec duration for each bullet) low fire rate, light knockback, 1 sec reload system. -> Done
- Gate role: ranged switches, safe poke, enemy state control. -> Not Yet
- Effort: S-M.

### 2.2 Distinct Upgrades (High Value, Low Art Cost)
1. Charged Slash
- Hold attack briefly for thicker arc that breaks "reinforced" obstacles.
- Uses same slash asset, just scale/color/timing changes.
- Gate role: hard-block destruction tier.
- Effort: S.

2. Mark Dash (dash leaves temporary marker)
- First dash plants a mark; second dash within short time snaps back to mark.
- Gives fake "teleport skill" feel without full portal complexity.
- Gate role: timed door traversal, hazard crossing.
- Effort: M.

3. Recoil Shot (late-game downward blast) --> Done
- Fire gun downward in air to gain upward recoil boost.
- This is a controlled pseudo-double-jump for late game routing.
- Uses no new body animation; all feedback lives on weapon muzzle flash + player squash/stretch.
- Gate role: late vertical access and recovery routes.
- Effort: M.

### 2.3 Portal Skill Rework (Make It Legit, Not Cheat-Only)
Portal stays in, but controlled:
- Two shots max (entry/exit), limited range, line-of-sight placement rules.
- Cannot place in boss room or moving platforms.
- Add "portal lock" surfaces (certain walls only).
- Gate role: late-game route compression + optional secrets.
- Effort: M (not L if surface rules are strict).

## 3. Ability Gating Map (Minimal but Meaningful)

Use 5 gate types only:
1. Soft Break Gate
- Needs basic slash.
- Assets: bottles/wine glass, weak claw-enemy barricades.

2. Speed Gate
- Needs dash.
- Assets: saw corridors, conveyor + spike lanes, timed button doors.

3. Vertical Skill Gate
- Needs pogo or recoil-shot mastery.
- Assets: spike floors with safe enemy bounce targets, jump pad chains.

4. Logic Gate
- Needs lever/button/key + maybe charged slash.
- Assets: keyhole gold block, exclamation gold block, lever states.

5. Ranged Trigger Gate
- Needs gun (and late recoil-shot for advanced variants).
- Assets: buttons at distance, risky saw corridors where melee is bad, target blocks.

Foreshadowing rule for all gate types:
- Show unreachable examples of the gate before teaching the full solution.
- First seen: tease only. Second seen: partial interaction. Third seen: full solve.

## 4. Level Design Ideas (Foreshadowing + Asset-Driven Rooms)

### 4.1 Unreachable-First Language (Blasphemous-style payoff)
1. Start area tease platform
- In the first playable zone, show one obvious ledge near start that cannot be reached yet.
- Put a visible reward silhouette (coin, door frame, bottle cluster) so it stays in memory.

2. Early ladder frustration hook
- Teach ladder in a safe lane, then show a second ladder that starts above jump height.
- Player immediately understands: "I know this mechanic, but I need a later tool."

3. Fast payoff rule
- Every teased unreachable in early zones should become reachable within 20-30 minutes.
- Keep the promise short so backtracking feels rewarding.

### 4.2 Directional Lever Routing (New Core Idea)
Use 3-state lever as room router:
1. Lever left -> open left route/door, close right route.
2. Lever right -> open right route/door, close left route.
3. Lever neutral -> either all closed or opens a third route (choose one rule per room and telegraph it clearly).

Good uses:
- Route commitment: choose combat-heavy left or puzzle-heavy right.
- Shortcut unlock: neutral state opens central return door after both side paths are done.
- Timed pressure: flip lever then dash to selected lane before it resets.

### 4.3 Room Recipes (Combined, No Duplicates)
1. Conveyor + Saw + Claw lane
- Conveyor pushes player into hazard pressure; claw blocks clean path.
- Solve with dash timing, slash clearance, or ranged trigger.

2. Ladder-over-hazard strip
- Ladder is reachable by pogoing over robot heads above spikes.
- Keeps pogo simple and always readable.

3. Gun utility lane
- Distant button is visible; melee route is intentionally riskier.
- Teaches gun as utility, not only DPS.

4. Acid valve crossroom
- Green flow blocks lower path until valve/lever toggle is hit.
- Draining it reveals a clean return shortcut.

5. Rope anchor dash corridor
- Anchors mark safe rhythm points while floor hazards punish hesitation.
- Reinforces horizontal dash identity.

6. Jump pad clarity room
- Jump pad is only for high bounce.
- Touch pad -> immediate boost, no extra rules.

### 4.4 Tease Catalog (Show Early, Resolve Later)
1. High ladder start point out of reach.
2. Gold keyhole block near start, key seen behind later gate.
3. Distant button visible through a gap.
4. Bottle/wine-glass cluster behind reinforced route.
5. Locked door visible now, reachable from a wrapped path later.

### 4.5 Room Complexity Limits
1. One primary idea per room.
2. Early game: max two interacting hazards.
3. If a room uses three systems, one should be passive.
4. Give one safe reset tile before each retry segment.

## 5. Enemy Ideas Using Current Sprites (No New Big Art, All Pogoable)
1. Face Saw (stationary spiky face)
- Role: patrol hazard drone (contact damage).
- New twist: toggles between "slow orbit" and "rush line" when player enters cone range.
- Counterplay: dash through timing or slash stun window.

2. Sponge Square (happy/angry)
- Role: mood-state ranged enemy.
- Happy: passive drift. Angry: squeezes water shots.

3. Crab Claw Spike
- Role: destructible blocker enemy.
- Consistent rule: always damageable by slash/gun regardless of open/closed frame.
- Use as pressure obstacle that occupies tight routes.

4. Small Spike Robot (crawl + hide)
- Role: rhythm tank.
- Damage rule can still vary by state, but pogo always works in all states.

5. Small Smooth Robot (crawl + hide, no spike)
- Role: bait enemy.
- New twist: fakes hide cadence then suddenly lunges.

6. Big Smooth Robot
- Role: mini-warden.
- New twist: body-blocks corridors and forces dash reposition.

7. Winged Robot Flyer
- Role: aerial pressure.
- Needle shooter behavior: attacks from distance, stops attacking when player gets close, retreats to resume ranged pressure.

## 6. Optional "Imagine" Additions (Keep Only If Time Remains)

1. Echo Slash
- Charged slash sends a delayed phantom slash along the same path.
- Uses duplicated slash VFX, no new character animation.
- Use for hitting behind grates or delayed switches.
- Effort: M.

2. Aggro Relay Rooms
- Buttons require enemy body presence (enemy stands on button).
- Player manipulates enemy behavior to solve route.
- Effort: M.

3. Heat/Cool Surface Tags
- Same tile, different logic state by room trigger.
- Example: acid pipe room heated -> steam burst hazards; cooled -> safe platform windows.
- Effort: M (logic heavy, art light).

4. Fake Save Flag Traps (Optional spice)
- Some flags are checkpoints, some are bait that spawn short ambush.
- Use carefully (1-2 in whole game) to avoid frustration.
- Effort: S.

## 7. Scope Guardrails (Anti-Scope-Creep Rules)
- Hard cap abilities at 5 active systems:
  - Floating weapon core (sword + gun)
  - Horizontal dash
  - Pogo
  - One advanced mobility system (Recoil Shot OR Mark Dash for v1)
  - Optional late utility (Portal only if previous systems are done)
- Hard cap enemy families at 5 for first release (variants allowed).
- Hard cap puzzle depth:
  - Max 2-step logic in normal rooms
  - Max 3-step logic in one optional challenge room
- Boss phase cap: 2 phases max.
- If a feature needs new multi-frame character animation, auto-park it.

## 8. Practical Priority Stack (Ideas, Not Full Production Plan)
1. Priority A (Implement First)
- Floating sword slash, horizontal dash, enemy-dependent pogo core loop.
- Base gun shot (single projectile, low rate).
- 3 enemy archetypes: saw, sponge, crawl-hide robot.
- 4 gate types: soft break, speed, vertical, ranged trigger.

2. Priority B (Make It Distinct)
- Charged Slash.
- Late-game Recoil Shot (downward gun boost).
- Either Mark Dash OR Portal (strict surfaces), not both in first pass.
- Conveyor + timed button room templates.

3. Priority C (Optional Flavor)
- Echo Slash.
- Aggro relay puzzle room.
- Acid flow control set piece.

## 9. Quick "Kill List" (Do Not Do For v1)
- Wall climbing systems.
- Complex combo trees.
- Multiple full gun archetypes (shotgun, beam, rockets, etc.) for v1.
- More than one boss.
- Any idea requiring major new sprite animation sets.

---

Use this doc as an idea filter:
- If new idea reuses existing sprite logic and creates a clear gate, keep it.
- If new idea requires many new animations or does not unlock exploration routes, park it.
