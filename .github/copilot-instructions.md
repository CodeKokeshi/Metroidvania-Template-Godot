1. Stop doing this: @onready var weapon_sprite: Sprite2D = $pivot/weapon-sprite
  this is wrong!
  do this instead and always: @onready var weapon_sprite: Sprite2D = $"pivot/weapon-sprite"
  Basically, always quote if it uses - or any other special character. It is a good practice to always quote, even if it doesn't have special characters, to avoid any potential issues in the future.
