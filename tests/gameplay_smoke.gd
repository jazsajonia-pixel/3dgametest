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
    _assert_imported_pipe_asset(game)
    assert(game.mobile_action_buttons.size() == 5)
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
    assert(game._collected_count() == 3)
    assert(not game.exit_door.visible)
    assert(game.exit_door.get_node("CollisionShape3D").disabled)
    game._update_enemy_visuals(0.1)
    assert(game.enemy.get_meta("arms").size() == 2)
    game._finish(false)
    assert(game.mobile_action_buttons.has("PLAY AGAIN"))
    print("PASS: mobile stick/look, action buttons, restart UI, echo, recharge, shards, exit, and creature animation.")
    game.ambient_player.stop()
    game.pulse_player.stop()
    game.heart_player.stop()
    game.ambient_player.stream = null
    game.pulse_player.stream = null
    game.heart_player.stream = null
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
