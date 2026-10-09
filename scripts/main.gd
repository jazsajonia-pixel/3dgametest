extends Spatial

# THE HUM: Archive of the Drowned
# Procedural, self-contained first-person horror prototype for the Godot 3.x API.

const HALL_LENGTH = 76.0
const MAX_ECHOES = 3
const ECHO_DURATION = 5.0
const ECHO_COOLDOWN = 8.0
const WALK_SPEED = 3.1
const RUN_SPEED = 5.1
const CROUCH_SPEED = 1.55
const GRAVITY = 24.0

var player = null
var camera = null
var flashlight = null
var enemy = null
var enemy_core = null
var enemy_eyes = []
var exit_door = null
var ui_status = null
var ui_objective = null
var ui_hint = null
var ui_message = null
var ui_reticle = null
var darkness_overlay = null
var shards = []
var safe_stations = []
var flicker_lights = []
var echo_rings = []
var pulse_charges = MAX_ECHOES
var echo_timer = 0.0
var pulse_cooldown = 0.0
var battery = 100.0
var torch_on = false
var crouching = false
var enemy_awake = false
var enemy_target = Vector3(0, 0, 0)
var enemy_speed = 1.15
var message_timer = 0.0
var caught = false
var completed = false
var gait_phase = 0.0
var eye_nodes = []
var clock = 0.0
var ambient_player = null
var pulse_player = null
var heart_player = null
var exit_warning = 0.0
var objective_count = 3

func _ready():
	_setup_environment()
	_build_world()
	_build_player()
	_build_enemy()
	_build_pickups()
	_build_hud()
	_set_message("THE ARCHIVE IS LISTENING. Move quietly.", 5.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _setup_audio():
	ambient_player = AudioStreamPlayer.new()
	ambient_player.name = "Archive ambience"
	ambient_player.stream = load("res://assets/audio/archive_hum.wav")
	ambient_player.volume_db = -11.0
	add_child(ambient_player)
	ambient_player.play()
	pulse_player = AudioStreamPlayer.new()
	pulse_player.stream = load("res://assets/audio/echolocation.wav")
	pulse_player.volume_db = -4.5
	add_child(pulse_player)
	heart_player = AudioStreamPlayer.new()
	heart_player.stream = load("res://assets/audio/drowned_heartbeat.wav")
	heart_player.volume_db = -7.0
	add_child(heart_player)

func _setup_environment():
	var world = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.008, 0.014, 0.021)
	env.ambient_light_color = Color(0.19, 0.25, 0.29)
	env.ambient_light_energy = 0.16
	env.fog_enabled = true
	env.fog_color = Color(0.027, 0.055, 0.065)
	env.fog_depth_begin = 8.0
	env.fog_depth_end = 52.0
	env.fog_depth_curve = 1.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.9
	env.glow_enabled = true
	env.glow_intensity = 0.55
	env.glow_bloom = 0.08
	world.environment = env
	add_child(world)

	var moon = DirectionalLight.new()
	moon.light_color = Color(0.32, 0.48, 0.55)
	moon.light_energy = 0.24
	moon.rotation_degrees = Vector3(-48, -23, 0)
	moon.shadow_enabled = true
	add_child(moon)

func _build_world():
	# A single long, flooded concrete service hall, with inset listening alcoves.
	var concrete = _mat(Color(0.105, 0.145, 0.155), 0.18, 0.78)
	var wall_mat = _concrete_material(Color(0.105, 0.135, 0.145), Vector2(18, 18), 0.08, 0.88)
	var ceiling_mat = _concrete_material(Color(0.055, 0.074, 0.081), Vector2(22, 15), 0.06, 0.91)
	var steel = _mat(Color(0.105, 0.15, 0.16), 0.72, 0.34)
	var trim = _mat(Color(0.12, 0.37, 0.38), 0.68, 0.24, Color(0.025, 0.11, 0.11))
	var floor_mat = _concrete_material(Color(0.065, 0.10, 0.11), Vector2(32, 19), 0.48, 0.28)
	var rust = _mat(Color(0.27, 0.11, 0.065), 0.28, 0.75)

	_box(self, "Wet foundation", Vector3(0, -0.33, -25), Vector3(10.6, 0.66, HALL_LENGTH + 10), floor_mat, true)
	var wall_sections = [[5.14, 21.72], [-15.0, 13.44], [-31.0, 13.44], [-53.14, 25.72]]
	for section in wall_sections:
		_box(self, "West wall section", Vector3(-5.05, 2.55, section[0]), Vector3(0.56, 5.1, section[1]), wall_mat, true)
		_box(self, "East wall section", Vector3(5.05, 2.55, section[0]), Vector3(0.56, 5.1, section[1]), wall_mat, true)
	_box(self, "Ceiling slab", Vector3(0, 5.28, -25), Vector3(10.6, 0.42, HALL_LENGTH + 10), ceiling_mat, true)

	# Worn tile joints and puddled patches break up the long reflections.
	for z in range(-64, 14, 4):
		_box(self, "Floor joint", Vector3(0, 0.012, float(z)), Vector3(9.75, 0.018, 0.035), steel, false)
		if int(abs(z)) % 8 == 0:
			_box(self, "Drain channel", Vector3(0, 0.025, float(z) + 1.6), Vector3(0.38, 0.035, 0.10), steel, false)
	for i in range(18):
		var zpos = -60.0 + float(i) * 4.15
		var xside = -1.0 if i % 2 == 0 else 1.0
		var puddle = _mat(Color(0.19, 0.27, 0.26), 0.04, 0.24, Color(0.018, 0.028, 0.026))
		var patch = _part(self, SphereMesh.new(), Vector3(xside * (1.1 + float(i % 3) * 0.57), 0.025, zpos), puddle)
		patch.scale = Vector3(0.52 + float(i % 3) * 0.19, 0.012, 0.24 + float(i % 2) * 0.13)

	# Repeating structural ribs and service conduits.
	for i in range(11):
		var z = 8.0 - float(i) * 7.0
		_box(self, "Ceiling rib", Vector3(0, 4.98, z), Vector3(9.8, 0.20, 0.28), steel, false)
		_box(self, "West conduit", Vector3(-4.65, 3.98, z - 2.7), Vector3(0.16, 0.16, 5.35), rust, false)
		_box(self, "East conduit", Vector3(4.65, 3.72, z - 3.8), Vector3(0.12, 0.12, 4.4), steel, false)
		_box(self, "Wall seam", Vector3(-4.74, 1.14, z - 2.9), Vector3(0.055, 0.045, 5.8), trim, false)
		_box(self, "Wall seam", Vector3(4.74, 1.14, z - 2.9), Vector3(0.055, 0.045, 5.8), trim, false)

	# Small recessed listening bays; deliberately open-fronted so the player can slip inside.
	var bay_z = [-7.0, -23.0, -39.0]
	for i in range(bay_z.size()):
		var bz = bay_z[i]
		var side = -1.0 if i % 2 == 0 else 1.0
		var center_x = side * 6.35
		_box(self, "Bay floor", Vector3(center_x, -0.29, bz), Vector3(3.2, 0.58, 8.0), concrete, true)
		_box(self, "Bay back", Vector3(center_x + side * 1.52, 2.15, bz), Vector3(0.26, 4.3, 8.0), wall_mat, true)
		_box(self, "Bay side wall", Vector3(side * 6.35, 2.05, bz - 3.9), Vector3(3.2, 4.1, 0.22), wall_mat, true)
		_box(self, "Bay side wall", Vector3(side * 6.35, 2.05, bz + 3.9), Vector3(3.2, 4.1, 0.22), wall_mat, true)
		_box(self, "Bay lintel", Vector3(side * 4.95, 4.12, bz), Vector3(0.28, 0.34, 2.55), steel, false)
		_box(self, "Bay threshold", Vector3(side * 4.35, 0.14, bz), Vector3(0.88, 0.24, 2.45), rust, false)
		_box(self, "Bay bench", Vector3(center_x - side * 0.55, 0.68, bz + 1.8), Vector3(1.0, 0.26, 2.1), steel, false)
		_box(self, "Bay cabinet", Vector3(center_x, 1.2, bz - 1.5), Vector3(0.75, 2.0, 0.66), wall_mat, true)
		_box(self, "Bay light", Vector3(center_x, 4.16, bz), Vector3(0.26, 0.08, 1.65), trim, false)
		var bay_light = _omni(Vector3(center_x, 3.82, bz), Color(0.2, 0.73, 0.72), 0.42, 6.5, true)
		flicker_lights.append([bay_light, 0.42, float(i) * 1.2 + 1.0])

	# Overhead lamps alternate cold white and drowned amber; their irregular flicker is intentional.
	for i in range(10):
		var zlamp = 8.0 - float(i) * 7.6
		var amber = i % 3 == 2
		var hue = Color(0.92, 0.47, 0.21) if amber else Color(0.44, 0.69, 0.74)
		var energy = 0.62 if amber else 0.82
		_box(self, "Lamp diffuser", Vector3(0, 4.99, zlamp), Vector3(0.54, 0.045, 2.1), _emissive(hue, 0.8), false)
		var lamp = _omni(Vector3(0, 4.68, zlamp), hue, energy, 9.0, true)
		flicker_lights.append([lamp, energy, float(i) * 0.73])

	# Wall niches, faded warning stripes and occasional pipe brackets give the hall scale.
	for i in range(7):
		var zw = -2.0 - float(i) * 9.8
		var left = i % 2 == 0
		var side_x = -4.7 if left else 4.7
		_box(self, "Access plate", Vector3(side_x, 2.1, zw), Vector3(0.08, 0.72, 1.3), steel, false)
		_box(self, "Access indicator", Vector3(side_x + (0.055 if left else -0.055), 2.25, zw - 0.38), Vector3(0.035, 0.065, 0.15), _emissive(Color(0.78, 0.15, 0.095), 0.55), false)
		for stripe in range(3):
			_box(self, "Paint stripe", Vector3(side_x, 0.35 + float(stripe) * 0.07, zw - 0.65), Vector3(0.09, 0.045, 0.35), rust, false)

	# Three safe resonator plinths replenish the scarce pulse charges and lamp cells.
	for idx in range(3):
		var sz = 1.0 - float(idx) * 25.0
		var sx = -2.65 if idx % 2 == 0 else 2.65
		var station = _build_station(Vector3(sx, 0.0, sz), idx)
		safe_stations.append(station)

	# Final bulkhead, red status strips, and the exit lamps.
	exit_door = _box(self, "Sealed bulkhead", Vector3(0, 2.42, -63.2), Vector3(7.7, 4.84, 0.75), steel, true)
	_box(self, "Exit frame", Vector3(0, 4.93, -62.65), Vector3(8.4, 0.3, 0.5), rust, false)
	_box(self, "Exit light left", Vector3(-3.65, 4.35, -62.68), Vector3(0.22, 0.12, 0.42), _emissive(Color(0.76, 0.10, 0.055), 0.75), false)
	_box(self, "Exit light right", Vector3(3.65, 4.35, -62.68), Vector3(0.22, 0.12, 0.42), _emissive(Color(0.76, 0.10, 0.055), 0.75), false)
	_omni(Vector3(0, 3.8, -60.2), Color(0.72, 0.12, 0.075), 0.65, 7.0, false)

func _build_station(pos, index):
	var station = Spatial.new()
	station.translation = pos
	add_child(station)
	var base_mat = _mat(Color(0.12, 0.18, 0.19), 0.76, 0.34)
	var glow_mat = _emissive(Color(0.24, 0.9, 0.81), 1.1)
	_box(station, "Resonator plinth", Vector3(0, 0.42, 0), Vector3(0.82, 0.82, 0.82), base_mat, false)
	_box(station, "Resonator crown", Vector3(0, 0.9, 0), Vector3(0.94, 0.08, 0.94), glow_mat, false)
	_box(station, "Resonator glyph", Vector3(0, 1.02, 0), Vector3(0.38, 0.025, 0.38), _emissive(Color(0.88, 0.72, 0.36), 0.7), false)
	var light = _omni(Vector3(0, 1.1, 0), Color(0.22, 0.85, 0.75), 0.3, 3.8, false)
	return {"node": station, "light": light, "index": index}

func _build_player():
	player = KinematicBody.new()
	player.name = "Listener"
	player.translation = Vector3(0, 0.92, 10.0)
	add_child(player)
	var shape = CapsuleShape.new()
	shape.radius = 0.34
	shape.height = 1.82
	var collider = CollisionShape.new()
	collider.shape = shape
	player.add_child(collider)
	camera = Camera.new()
	camera.current = true
	camera.translation = Vector3(0, 1.55, 0)
	camera.fov = 78.0
	player.add_child(camera)
	flashlight = SpotLight.new()
	flashlight.light_color = Color(0.79, 0.91, 0.92)
	flashlight.light_energy = 2.25
	flashlight.spot_range = 19.0
	flashlight.spot_angle = 38.0
	flashlight.spot_angle_attenuation = 1.2
	flashlight.shadow_enabled = true
	flashlight.translation = Vector3(0.12, -0.12, -0.08)
	flashlight.visible = false
	camera.add_child(flashlight)

func _build_enemy():
	enemy = Spatial.new()
	enemy.name = "The Drowned Listener"
	enemy.translation = Vector3(0.0, 0.0, -53.0)
	add_child(enemy)
	var hide = _mat(Color(0.009, 0.015, 0.018), 0.02, 0.97)
	var edge = _mat(Color(0.065, 0.095, 0.094), 0.1, 0.8)
	var core_mat = _emissive(Color(0.46, 0.035, 0.023), 0.0)
	enemy_core = _part(enemy, CapsuleMesh.new(), Vector3(0, 1.5, 0), hide)
	enemy_core.mesh.radius = 0.39
	enemy_core.mesh.mid_height = 1.35
	var chest = _part(enemy, SphereMesh.new(), Vector3(0, 2.08, 0), hide)
	chest.scale = Vector3(0.64, 0.89, 0.38)
	var head = _part(enemy, SphereMesh.new(), Vector3(0, 2.91, -0.07), edge)
	head.scale = Vector3(0.32, 0.43, 0.31)
	head.name = "Tilted mask"
	var shoulder_l = _part(enemy, SphereMesh.new(), Vector3(-0.54, 2.11, 0.0), hide)
	shoulder_l.scale = Vector3(0.34, 0.24, 0.33)
	var shoulder_r = _part(enemy, SphereMesh.new(), Vector3(0.54, 2.11, 0.0), hide)
	shoulder_r.scale = Vector3(0.34, 0.24, 0.33)
	var arm_l = _part(enemy, CapsuleMesh.new(), Vector3(-0.69, 1.48, -0.02), edge)
	arm_l.mesh.radius = 0.12
	arm_l.mesh.mid_height = 0.95
	arm_l.rotation.z = -0.13
	var arm_r = _part(enemy, CapsuleMesh.new(), Vector3(0.69, 1.48, -0.02), edge)
	arm_r.mesh.radius = 0.12
	arm_r.mesh.mid_height = 0.95
	arm_r.rotation.z = 0.13
	var hand_l = _part(enemy, SphereMesh.new(), Vector3(-0.77, 0.88, -0.12), hide)
	hand_l.scale = Vector3(0.18, 0.31, 0.14)
	var hand_r = _part(enemy, SphereMesh.new(), Vector3(0.77, 0.88, -0.12), hide)
	hand_r.scale = Vector3(0.18, 0.31, 0.14)
	var eye_mat = _emissive(Color(0.95, 0.09, 0.025), 0.8)
	for eye_x in [-0.13, 0.13]:
		var eye = _part(enemy, SphereMesh.new(), Vector3(eye_x, 2.98, -0.345), eye_mat)
		eye.scale = Vector3(0.038, 0.025, 0.025)
		eye_nodes.append(eye)
	var leg_l = _part(enemy, CapsuleMesh.new(), Vector3(-0.22, 0.57, 0.03), hide)
	leg_l.mesh.radius = 0.15
	leg_l.mesh.mid_height = 0.8
	var leg_r = _part(enemy, CapsuleMesh.new(), Vector3(0.22, 0.57, 0.03), hide)
	leg_r.mesh.radius = 0.15
	leg_r.mesh.mid_height = 0.8
	enemy.set_meta("arms", [arm_l, arm_r])
	enemy.set_meta("legs", [leg_l, leg_r])
	enemy.set_meta("head", head)
	enemy.set_meta("hands", [hand_l, hand_r])
	enemy.set_meta("core_material", core_mat)
	enemy_core.material_override = core_mat
	_omni(Vector3(0, 2.96, -0.7), Color(0.65, 0.035, 0.018), 0.16, 3.4, false)

func _build_pickups():
	var positions = [Vector3(-2.75, 1.18, -7.0), Vector3(2.75, 1.18, -23.0), Vector3(-2.75, 1.18, -39.0)]
	var tints = [Color(0.44, 0.91, 0.87), Color(0.93, 0.54, 0.28), Color(0.56, 0.68, 0.99)]
	for i in range(positions.size()):
		var shard = Spatial.new()
		shard.name = "Memory shard %d" % (i + 1)
		shard.translation = positions[i]
		shard.visible = false
		add_child(shard)
		var shardmat = _emissive(tints[i], 0.95)
		var crystal = _part(shard, SphereMesh.new(), Vector3(0, 0, 0), shardmat)
		crystal.scale = Vector3(0.17, 0.27, 0.17)
		crystal.rotation_degrees = Vector3(20, 0, 35)
		var ring = _part(shard, _ring_mesh(0.28, 0.31), Vector3.ZERO, _emissive(tints[i], 0.5))
		var light = OmniLight.new()
		light.light_color = tints[i]
		light.light_energy = 0.0
		light.omni_range = 4.0
		shard.add_child(light)
		shards.append({"node": shard, "light": light, "taken": false, "home": positions[i], "index": i})

func _build_hud():
	var layer = CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	darkness_overlay = ColorRect.new()
	darkness_overlay.anchor_right = 1.0
	darkness_overlay.anchor_bottom = 1.0
	darkness_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shade = Shader.new()
	shade.code = """
shader_type canvas_item;
uniform float pressure = 0.0;
void fragment() {
	vec2 q = UV - vec2(0.5);
	float vignette = smoothstep(0.26, 0.78, length(q * vec2(1.28, 1.0)));
	float grain = fract(sin(dot(floor(UV * vec2(840.0, 470.0)) + TIME * 17.0, vec2(12.9898, 78.233))) * 43758.5453);
	float a = vignette * (0.34 + pressure * 0.22) + grain * 0.027;
	COLOR = vec4(vec3(0.004, 0.012, 0.017), a);
}
"""
	var overlay_mat = ShaderMaterial.new()
	overlay_mat.shader = shade
	darkness_overlay.material = overlay_mat
	layer.add_child(darkness_overlay)

	ui_reticle = _label(layer, "+", Vector2(-8, -14), Vector2(16, 25), 19, Color(0.55, 0.86, 0.83), true)
	ui_reticle.anchor_left = 0.5
	ui_reticle.anchor_right = 0.5
	ui_reticle.anchor_top = 0.5
	ui_reticle.anchor_bottom = 0.5
	ui_status = _label(layer, "", Vector2(32, 48), Vector2(700, 28), 17, Color(0.61, 0.82, 0.79), false)
	ui_objective = _label(layer, "", Vector2(32, 78), Vector2(900, 28), 16, Color(0.84, 0.86, 0.78), false)
	ui_hint = _label(layer, "WASD MOVE   SHIFT RUN   CTRL CROUCH\nQ LISTEN   F LAMP   E RESONATE   ESC RELEASE MOUSE", Vector2(32, -92), Vector2(700, 72), 14, Color(0.48, 0.61, 0.61), false)
	ui_hint.anchor_top = 1.0
	ui_hint.anchor_bottom = 1.0
	ui_message = _label(layer, "", Vector2(300, 390), Vector2(1000, 50), 22, Color(0.81, 0.94, 0.88), true)
	ui_message.visible = false
	var title = _label(layer, "THE HUM  /  ARCHIVE OF THE DROWNED", Vector2(32, 19), Vector2(720, 26), 15, Color(0.58, 0.72, 0.72), false)
	title.add_color_override("font_color", Color(0.56, 0.71, 0.69, 0.68))

func _process(delta):
	clock += delta
	if message_timer > 0.0:
		message_timer -= delta
		if message_timer <= 0.0 and ui_message != null:
			ui_message.visible = false
	if echo_timer > 0.0:
		echo_timer = max(0.0, echo_timer - delta)
		for shard in shards:
			if not shard["taken"]:
				var node = shard["node"]
				node.visible = true
				node.translation.y = shard["home"].y + sin(clock * 2.2 + float(shard["index"])) * 0.11
				node.rotation.y += delta * (0.7 + 0.12 * float(shard["index"]))
				shard["light"].light_energy = 0.66 + 0.12 * sin(clock * 5.0)
		_check_shard_pickups()
	else:
		for shard in shards:
			shard["node"].visible = false
			shard["light"].light_energy = 0.0
	pulse_cooldown = max(0.0, pulse_cooldown - delta)
	if message_timer <= 0 and ui_message != null:
		ui_message.visible = false
	_animate_echo_rings(delta)
	_update_flicker()
	_update_enemy_visuals(delta)
	_update_hud()
	if torch_on:
		battery = max(0.0, battery - delta * 1.65)
		if battery <= 0.0:
			torch_on = false
			flashlight.visible = false
			_set_message("THE LAMP CELL IS EMPTY. Find a resonator plinth.", 3.1)
	_check_safe_stations(delta)
	if player != null and not caught and not completed:
		exit_warning = max(0.0, exit_warning - delta)
		if player.global_transform.origin.z < -59.4:
			if _collected_count() >= objective_count:
				completed = true
				_finish(true)
			else:
				player.translation.z = -59.2
				if exit_warning <= 0.0:
					_set_message("BULKHEAD LOCKED — recover all three memory fragments.", 3.0)
					exit_warning = 3.0

func _physics_process(delta):
	if player == null or caught or completed:
		return
	var wish = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		wish.z -= 1.0
	if Input.is_key_pressed(KEY_S):
		wish.z += 1.0
	if Input.is_key_pressed(KEY_A):
		wish.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		wish.x += 1.0
	wish = (player.global_transform.basis * wish).normalized()
	crouching = Input.is_key_pressed(KEY_CONTROL)
	var sprinting = Input.is_key_pressed(KEY_SHIFT) and not crouching and wish.length() > 0.1
	var move_speed = CROUCH_SPEED if crouching else (RUN_SPEED if sprinting else WALK_SPEED)
	var velocity = Vector3(wish.x * move_speed, 0.0, wish.z * move_speed)
	var vertical_speed = 0.0
	if player.has_meta("vertical_speed"):
		vertical_speed = float(player.get_meta("vertical_speed"))
	velocity.y = vertical_speed
	if not player.is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.2
	velocity = player.move_and_slide(velocity, Vector3.UP)
	player.set_meta("vertical_speed", velocity.y)
	var cam_target = 1.08 if crouching else 1.55
	var speed_factor = min(1.0, wish.length() * (1.45 if sprinting else 0.75))
	gait_phase += delta * (10.5 if sprinting else 7.1) * speed_factor
	camera.translation.y = lerp(camera.translation.y, cam_target + sin(gait_phase) * 0.035 * speed_factor, delta * 8.0)
	camera.translation.x = lerp(camera.translation.x, sin(gait_phase * 0.5) * 0.028 * speed_factor, delta * 6.0)
	camera.fov = lerp(camera.fov, 83.0 if sprinting else 78.0, delta * 3.0)
	if sprinting:
		battery = max(0.0, battery - delta * 0.1)
	_update_enemy(delta)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not caught and not completed:
		player.rotate_y(-event.relative.x * 0.0019)
		camera.rotation.x = clamp(camera.rotation.x - event.relative.y * 0.0018, -1.25, 1.25)
	if event is InputEventMouseButton and event.pressed:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventKey and event.pressed and not event.echo:
		if event.scancode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
		elif event.scancode == KEY_Q and not caught and not completed:
			_emit_echo()
		elif event.scancode == KEY_F and not caught and not completed:
			_toggle_torch()
		elif event.scancode == KEY_E and not caught and not completed:
			_interact()
		elif event.scancode == KEY_R and (caught or completed):
			get_tree().reload_current_scene()

func _emit_echo():
	if pulse_cooldown > 0.0:
		_set_message("THE RESONATOR IS STILL RINGING  ·  %.1fs" % pulse_cooldown, 1.4)
		return
	if pulse_charges <= 0:
		_set_message("NO CHARGE. Stand beside a lit resonator plinth.", 2.2)
		return
	pulse_charges -= 1
	pulse_cooldown = ECHO_COOLDOWN
	echo_timer = ECHO_DURATION
	enemy_awake = true
	enemy_target = player.global_transform.origin
	enemy_speed = 1.12 + float(_collected_count()) * 0.22
	_spawn_echo_wave()
	_set_message("ECHO SENT. Your last position is now the lure.", 3.0)
	if enemy != null:
		enemy.look_at(Vector3(enemy_target.x, enemy.global_transform.origin.y, enemy_target.z), Vector3.UP)

func _toggle_torch():
	if battery <= 1.0:
		_set_message("LAMP CELL EMPTY — recharge at a resonator plinth.", 2.2)
		return
	torch_on = not torch_on
	flashlight.visible = torch_on
	_set_message("LAMP ON  ·  the Listener can see the beam." if torch_on else "Lamp shuttered. Keep to the dark.", 1.8)

func _interact():
	for station_data in safe_stations:
		var station = station_data["node"]
		if player.global_transform.origin.distance_to(station.global_transform.origin) < 2.35:
			pulse_charges = MAX_ECHOES
			battery = 100.0
			_set_message("RESONATOR SYNCED  ·  pulse charges and lamp cell restored.", 3.0)
			return
	if player.global_transform.origin.z < -57.5 and _collected_count() >= objective_count:
		completed = true
		_finish(true)
	else:
		_set_message("Hold still and listen. The fragments answer a pulse.", 2.0)

func _check_shard_pickups():
	for shard in shards:
		if shard["taken"] or not shard["node"].visible:
			continue
		if player.global_transform.origin.distance_to(shard["node"].global_transform.origin) < 1.3:
			shard["taken"] = true
			shard["node"].visible = false
			shard["light"].light_energy = 0.0
			var count = _collected_count()
			_set_message("MEMORY %d / %d RECOVERED. It remembers you now." % [count, objective_count], 3.1)
			if count >= objective_count:
				_set_message("ALL MEMORIES RESTORED. The bulkhead is awake.", 4.0)
				if exit_door != null:
					exit_door.visible = false
					exit_door.get_node("CollisionShape").disabled = true

func _check_safe_stations(delta):
	if player == null:
		return
	for station_data in safe_stations:
		var d = player.global_transform.origin.distance_to(station_data["node"].global_transform.origin)
		if d < 2.1:
			if pulse_charges < MAX_ECHOES or battery < 99.8:
				pulse_charges = min(MAX_ECHOES, pulse_charges + delta * 0.32)
				battery = min(100.0, battery + delta * 8.0)
		if d < 12.0 and station_data["light"] != null:
			station_data["light"].light_energy = 0.3 + 0.08 * sin(clock * 1.8 + float(station_data["index"]))

func _update_enemy(delta):
	if enemy == null or not enemy_awake:
		return
	var epos = enemy.global_transform.origin
	var ppos = player.global_transform.origin
	var delta_to_target = enemy_target - epos
	delta_to_target.y = 0.0
	var direction = delta_to_target.normalized()
	if delta_to_target.length() > 0.38:
		var forward = -camera.global_transform.basis.z
		var to_enemy = (epos - ppos).normalized()
		var lit = torch_on and forward.dot(to_enemy) > 0.62 and ppos.distance_to(epos) < 14.0
		var pace = enemy_speed * (1.65 if lit else 1.0)
		var step = min(delta_to_target.length(), pace * delta)
		var away = -direction if lit else direction
		enemy.global_translate(away * step)
		enemy.look_at(Vector3(enemy_target.x, epos.y + 0.5, enemy_target.z), Vector3.UP)
	# It attacks only when it reaches the listener's body: crouching alone won't save you.
	if ppos.distance_to(epos + Vector3(0, 1.0, 0)) < 1.28:
		caught = true
		_finish(false)

func _update_enemy_visuals(delta):
	if enemy == null:
		return
	var arms = enemy.get_meta("arms")
	var legs = enemy.get_meta("legs")
	var head = enemy.get_meta("head")
	var moving = enemy_awake and enemy_target.distance_to(enemy.global_transform.origin) > 0.4
	var rate = clock * (9.0 if moving else 2.1)
	arms[0].rotation.x = sin(rate) * (0.26 if moving else 0.055)
	arms[1].rotation.x = -sin(rate) * (0.26 if moving else 0.055)
	legs[0].rotation.x = -sin(rate) * (0.31 if moving else 0.025)
	legs[1].rotation.x = sin(rate) * (0.31 if moving else 0.025)
	head.rotation.z = sin(clock * 0.7) * 0.075 + (0.19 if moving else 0.0)
	enemy.translation.y = abs(sin(rate)) * (0.07 if moving else 0.018)
	# A pulse briefly exposes a wet, red inner core; otherwise the silhouette vanishes in fog.
	var reveal = echo_timer > 0.2
	var core_mat = enemy.get_meta("core_material")
	core_mat.emission_energy = 0.95 if reveal else 0.0
	for eye in eye_nodes:
		eye.visible = reveal or player.global_transform.origin.distance_to(enemy.global_transform.origin) < 6.0

func _update_flicker():
	for entry in flicker_lights:
		var lamp = entry[0]
		var base = entry[1]
		var phase = entry[2]
		var wobble = 0.90 + 0.075 * sin(clock * 10.0 + phase) + 0.035 * sin(clock * 24.3 + phase * 2.7)
		if fposmod(clock * 2.2 + phase, 19.0) < 0.22:
			wobble = 0.12
		lamp.light_energy = base * wobble

func _spawn_echo_wave():
	var ring = MeshInstance.new()
	ring.mesh = _ring_mesh(0.075, 0.12)
	ring.translation = player.global_transform.origin + Vector3(0, 0.08, 0)
	var mat = _emissive(Color(0.28, 0.89, 0.8, 0.78), 1.4)
	mat.flags_transparent = true
	ring.material_override = mat
	add_child(ring)
	echo_rings.append({"node": ring, "mat": mat, "age": 0.0})

func _animate_echo_rings(delta):
	for i in range(echo_rings.size() - 1, -1, -1):
		var item = echo_rings[i]
		item["age"] += delta
		var t = item["age"] / 1.12
		if t >= 1.0:
			item["node"].queue_free()
			echo_rings.remove(i)
		else:
			item["node"].scale = Vector3(0.3 + t * 14.0, 1.0, 0.3 + t * 14.0)
			item["mat"].albedo_color.a = (1.0 - t) * 0.68
			item["mat"].emission_energy = (1.0 - t) * 1.35

func _update_hud():
	if ui_status == null:
		return
	var torch_text = "LAMP %02d%%" % int(battery)
	var pulse_text = "ECHO %d/%d" % [int(ceil(pulse_charges)), MAX_ECHOES]
	var echo_text = "  ·  ECHO VISION %.1fs" % echo_timer if echo_timer > 0.0 else ""
	ui_status.text = "%s     %s%s" % [torch_text, pulse_text, echo_text]
	var count = _collected_count()
	ui_objective.text = "RECOVER MEMORIES  %d / %d     ·     KEEP THE BULKHEAD IN SIGHT" % [count, objective_count]
	if echo_timer > 0.0:
		ui_reticle.add_color_override("font_color", Color(0.42, 1.0, 0.87))
	else:
		ui_reticle.add_color_override("font_color", Color(0.55, 0.86, 0.83, 0.68))
	if darkness_overlay != null:
		var pressure = 0.0
		if enemy != null and player != null:
			pressure = clamp(1.0 - player.global_transform.origin.distance_to(enemy.global_transform.origin) / 14.0, 0.0, 1.0)
		darkness_overlay.material.set_shader_param("pressure", pressure)

func _finish(won):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var panel = ColorRect.new()
	panel.color = Color(0.003, 0.008, 0.012, 0.9)
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_node("CanvasLayer").add_child(panel)
	var headline = _label(panel, "", Vector2(0, -74), Vector2(1000, 74), 34, Color(0.71, 0.91, 0.86), true)
	headline.anchor_left = 0.5
	headline.anchor_right = 0.5
	headline.anchor_top = 0.5
	headline.anchor_bottom = 0.5
	headline.rect_position = Vector2(-500, -74)
	var body = _label(panel, "", Vector2(0, 12), Vector2(980, 96), 18, Color(0.68, 0.77, 0.74), true)
	body.anchor_left = 0.5
	body.anchor_right = 0.5
	body.anchor_top = 0.5
	body.anchor_bottom = 0.5
	body.rect_position = Vector2(-490, 14)
	if won:
		headline.text = "THE ARCHIVE LETS YOU GO"
		body.text = "Three memories restored. The signal falls silent.\n\nPress R to descend again."
	else:
		headline.text = "IT FOLLOWED THE ECHO"
		body.text = "The Listener found the last place you called from.\n\nPress R to try another way."

func _set_message(text, duration):
	if ui_message == null:
		return
	ui_message.text = text
	ui_message.visible = true
	message_timer = duration

func _collected_count():
	var total = 0
	for shard in shards:
		if shard["taken"]:
			total += 1
	return total

func _concrete_material(tint, tiling, metalness, roughness):
	var shader = Shader.new()
	shader.code = """
shader_type spatial;
uniform vec3 base_tint;
uniform vec2 tile_scale;
uniform float base_metalness = 0.0;
uniform float base_roughness = 0.8;
float hash2(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}
float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash2(i), hash2(i + vec2(1.0, 0.0)), f.x),
               mix(hash2(i + vec2(0.0, 1.0)), hash2(i + vec2(1.0, 1.0)), f.x), f.y);
}
void fragment() {
    vec2 p = UV * tile_scale;
    float low = value_noise(p * 0.31);
    float grit = value_noise(p * 3.7);
    float pores = value_noise(p * 21.0);
    float damp = smoothstep(0.43, 0.78, value_noise(p * 0.47 + vec2(17.2, 8.3)));
    float mottling = 0.70 + low * 0.32 + grit * 0.12 + pores * 0.055;
    ALBEDO = base_tint * mottling * mix(0.94, 1.07, damp);
    METALLIC = base_metalness;
    ROUGHNESS = clamp(base_roughness + (grit - 0.5) * 0.12 - damp * 0.17, 0.16, 1.0);
}
"""
	var material = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_param("base_tint", Vector3(tint.r, tint.g, tint.b))
	material.set_shader_param("tile_scale", tiling)
	material.set_shader_param("base_metalness", metalness)
	material.set_shader_param("base_roughness", roughness)
	return material

func _mat(color, metallic, roughness, emission = Color(0, 0, 0)):
	var material = SpatialMaterial.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	if emission.r + emission.g + emission.b > 0.001:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy = 0.45
	return material

func _emissive(color, energy):
	var material = SpatialMaterial.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b)
	material.emission_energy = energy
	material.roughness = 0.36
	return material

func _box(parent, label, pos, size, material, solid):
	var mesh = MeshInstance.new()
	mesh.name = label
	var cube = CubeMesh.new()
	cube.size = size
	mesh.mesh = cube
	mesh.material_override = material
	if solid:
		var body = StaticBody.new()
		body.name = label + " collision"
		body.translation = pos
		parent.add_child(body)
		mesh.translation = Vector3.ZERO
		body.add_child(mesh)
		var shape = CollisionShape.new()
		shape.name = "CollisionShape"
		var boxshape = BoxShape.new()
		boxshape.extents = size * 0.5
		shape.shape = boxshape
		body.add_child(shape)
		return body
	mesh.translation = pos
	parent.add_child(mesh)
	return mesh

func _part(parent, mesh, pos, material):
	var node = MeshInstance.new()
	node.mesh = mesh
	node.material_override = material
	node.translation = pos
	parent.add_child(node)
	return node

func _omni(pos, color, energy, radius, shadows):
	var light = OmniLight.new()
	light.translation = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = radius
	light.shadow_enabled = shadows
	add_child(light)
	return light

func _ring_mesh(inner_radius, outer_radius):
	var surface = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segments = 48
	for i in range(segments):
		var a0 = TAU * float(i) / float(segments)
		var a1 = TAU * float(i + 1) / float(segments)
		var p0 = Vector3(cos(a0) * inner_radius, 0.0, sin(a0) * inner_radius)
		var p1 = Vector3(cos(a0) * outer_radius, 0.0, sin(a0) * outer_radius)
		var p2 = Vector3(cos(a1) * outer_radius, 0.0, sin(a1) * outer_radius)
		var p3 = Vector3(cos(a1) * inner_radius, 0.0, sin(a1) * inner_radius)
		surface.add_vertex(p0)
		surface.add_vertex(p1)
		surface.add_vertex(p2)
		surface.add_vertex(p0)
		surface.add_vertex(p2)
		surface.add_vertex(p3)
	surface.generate_normals()
	return surface.commit()

func _label(parent, text, position, size, font_size, color, centered):
	var label = Label.new()
	label.text = text
	label.rect_position = position
	label.rect_size = size
	label.clip_text = true
	label.add_color_override("font_color", color)
	label.add_color_override("font_color_shadow", Color(0.0, 0.01, 0.014, 0.95))
	label.add_constant_override("shadow_offset_x", 2)
	label.add_constant_override("shadow_offset_y", 2)
	label.add_font_override("font", _font(font_size))
	if centered:
		label.align = Label.ALIGN_CENTER
		label.valign = Label.VALIGN_CENTER
	parent.add_child(label)
	return label

func _font(size):
	var font = DynamicFont.new()
	font.size = size
	font.font_data = load("res://assets/fonts/DejaVuSans.ttf")
	return font
