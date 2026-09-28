o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

hl.unbind("SUPER + CTRL + V")
o.bind("SUPER + SHIFT + V", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")

local key_press_milliseconds = 50

local function send_chords(chords)
  for index, chord in ipairs(chords) do
    local start = (index - 1) * key_press_milliseconds * 2

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = chord[1], key = chord[2], state = "down" }))
    end, { timeout = math.max(start, 1), type = "oneshot" })

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = chord[1], key = chord[2], state = "up" }))
    end, { timeout = start + key_press_milliseconds, type = "oneshot" })
  end
end

local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end

  return false
end

local function active_window_is_zed()
  local window = hl.get_active_window()
  return window ~= nil and (window.class or ""):find("^dev%.zed%.Zed") ~= nil
end

local key_names = {
  BRACKETLEFT = "bracketleft",
  BRACKETRIGHT = "bracketright",
  MINUS = "minus",
  EQUAL = "equal",
  SLASH = "slash",
  comma = "comma",
  LEFT = "Left",
  RIGHT = "Right",
  UP = "Up",
  DOWN = "Down",
  BACKSPACE = "BackSpace",
  ["code:19"] = "0",
}

local function pressed_chord(keys)
  local parts = {}
  for part in keys:gmatch("[^%s+]+") do
    table.insert(parts, part)
  end

  local key = table.remove(parts)
  return { table.concat(parts, " "), key_names[key] or key }
end

-- Zed gets every Super shortcut untouched, so zed/keymap.json can use Zed's macOS bindings with Super as Cmd.
local function mac_shortcut(keys, description, app_chords, terminal_chords)
  hl.unbind(keys)
  o.bind(keys, description, function()
    if active_window_is_terminal() then
      send_chords(terminal_chords)
    elseif keys:find("SUPER", 1, true) and active_window_is_zed() then
      send_chords({ pressed_chord(keys) })
    else
      send_chords(app_chords)
    end
  end)
end

local function same_everywhere(keys, description, chords)
  mac_shortcut(keys, description, chords, chords)
end

local function zed_or(keys, description, fallback)
  hl.unbind(keys)
  o.bind(keys, description, function()
    if active_window_is_zed() then
      send_chords({ pressed_chord(keys) })
    elseif type(fallback) == "string" then
      hl.exec_cmd(fallback)
    else
      hl.dispatch(fallback)
    end
  end)
end

local command_letters = {
  { "B", "Bold" },
  { "D", "Bookmark" },
  { "F", "Find" },
  { "G", "Find next" },
  { "I", "Italic" },
  { "J", "Downloads" },
  { "K", "Insert link" },
  { "L", "Address bar" },
  { "N", "New window" },
  { "O", "Open" },
  { "P", "Print" },
  { "R", "Reload" },
  { "S", "Save" },
  { "U", "Underline" },
  { "W", "Close tab" },
  { "Z", "Undo" },
}

for _, letter in ipairs(command_letters) do
  mac_shortcut("SUPER + " .. letter[1], "Mac " .. letter[2], { { "CTRL", letter[1] } }, { { "CTRL SHIFT", letter[1] } })
end

mac_shortcut("SUPER + C", "Universal copy", { { "CTRL", "C" } }, { { "CTRL", "Insert" } })
mac_shortcut("SUPER + V", "Universal paste", { { "CTRL", "V" } }, { { "SHIFT", "Insert" } })
same_everywhere("SUPER + X", "Universal cut", { { "CTRL", "X" } })

zed_or("SUPER + SHIFT + N", "Editor, or new window in Zed", "omarchy-launch-editor")
zed_or("SUPER + SHIFT + F", "File manager, or search in files in Zed", "omarchy-launch-nautilus")
zed_or("SUPER + SLASH", "Monitor scaling up, or toggle comment in Zed", "omarchy-hyprland-monitor-scaling up")
zed_or("SUPER + comma", "Dismiss last notification, or settings in Zed", "omarchy-shell notifications dismissOne")
zed_or("SUPER + ALT + S", "Move window to scratchpad, or save all in Zed", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
zed_or("SUPER + ALT + LEFT", "Move window to group on left, or previous tab in Zed", hl.dsp.window.move({ into_group = "l" }))
zed_or("SUPER + ALT + RIGHT", "Move window to group on right, or next tab in Zed", hl.dsp.window.move({ into_group = "r" }))
zed_or("SUPER + ALT + UP", "Move window to group on top, or add cursor above in Zed", hl.dsp.window.move({ into_group = "u" }))
zed_or("SUPER + ALT + DOWN", "Move window to group on bottom, or add cursor below in Zed", hl.dsp.window.move({ into_group = "d" }))

hl.unbind("SUPER + T")
o.bind("SUPER + T", "Mac New tab, or new terminal in a terminal", function()
  if active_window_is_terminal() then
    hl.exec_cmd("omarchy-launch-terminal")
  elseif active_window_is_zed() then
    send_chords({ { "SUPER", "T" } })
  else
    send_chords({ { "CTRL", "T" } })
  end
end)

same_everywhere("SUPER + A", "Mac Select all", { { "CTRL", "A" } })
same_everywhere("SUPER + SHIFT + Z", "Mac Redo", { { "CTRL SHIFT", "Z" } })
same_everywhere("SUPER + SHIFT + T", "Mac Reopen closed tab", { { "CTRL SHIFT", "T" } })
same_everywhere("SUPER + SHIFT + P", "Mac Command palette", { { "CTRL SHIFT", "P" } })

hl.unbind("SUPER + code:19")
same_everywhere("SUPER + code:19", "Mac Actual size", { { "CTRL", "0" } })

hl.unbind("SUPER + code:20")
same_everywhere("SUPER + MINUS", "Mac Zoom out", { { "CTRL", "minus" } })

hl.unbind("SUPER + code:21")
same_everywhere("SUPER + EQUAL", "Mac Zoom in", { { "CTRL", "equal" } })

same_everywhere("SUPER + BRACKETLEFT", "Mac Back", { { "ALT", "Left" } })
same_everywhere("SUPER + BRACKETRIGHT", "Mac Forward", { { "ALT", "Right" } })
same_everywhere("SUPER + SHIFT + BRACKETLEFT", "Mac Previous tab", { { "CTRL SHIFT", "Tab" } })
same_everywhere("SUPER + SHIFT + BRACKETRIGHT", "Mac Next tab", { { "CTRL", "Tab" } })

same_everywhere("SUPER + LEFT", "Mac Line start", { { "", "Home" } })
same_everywhere("SUPER + RIGHT", "Mac Line end", { { "", "End" } })
same_everywhere("SUPER + UP", "Mac Document start", { { "CTRL", "Home" } })
same_everywhere("SUPER + DOWN", "Mac Document end", { { "CTRL", "End" } })
same_everywhere("SUPER + SHIFT + LEFT", "Mac Select to line start", { { "SHIFT", "Home" } })
same_everywhere("SUPER + SHIFT + RIGHT", "Mac Select to line end", { { "SHIFT", "End" } })
same_everywhere("SUPER + SHIFT + UP", "Mac Select to document start", { { "CTRL SHIFT", "Home" } })
same_everywhere("SUPER + SHIFT + DOWN", "Mac Select to document end", { { "CTRL SHIFT", "End" } })
mac_shortcut("SUPER + BACKSPACE", "Mac Delete to line start", { { "SHIFT", "Home" }, { "", "BackSpace" } }, { { "CTRL", "U" } })

same_everywhere("ALT + LEFT", "Mac Word left", { { "CTRL", "Left" } })
same_everywhere("ALT + RIGHT", "Mac Word right", { { "CTRL", "Right" } })
same_everywhere("ALT + SHIFT + LEFT", "Mac Select word left", { { "CTRL SHIFT", "Left" } })
same_everywhere("ALT + SHIFT + RIGHT", "Mac Select word right", { { "CTRL SHIFT", "Right" } })
mac_shortcut("ALT + BACKSPACE", "Mac Delete word left", { { "CTRL", "BackSpace" } }, { { "CTRL", "W" } })
mac_shortcut("ALT + DELETE", "Mac Delete word right", { { "CTRL", "Delete" } }, { { "ALT", "D" } })
