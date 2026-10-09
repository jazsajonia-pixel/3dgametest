extends SceneTree

func _initialize():
    call_deferred("_capture")

func _capture():
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
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
    game.ambient_player.stop()
    game.pulse_player.stream = null
    game.heart_player.stream = null
    image = null
    await create_timer(0.35).timeout
    game.queue_free()
    game = null
    await process_frame
    await process_frame
    quit()
