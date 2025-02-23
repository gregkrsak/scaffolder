tool
class_name SlowMotionController
extends Node


signal slow_motion_toggled(is_enabled)

const DESATURATION_SHADER := \
        preload("res://addons/scaffolder/src/desaturation.shader")

const GROUP_NAME_DESATURATABLES := "desaturatables"

const ENABLE_SLOW_MOTION_DURATION := 0.3
const DISABLE_SLOW_MOTION_DURATION := 0.2
const DISABLE_SLOW_MOTION_SATURATION_DURATION_MULTIPLIER := 0.9

var is_enabled := false setget set_slow_motion_enabled
var is_transitioning := false

var time_scale := 0.02
var tick_tock_tempo_multiplier := 25.0
var saturation := 0.2

var music: SlowMotionMusic

var _slow_motionable_animators := []

var _tween: ScaffolderTween
var _desaturation_material: ShaderMaterial


func _init() -> void:
    Sc.logger.on_global_init(self, "SlowMotionController")
    
    music = SlowMotionMusic.new()
    add_child(music)
    
    _tween = ScaffolderTween.new()
    add_child(_tween)
    
    _desaturation_material = ShaderMaterial.new()
    _desaturation_material.shader = DESATURATION_SHADER
    _set_saturation(1.0)
    
    music.connect(
            "transition_completed",
            self,
            "_on_music_transition_complete")


func register_manifest(manifest: Dictionary) -> void:
    if manifest.has("time_scale"):
        self.time_scale = manifest.time_scale
    if manifest.has("tick_tock_tempo_multiplier"):
        self.tick_tock_tempo_multiplier = manifest.tick_tock_tempo_multiplier
    if manifest.has("saturation"):
        self.saturation = manifest.saturation


func set_slow_motion_enabled(value: bool) -> void:
    if value == is_enabled:
        # No change.
        return
    
    is_enabled = value
    is_transitioning = true
    
    _tween.stop_all()
    
    var next_time_scale: float
    var time_scale_duration: float
    var ease_name: String
    var next_saturation: float
    var saturation_duration: float
    if is_enabled:
        next_time_scale = time_scale
        time_scale_duration = ENABLE_SLOW_MOTION_DURATION
        ease_name = "ease_in"
        next_saturation = saturation
        saturation_duration = \
                time_scale_duration * \
                DISABLE_SLOW_MOTION_SATURATION_DURATION_MULTIPLIER
    else:
        next_time_scale = 1.0
        time_scale_duration = DISABLE_SLOW_MOTION_DURATION
        ease_name = "ease_out"
        next_saturation = 1.0
        saturation_duration = time_scale_duration
    
    # Update time scale.
    _tween.interpolate_method(
            self,
            "_set_time_scale",
            Sc.time.time_scale,
            next_time_scale,
            time_scale_duration,
            ease_name,
            0.0,
            TimeType.PLAY_PHYSICS)
    
    # Update desaturation.
    var desaturatables: Array = Sc.utils.get_all_nodes_in_group(
            GROUP_NAME_DESATURATABLES)
    for node in desaturatables:
        node.material = _desaturation_material
    _tween.interpolate_method(
            self,
            "_set_saturation",
            _get_saturation(),
            next_saturation,
            saturation_duration,
            ease_name,
            0.0,
            TimeType.PLAY_PHYSICS)
    
    _tween.start()
    
    # Update music.
    if is_enabled:
        music.start(time_scale_duration)
    else:
        music.stop(time_scale_duration)
    
    emit_signal("slow_motion_toggled", is_enabled)


func _get_saturation() -> float:
    return _desaturation_material.get_shader_param("saturation")


func _set_saturation(saturation: float) -> void:
    _desaturation_material.set_shader_param("saturation", saturation)


func _get_time_scale() -> float:
    return Sc.time.time_scale


func _set_time_scale(value: float) -> void:
    # Update the main time_scale.
    Sc.time.time_scale = value
    
    # Update ScaffolderCharacterAnimators.
    for animator in _slow_motionable_animators:
        animator.match_rate_to_time_scale()


func _on_music_transition_complete(is_active: bool) -> void:
    is_transitioning = false


func get_is_enabled_or_transitioning() -> bool:
    return is_enabled or is_transitioning


func add_animator(animator: Node2D) -> void:
    _slow_motionable_animators.push_back(animator)


func remove_animator(animator: Node2D) -> void:
    _slow_motionable_animators.erase(animator)
