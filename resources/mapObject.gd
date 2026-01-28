extends Resource
class_name mapObject
@export var properties = {}
@export_file("*.tscn") var node : String
@export var name := "Object"
@export var unlisted := false
@export_category("if your object needs a special menu to pop up for a variable, like when picking a weapon or a texture for example")
@export var specials : Array[SpecialProperty]
