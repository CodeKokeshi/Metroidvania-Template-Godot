# Notes: We can't have a lot of things here. This needs to be a small scope game. Small world. One boss. A metroidvania that is not too big, just enough to display that areas are connected and that the player can explore them. We just need the ability to reach them.

# Important Things: The player only has two frames of animation. One standing on the ground and one is hopping. Literally just two frames. To make the player look like he's running I just alternate the two frames. To make it look like he's jumping I only get the "hopping" frame. So the player is very simple. I just use squeeze and stretch to give some sort of animation to the player while doing certain actions. That's why we can't have wall climbing, jumping or whatever because we don't have necessary animations for that. And that's why the attack animation is to be an independent thing, the player has no arms so we can use that to our advantage and make the players imagine that those invisible arms are doing the slashing. But we can't do those shit with wall climbing and other impossible actions so don't ever suggest those.

My Plans
1. The ability to slash enemies and obstacles. This will be the basic attack of the player. It will be a short range attack that can be used to break obstacles and damage enemies.
2. Dashing. This will be a high speed movement. Can be combined with slashing to break "greater" obstacles. It has cooldown, so it can't be used all the time. It can also be used to dodge enemy attacks. Or do the attack itself to the enemies while dashing. Basically a high speed attack.
3. Pogoing. Attacking enemies or traps below the player will cause the player to bounce up. This can be used to reach higher areas or to chain attacks on enemies. It can also be used to break certain obstacles that are only breakable from below.
4. Skills (three at max):
    - Portal Gun (easily doable with basic assets) - Blue circle and red circle. Each corresponds to an exit and entrance. Throwable.

What we currently have.
For now I'll write down the enemies I have in my assets:
1. A stationary saw blade with face. Yeah he doesn't spin. But he's spiky. One frame animation. We can make him float / fly around. A flight type enemy that is metal. Size: Same as Player.
2. A square enemy with a face that changes from happy to angry. Just literally that's what it is. It has just two frames of animation. His design look like a sponge. Size: Same as Player.
3. A stationary object with a crab claw like appearance. Literally it's just a crab-claw that is standing like a normal spike. But it opens and closes. It has two frames of animation. Size: Half of the Player.
4. A crawling robot that has a cute face. It has bobbing animations of 2 frames which make it look like it's crawling. It's appearance is litearlly a crawling cute robot with a single spike on it's top. But it has a third frame. And that's it's hiding. Only the spike is there. We can make it invulnerable when it's hiding! Size: Half of the Player
5. This next robot. Is literally the copy of the previosu robot but no spike. Same behavior, two frames - crawling, and one frame hiding. Size: Half of the Player.
6. Same as number 5 but the size is the same as the player. So a big robot. Same behavior as well.
7. This next enemy is a literal flying enemy with wings. With three frames all are flapping animation, it looks like a bee with bat wings but robot appearance. Size: Same as Player.
8. For the bosses we don't have to think of them for now. I'm planning to use the other player assets for it. (The player has 4 variations, I'm using the variation 1). But all are same situation. All are 24x24, has 2 frames. And with the player logic of not having an arm we can just make the boss like that. We can make some bosses fly. Use patterned attack and so on. But let's not think about it for now.

Next I'll write down the tileset I got but I'll exclude the blocks. I'll only detail the "environment" usable stuff:
Default Tileset: If I didn't say the frame count it's one frame.
1. A lever. It has three frames. Tilted to the left, tilted to the right and neutral.
2. Diamond.
3. Spikes.
4. Flag (2 Variation) - One is short, one is tall. It has two frames that makes it wave.
5. Button - It has two frames. Pressed and unpressed.
6. A jump pad. It has two frames. pressed and stretched.
7. Key
8. Gold Blocks that has four variation (think about the mario mystery block) - First variation, empty block, just gold block. Second variation, it has a keyhole in it. Third variation, it has a exclamation mark in it. Fourth variation, it has a circle on it.
9. Well, I think I'll include the ladder here.
10. There's also ropes. Horizontal and vertical. There are also this metal where the rope are attached so think of it like this. Ropes are only there when we got this metal. We got the sprite for the metal alone. But the rope is dependent on it, meaning the ends of the ropes is always drawn atop the metal. This will spark some ideas.
11. Coin, two frames for spinnning.
12. Water. We can make this swimmable or just a hazard.
13. A door.
That's for the default tileset. Now we have the other expansions.
Food Expansion: This tileset is kind of confusing in a sense because it uses pizzas as spikes. Or burgers as blocks. And it doesn't look threatening at all. But what we got here is a.
1. Pizza - Pointy upwards lookin like a spike.
Note: I think the burger, sushi, onigiri and so on is blocks which we already said we will ignore.
2. Bottles and Wine Glass. I think these can be used as breakable objects, it doesn't have frames for those yet but I can just animate it.
Industrial Expansion:
1. Rope but with hook at the end.
2. An actual saw. Placeable anywhere.
3. A door again.
4. A ladder again.
5. A conveyor belt. We can make this move the player in a certain direction when they stand on it.
6. A green water seemingly toxic or like an acid. But unlike water, we have a tiles here that displays this coming out of the pipe. So we can literally make a thing where we can make it stop from flowing out.

Note to all these expansions. They can all be used together alongside each other. Do not think of them as separate themes. Their blocks can look like a seperate theme but them environment stuff are clearly useable and mixable together.

What we can do as approach are similar to the player.
For example the player has no attack animations right so we leave all the attack animations to the slash animation we're gonna make later on. That principle can be applied to the enemies as well. The saw blade has no attack animation. But it can fly. So we can make it fly around and damage the player on contact.

The square enemy has no attack but it looks like a sponge and it has a happy and angry face. With a little bit of pixel art we can make it "squeeze" out water to attack from long range.

While for the crab claw. Which is by default is literally just a spike with animation, but this time. Instead of an actual environmental spike. We can destroy it. It has lives. So we can turn it into a breakable enemy. We can place it on place that are actually obstructing the player and it forces the player to destroy it.

You get the idea? That's what I want to hear from you when you look at my asset list.

And not only that, we need to focus on the player as well. What are the abilities that we need to implement for the player so we can do the concept of utility/ability gating? Without adding much assets.
