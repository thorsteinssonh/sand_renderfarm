import bpy
bpy.context.user_preferences.system.compute_device_type = 'NONE'
bpy.context.scene.cycles.device = 'CPU'

for scene in bpy.data.scenes:
    scene.render.tile_x = 64
    scene.render.tile_y = 64
