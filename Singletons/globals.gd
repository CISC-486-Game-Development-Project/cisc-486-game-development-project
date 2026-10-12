## A singleton for containing global variables referenced throughout the project.
extends Node

var player_count: int = 1
var player_devices: Array[int] = [-1, -1, -1, -1]
var selected_characters: Array[Character] = [null, null, null, null]
