@tool
extends EditorExportPlugin


func _get_name() -> String:
	return "update_version"


func _begin_customize_resources(platform: EditorExportPlatform, features: PackedStringArray) -> bool:
	return not "editor" in features


func _customize_resource(resource: Resource, path: String) -> Resource:
	if path != "res://version.tres":
		return null
	
	var output := []
	var script_path := ProjectSettings.globalize_path("res://get-version.sh")
	var exit_code := OS.execute(script_path, [], output, true)
	
	if exit_code != 0:
		var message = "Failed to run the get-version.sh script.\n" + \
			"The generated game will not display version information correctly.\n" + \
			("\n".join(output))
		
		push_error(message)
		
		# Is there no way to abort??
		return null
	
	var results = output[0].split("\n")
	var version = results[0]
	var commit = results[1]
	
	resource.data.version = version
	resource.data.commit = commit
	return resource


func _customize_scene(scene: Node, path: String) -> Node:
	return null


func _get_customization_configuration_hash() -> int:
	return randi() # Never cache, hopefully (?)
