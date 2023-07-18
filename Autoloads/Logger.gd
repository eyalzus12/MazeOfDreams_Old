extends Node

#wtf - an impossible event. should never get outputted.
#error - something really bad happened. the game might not be able to continue.
#warning - something weird happened. the game can function.
#info - general message.
#log - detail an event.
#debug - use for debugging.

var wtf_list: PackedStringArray
var error_list: PackedStringArray
var warn_list: PackedStringArray
var info_list: PackedStringArray
var log_list: PackedStringArray
var debug_list: PackedStringArray
var need_update: bool = false

func _process(_delta: float) -> void:
	if not need_update:
		return
	if not log_list.is_empty():
		print_rich("\n".join(log_list))
		log_list.clear()
	if not info_list.is_empty():
		print_rich("\n".join(info_list))
		info_list.clear()
	if not warn_list.is_empty():
		print_rich("\n".join(warn_list))
		warn_list.clear()
	if not error_list.is_empty():
		print_rich("\n".join(error_list))
		error_list.clear()
	if not wtf_list.is_empty():
		print_rich("\n".join(wtf_list))
		wtf_list.clear()
	if not debug_list.is_empty():
		print_rich("\n".join(debug_list))
		debug_list.clear()
	need_update = false

func error(s: String, with_stack: bool = true) -> void:
	error_list.push_back("[color=red]ERROR: "+s+"[/color]")
	if with_stack:
		error_list.push_back("[color=red]STACK: "+str(get_stack())+"[/color]")
	need_update = true
func warn(s: String, with_stack: bool = true) -> void:
	warn_list.push_back("[color=yellow]WARN:  "+s+"[/color]")
	if with_stack:
		warn_list.push_back("[color=yellow]STACK: "+str(get_stack())+"[/color]")
	need_update = true
func info(s: String, with_stack: bool = false) -> void:
	info_list.push_back("[color=white]INFO:  "+s+"[/color]")
	if with_stack:
		info_list.push_back("[color=white]STACK: "+str(get_stack())+"[/color]")
	need_update = true
func logs(s: String, with_stack: bool = false) -> void:
	log_list.push_back("[color=gray]LOG:   "+s+"[/color]")
	if with_stack:
		log_list.push_back("[color=gray]STACK: "+str(get_stack())+"[/color]")
	need_update = true
func debug(s: String, with_stack: bool = false) -> void:
	debug_list.push_back("[color=purple]DEBUG: "+s+"[/color]")
	if with_stack:
		debug_list.push_back("[color=purple]STACK: "+str(get_stack())+"[/color]")
	need_update = true
func wtf(s: String, with_stack: bool = true) -> void:
	wtf_list.push_back("[color=orange]WTF??: "+s+"[/color]")
	if with_stack:
		wtf_list.push_back("[color=orange]STACK: "+str(get_stack())+"[/color]")
	need_update = true
