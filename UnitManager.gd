extends Node2D


var world 

@onready var player_prefab = preload("res://player.tscn")


var spawned_players = {}


# Called when the node enters the scene tree for the first time.
func initialize():
	
	world = get_tree().get_nodes_in_group("World")[0]


func spawn_player(_pos) -> void:
	var p = player_prefab.instantiate()
	add_child(p)
	var id = spawned_players.size()
	spawned_players[id] = p
	
	p.position = _pos
