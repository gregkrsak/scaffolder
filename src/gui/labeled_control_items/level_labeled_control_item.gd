class_name LevelLabeledControlItem
extends TextLabeledControlItem


const LABEL := "Level:"
const DESCRIPTION := ""

var level_id: String


func _init(level_session_or_id).(
        LABEL,
        DESCRIPTION \
        ) -> void:
    self.level_id = \
            level_session_or_id.id if \
            level_session_or_id is ScaffolderLevel else \
            (level_session_or_id if \
            level_session_or_id is String else \
            "")


func get_text() -> String:
    return Gs.level_config.get_level_config(level_id).name if \
            level_id != "" else \
            "—"
