extends Node2D

var dialogue_table = {}
var active_dialogue_name = ""
var current_index = 0
var typewriter_speed = 0.8
var typewriter_progress = 0.0
var current_dialogue_end_condition = ""
var dialogue_end_cond_param = null


func _ready():
	var dialogue_file = FileAccess.open("res://data/dialogues.json", FileAccess.READ)
	dialogue_table = JSON.parse_string(dialogue_file.get_as_text())


func _physics_process(_delta):
	# check if a dialogue is currently active
	if active_dialogue_name != "":
		if check_end_condition() && typewriter_progress >= 1.0:
			proceed_dialogue()
	
	# typewriter effect
	if Globals.gameplay_scene_active:
		var dialogue_text_display = get_tree().current_scene.get_node("user_interface/dialogue_box/display_text")
		dialogue_text_display.visible_ratio += typewriter_speed / float(len(dialogue_text_display.get_parsed_text()))
		typewriter_progress = dialogue_text_display.visible_ratio


func check_end_condition():
	var value = false
	match current_dialogue_end_condition:
		"":
			if Input.is_action_pressed("jump"):
				value = true
		"i": # for "input"
			if Input.is_action_pressed(dialogue_end_cond_param):
				value = true
	return value


func modify_text(original_text : String):
	var new_text = ""
	var input_mode = false
	var input = ""
	
	var orig_text_with_header = original_text
	# if "%"(header symbol) is found at index 0 of text, use index 1 as current dialogue end condition
	# see the functionality of each header under 'check_end_condition()'
	if orig_text_with_header[0] == "%":
		current_dialogue_end_condition = orig_text_with_header[1]
		orig_text_with_header = orig_text_with_header.erase(0, 2)
	
	# loop through all characters of original text
	for c in orig_text_with_header:
		# if character is "$", add letters to current input
		if c == "$":
			if input_mode == false:
				input_mode = true
			else:
				input_mode = false
				# if a 2nd "$" is found, take current input and find a keycode
				new_text = new_text + "[color=84ff9b]" + find_key_via_input_action(input) + "[/color]"
				input = ""
		elif input_mode == true:
			input = input + c
		else:
			new_text = new_text + c
	return new_text


func find_key_via_input_action(input : String):
	var input_keycode = ""
	if InputMap.action_get_events(input)[0] is InputEventKey:
		input_keycode = OS.get_keycode_string(InputMap.action_get_events(input)[0].physical_keycode)
	else:
		input_keycode = InputMap.action_get_events(input)[0].as_text()
	return input_keycode


func start_dialogue(dialogue_str_index : String): # you can't acces user interface on the first frame, so only do this 2nd frame and onwards
	active_dialogue_name = dialogue_str_index
	current_index = 0
	proceed_dialogue()


func proceed_dialogue():
	var portrait = null
	if Globals.gameplay_scene_active:
		portrait = get_tree().current_scene.get_node("user_interface/dialogue_box/npc_portrait")
	portrait.texture = null
	current_dialogue_end_condition = ""
	dialogue_end_cond_param = null
	# get table of all text in the current dialogue
	var active_dialogue_table = dialogue_table[active_dialogue_name]
	var text_to_display = ""
	# confirm that current index is within range
	if current_index < len(active_dialogue_table):
		# apply a silly portrait texture if there is one
		if len(active_dialogue_table[current_index]) > 2:
			portrait.texture = load("res://textures/portraits/" + active_dialogue_table[current_index][2] + ".png")
		var raw_text = active_dialogue_table[current_index][0]
		# if char 0 is "%", look for an end condition parameter
		if raw_text[0] == "%":
			dialogue_end_cond_param = active_dialogue_table[current_index][1]
		text_to_display = modify_text(raw_text)
		current_index += 1
	else:
		# no dialogue is active when the last index is reached
		active_dialogue_name = ""
	apply_text_to_user_interface(text_to_display)


func apply_text_to_user_interface(text_to_apply : String):
	if Globals.gameplay_scene_active:
		var dialogue_box = get_tree().current_scene.get_node("user_interface/dialogue_box")
		if text_to_apply != "":
			dialogue_box.get_node("display_text").visible_ratio = 0.0
			#dialogue_box.get_node("display_text").text = text_to_apply
			dialogue_box.get_node("display_text").parse_bbcode(text_to_apply)
			print("Dialogue: " + dialogue_box.get_node("display_text").get_parsed_text())
			if !get_tree().current_scene.dialogue_visible:
				dialogue_box.get_node("anim").play("fade_in")
		else:
			dialogue_box.get_node("anim").play("fade_out")
