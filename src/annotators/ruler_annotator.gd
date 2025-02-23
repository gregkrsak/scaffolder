class_name RulerAnnotator
extends Node2D


var font: Font

var viewport: Viewport

var viewport_size: Vector2
var previous_camera_position := Vector2.ZERO
var previous_camera_zoom := 1.0


func _ready() -> void:
    font = Sc.gui.fonts.main_xxs
    
    viewport = get_viewport()
    viewport_size = viewport.get_visible_rect().size
    if !viewport.is_connected(
            "size_changed",
            self,
            "_on_viewport_size_changed"):
        viewport.connect(
                "size_changed",
                self,
                "_on_viewport_size_changed")


func _process(_delta: float) -> void:
    var next_camera_position: Vector2 = Sc.camera_controller.get_position()
    var next_camera_zoom: float = Sc.camera_controller.get_derived_zoom()
    
    if next_camera_position != previous_camera_position or \
            next_camera_zoom != previous_camera_zoom:
        # The camera changed, so we need to update the ruler.
        previous_camera_position = next_camera_position
        previous_camera_zoom = next_camera_zoom
        update()


func _draw() -> void:
    if !is_instance_valid(Sc.level):
        return
    
    var grid_spacing: Vector2 = \
            Sc.level_session.config.cell_size / previous_camera_zoom
    var screen_start_position: Vector2 = \
            previous_camera_position / previous_camera_zoom - \
            viewport_size / 2.0
    
    # Offset the start position to align with the grid cell boundaries.
    var ruler_start_position := Vector2(
            -fmod((screen_start_position.x + grid_spacing.x * 1000000000),
                    grid_spacing.x),
            -fmod((screen_start_position.y + grid_spacing.y * 1000000000),
                    grid_spacing.y))
    
    var ruler_size := viewport_size + grid_spacing
    var vertical_line_count := floor(ruler_size.x / grid_spacing.x) as int + 1
    var horizontal_line_count := \
            floor(ruler_size.y / grid_spacing.y) as int + 1
    var font_height := font.get_height()
    
    var start_x: float
    var start_y: float
    
    # Draw the vertical lines.
    start_y = ruler_start_position.y
    for i in vertical_line_count:
        start_x = ruler_start_position.x + grid_spacing.x * i
        var start_position := Vector2(start_x, start_y)
        var end_position := Vector2(start_x, start_y + ruler_size.y)
        draw_line(
                start_position,
                end_position,
                Sc.ann_params.ruler_line_color,
                Sc.ann_params.ruler_line_width)
        
        var text := str(round((screen_start_position.x + start_x) * \
                previous_camera_zoom))
        text = "0" if text == "-0" else text
        draw_string(
                font,
                Vector2(start_position.x + 4, font_height),
                text,
                Sc.ann_params.ruler_text_color)
    
    # Draw the horizontal lines.
    start_x = ruler_start_position.x
    for i in range(1, horizontal_line_count):
        start_y = ruler_start_position.y + grid_spacing.y * i
        var start_position := Vector2(start_x, start_y)
        var end_position := Vector2(start_x + ruler_size.x, start_y)
        draw_line(
                start_position,
                end_position,
                Sc.ann_params.ruler_line_color,
                Sc.ann_params.ruler_line_width)
        
        var text := str(round((screen_start_position.y + start_y) * \
                previous_camera_zoom))
        text = "0" if text == "-0" else text
        draw_string(
                font,
                Vector2(4, start_position.y + font_height * 0.8),
                text,
                Sc.ann_params.ruler_text_color)


func _on_viewport_size_changed() -> void:
    viewport_size = viewport.get_visible_rect().size
    update()
