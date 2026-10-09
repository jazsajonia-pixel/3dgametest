extends SceneTree

func _initialize():
    call_deferred("_run_checks")

func _run_checks():
    var game = load("res://scenes/main.tscn").instance()
    root.add_child(game)
    yield(self, "idle_frame")
    assert(game.player != null)
    assert(game.shards.size() == 3)
    assert(game.pulse_charges == 3)
    assert(not game.flashlight.visible)

    game._emit_echo()
    assert(game.pulse_charges == 2)
    assert(game.echo_timer > 4.9)
    assert(game.enemy_awake)
    assert(game.echo_rings.size() == 1)
    game._process(0.05)
    assert(game.shards[0]["node"].visible)

    game._toggle_torch()
    assert(game.torch_on)
    assert(game.flashlight.visible)
    game._toggle_torch()
    assert(not game.torch_on)

    var station = game.safe_stations[0]["node"]
    game.player.global_transform.origin = station.global_transform.origin
    game.battery = 20.0
    game.pulse_charges = 1
    game._interact()
    assert(game.pulse_charges == 3)
    assert(game.battery == 100.0)

    for shard in game.shards:
        if not shard["taken"]:
            game.player.global_transform.origin = shard["node"].global_transform.origin
            game._check_shard_pickups()
    assert(game._collected_count() == 3)
    assert(not game.exit_door.visible)
    assert(game.exit_door.get_node("CollisionShape").disabled)
    game._update_enemy_visuals(0.1)
    assert(game.enemy.get_meta("arms").size() == 2)
    print("PASS: startup, echo reveal, torch, recharge, all shards, exit unlock, and creature animation.")
    quit()
