extends Control

var tile_tex

var index := -1


func initialize(tex):
	tile_tex = $"Button/Tile Tex"
	
	tile_tex.texture = tex
