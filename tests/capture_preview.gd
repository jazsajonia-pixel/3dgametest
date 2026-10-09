extends SceneTree

func _initialize():
    call_deferred("_capture")

func _capture():
    var game = load("res://scenes/main.tscn").instance()
    root.add_child(game)
    game._emit_echo()
    game.ui_message.visible = false
    game.message_timer = 0.0
    yield(self, "idle_frame")
    yield(self, "idle_frame")
    var image = get_root().get_viewport().get_texture().get_data()
    image.flip_y()
    var err = image.save_png("res://screenshots/archive-preview.png")
    if err != OK:
        printerr("Preview screenshot save failed: ", err)
        quit(1)
        return
    print("Captured screenshots/archive-preview.png")
    quit()
