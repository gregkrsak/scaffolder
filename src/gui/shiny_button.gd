tool
class_name ShinyButton, "res://addons/scaffolder/assets/images/editor_icons/shiny_button.png"
extends Button


const SHINE_TEXTURE := \
        preload("res://addons/scaffolder/assets/images/gui/shine_line.png")
const SHINE_DURATION := 0.35
const SHINE_INTERVAL := 3.5
const SHINE_SCALE := Vector2(1.0, 1.0)
const COLOR_PULSE_DURATION := 1.2
const COLOR_PULSE_INTERVAL := 2.4

export var texture: Texture setget _set_texture,_get_texture
export var texture_scale := Vector2(1.0, 1.0) setget \
        _set_texture_scale,_get_texture_scale
export var is_shiny := false setget _set_is_shiny,_get_is_shiny
export var includes_color_pulse := false setget \
        _set_includes_color_pulse,_get_includes_color_pulse
export var is_font_xl := false setget _set_is_font_xl,_get_is_font_xl

var shine_interval_id := -1
var color_pulse_interval_id := -1

var shine_start_x: float
var shine_end_x: float

var button_style_normal: StyleBox
var button_style_hover: StyleBox
var button_style_pressed: StyleBox
var button_style_pulse: StyleBoxFlat

var shine_tween := ScaffolderTween.new()
var color_pulse_tween := ScaffolderTween.new()


func _enter_tree() -> void:
    add_child(shine_tween)
    add_child(color_pulse_tween)


func _ready() -> void:
    button_style_normal = $MarginContainer/BottomButton.get_stylebox("normal")
    button_style_hover = $MarginContainer/BottomButton.get_stylebox("hover")
    button_style_pressed = \
            $MarginContainer/BottomButton.get_stylebox("pressed")
    
    Gs.utils.connect(
            "display_resized", self, "update")
    update()


func _exit_tree() -> void:
    if is_instance_valid(button_style_pulse):
        button_style_pulse.destroy()


func update_gui_scale() -> bool:
    if !has_meta("gs_rect_size"):
        set_meta("gs_rect_position", rect_position)
        set_meta("gs_rect_size", rect_size)
        set_meta("gs_rect_min_size", rect_min_size)
        set_meta("gs_texture_scale", texture_scale)
    var original_rect_position: Vector2 = get_meta("gs_rect_position")
    var original_rect_size: Vector2 = get_meta("gs_rect_size")
    var original_rect_min_size: Vector2 = get_meta("gs_rect_min_size")
    var original_texture_scale: Vector2 = get_meta("gs_texture_scale")

    texture_scale = original_texture_scale * Gs.gui.scale
    rect_min_size = original_rect_min_size * Gs.gui.scale
    rect_size = original_rect_size * Gs.gui.scale
    rect_position = original_rect_position * Gs.gui.scale
    $MarginContainer/ShineLineWrapper/ShineLine.scale = \
            SHINE_SCALE * Gs.gui.scale
    $MarginContainer/ScaffolderTextureRect.update_gui_scale()
    update()
    
    return true


func update() -> void:
    call_deferred("_deferred_update")


func _deferred_update() -> void:
    var half_size := rect_size / 2.0
    var shine_base_position: Vector2 = half_size
    shine_start_x = shine_base_position.x - rect_size.x
    shine_end_x = shine_base_position.x + rect_size.x
    
    if is_instance_valid(button_style_pulse):
        button_style_pulse.destroy()
    button_style_pulse = Gs.utils.create_stylebox_flat_scalable({
        bg_color = Gs.colors.button_normal,
        corner_radius = Gs.styles.button_corner_radius,
        corner_detail = Gs.styles.button_corner_detail,
        shadow_size = Gs.styles.button_shadow_size,
    })
    
    $MarginContainer.rect_size = rect_size
    $MarginContainer/BottomButton.text = text
    $MarginContainer/ShineLineWrapper/ShineLine.position = \
            Vector2(shine_start_x, shine_base_position.y)
    $MarginContainer/ScaffolderTextureRect.texture = texture
    $MarginContainer/ScaffolderTextureRect.texture_scale = texture_scale
    var font: Font = \
            Gs.gui.fonts.main_xl if \
            is_font_xl else \
            Gs.gui.fonts.main_m
    $MarginContainer/BottomButton.add_font_override(
            "font",
            font)
    
    shine_tween.stop_all()
    Gs.time.clear_interval(shine_interval_id)
    
    color_pulse_tween.stop_all()
    Gs.time.clear_interval(color_pulse_interval_id)
    $MarginContainer/BottomButton.add_stylebox_override(
            "normal",
            button_style_normal)
    
    if is_shiny:
        _trigger_shine()
        shine_interval_id = Gs.time.set_interval(
                funcref(self, "_trigger_shine"),
                SHINE_INTERVAL)
    
    if includes_color_pulse:
        _trigger_color_pulse()
        color_pulse_interval_id = Gs.time.set_interval(
                funcref(self, "_trigger_color_pulse"),
                COLOR_PULSE_INTERVAL)


func _trigger_shine() -> void:
    shine_tween.interpolate_property(
            $MarginContainer/ShineLineWrapper/ShineLine,
            "position:x",
            shine_start_x,
            shine_end_x,
            SHINE_DURATION,
            "linear")
    shine_tween.start()


func _trigger_color_pulse() -> void:
    # Give priority to normal button state styling.
    if $MarginContainer/TopButton.is_hovered() or \
            $MarginContainer/TopButton.is_pressed():
        return
    
    var color_original: Color = \
            button_style_normal.bg_color if \
            button_style_normal is StyleBoxFlat else \
            Gs.colors.button_normal
    var color_pulse: Color = Gs.colors.shiny_button_highlight
    var pulse_half_duration := COLOR_PULSE_DURATION / 2.0
    
    button_style_pulse.bg_color = color_original
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_pulse)
    
    color_pulse_tween.interpolate_property(
            button_style_pulse,
            "bg_color",
            color_original,
            color_pulse,
            pulse_half_duration,
            "ease_in_out_weak")
    color_pulse_tween.interpolate_property(
            button_style_pulse,
            "bg_color",
            color_pulse,
            color_original,
            pulse_half_duration,
            "ease_in_out_weak",
            pulse_half_duration)
    color_pulse_tween.start()


func _set_texture(value: Texture) -> void:
    texture = value
    update()


func _get_texture() -> Texture:
    return texture


func _set_texture_scale(value: Vector2) -> void:
    texture_scale = value
    update()


func _get_texture_scale() -> Vector2:
    return texture_scale


func _set_is_shiny(value: bool) -> void:
    is_shiny = value
    update()


func _get_is_shiny() -> bool:
    return is_shiny


func _set_includes_color_pulse(value: bool) -> void:
    includes_color_pulse = value
    update()


func _get_includes_color_pulse() -> bool:
    return includes_color_pulse


func _set_is_font_xl(value: bool) -> void:
    is_font_xl = value
    update()


func _get_is_font_xl() -> bool:
    return is_font_xl


func press() -> void:
    _on_TopButton_pressed()


func _on_TopButton_pressed() -> void:
    emit_signal("pressed")


func _on_TopButton_mouse_entered() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_hover)


func _on_TopButton_mouse_exited() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_normal)


func _on_TopButton_button_down() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_pressed)


func _on_TopButton_button_up() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_hover)
