-- Rainbow Lasers
-- Replaces the laser beam spritesheets with RGB ("rainbow") variants.
--
-- Every beam sheet shipped by this mod is the vanilla 8-frame animation repeated
-- once per hue step, laid out 8 frames per row. That gives 8 * 9 = 72 frames, so
-- a beam cycles through its animation while walking through the hues.

local RGB_FRAME_COUNT = 72 -- total frames in every sheet in graphics/
local RGB_LINE_LENGTH = 8  -- frames per row, i.e. the vanilla animation length
local RGB_HUE_STEPS = RGB_FRAME_COUNT / RGB_LINE_LENGTH -- rows, i.e. hues

local ANIMATION_SPEED = 0.5
local TINT = nil -- e.g. {0.5, 0.5, 0.5} to dim the beams; nil keeps the sheets as-is

local GRAPHICS = "__RainbowLasers__/graphics/"

-- Beams whose graphics we recolour. "laser-beam" is the vanilla one used by laser
-- turrets, personal laser defense and destroyer robots; the no-sound variant only
-- exists when another mod adds it.
local BEAM_NAMES = { "laser-beam", "laser-beam-no-sound" }

-- Points an animation at one of our RGB sheets. The frame layout is ours now, so
-- any vanilla or third-party layout hints have to go, otherwise the sheet is read
-- with the wrong geometry (or `filename` is ignored outright).
local function apply_rgb_sheet(animation, filename)
  if not animation then return end

  animation.filename = filename
  animation.filenames = nil
  animation.stripes = nil
  animation.slice = nil
  animation.frame_count = RGB_FRAME_COUNT
  animation.line_length = RGB_LINE_LENGTH
  animation.repeat_count = nil
  animation.frame_sequence = nil
  animation.animation_speed = ANIMATION_SPEED
  animation.tint = TINT
end

-- The light layers keep their vanilla sheet, so they are stretched over the longer
-- RGB cycle instead: the same few frames are repeated once per hue step.
local function stretch_light(animation)
  if not animation then return end

  local frames = (animation.frame_count or 1) * (animation.repeat_count or 1)
  if frames > 0 and RGB_FRAME_COUNT % frames == 0 then
    animation.repeat_count = (animation.repeat_count or 1) * (RGB_FRAME_COUNT / frames)
  else
    animation.repeat_count = RGB_HUE_STEPS
  end
  animation.animation_speed = ANIMATION_SPEED
end

-- Beam parts are layered: a visible layer plus a `draw_as_light` glow layer. Look
-- them up by that flag rather than by index, so added layers don't shift things.
local function split_layers(animation)
  if not animation then return nil, nil end

  if not animation.layers then
    if animation.draw_as_light then return nil, animation end
    return animation, nil
  end

  local visible, light
  for _, layer in pairs(animation.layers) do
    if layer.draw_as_light then
      light = light or layer
    else
      visible = visible or layer
    end
  end
  return visible, light
end

local function recolour_beam_part(animation, filename)
  local visible, light = split_layers(animation)
  apply_rgb_sheet(visible, filename)
  stretch_light(light)
end

local function recolour_beam(name)
  local beam = data.raw["beam"] and data.raw["beam"][name]
  local graphics_set = beam and beam.graphics_set
  if not graphics_set then return end

  local beam_graphics = graphics_set.beam
  if beam_graphics then
    recolour_beam_part(beam_graphics.head, GRAPHICS .. "laser-body-rgb.png")
    recolour_beam_part(beam_graphics.tail, GRAPHICS .. "laser-end-rgb.png")

    -- `body` is a list of animation variations, all of which use the body sheet.
    for _, variation in pairs(beam_graphics.body or {}) do
      recolour_beam_part(variation, GRAPHICS .. "laser-body-rgb.png")
    end
  end

  -- The ground glow is a single light animation per part, with a red vanilla tint
  -- that has to go along with the sheet.
  local ground = graphics_set.ground
  if ground then
    apply_rgb_sheet(ground.head, GRAPHICS .. "laser-ground-light-head-rgb.png")
    apply_rgb_sheet(ground.body, GRAPHICS .. "laser-ground-light-body-rgb.png")
    apply_rgb_sheet(ground.tail, GRAPHICS .. "laser-ground-light-tail-rgb.png")
  end
end

for _, name in pairs(BEAM_NAMES) do
  recolour_beam(name)
end
