## A data class for storing behaviour for throwable items.
class_name ThrowableItem
extends Item

enum WallBehaviour { BOUNCE, DESTROY, SLIDE }

@export var wall_behaviour: WallBehaviour ## Determines what happens when this item hits a wall
@export var damages_karts: bool ## Determines whether this item causes karts to spin out when it hits them.
@export var destroy_on_kart_hit: bool ## Determines if this item is destroyed when it hits a kart.
@export var throw_speed: float ## The speed this item travels at when thrown. Ignored if is_static is true.
@export var is_static: bool ## If true, this item will not move after thrown.
