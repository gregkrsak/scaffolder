tool
class_name Time
extends Node


const PHYSICS_FPS := 60.0
const PHYSICS_TIME_STEP := 1.0 / PHYSICS_FPS

const _DEFAULT_TIME_SCALE := 1.0

const _DEFAULT_ADDITIONAL_DEBUG_TIME_SCALE := 1.0
#const _DEFAULT_ADDITIONAL_DEBUG_TIME_SCALE := 0.1

var time_scale := _DEFAULT_TIME_SCALE setget _set_time_scale
var additional_debug_time_scale := _DEFAULT_ADDITIONAL_DEBUG_TIME_SCALE \
        setget _set_additional_debug_time_scale

var _app_time: _TimeTracker
var _play_time: _TimeTracker

# Dictionary<int, _Timeout>
var _timeouts := {}
# Dictionary<int, _Interval>
var _intervals := {}
# Dictionary<int, ScaffolderTween>
var _tweens := {}
var _last_timeout_id := -1
# Dictionary<FuncRef, _Throttler>
var _throttled_callbacks := {}
# Dictionary<FuncRef, _Debouncer>
var _debounced_callbacks := {}


func _init() -> void:
    Sc.logger.on_global_init(self, "Time")
    pause_mode = Node.PAUSE_MODE_PROCESS


func _ready() -> void:
    _app_time = _TimeTracker.new()
    _app_time.pause_mode = Node.PAUSE_MODE_PROCESS
    add_child(_app_time)
    
    _play_time = _TimeTracker.new()
    _play_time.pause_mode = Node.PAUSE_MODE_STOP
    add_child(_play_time)


func _process(_delta: float) -> void:
    _handle_tweens()
    _handle_timeouts()
    _handle_intervals()


func _handle_tweens() -> void:
    var finished_tween_ids := []
    for id in _tweens:
        var tween: ScaffolderTween = _tweens[id]
        tween.step()
        if !tween.is_active():
            finished_tween_ids.push_back(id)
    
    for id in finished_tween_ids:
        _tweens.erase(id)


# This only ever triggers one expired timeout within a single frame, which
# helps to balance load on the CPU.
func _handle_timeouts() -> void:
    var expired_timeout_id := -1
    for id in _timeouts:
        if _timeouts[id].get_has_expired():
            expired_timeout_id = id
            break
    
    if expired_timeout_id >= 0:
        _timeouts[expired_timeout_id].trigger()
        _timeouts.erase(expired_timeout_id)


# This only ever triggers one interval within a single frame, which helps to
# balance load on the CPU.
func _handle_intervals() -> void:
    var triggered_interval_id := -1
    for id in _intervals:
        if _intervals[id].get_has_reached_next_trigger_time():
            triggered_interval_id = id
            break
    
    if triggered_interval_id >= 0:
        _intervals[triggered_interval_id].trigger()


func get_next_task_id() -> int:
    _last_timeout_id += 1
    return _last_timeout_id


func get_app_time() -> float:
    return get_elapsed_time(TimeType.APP_PHYSICS)


func get_clock_time() -> float:
    return get_elapsed_time(TimeType.APP_CLOCK)


func get_play_time() -> float:
    return get_elapsed_time(TimeType.PLAY_PHYSICS)


func get_scaled_play_time() -> float:
    return get_elapsed_time(TimeType.PLAY_PHYSICS_SCALED)


func get_play_physics_frame_count() -> int:
    return _play_time.physics_frame_count


func get_elapsed_time(time_type: int) -> float:
    var tracker := _get_time_tracker_for_time_type(time_type)
    var key := _get_elapsed_time_key_for_time_type(time_type)
    return tracker.get(key)


func _get_time_tracker_for_time_type(time_type: int) -> _TimeTracker:
    match time_type:
        TimeType.APP_PHYSICS, \
        TimeType.APP_CLOCK, \
        TimeType.APP_PHYSICS_SCALED, \
        TimeType.APP_CLOCK_SCALED, \
        TimeType.APP_PHYSICS_FRAME_COUNT, \
        TimeType.APP_RENDER_FRAME_COUNT:
            return _app_time
        TimeType.PLAY_PHYSICS, \
        TimeType.PLAY_RENDER, \
        TimeType.PLAY_PHYSICS_SCALED, \
        TimeType.PLAY_RENDER_SCALED, \
        TimeType.PLAY_PHYSICS_FRAME_COUNT, \
        TimeType.PLAY_RENDER_FRAME_COUNT:
            return _play_time
        _:
            Sc.logger.error("Unrecognized time_type: %d" % time_type)
            return null


func _get_elapsed_time_key_for_time_type(time_type: int) -> String:
    match time_type:
        TimeType.APP_PHYSICS, \
        TimeType.PLAY_PHYSICS:
            return "elapsed_physics_time"
        TimeType.APP_PHYSICS_SCALED, \
        TimeType.PLAY_PHYSICS_SCALED:
            return "elapsed_physics_scaled_time"
        TimeType.APP_CLOCK:
            return "elapsed_clock_time"
        TimeType.APP_CLOCK_SCALED:
            return "elapsed_clock_scaled_time"
        TimeType.PLAY_RENDER:
            return "elapsed_render_time"
        TimeType.PLAY_RENDER_SCALED:
            return "elapsed_render_scaled_time"
        TimeType.APP_PHYSICS_FRAME_COUNT, \
        TimeType.PLAY_PHYSICS_FRAME_COUNT:
            return "physics_frame_count"
        TimeType.APP_RENDER_FRAME_COUNT, \
        TimeType.PLAY_RENDER_FRAME_COUNT:
            return "render_frame_count"
        _:
            Sc.logger.error("Unrecognized time_type: %d" % time_type)
            return ""


func get_combined_scale() -> float:
    return time_scale * additional_debug_time_scale


func scale_delta(duration: float) -> float:
    return duration * get_combined_scale()


func _set_time_scale(value: float) -> void:
    time_scale = value
    _app_time.time_scale = get_combined_scale()
    _play_time.time_scale = get_combined_scale()


func _set_additional_debug_time_scale(value: float) -> void:
    additional_debug_time_scale = value
    _app_time.time_scale = get_combined_scale()
    _play_time.time_scale = get_combined_scale()


func tween_method(
        object: Object,
        key: String,
        initial_val,
        final_val,
        duration: float,
        ease_name := "ease_in_out",
        delay := 0.0,
        time_type := TimeType.APP_PHYSICS,
        on_completed_callback: FuncRef = null,
        arguments := []) -> int:
    return _tween(
            object,
            key,
            false,
            initial_val,
            final_val,
            duration,
            ease_name,
            delay,
            time_type,
            on_completed_callback,
            arguments)


func tween_property(
        object: Object,
        key: String,
        initial_val,
        final_val,
        duration: float,
        ease_name := "ease_in_out",
        delay := 0.0,
        time_type := TimeType.APP_PHYSICS,
        on_completed_callback: FuncRef = null,
        arguments := []) -> int:
    return _tween(
            object,
            key,
            true,
            initial_val,
            final_val,
            duration,
            ease_name,
            delay,
            time_type,
            on_completed_callback,
            arguments)


func _tween(
        object: Object,
        key: String,
        is_property: bool,
        initial_val,
        final_val,
        duration: float,
        ease_name: String,
        delay: float,
        time_type := TimeType.APP_PHYSICS,
        on_completed_callback: FuncRef = null,
        arguments := []) -> int:
    var tween := ScaffolderTween.new()
    tween._interpolate(
            object,
            key,
            is_property,
            initial_val,
            final_val,
            duration,
            ease_name,
            delay,
            time_type)
    if on_completed_callback != null:
        tween.connect(
                "tween_all_completed",
                self,
                "_call_tween_completed_callback",
                [on_completed_callback, arguments])
    tween.start()
    _tweens[tween.id] = tween
    return tween.id


func _call_tween_completed_callback(
        on_completed_callback: FuncRef,
        arguments: Array) -> void:
    on_completed_callback.call_funcv(arguments)


func clear_tween(
        tween_id: int,
        triggers_completed := false) -> bool:
    if !_tweens.has(tween_id):
        return false
    if triggers_completed:
        _tweens[tween_id].trigger_completed()
    _tweens.erase(tween_id)
    return true


func set_timeout(
        callback: FuncRef,
        delay: float,
        arguments := [],
        time_type := TimeType.APP_PHYSICS) -> int:
    var timeout := _Timeout.new(
            time_type,
            callback,
            delay,
            arguments)
    _timeouts[timeout.id] = timeout
    return timeout.id


func clear_timeout(
        timeout_id: int,
        triggers_timeout := false) -> bool:
    if !_timeouts.has(timeout_id):
        return false
    if triggers_timeout:
        _timeouts[timeout_id].trigger()
    _timeouts.erase(timeout_id)
    return true


func set_interval(
        callback: FuncRef,
        period: float,
        arguments := [],
        time_type := TimeType.APP_PHYSICS) -> int:
    var interval := _Interval.new(
            time_type,
            callback,
            period,
            arguments)
    _intervals[interval.id] = interval
    return interval.id


func clear_interval(
        interval_id: int,
        triggers_interval := false) -> bool:
    if !_intervals.has(interval_id):
        return false
    if triggers_interval:
        _intervals[interval_id].trigger()
    _intervals.erase(interval_id)
    return true


func throttle(
        callback: FuncRef,
        interval: float,
        invokes_at_end := true,
        time_type := TimeType.APP_PHYSICS) -> FuncRef:
    var throttler := _Throttler.new(
            time_type,
            callback,
            interval,
            invokes_at_end)
    var throttled_callback := funcref(
            throttler,
            "on_call")
    _throttled_callbacks[throttled_callback] = throttler
    return throttled_callback


func clear_throttle(throttled_callback: FuncRef) -> void:
    assert(_throttled_callbacks.has(throttled_callback))
    _throttled_callbacks[throttled_callback].cancel()


func debounce(
        callback: FuncRef,
        interval: float,
        invokes_at_start := false,
        time_type := TimeType.APP_PHYSICS) -> FuncRef:
    var debouncer := _Debouncer.new(
            time_type,
            callback,
            interval,
            invokes_at_start)
    var debounced_callback := funcref(
            debouncer,
            "on_call")
    _debounced_callbacks[debounced_callback] = debouncer
    return debounced_callback


func clear_debounce(debounced_callback: FuncRef) -> void:
    assert(_debounced_callbacks.has(debounced_callback))
    _debounced_callbacks[debounced_callback].cancel()
