extends Resource
class_name LevelData

@export var level_id: int = 0
@export var level_cleared: bool = false
@export var time_target: float = 30.0
@export var player_damaged: bool = false
@export var stage_finished: bool = false
@export var player_time: float
@export var player_time_string: String = "00:00:000"
@export var target_time_reached: bool = false
@export var total_stars: int = 0
