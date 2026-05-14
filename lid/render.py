import bpy
import math
import mathutils
import os

out_dir = os.path.dirname(os.path.abspath(__file__))
stl_path = os.path.join(out_dir, "lid.stl")

bpy.ops.wm.read_factory_settings(use_empty=True)

bpy.context.scene.render.engine = 'CYCLES'
bpy.context.scene.cycles.device = 'CPU'
bpy.context.scene.cycles.samples = 64
bpy.context.scene.render.resolution_x = 1200
bpy.context.scene.render.resolution_y = 800
bpy.context.scene.render.resolution_percentage = 100
bpy.context.scene.render.film_transparent = False
bpy.context.scene.render.image_settings.file_format = 'PNG'

world = bpy.data.worlds.new("World")
bpy.context.scene.world = world
tree = world.node_tree
bg = tree.nodes.get("Background")
if bg:
    bg.inputs[0].default_value = (0.82, 0.82, 0.82, 1.0)
    bg.inputs[1].default_value = 0.3

bpy.ops.wm.stl_import(filepath=stl_path)
mesh_objs = [o for o in bpy.data.objects if o.type == 'MESH']

key = bpy.data.lights.new(name="Key", type='SUN')
key.energy = 6.0
key.angle = math.radians(2)
key.color = (1.0, 0.95, 0.9)
key_obj = bpy.data.objects.new("Key", key)
bpy.context.collection.objects.link(key_obj)
key_obj.rotation_euler = (math.radians(50), math.radians(0), math.radians(60))

rim_light = bpy.data.lights.new(name="Rim", type='SUN')
rim_light.energy = 3.0
rim_light.angle = math.radians(1)
rim_light.color = (1.0, 1.0, 1.0)
rim_obj = bpy.data.objects.new("Rim", rim_light)
bpy.context.collection.objects.link(rim_obj)
rim_obj.rotation_euler = (math.radians(15), math.radians(0), math.radians(180))

bottom_light = bpy.data.lights.new(name="Bottom", type='SUN')
bottom_light.energy = 2.5
bottom_light.angle = math.radians(10)
bottom_light.color = (0.9, 0.92, 1.0)
bottom_obj = bpy.data.objects.new("Bottom", bottom_light)
bpy.context.collection.objects.link(bottom_obj)
bottom_obj.rotation_euler = (math.radians(150), math.radians(0), math.radians(-30))

mat = bpy.data.materials.new(name="PETG")
mat.use_nodes = True
nodes = mat.node_tree.nodes
links = mat.node_tree.links

bsdf = nodes.get("Principled BSDF")
bsdf.inputs["Base Color"].default_value = (0.10, 0.28, 0.48, 1.0)
bsdf.inputs["Roughness"].default_value = 0.45
bsdf.inputs["IOR"].default_value = 1.57

tex_coord = nodes.new('ShaderNodeTexCoord')

wave = nodes.new('ShaderNodeTexWave')
wave.wave_type = 'BANDS'
wave.bands_direction = 'Z'
wave.inputs['Scale'].default_value = 600.0
wave.inputs['Distortion'].default_value = 0.3
wave.inputs['Detail'].default_value = 2.0
wave.inputs['Detail Scale'].default_value = 1.0

bump_layers = nodes.new('ShaderNodeBump')
bump_layers.inputs['Strength'].default_value = 0.15
bump_layers.inputs['Distance'].default_value = 0.001

links.new(tex_coord.outputs['Object'], wave.inputs['Vector'])
links.new(wave.outputs['Fac'], bump_layers.inputs['Height'])

noise_fine = nodes.new('ShaderNodeTexNoise')
noise_fine.inputs['Scale'].default_value = 800.0
noise_fine.inputs['Detail'].default_value = 8.0
noise_fine.inputs['Roughness'].default_value = 0.7

bump_grain = nodes.new('ShaderNodeBump')
bump_grain.inputs['Strength'].default_value = 0.12
bump_grain.inputs['Distance'].default_value = 0.0005

links.new(tex_coord.outputs['Object'], noise_fine.inputs['Vector'])
links.new(noise_fine.outputs['Fac'], bump_grain.inputs['Height'])
links.new(bump_grain.outputs['Normal'], bump_layers.inputs['Normal'])
links.new(bump_layers.outputs['Normal'], bsdf.inputs['Normal'])

noise_rough = nodes.new('ShaderNodeTexNoise')
noise_rough.inputs['Scale'].default_value = 200.0
noise_rough.inputs['Detail'].default_value = 4.0

map_range = nodes.new('ShaderNodeMapRange')
map_range.inputs['From Min'].default_value = 0.0
map_range.inputs['From Max'].default_value = 1.0
map_range.inputs['To Min'].default_value = 0.35
map_range.inputs['To Max'].default_value = 0.55

links.new(tex_coord.outputs['Object'], noise_rough.inputs['Vector'])
links.new(noise_rough.outputs['Fac'], map_range.inputs['Value'])
links.new(map_range.outputs['Result'], bsdf.inputs['Roughness'])

for obj in mesh_objs:
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    bpy.context.view_layer.objects.active = obj
    mod = obj.modifiers.new(name="EdgeSplit", type='EDGE_SPLIT')
    mod.split_angle = math.radians(30)

min_c = mathutils.Vector((float('inf'),) * 3)
max_c = mathutils.Vector((float('-inf'),) * 3)
for obj in mesh_objs:
    for corner in obj.bound_box:
        wc = obj.matrix_world @ mathutils.Vector(corner)
        min_c = mathutils.Vector((min(min_c[i], wc[i]) for i in range(3)))
        max_c = mathutils.Vector((max(max_c[i], wc[i]) for i in range(3)))

center = (min_c + max_c) / 2
size = max_c - min_c
max_dim = max(size.x, size.y, size.z)

cam_data = bpy.data.cameras.new("Camera")
cam = bpy.data.objects.new("Camera", cam_data)
bpy.context.collection.objects.link(cam)
bpy.context.scene.camera = cam
cam.data.type = 'PERSP'
cam.data.lens = 50

d = max_dim * 2.5

def aim_camera(location, target):
    cam.location = location
    direction = mathutils.Vector(target) - mathutils.Vector(location)
    rot_quat = direction.to_track_quat('-Z', 'Y')
    cam.rotation_euler = rot_quat.to_euler()

views = {
    "assembled-top": (
        (center.x + d * 0.45, center.y - d * 0.45, center.z + d * 0.75),
        center,
    ),
    "assembled-bottom": (
        (center.x + d * 0.45, center.y - d * 0.45, center.z - d * 0.75),
        center,
    ),
    "assembled-side": (
        (center.x + d * 0.05, center.y - d * 0.95, center.z + d * 0.2),
        center,
    ),
}

for name, (loc, target) in views.items():
    aim_camera(loc, target)
    bpy.context.scene.render.filepath = os.path.join(out_dir, name + ".png")
    bpy.ops.render.render(write_still=True)
    print(f"Rendered {name}")

print("Done!")
