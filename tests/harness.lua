-- Minimal stand-in for Factorio's data stage, fed the real base prototypes from
-- https://github.com/wube/factorio-data (fetched by tests/run.sh).
BASE_BEAMS = os.getenv("FACTORIO_DATA") or "tests/factorio-data"
BASE_BEAMS = BASE_BEAMS .. "/base/prototypes/entity/beams.lua"
MOD_ROOT = os.getenv("MOD_ROOT") or "RainbowLasers-2-1"

util = setmetatable({ by_pixel = function(x, y) return {x/32, y/32} end,
                      by_pixel_hr = function(x, y) return {x/64, y/64} end,
                      table = { deepcopy = function(t) return t end } },
                    {__index = function() return function() return {} end end})
function volume_multiplier() return {} end
function sound_variations() return {} end
function make_heat_pipe_pictures() return {} end
data = { raw = {} }
function data:extend(list)
  for _, p in pairs(list) do
    self.raw[p.type] = self.raw[p.type] or {}
    self.raw[p.type][p.name] = p
  end
end

local ok, err = pcall(dofile, BASE_BEAMS)
print("base beams.lua loaded:", ok, ok and "" or err)
assert(data.raw.beam and data.raw.beam["laser-beam"], "laser-beam not produced by base prototypes")
print("beams present:", (function() local t={} for k in pairs(data.raw.beam) do t[#t+1]=k end table.sort(t) return table.concat(t, ", ") end)())

-- snapshot the vanilla values we care about
local gs = data.raw.beam["laser-beam"].graphics_set
print(("VANILLA head visible: %s frames=%s line=%s  | light frames=%s repeat=%s")
  :format(gs.beam.head.layers[1].filename:match("[^/]+$"), tostring(gs.beam.head.layers[1].frame_count),
          tostring(gs.beam.head.layers[1].line_length), tostring(gs.beam.head.layers[2].frame_count),
          tostring(gs.beam.head.layers[2].repeat_count)))
print(("VANILLA ground.head: %s repeat=%s tint=%s"):format(gs.ground.head.filename:match("[^/]+$"),
      tostring(gs.ground.head.repeat_count), gs.ground.head.tint and "red" or "nil"))

dofile(MOD_ROOT .. "/data-updates.lua")
print("\n--- after Rainbow Lasers data-updates.lua ---")
