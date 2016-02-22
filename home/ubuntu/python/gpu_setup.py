import bpy
bpy.context.user_preferences.system.compute_device_type = 'CUDA'
bpy.context.user_preferences.system.compute_device = 'CUDA_0'
bpy.context.scene.cycles.device = 'GPU'

for scene in bpy.data.scenes:
    scene.render.tile_x = 256
    scene.render.tile_y = 256

