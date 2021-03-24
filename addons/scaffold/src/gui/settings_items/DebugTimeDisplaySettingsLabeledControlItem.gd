extends CheckboxLabeledControlItem
class_name DebugTimeDisplaySettingsLabeledControlItem

const LABEL := "Debug time display"
const DESCRIPTION := ""

func _init().( \
        LABEL, \
        DESCRIPTION \
        ) -> void:
    pass

func on_pressed(pressed: bool) -> void:
    Gs.is_debug_time_shown = pressed
    Gs.save_state.set_setting( \
            Gs.IS_DEBUG_TIME_SHOWN_SETTINGS_KEY, \
            Gs.is_debug_time_shown)

func get_is_pressed() -> bool:
    return Gs.is_debug_time_shown

func get_is_enabled() -> bool:
    return true
