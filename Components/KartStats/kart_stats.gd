## A data container resource for defining the stats of a kart.
class_name KartStats
extends Resource

# Export Vars
@export_custom(PROPERTY_HINT_RANGE, "0.0,5.0,0.1") var base_speed: float ## A value from 0 to 5 determining the speed-based stats of the kart.
@export_custom(PROPERTY_HINT_RANGE, "0.0,5.0,0.1") var base_acceleration: float ## A value from 0 to 5 determining the acceleration-based stats of the kart.
@export_custom(PROPERTY_HINT_RANGE, "0.0,5.0,0.1") var base_boost: float ## A value from 0 to 5 determining the boost-based stats of the kart.
@export_custom(PROPERTY_HINT_RANGE, "0.0,5.0,0.1") var base_handling: float ## A value from 0 to 5 determining the handling-based stats of the kart.
