extends InspectorItemController
class_name DescriptionItemController

const TYPE := InspectorItemType.DESCRIPTION
const IS_LEAF := true
const STARTS_COLLAPSED := true

var text: String
var description_text: String
var get_annotation_elements_funcref: FuncRef
var get_annotation_elements_arg

func _init( \
        parent_item: TreeItem, \
        tree: Tree, \
        graph: PlatformGraph, \
        text: String, \
        description_text: String, \
        get_annotation_elements_funcref: FuncRef, \
        get_annotation_elements_arg = null, \
        background_color = null) \
        .( \
        TYPE, \
        IS_LEAF, \
        STARTS_COLLAPSED, \
        parent_item, \
        tree, \
        graph) -> void:
    self.text = text
    self.description_text = description_text
    self.get_annotation_elements_funcref = get_annotation_elements_funcref
    self.get_annotation_elements_arg = get_annotation_elements_arg
    if background_color == null:
        background_color = Surfacer.ann_defaults \
                    .INSPECTOR_DESCRIPTION_ITEM_BACKGROUND_COLOR
    self.tree_item.set_custom_bg_color( \
            0, \
            background_color)
    _post_init()

func to_string() -> String:
    return "%s { text=%s }" % [ \
        InspectorItemType.get_type_string(type), \
        text, \
    ]

func get_text() -> String:
    return text

func get_description() -> String:
    return description_text

func find_and_expand_controller( \
        search_type: int, \
        metadata: Dictionary) -> bool:
    return false

func _create_children_inner() -> void:
    # Do nothing.
    pass

func _destroy_children_inner() -> void:
    # Do nothing.
    pass

func get_annotation_elements() -> Array:
    if get_annotation_elements_arg != null:
        return get_annotation_elements_funcref.call_func(get_annotation_elements_arg)
    else:
        return get_annotation_elements_funcref.call_func()
