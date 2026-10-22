@tool
extends EditorImportPlugin

enum Delimiters { COMMA, TAB }


func _get_importer_name():
	return "com.timothyqiu.godot-csv-importer"


func _get_visible_name():
	return "CSV Data"


func _get_priority():
	# The built-in Translation importer needs a restart to switch to other importer
	return 2.0

func _get_import_order():
	return 0

func _get_recognized_extensions():
	return ["csv", "tsv"]


func _get_save_extension():
	return "res"


func _get_resource_type():
	return "Resource"


func _get_import_options(_path, preset):
	var delimiter = Delimiters.COMMA

	return [
		{name="delimiter", default_value=delimiter, property_hint=PROPERTY_HINT_ENUM, hint_string="Comma,Tab"},
		{name="detect_numbers", default_value=false},
		{name="force_float", default_value=true},
	]


func _get_option_visibility(_path, option, options):
	return true	# Godot does not update the visibility immediately
	if option == "force_float":
		return options.detect_numbers
	return true


func _import(source_file, save_path, options, platform_variants, gen_files):
	var delim: String
	match options.delimiter:
		Delimiters.COMMA:
			delim = ","
		Delimiters.TAB:
			delim = "\t"

	var file = FileAccess.open(source_file, FileAccess.READ)
	if not file:
		printerr("Failed to open file: ", source_file)
		return FAILED

	var lines = []
	while not file.eof_reached():
		var line = file.get_csv_line(delim)
		if options.detect_numbers and lines.size() > 0:
			var detected := []
			for field in line:
				if not options.force_float and field.is_valid_int():
					detected.append(int(field))
				elif field.is_valid_float():
					detected.append(float(field))
				else:
					detected.append(field)
			lines.append(detected)
		else:
			lines.append(line)
	file.close()

	# Remove trailing empty line
	if not lines.is_empty() and lines.back().size() == 1 and lines.back()[0] == "":
		lines.pop_back()

	var data = preload("csv_data.gd").new()

	if not lines.is_empty():
		var headers = lines[0]
		for header in headers:
			data.header_records[header] = []
		for i in range(1, lines.size()):
			var fields = lines[i]
			if fields.size() > headers.size():
				printerr("Line %d has more fields than headers" % i)
				return ERR_PARSE_ERROR
			for j in headers.size():
				var name = headers[j]
				var value = fields[j] if j < fields.size() else null
				data.header_records[name].append(value)
	data.records = lines

	var filename = save_path + "." + _get_save_extension()
	var err = ResourceSaver.save(data, filename)
	if err != OK:
		printerr("Failed to save resource: ", err)
	return err
