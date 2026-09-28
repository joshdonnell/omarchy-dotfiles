hl.config({
  input = {
    touchpad = {
      natural_scroll = false,
      scroll_factor = 0.25,
    },
  },
  gestures = {
    workspace_swipe_create_new = false,
    workspace_swipe_invert = false,
    workspace_swipe_cancel_ratio = 0.3,
    workspace_swipe_min_speed_to_force = 60,
  },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
