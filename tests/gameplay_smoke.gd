extends SceneTree

func _initialize():
    call_deferred("_run_checks")

func _assert_imported_pipe_asset(game):
    var prop = game.industrial_pipe_prop
    assert(prop != null)
    assert(prop.name == "ModularIndustrialPipes_CC0")
    assert(prop.position.is_equal_approx(Vector3(6.85, 0.75, -23.0)))
    assert(is_equal_approx(prop.rotation.y, PI * 0.5))
    var meshes = prop.find_children("*", "MeshInstance3D", true, false)
    assert(meshes.size() == 8)
    for mesh_node in meshes:
        var mesh = mesh_node as MeshInstance3D
        assert(mesh.mesh.get_surface_count() == 1)
        var material = mesh.get_active_material(0) as StandardMaterial3D
        assert(material != null)
        assert(material.albedo_texture != null)
        assert(material.normal_enabled and material.normal_texture != null)
        assert(material.roughness_texture != null)
    var collision = prop.get_node("PipeAssemblyCollision/CollisionShape3D")
    assert(collision.shape is BoxShape3D)
    assert(collision.shape.size.is_equal_approx(Vector3(2.05, 2.0, 0.62)))

func _assert_concrete_wall_trial(game):
    var body = game.concrete_trial_wall
    assert(body != null)
    assert(body.name == "Concrete Wall 003 trial collision")
    var wall = body.get_node("Concrete Wall 003 trial") as MeshInstance3D
    assert(wall != null)
    var material = wall.material_override as StandardMaterial3D
    assert(material != null)
    assert(material.albedo_texture != null)
    assert(material.normal_enabled and material.normal_texture != null)
    assert(material.roughness_texture != null)
    assert(material.ao_enabled and material.ao_texture != null)
    assert(material.uv1_scale.is_equal_approx(Vector3(2.0, 2.0, 2.0)))
    var shape = body.get_node("CollisionShape3D").shape as BoxShape3D
    assert(shape.size.is_equal_approx(Vector3(0.26, 4.3, 8.0)))
    assert(game.bay_back_walls.size() == 3)
    assert(game.bay_back_walls[1] == body)
    for wall_index in [0, 2]:
        var procedural_body = game.bay_back_walls[wall_index]
        var procedural_wall = procedural_body.get_node("Bay back") as MeshInstance3D
        assert(procedural_wall.material_override is ShaderMaterial)

func _assert_listener_echo_and_recoil(game):
    var original_player_position = game.player.global_position
    var original_enemy_position = game.enemy.global_position
    var original_camera_rotation = game.camera.rotation

    var first_echo_position = Vector3(-1.2, 0.92, -12.0)
    game.player.global_position = first_echo_position
    game._emit_echo()
    assert(game.enemy_awake)
    assert(game.enemy_target.is_equal_approx(first_echo_position))

    var second_echo_position = Vector3(1.4, 0.92, -21.0)
    game.pulse_cooldown = 0.0
    game.player.global_position = second_echo_position
    game._emit_echo()
    assert(game.enemy_target.is_equal_approx(second_echo_position))

    # A delayed physics frame may reach the lure, but the Listener must not
    # cross past it. Move the player away so arrival itself is not an attack.
    game.enemy.global_position = Vector3(0.0, 0.0, -53.0)
    game.player.global_position = second_echo_position + Vector3(5.0, 0.0, 0.0)
    game._update_enemy(100.0)
    var horizontal_target_offset = Vector2(game.enemy.global_position.x - second_echo_position.x, game.enemy.global_position.z - second_echo_position.z)
    assert(horizontal_target_offset.length() < 0.001)
    assert(not game.caught)

    for ring in game.echo_rings:
        ring["node"].queue_free()
    game.echo_rings.clear()
    game.pulse_player.stop()
    game.pulse_charges = game.MAX_ECHOES
    game.pulse_cooldown = 0.0
    game.echo_timer = 0.0
    game.enemy_awake = false
    game.enemy_target = Vector3.ZERO
    game.player.global_position = original_player_position

    # When the Listener reaches the last echo while the player keeps the beam
    # trained on it, it must recoil instead of freezing at the lure and catching.
    game.player.global_position = Vector3(0.0, 0.92, -30.0)
    game.enemy.global_position = Vector3(0.0, 0.0, -30.2)
    game.enemy_target = game.enemy.global_position
    game.enemy_awake = true
    game.torch_on = true
    game.flashlight.visible = true
    game.camera.look_at(game.enemy_core.global_position, Vector3.UP)
    var distance_before_recoil = game.player.global_position.distance_to(game.enemy.global_position)
    game._update_enemy(0.1)
    assert(game.enemy_recoiling)
    assert(not game.caught)
    assert(game.enemy.global_position.distance_to(game.player.global_position) > distance_before_recoil)

    game.torch_on = false
    game.flashlight.visible = false
    game.enemy_awake = false
    game.enemy.global_position = original_enemy_position
    game.enemy_target = Vector3.ZERO
    game.player.global_position = original_player_position
    game.camera.rotation = original_camera_rotation

func _assert_surface_footsteps(game):
    assert(game.wet_surface_zones.size() == 18)
    var first_wet_center = game.wet_surface_zones[0]["center"]
    assert(game._is_wet_surface(Vector3(first_wet_center.x, 0.0, first_wet_center.y)))
    assert(not game._is_wet_surface(Vector3(0.0, 0.0, 10.0)))

    var dry_walk = game._footstep_noise_level(false, false, false)
    var wet_walk = game._footstep_noise_level(true, false, false)
    var crouched_wet = game._footstep_noise_level(true, true, false)
    var wet_sprint = game._footstep_noise_level(true, false, true)
    assert(wet_walk > dry_walk)
    assert(crouched_wet < wet_walk)
    assert(wet_sprint > wet_walk)
    assert(game._footstep_volume_db(true, false, false) > game._footstep_volume_db(false, false, false))
    assert(game._footstep_volume_db(true, true, false) < game._footstep_volume_db(true, false, false))
    assert(game._footstep_volume_db(true, false, true) > game._footstep_volume_db(true, false, false))
    assert(game._footstep_interval(true, false) > game._footstep_interval(false, false))
    assert(game._footstep_interval(false, true) < game._footstep_interval(false, false))
    assert(game.footstep_concrete_stream != null)
    assert(game.footstep_splash_stream != null)

    game.enemy_awake = false
    game.footstep_timer = 0.0
    assert(game._advance_footsteps(0.016, 3.1, true, false, false, false))
    assert(not game._advance_footsteps(0.10, 3.1, true, false, false, false))
    assert(game._advance_footsteps(0.43, 3.1, true, false, false, false))
    assert(not game._advance_footsteps(0.1, 0.0, true, false, false, false))
    assert(not game._advance_footsteps(0.1, 3.1, false, false, false, false))
    game.footstep_player.stop()

    var original_player_position = game.player.global_position
    var original_enemy_position = game.enemy.global_position
    var original_enemy_target = game.enemy_target
    game.player.global_position = Vector3(0.0, 0.92, -30.0)
    game.enemy.global_position = Vector3(0.0, 0.0, -40.0)
    game.enemy_awake = true
    game.enemy_target = Vector3(99.0, 0.0, 99.0)
    var dry_step_was_heard = game._emit_footstep(false, false, false)
    assert(not dry_step_was_heard)
    assert(game.enemy_target == Vector3(99.0, 0.0, 99.0))
    var wet_step_was_heard = game._emit_footstep(true, false, false)
    assert(wet_step_was_heard)
    assert(game.enemy_target.is_equal_approx(game.player.global_position))

    game.enemy.global_position = Vector3(0.0, 0.0, -37.0)
    game.enemy_target = Vector3(99.0, 0.0, 99.0)
    assert(not game._emit_footstep(false, true, false))
    assert(game._emit_footstep(true, true, false))
    assert(game.enemy_target.is_equal_approx(game.player.global_position))

    game.footstep_player.stop()
    game.enemy_awake = false
    game.enemy.global_position = original_enemy_position
    game.enemy_target = original_enemy_target
    game.player.global_position = original_player_position
    game.footstep_timer = 0.0
    game.footstep_alert_timer = 0.0

func _assert_movement_onboarding(game):
    assert(not game.enemy_awake)
    assert(not game.tutorial_dry_step_seen)
    assert(not game.tutorial_wet_walk_seen)
    assert(not game.tutorial_wet_crouch_seen)
    assert(not game.movement_tutorial_complete)
    assert(game._advance_footsteps(0.016, 3.1, true, false, false, false))
    assert(game.tutorial_dry_step_seen)
    assert(game.ui_message.text.contains("DRY CONCRETE"))
    assert(not game._advance_footsteps(0.10, 3.1, true, false, false, false))
    assert(game._advance_footsteps(0.53, 3.1, true, true, false, false))
    assert(game.tutorial_wet_walk_seen)
    assert(game.ui_message.text.contains("PUDDLE"))
    assert(not game.movement_tutorial_complete)
    assert(game._advance_footsteps(0.53, 1.55, true, true, true, false))
    assert(game.tutorial_wet_crouch_seen)
    assert(game.movement_tutorial_complete)
    assert(game.ui_message.text.contains("LESSON COMPLETE"))
    assert(not game.enemy_awake)
    assert(not game._advance_footstep_tutorial(true, true))

    game.tutorial_dry_step_seen = false
    game.tutorial_wet_walk_seen = false
    game.tutorial_wet_crouch_seen = false
    game.movement_tutorial_complete = false
    game.footstep_timer = 0.0
    assert(game._advance_footsteps(0.016, 1.55, true, true, true, false))
    assert(game.ui_message.text.contains("CROUCH"))
    assert(not game.movement_tutorial_complete)
    game.footstep_timer = 0.0
    assert(game._advance_footsteps(0.016, 3.1, true, true, false, false))
    assert(game.movement_tutorial_complete)
    assert(game.ui_message.text.contains("LESSON COMPLETE"))
    game.footstep_player.stop()

func _run_checks():
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    assert(game.player != null)
    var floor_box = game.get_node("Wet foundation collision/CollisionShape3D").shape
    assert(floor_box.size.is_equal_approx(Vector3(10.6, 0.66, 86.0)))
    assert(game.shards.size() == 3)
    assert(game.pulse_charges == 3)
    assert(not game.flashlight.visible)
    assert(game.ui_message.visible)
    assert(game.ui_message.text.contains("DORMANT"))
    assert(game.ui_hint.text.contains("ECHO reveals fragments"))
    assert(game.ui_hint.text.contains("pulse origin"))
    assert(game.ui_hint.text.contains("move away"))
    var pulse_hint_color = game.ui_hint.get_theme_color("font_color")
    assert(pulse_hint_color.r >= 0.65 and pulse_hint_color.g >= 0.78)
    var pulse_hint_rect = game.ui_hint.get_global_rect()
    assert(pulse_hint_rect.position.x >= 0.0 and pulse_hint_rect.end.x <= 1600.0)
    assert(pulse_hint_rect.position.y >= 0.0 and pulse_hint_rect.end.y <= 900.0)
    assert(pulse_hint_rect.size.y >= 60.0)
    _assert_imported_pipe_asset(game)
    _assert_concrete_wall_trial(game)
    _assert_listener_echo_and_recoil(game)
    _assert_movement_onboarding(game)
    _assert_surface_footsteps(game)
    assert(game.mobile_action_buttons.size() == 7)
    var stick_center = game.mobile_stick_base.global_position + game.mobile_stick_base.size * 0.5
    var touch_down = InputEventScreenTouch.new()
    touch_down.index = 0
    touch_down.pressed = true
    touch_down.position = stick_center
    game._handle_mobile_touch(touch_down)
    var touch_drag = InputEventScreenDrag.new()
    touch_drag.index = 0
    touch_drag.position = stick_center + Vector2(30, -30)
    touch_drag.relative = Vector2(30, -30)
    game._handle_mobile_touch(touch_drag)
    assert(game.mobile_move_vector.length() > 0.5)
    var touch_up = InputEventScreenTouch.new()
    touch_up.index = 0
    touch_up.pressed = false
    touch_up.position = touch_drag.position
    game._handle_mobile_touch(touch_up)
    assert(game.mobile_move_vector == Vector2.ZERO)
    var look_position = Vector2(game.get_viewport().get_visible_rect().size.x * 0.70, game.get_viewport().get_visible_rect().size.y * 0.52)
    var look_down = InputEventScreenTouch.new()
    look_down.index = 1
    look_down.pressed = true
    look_down.position = look_position
    game._handle_mobile_touch(look_down)
    assert(game.mobile_look_touch_index == 1)
    var yaw_before = game.player.rotation.y
    var look_drag = InputEventScreenDrag.new()
    look_drag.index = 1
    look_drag.position = look_position + Vector2(24, 0)
    look_drag.relative = Vector2(24, 0)
    game._handle_mobile_touch(look_drag)
    assert(game.player.rotation.y != yaw_before)
    var look_up = InputEventScreenTouch.new()
    look_up.index = 1
    look_up.pressed = false
    look_up.position = look_drag.position
    game._handle_mobile_touch(look_up)
    assert(game.mobile_look_touch_index == -1)

    game.mobile_action_buttons["RUN"].emit_signal("toggled", true)
    assert(game.mobile_sprinting)
    game.mobile_action_buttons["RUN"].emit_signal("toggled", false)
    game.mobile_action_buttons["CROUCH"].emit_signal("toggled", true)
    assert(game.mobile_crouching)
    game.mobile_action_buttons["CROUCH"].emit_signal("toggled", false)

    game.mobile_action_buttons["ECHO"].emit_signal("pressed")
    assert(game.pulse_charges == 2)
    assert(game.echo_timer > 4.9)
    assert(game.enemy_awake)
    assert(game.enemy_target.is_equal_approx(game.player.global_position))
    assert(game.ui_message.text.contains("MOVE AWAY"))
    assert(game.ui_message.text.contains("FOOTSTEPS CAN EXPOSE YOU"))
    assert(game.echo_rings.size() == 1)
    game._process(0.05)
    assert(game.shards[0]["node"].visible)
    for ring_step in range(12):
        game._animate_echo_rings(0.1)
    assert(game.echo_rings.is_empty())

    game.mobile_action_buttons["LAMP"].emit_signal("pressed")
    assert(game.torch_on)
    assert(game.flashlight.visible)
    game.mobile_action_buttons["LAMP"].emit_signal("pressed")
    assert(not game.torch_on)

    var station = game.safe_stations[0]["node"]
    game.player.global_position = station.global_position
    game.battery = 20.0
    game.pulse_charges = 1
    game.mobile_action_buttons["USE"].emit_signal("pressed")
    assert(game.pulse_charges == 3)
    assert(game.battery == 100.0)

    for shard in game.shards:
        if not shard["taken"]:
            game.player.global_position = shard["node"].global_position
            game._check_shard_pickups()
            if int(shard["index"]) == 0:
                assert(game.memory_record_unlocked)
                assert(game.ui_message.text.contains("Read RECORD 01"))
                assert(game.memory_read_button.visible)
                assert(not game.memory_record_panel.visible)
                game.memory_read_button.emit_signal("pressed")
                await process_frame
                assert(game.memory_record_panel.visible)
                assert(game.memory_record_body.text.contains("night crew were still inside"))
                assert(game.memory_record_body.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART)
                assert(not game.get_tree().paused)
                var record_rect = game.memory_record_panel.get_global_rect()
                assert(record_rect.position.x >= 0.0 and record_rect.end.x <= 1600.0)
                assert(record_rect.position.y >= 0.0 and record_rect.end.y <= 900.0)
                assert(game._touch_over_mobile_button(record_rect.get_center()))
                game.memory_record_timer = 0.05
                game._process(0.1)
                assert(not game.memory_record_panel.visible)
                assert(game.memory_read_button.visible)
                game.memory_read_button.emit_signal("pressed")
                assert(game.memory_record_panel.visible)
                game.memory_close_button.emit_signal("pressed")
                assert(not game.memory_record_panel.visible)
    assert(game._collected_count() == 3)
    assert(not game.exit_door.visible)
    assert(game.exit_door.get_node("CollisionShape3D").disabled)
    game._update_enemy_visuals(0.1)
    assert(game.enemy.get_meta("arms").size() == 2)
    game._finish(false)
    assert(game.mobile_action_buttons.has("PLAY AGAIN"))
    print("PASS: mobile controls, echo/pursuit, surface footsteps and noise, movement onboarding, progression, creature animation, and licensed assets.")
    game.ambient_player.stop()
    game.pulse_player.stop()
    game.heart_player.stop()
    game.footstep_player.stop()
    game.ambient_player.stream = null
    game.pulse_player.stream = null
    game.heart_player.stream = null
    game.footstep_player.stream = null
    game.footstep_concrete_stream = null
    game.footstep_splash_stream = null
    await create_timer(0.35).timeout
    floor_box = null
    station = null
    stick_center = Vector2.ZERO
    touch_down = null
    touch_drag = null
    touch_up = null
    look_down = null
    look_drag = null
    look_up = null
    game.queue_free()
    game = null
    await process_frame
    await process_frame
    quit()
