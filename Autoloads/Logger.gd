extends Node

var error_list: PackedStringArray
var warn_list: PackedStringArray
var info_list: PackedStringArray
var debug_list: PackedStringArray
var need_update: bool = false

func _process(_delta: float) -> void:
	if not need_update:
		return
	if not error_list.is_empty():
		print_rich("\n".join(error_list))
		error_list.clear()
	if not warn_list.is_empty():
		print_rich("\n".join(warn_list))
		warn_list.clear()
	if not info_list.is_empty():
		print_rich("\n".join(info_list))
		info_list.clear()
	if not debug_list.is_empty():
		print_rich("\n".join(debug_list))
		debug_list.clear()
	need_update = false

func error(s: String) -> void:
	error_list.push_back("[color=red]ERROR: "+s+"[/color]")
	need_update = true
func warn(s: String) -> void:
	warn_list.push_back("[color=yellow]WARN:  "+s+"[/color]")
	need_update = true
func info(s: String) -> void:
	info_list.push_back("[color=white]INFO:  "+s+"[/color]")
	need_update = true
func debug(s: String) -> void:
	debug_list.push_back("[color=purple]DEBUG: "+s+"[/color]")
	need_update = true
