extends SurfaceLegendItem
class_name OriginSurfaceLegendItem

const TYPE := LegendItemType.ORIGIN_SURFACE
const TEXT := "Origin\nsurface"
var COLOR_PARAMS: ColorParams = \
        AnnotationElementDefaults.ORIGIN_SURFACE_COLOR_PARAMS

func _init().( \
        TYPE, \
        TEXT, \
        COLOR_PARAMS) -> void:
    pass
