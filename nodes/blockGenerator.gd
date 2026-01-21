extends VoxelGeneratorScript

const channel : int = VoxelBuffer.CHANNEL_TYPE
var blocks : Array[Vector3i]
func _get_used_channels_mask() -> int:
	return 1 << channel

func _generate_block(buffer : VoxelBuffer, origin : Vector3i, lod : int) -> void:
	if lod != 0:
		return
	buffer.set_voxel(1,randi_range(-8,8),randi_range(-8,8),randi_range(-8,8),channel)
