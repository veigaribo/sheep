@tool
extends EditorPlugin


var _update_version_plugin: EditorExportPlugin


func _enter_tree():
	const UpdateVersion := preload("res://addons/update_version_on_export/update_version.gd")
	
	_update_version_plugin = UpdateVersion.new()
	add_export_plugin(_update_version_plugin)


func _exit_tree():
	remove_export_plugin(_update_version_plugin)
	pass
