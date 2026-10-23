extends Node

var items: Array[Item]

# Index: the probabilities for a player in position n-1
# Value: array of floats which sums to 1, representing probabilities of items in above order
var place_weight_distributions: Array[Array]

func _ready():
	# Populates item_weights with all items in weights.csv, using its weights and the resources in BASE_PATH
	
	const BASE_PATH = "res://Resources/Items/" # This path must have a tres file which corresponds to each item
	
	# Gets data from weights.csv as a dictionary
	# Keys: Item name as used in tres file name, ex: spike_ring
	# Values: Array of floats, indicating weight at first through last place
	var item_name_weights: Dictionary = preload("uid://u1o804vjh5hf").header_records
	
	var item_names = item_name_weights.keys()
	
	place_weight_distributions.resize(Globals.player_count)
	
	for item_name in item_names:
		var weights = item_name_weights[item_name]
		for place in range(place_weight_distributions.size()):
			place_weight_distributions[place].append(weights[place])
	
	for weight_distribution in place_weight_distributions:
		var weight_sum = 0.0
		for item_value in weight_distribution:
			weight_sum += item_value
		
		for item_index in range(weight_distribution.size()):
			weight_distribution[item_index] /= weight_sum
	
	items.resize(item_names.size())
	var item_dir = DirAccess.open(BASE_PATH)
	item_dir.list_dir_begin()
	var file_name = item_dir.get_next()
	while file_name != "":
		if item_dir.current_is_dir:
			var potential_files: Array = ResourceLoader.list_directory(BASE_PATH + file_name)
			for potential_file in potential_files:
				if potential_file.split(".")[0] in item_names and potential_file.split(".")[1] == "tres":
					var found_file: Item = load(BASE_PATH+file_name+"/"+potential_file)
					items[item_names.find(potential_file.split(".")[0])] = found_file
		file_name = item_dir.get_next()
	assert(items.count(null) == 0, "The %s item(s) have not been found in %s, end result is %s" % [items.count(null), BASE_PATH, items])

func get_random_item(place: int) -> Item:
	"""
	Generate a random item to give to a player at place
	"""
	var weight_distribution = place_weight_distributions[place-1]
	var item_index = -1
	var value_index: float = randf()
	while value_index >= 0 and item_index < weight_distribution.size()-1:
		value_index -= weight_distribution[item_index + 1]
		item_index += 1
	return items[item_index]
