tool
class_name JsonUtils
extends Node


var REGEX_TO_MATCH_TRAILING_ZEROS_AFTER_DECIMAL := RegEx.new()


func _init() -> void:
    Sc.logger.on_global_init(self, "JsonUtils")
    REGEX_TO_MATCH_TRAILING_ZEROS_AFTER_DECIMAL.compile("\\.0*$")


# JSON encoding with custom syntax for vector values.
func to_json_object(value):
    match typeof(value):
        TYPE_STRING, \
        TYPE_BOOL, \
        TYPE_INT, \
        TYPE_REAL:
            return value
        TYPE_VECTOR2:
            return {
                "x": value.x,
                "y": value.y,
            }
        TYPE_VECTOR3:
            return {
                "x": value.x,
                "y": value.y,
                "z": value.z,
            }
        TYPE_COLOR:
            return {
                "r": value.r,
                "g": value.g,
                "b": value.b,
                "a": value.a,
            }
        TYPE_RECT2:
            return {
                "x": value.position.x,
                "y": value.position.y,
                "w": value.size.x,
                "h": value.size.y,
            }
        TYPE_ARRAY:
            value = value.duplicate()
            for index in value.size():
                value[index] = to_json_object(value[index])
            return value
        TYPE_RAW_ARRAY, \
        TYPE_INT_ARRAY, \
        TYPE_REAL_ARRAY, \
        TYPE_STRING_ARRAY, \
        TYPE_VECTOR2_ARRAY, \
        TYPE_VECTOR3_ARRAY, \
        TYPE_COLOR_ARRAY:
            value = Array(value)
            for index in value.size():
                value[index] = to_json_object(value[index])
            return value
        TYPE_DICTIONARY:
            value = value.duplicate()
            for key in value:
                value[key] = to_json_object(value[key])
            return value
        _:
            Sc.logger.error("Unsupported data type for JSON: " + value)


# JSON decoding with custom syntax for vector values.
func from_json_object(json):
    match typeof(json):
        TYPE_ARRAY:
            json = json.duplicate()
            for i in json.size():
                json[i] = from_json_object(json[i])
            return json
        TYPE_DICTIONARY:
            if json.size() == 2 and \
                    json.has("x") and \
                    json.has("y"):
                return Vector2(json.x, json.y)
            elif json.size() == 3 and \
                    json.has("x") and \
                    json.has("y") and \
                    json.has("z"):
                return Vector3(json.x, json.y, json.z)
            elif json.size() == 4 and \
                    json.has("r") and \
                    json.has("g") and \
                    json.has("b") and \
                    json.has("a"):
                return Color(json.r, json.g, json.b, json.a)
            elif json.size() == 4 and \
                    json.has("x") and \
                    json.has("y") and \
                    json.has("w") and \
                    json.has("h"):
                return Rect2(json.x, json.y, json.w, json.h)
            else:
                json = json.duplicate()
                for key in json:
                    json[key] = from_json_object(json[key])
                return json
        _:
            return json


func encode_vector2(value: Vector2) -> String:
    return "%s,%s" % [
        float_to_string(value.x),
        float_to_string(value.y),
    ]


func decode_vector2(value: String) -> Vector2:
    var comma_index := value.find(",")
    return Vector2(
            float(value.substr(0, comma_index - 1)),
            float(value.substr(comma_index + 1)))


func encode_vector3(value: Vector3) -> String:
    return "%s,%s,%s" % [
        float_to_string(value.x),
        float_to_string(value.y),
        float_to_string(value.z),
    ]


func decode_vector3(value: String) -> Vector3:
    var comma_index_1 := value.find(",")
    var comma_index_2 := value.find(",", comma_index_1 + 1)
    return Vector3(
            float(value.substr(0, comma_index_1 - 1)),
            float(value.substr(comma_index_1 + 1,
                    comma_index_2 - comma_index_1 - 1)),
            float(value.substr(comma_index_2 + 1)))


func encode_rect2(value: Rect2) -> String:
    return "%s,%s,%s,%s" % [
        float_to_string(value.position.x),
        float_to_string(value.position.y),
        float_to_string(value.size.x),
        float_to_string(value.size.y),
    ]


func decode_rect2(value: String) -> Rect2:
    var comma_index_1 := value.find(",")
    var comma_index_2 := value.find(",", comma_index_1 + 1)
    var comma_index_3 := value.find(",", comma_index_2 + 1)
    return Rect2(
            float(value.substr(0, comma_index_1 - 1)),
            float(value.substr(comma_index_1 + 1,
                    comma_index_2 - comma_index_1 - 1)),
            float(value.substr(comma_index_2 + 1,
                    comma_index_3 - comma_index_2 - 1)),
            float(value.substr(comma_index_3 + 1)))


func encode_color(value: Color) -> String:
    return "%s,%s,%s,%s" % [
        float_to_string(value.r),
        float_to_string(value.g),
        float_to_string(value.b),
        float_to_string(value.a),
    ]


func decode_color(value: String) -> Color:
    var comma_index_1 := value.find(",")
    var comma_index_2 := value.find(",", comma_index_1 + 1)
    var comma_index_3 := value.find(",", comma_index_2 + 1)
    if comma_index_3 >= 0:
        return Color(
                float(value.substr(0, comma_index_1 - 1)),
                float(value.substr(comma_index_1 + 1,
                        comma_index_2 - comma_index_1 - 1)),
                float(value.substr(comma_index_2 + 1,
                        comma_index_3 - comma_index_2 - 1)),
                float(value.substr(comma_index_3 + 1)))
    else:
        return Color(
                float(value.substr(0, comma_index_1 - 1)),
                float(value.substr(comma_index_1 + 1,
                        comma_index_2 - comma_index_1 - 1)),
                float(value.substr(comma_index_2 + 1)))


func encode_vector2_array(value) -> Array:
    var result := []
    result.resize(value.size())
    for i in value.size():
        result[i] = encode_vector2(value[i])
    return result


func decode_vector2_array(value: Array) -> Array:
    var result := []
    result.resize(value.size())
    for i in value.size():
        result[i] = decode_vector2(value[i])
    return result


func remove_trailing_zeros_after_decimal(value: String) -> String:
    return REGEX_TO_MATCH_TRAILING_ZEROS_AFTER_DECIMAL.sub(value, ".")


func float_to_string(value: float) -> String:
    return remove_trailing_zeros_after_decimal("%f" % value)
