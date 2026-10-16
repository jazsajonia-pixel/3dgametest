extends SceneTree

func _initialize():
    call_deferred("_capture")

func _capture():
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    await process_frame
    var onboarding_image = get_root().get_viewport().get_texture().get_image()
    var onboarding_err = onboarding_image.save_png("res://screenshots/onboarding-preview.png")
    if onboarding_err != OK:
        printerr("Onboarding screenshot save failed: ", onboarding_err)
        quit(1)
        return
    print("Captured screenshots/onboarding-preview.png")
    onboarding_image = null

    game.player.position = Vector3(5.3, 0.92, -23.0)
    game.player.rotation.y = -1.55
    game.camera.rotation.x = -0.42
    game._toggle_torch()
    game._emit_echo()
    game.ui_message.visible = false
    game.message_timer = 0.0
    await process_frame
    await process_frame
    var image = get_root().get_viewport().get_texture().get_image()
    var err = image.save_png("res://screenshots/archive-preview.png")
    if err != OK:
        printerr("Preview screenshot save failed: ", err)
        quit(1)
        return
    print("Captured screenshots/archive-preview.png")

    var first_memory = game.shards[0]
    first_memory["node"].visible = true
    game.player.global_position = first_memory["node"].global_position
    game._check_shard_pickups()
    if not game.memory_read_button.visible:
        printerr("Memory record did not unlock after the first fragment.")
        quit(1)
        return
    game.memory_read_button.emit_signal("pressed")
    await process_frame
    await process_frame
    var memory_image = get_root().get_viewport().get_texture().get_image()
    var memory_err = memory_image.save_png("res://screenshots/memory-record-preview.png")
    if memory_err != OK:
        printerr("Memory record screenshot save failed: ", memory_err)
        quit(1)
        return
    print("Captured screenshots/memory-record-preview.png")

    game.ambient_player.stop()
    game.pulse_player.stream = null
    game.heart_player.stream = null
    game.footstep_player.stop()
    game.footstep_player.stream = null
    game.footstep_concrete_stream = null
    game.footstep_splash_stream = null
    game.footstep_player = null
    image = null
    memory_image = null
    await create_timer(0.35).timeout
    game.queue_free()
    game = null
    await process_frame
    await process_frame
    quit()
