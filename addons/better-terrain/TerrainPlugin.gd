@tool
extends EditorPlugin

const AUTOLOAD_NAME = "BetterTerrain"
var dock : Control
var button : Button

var stored_layer_modulates:Array = []

var tme : Control
var tme_parent : Control
var tme_index : int
var tme_button : Button
var tme_layer_highlight:Button

func _enter_tree() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/better-terrain/BetterTerrain.gd")
	
	dock = load("res://addons/better-terrain/editor/Dock.tscn").instantiate()
	dock.update_overlay.connect(self.update_overlays)
	dock.layer_changed.connect(_on_layer_changed)
	get_editor_interface().get_editor_main_screen().mouse_exited.connect(dock.canvas_mouse_exit)
	dock.undo_manager = get_undo_redo()
	button = add_control_to_bottom_panel(dock, "Terrain")
	button.visible = false
	
	var panel_buttons = button.get_parent().get_children()
	for pbutton in panel_buttons:
		if pbutton is Button:
			if pbutton.text == "TileMap":
				tme_button = pbutton
				break
	
	
	var a = get_editor_interface().get_base_control().get_children()
	var b = a[0].get_children()
	var c = b[1].get_children()
	var d = c[1].get_children()
	var e = d[1].get_children()
	var f = e[0].get_children()
	var g = f[0].get_children()
	var h = g[1].get_children()
	var i = h[0]
	for obj in i.get_children():
		if obj.name.contains("TileMapEditor"):
			tme = obj
			break
	
	if not tme:
		return
	
	tme_parent = tme.get_parent()
	tme_index = tme.get_index()
	
	var tme_a = tme.get_children()
	var tme_b = tme_a[0].get_children()
	for obj in tme_b:
		if obj is Button:
			if obj.tooltip_text == "Highlight Selected TileMap Layer":
				tme_layer_highlight = obj
	
	dock.connect("visibility_changed", func():
		check_tme()
		if not dock.visible:
			fix_tme()
	)
	tme_button.connect("pressed", func():
		fix_tme()
		button.button_pressed = false
		pass
	)
	button.connect("pressed", func():
		if not button.button_pressed and not dock.visible:
			tme.visible = false
	)
	

func check_tme():
	if dock.visible:
		tme.visible = true
		tme.reparent(dock.tme_panel)

func fix_tme():
	if tme and tme_parent:
		tme.reparent(tme_parent)
		tme_parent.move_child(tme, tme_index)
		dock.visible = false

func _exit_tree() -> void:
	fix_tme()
	remove_control_from_bottom_panel(dock)
	dock.queue_free()
	
	remove_autoload_singleton(AUTOLOAD_NAME)


func _handles(object) -> bool:
	return object is TileMap or object is TileSet


func _make_visible(visible) -> void:
	button.visible = visible


func _edit(object) -> void:
	dock.tiles_about_to_change()
	if object is TileMap:
		dock.tilemap = object
		dock.tileset = object.tile_set
		
		stored_layer_modulates = []
		for l in range(object.get_layers_count()):
			stored_layer_modulates.push_back(object.get_layer_modulate(l))
		_on_layer_changed()
	if object is TileSet:
		dock.tileset = object
	if not object:
		fix_tme()
		for l in range(stored_layer_modulates.size()):
			dock.tilemap.set_layer_modulate(l, stored_layer_modulates[l])
		stored_layer_modulates.clear()
	dock.tiles_changed()


func _forward_canvas_draw_over_viewport(overlay: Control) -> void:
	if dock.visible:
		dock.canvas_draw(overlay)


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if !dock.visible:
		return false
	
	return dock.canvas_input(event)

func _on_layer_changed():
	tme_layer_highlight.button_pressed = dock.highlight_layer.button_pressed
	tme_layer_highlight.emit_signal("pressed")
#	var pressed = dock.highlight_layer.button_pressed
#	if stored_layer_modulates.size() == 0:
#		for l in range(dock.tilemap.get_layers_count()):
#			stored_layer_modulates.push_back(dock.tilemap.get_layer_modulate(l))
#	for l in range(dock.tilemap.get_layers_count()):
#		var m = stored_layer_modulates[l]
#		if pressed:
#			if l < dock.layer:
#				m = m.darkened(0.5)
#			elif l > dock.layer:
#				m = m.darkened(0.5)
#				m.a *= 0.3
#		dock.tilemap.set_layer_modulate(l, m)
#
#	if not pressed:
#		stored_layer_modulates.clear()
