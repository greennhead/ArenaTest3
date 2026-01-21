extends Node3D

@export var voxelTerrain : VoxelTerrain
@onready var voxelTool : VoxelTool = voxelTerrain.get_voxel_tool()
@onready var mapLoader: Node3D = $mapLoader


func dig(pos :Vector3, power : float):
	voxelTool.mode = VoxelTool.MODE_REMOVE
	voxelTool.do_sphere(pos,power)
