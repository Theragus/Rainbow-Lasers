-- Edge cases another mod could create before data-updates runs.
local MOD = (os.getenv("MOD_ROOT") or "RainbowLasers") .. "/data-updates.lua"
local fails = 0
local function case(name, build, assertion)
  data = { raw = { beam = {} } }
  build(data.raw.beam)
  local ok, err = pcall(dofile, MOD)
  if not ok then
    print(("  FAIL %-38s crashed: %s"):format(name, err)); fails = fails + 1; return
  end
  local aok, aerr = pcall(assertion, data.raw.beam)
  if aok then print(("  OK   %s"):format(name))
  else print(("  FAIL %-38s %s"):format(name, aerr)); fails = fails + 1 end
end

local function layer(light) return { filename = "__base__/x.png", frame_count = 8, line_length = 8,
                                     width = 64, height = 12, draw_as_light = light or nil } end

case("no laser-beam at all", function() end, function() end)

case("beam exists but graphics_set removed",
  function(b) b["laser-beam"] = { type = "beam", name = "laser-beam" } end,
  function() end)

case("graphics_set present but empty",
  function(b) b["laser-beam"] = { graphics_set = {} } end,
  function() end)

case("light layer listed first",
  function(b) b["laser-beam"] = { graphics_set = { beam = { head = { layers = { layer(true), layer(false) } } } } } end,
  function(b)
    local l = b["laser-beam"].graphics_set.beam.head.layers
    assert(l[2].filename:find("RainbowLasers"), "visible layer (index 2) was not repointed")
    assert(l[1].filename:find("__base__"), "light layer (index 1) must keep its sheet")
    assert(l[1].repeat_count == 9, "light layer not stretched")
  end)

case("extra layers inserted by another mod",
  function(b) b["laser-beam"] = { graphics_set = { beam = { head = { layers = { layer(false), layer(false), layer(true) } } } } } end,
  function(b)
    local l = b["laser-beam"].graphics_set.beam.head.layers
    assert(l[1].frame_count == 72, "first visible layer not converted")
    assert(l[3].repeat_count == 9, "light layer not stretched")
  end)

case("multiple body variations",
  function(b) b["laser-beam"] = { graphics_set = { beam = { body = {
      { layers = { layer(false), layer(true) } }, { layers = { layer(false), layer(true) } } } } } } end,
  function(b)
    for i, v in ipairs(b["laser-beam"].graphics_set.beam.body) do
      assert(v.layers[1].filename:find("RainbowLasers"), "body variation " .. i .. " not converted")
    end
  end)

case("sheet previously replaced using stripes",
  function(b) b["laser-beam"] = { graphics_set = { beam = { head = { layers = {
      { stripes = {{ filename = "__other__/s.png", width_in_frames = 8, height_in_frames = 1 }},
        frame_count = 8, width = 64, height = 12 }, layer(true) } } } } } end,
  function(b)
    local l = b["laser-beam"].graphics_set.beam.head.layers[1]
    assert(l.stripes == nil, "stripes not cleared - filename would be ignored")
    assert(l.filename:find("RainbowLasers"), "filename not set")
  end)

case("unlayered (single animation) beam part",
  function(b) b["laser-beam"] = { graphics_set = { beam = { head = layer(false) } } } end,
  function(b) assert(b["laser-beam"].graphics_set.beam.head.frame_count == 72, "unlayered head not converted") end)

case("laser-beam-no-sound added by another mod",
  function(b) b["laser-beam-no-sound"] = { graphics_set = { ground = { body = layer(true) } } } end,
  function(b) assert(b["laser-beam-no-sound"].graphics_set.ground.body.filename:find("RainbowLasers"),
    "no-sound variant not converted") end)

print(("\n%d edge-case failures"):format(fails))
os.exit(fails == 0 and 0 or 1)
