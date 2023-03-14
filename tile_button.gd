extends Control

var tile_tex
@onready var selector = $selector

var index := -1


func initialize(tex):
	tile_tex = $"Button/Tile Tex"
	
	tile_tex.texture = tex
