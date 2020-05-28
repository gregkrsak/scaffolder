class_name LegendItemType

enum { \
    SURFACE, \
    ORIGIN_SURFACE, \
    DESTINATION_SURFACE, \
    HYPOTHETICAL_EDGE_TRAJECTORY, \
    VALID_EDGE_TRAJECTORY, \
    ORIGIN, \
    DESTINATION, \
    INSTRUCTION_START, \
    INSTRUCTION_END, \
    UNKNOWN, \
}

static func get_type_string(type: int) -> String:
    match type:
        SURFACE:
            return "SURFACE"
        ORIGIN_SURFACE:
            return "ORIGIN_SURFACE"
        DESTINATION_SURFACE:
            return "DESTINATION_SURFACE"
        HYPOTHETICAL_EDGE_TRAJECTORY:
            return "HYPOTHETICAL_EDGE_TRAJECTORY"
        VALID_EDGE_TRAJECTORY:
            return "VALID_EDGE_TRAJECTORY"
        ORIGIN:
            return "ORIGIN"
        DESTINATION:
            return "DESTINATION"
        INSTRUCTION_START:
            return "INSTRUCTION_START"
        INSTRUCTION_END:
            return "INSTRUCTION_END"
        UNKNOWN:
            return "UNKNOWN"
        _:
            Utils.error("Invalid LegendItemType: %s" % type)
            return ""
