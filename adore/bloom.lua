--bloom

local lg = love.graphics
local bloom = 
{
	shaders = 
	{
		blur = lg.newShader([[
	
			#define SAMPLE_COUNT 15

			extern vec2 SampleOffsets[SAMPLE_COUNT];
			extern float SampleWeights[SAMPLE_COUNT];
			
			vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 pos) {
				vec4 c = vec4(0,0,0,0);
				
				// Combine a number of weighted image filter taps.
				for (int i = 0; i < SAMPLE_COUNT; i++)
				{
						c += texture2D(tex, tex_coords + SampleOffsets[i]) * SampleWeights[i];
				}
				
				return c;
			}
		]]),
		cutoff = lg.newShader([[
			extern float cutoff;
			vec4 effect(vec4 color, Image tex, vec2 tex_coords, vec2 pos) {
		 
					color = texture2D(tex, tex_coords);
		
				return clamp((color - vec4(cutoff)) / (1.0 - cutoff),0.0,1.0);
			
			}
		]]),
		combine = lg.newShader([[

			extern Image BloomSampler;
			extern Image BaseSampler;

			extern float BloomIntensity;
			extern float BaseIntensity;

			extern float BloomSaturation;
			extern float BaseSaturation;


			// Helper for modifying the saturation of a color.
			vec4 AdjustSaturation(vec4 color, float saturation)
			{
					// The constants 0.3, 0.59, and 0.11 are chosen because the
					// human eye is more sensitive to green light, and less to blue.
					float grey = dot(color, vec4(0.3, 0.59, 0.11,0));

					return mix(vec4(grey), color, saturation);
			}
			
			vec4 effect(vec4 color, Image tex, vec2 texCoord, vec2 pos) {
				
				// Look up the bloom and original base image colors.
				vec4 bloom = texture2D(BloomSampler, texCoord);
				vec4 base = texture2D(BaseSampler, texCoord);
				
				
				// Adjust color saturation and intensity.
				bloom = AdjustSaturation(bloom, BloomSaturation) * BloomIntensity;
				base = AdjustSaturation(base, BaseSaturation) * BaseIntensity;
				
				// Darken down the base image in areas where there is a lot of bloom,
				// to prevent things looking excessively burned-out.
				base *= (1.0 - clamp(bloom,0.0,1.0));
				
				// Combine the two images.
				return base + bloom;
				
				}
			
		]])

	}
}
local shaders = bloom.shaders
local scene, rt1, rt2, origCanvas

local blurAmount = 1.5
local threshold = 0.8

local baseIntensity = 1
local bloomIntensity = 5
local baseSaturation = 1
local bloomSaturation = 0.3
local on = true

function bloom.settings(settings) 
	blurAmount = settings.blurAmount or blurAmount
	threshold = settings.threshold or threshold
	baseIntensity = settings.baseIntensity or threshold
	bloomIntensity = settings.bloomIntensity or bloomIntensity
	baseSaturation = settings.baseSaturation or baseSaturation
	bloomSaturation = settings.bloomSaturation or bloomSaturation
end

function bloom.toggle()
	on = not on
end

function bloom.disable()
	on = false
end

function bloom.enable()
	on = true
end

function bloom.can()
	if not on then return false end
	return true
end

function bloom.makeCanvasses()
	local res = adore.getGame().config.resolution
	scene = lg.newCanvas(res[1], res[2])
	rt1 = lg.newCanvas(res[1], res[2])
	rt2 = lg.newCanvas(res[1], res[2])
end

function bloom.preDraw()
	if not bloom.can() then return end
	if not scene then
		bloom.makeCanvasses()
	end
	origCanvas = lg.getCanvas()
	lg.setCanvas(scene)
	lg.clear()
end

function bloom:draw()
	if not bloom.can() then return end
		
		shaders.cutoff:send("cutoff", threshold or 0.8)
		
		lg.setCanvas(rt1)
		lg.clear()
		lg.setShader(shaders.cutoff)
		lg.draw(scene,0,0)
		
		bloom.setBlur(1 / 1280,0)
		
		lg.setCanvas(rt2)
		lg.clear()
		lg.setShader(shaders.blur)
		lg.draw(rt1,0,0)
		
		bloom.setBlur(0,1/720)
		
		lg.setCanvas(rt1)
		lg.clear()
		lg.setShader(shaders.blur)
		lg.draw(rt2,0,0)
		
		
		
		shaders.combine:send("BloomIntensity", bloomIntensity)
		shaders.combine:send("BaseIntensity", baseIntensity)
		shaders.combine:send("BloomSaturation", bloomSaturation)
		shaders.combine:send("BaseSaturation", baseSaturation)
		
		shaders.combine:send("BaseSampler", scene)
		shaders.combine:send("BloomSampler", rt1)
		
		lg.setShader(shaders.combine)
	
	
	lg.setCanvas(origCanvas)
	lg.draw(scene,0,0)
	
	lg.setShader()

end

function bloom.setBlur(dx,dy)
	
			
		local function gaussian(n)

			local theta = blurAmount;

			return ((1.0 / math.sqrt(2 * math.pi * theta)) * math.exp(-(n * n) / (2 * theta * theta)))
									 
		end

			local sampleCount = 15

			-- Create temporary arrays for computing our filter settings.
			local sampleWeights = {}
			local sampleOffsets = {}

			-- The first sample always has a zero offset.
			sampleWeights[0] = gaussian(0);
			sampleOffsets[0] = {0,0}

			-- Maintain a sum of all the weighting values.
			local totalWeights = sampleWeights[0];

			-- Add pairs of additional sample taps, positioned
			-- along a line in both directions from the center.
			for i = 0, sampleCount / 2 do
			
					-- Store weights for the positive and negative taps.
					local weight = gaussian(i + 1);

					sampleWeights[i * 2 + 1] = weight;
					sampleWeights[i * 2 + 2] = weight;

					totalWeights = totalWeights + weight * 2;

					--[[ To get the maximum amount of blurring from a limited number of
					// pixel shader samples, we take advantage of the bilinear filtering
					// hardware inside the texture fetch unit. If we position our texture
					// coordinates exactly halfway between two texels, the filtering unit
					// will average them for us, giving two samples for the price of one.
					// This allows us to step in units of two texels per sample, rather
					// than just one at a time. The 1.5 offset kicks things off by
					// positioning us nicely in between two texels.
					]]--
					local sampleOffset = i * 2 + 1.5

					local delta = {dx * sampleOffset, dy * sampleOffset}

					-- Store texture coordinate offsets for the positive and negative taps.
					sampleOffsets[i * 2 + 1] = delta;
					sampleOffsets[i * 2 + 2] = {-delta[1], -delta[2]}
			
			end

			-- Normalize the list of sample weightings, so they will always sum to one.
			for i=0,#sampleWeights do
				sampleWeights[i] = sampleWeights[i] / totalWeights
			end

			-- Tell the effect about our new filter settings.
			shaders.blur:send("SampleOffsets", unpack(sampleOffsets))
			shaders.blur:send("SampleWeights", unpack(sampleWeights))
			
end

adore.bloom = bloom
