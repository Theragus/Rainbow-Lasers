dofile("tests/harness.lua")

local png = {}  -- filled from a sidecar file of real PNG dimensions
for line in io.lines(os.getenv("PNG_DIMS") or "tests/png-dims.txt") do
  local w, h, name = line:match("(%d+) (%d+) (.+)")
  png[name] = {w = tonumber(w), h = tonumber(h)}
end

local failures, checks = {}, 0
local function check(cond, msg)
  checks = checks + 1
  if not cond then failures[#failures+1] = msg end
end

-- Verifies a replaced animation's declared grid matches the real image on disk.
local function check_sheet(anim, label)
  local file = anim.filename:match("[^/]+$")
  local dim = png[file]
  check(dim ~= nil, label .. ": sheet " .. file .. " not shipped by the mod")
  if not dim then return end
  local cols = anim.line_length
  local rows = anim.frame_count / cols
  check(rows % 1 == 0, label .. ": frame_count not divisible by line_length")
  check(anim.width * cols == dim.w,
    ("%s: %s width %d*%d=%d but image is %d"):format(label, file, anim.width, cols, anim.width*cols, dim.w))
  check(anim.height * rows == dim.h,
    ("%s: %s height %d*%d=%d but image is %d"):format(label, file, anim.height, rows, anim.height*rows, dim.h))
  check(anim.tint == nil, label .. ": tint should be cleared")
  check(anim.repeat_count == nil, label .. ": repeat_count should be cleared on an RGB sheet")
  print(("  OK %-12s %-34s %dx%d frames=%d grid=%dx%d"):format(label, file, anim.width, anim.height, anim.frame_count, cols, rows))
end

local gs = data.raw.beam["laser-beam"].graphics_set
local CYCLE = 72

-- beam layers
for _, part in ipairs{"head", "tail"} do
  local layers = gs.beam[part].layers
  check_sheet(layers[1], part)
  check(layers[1].filename:find("RainbowLasers"), part .. ": visible layer not repointed to the mod")
  local light = layers[2]
  check(light.draw_as_light == true, part .. ": layer 2 is not the light layer")
  check(light.filename:find("__base__") ~= nil, part .. " light: should keep the vanilla sheet")
  check((light.frame_count or 1) * (light.repeat_count or 1) == CYCLE,
    ("%s light: cycle is %d, expected %d"):format(part, (light.frame_count or 1)*(light.repeat_count or 1), CYCLE))
  check(light.animation_speed == 0.5, part .. " light: animation_speed mismatch")
  print(("  OK %-12s light cycle = %d frames (%d x %d)"):format(part, CYCLE, light.frame_count, light.repeat_count))
end

for i, variation in ipairs(gs.beam.body) do
  check_sheet(variation.layers[1], "body[" .. i .. "]")
  local light = variation.layers[2]
  check((light.frame_count or 1) * (light.repeat_count or 1) == CYCLE, "body light: wrong cycle length")
end

-- ground glow
for _, part in ipairs{"head", "body", "tail"} do
  check_sheet(gs.ground[part], "ground." .. part)
  check(gs.ground[part].draw_as_light == true, "ground." .. part .. ": lost draw_as_light")
  check(gs.ground[part].tint == nil, "ground." .. part .. ": vanilla red tint not cleared")
end

-- the animation must complete one full hue walk in the same time everywhere
for _, a in ipairs{gs.beam.head.layers[1], gs.beam.body[1].layers[1], gs.ground.head, gs.ground.body} do
  check(a.animation_speed == 0.5, "animation_speed drifted between parts")
end

-- untouched prototypes must stay untouched
local function mentions_mod(t, seen)
  seen = seen or {}
  if seen[t] then return false end
  seen[t] = true
  for k, v in pairs(t) do
    if type(v) == "string" and v:find("RainbowLasers") then return true end
    if type(v) == "table" and mentions_mod(v, seen) then return true end
  end
  return false
end
for _, other in ipairs{"electric-beam", "electric-beam-no-sound"} do
  check(not mentions_mod(data.raw.beam[other]), other .. " was modified but should not be")
  print("  OK " .. other .. " left alone")
end

print(("\n%d checks run, %d failures"):format(checks, #failures))
for _, f in ipairs(failures) do print("  FAIL " .. f) end
os.exit(#failures == 0 and 0 or 1)
