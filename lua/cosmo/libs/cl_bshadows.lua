--This code can be improved a lot.
--Feel free to improve, use or modify in any way although credit would be appreciated.

local render_PushRenderTarget = render.PushRenderTarget
local render_OverrideAlphaWriteEnable = render.OverrideAlphaWriteEnable
local render_Clear = render.Clear
local cam_Start2D = cam.Start2D
local render_CopyRenderTargetToTexture = render.CopyRenderTargetToTexture
local render_BlurRenderTarget = render.BlurRenderTarget
local render_PopRenderTarget = render.PopRenderTarget
local render_SetMaterial = render.SetMaterial
local math_ceil = math.ceil
local render_DrawScreenQuadEx = render.DrawScreenQuadEx
local render_DrawScreenQuad = render.DrawScreenQuad
local cam_End2D = cam.End2D
local math_sin, math_cos, math_rad = math.sin, math.cos, math.rad

local BSHADOWS = {}

local function load()
	local scrW, scrH = ScrW(), ScrH()
	local resString = scrW .. "" .. scrH

	BSHADOWS.RenderTarget = GetRenderTarget("bshadows_original_" .. resString, scrW, scrH)
	BSHADOWS.RenderTarget2 = GetRenderTarget("bshadows_shadow_" .. resString,  scrW, scrH)

	BSHADOWS.ShadowMaterial = CreateMaterial("bshadows","UnlitGeneric",{
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
		["alpha"] = 1
	})

	BSHADOWS.ShadowMaterialGrayscale = CreateMaterial("bshadows_grayscale","UnlitGeneric",{
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
		["$alpha"] = 1,
		["$color"] = "0 0 0",
		["$color2"] = "0 0 0"
	})

	BSHADOWS.BeginShadow = function()
		render_PushRenderTarget(BSHADOWS.RenderTarget)

		render_OverrideAlphaWriteEnable(true, true)
		render_Clear(0,0,0,0)
		render_OverrideAlphaWriteEnable(false, false)

		cam_Start2D()
	end

	BSHADOWS.EndShadow = function(intensity, spread, blur, opacity, direction, distance, _shadowOnly)
		opacity = opacity or 255
		direction = direction or 0
		distance = distance or 0
		_shadowOnly = _shadowOnly or false

		render_CopyRenderTargetToTexture(BSHADOWS.RenderTarget2)

		--Blur the second render target
		if blur > 0 then
			render_OverrideAlphaWriteEnable(true, true)
			render_BlurRenderTarget(BSHADOWS.RenderTarget2, spread, spread, blur)
			render_OverrideAlphaWriteEnable(false, false) 
		end

		--First remove the render target that the user drew
		render_PopRenderTarget()

		--Now update the material to what was drawn
		BSHADOWS.ShadowMaterial:SetTexture("$basetexture", BSHADOWS.RenderTarget)

		--Now update the material to the shadow render target
		BSHADOWS.ShadowMaterialGrayscale:SetTexture("$basetexture", BSHADOWS.RenderTarget2)

		--Work out shadow offsets
	local rad = math_rad(direction)
		local xOffset = math_sin(rad) * distance
		local yOffset = math_cos(rad) * distance

		--Now draw the shadow
		BSHADOWS.ShadowMaterialGrayscale:SetFloat("$alpha", opacity / 255) --set the alpha of the shadow
		render_SetMaterial(BSHADOWS.ShadowMaterialGrayscale)
		for i = 1, math_ceil(intensity) do
			render_DrawScreenQuadEx(xOffset, yOffset, scrW, scrH)
		end

		if not _shadowOnly then
			--Now draw the original
			BSHADOWS.ShadowMaterial:SetTexture("$basetexture", BSHADOWS.RenderTarget)
			render_SetMaterial(BSHADOWS.ShadowMaterial)
			render_DrawScreenQuad()
		end

		cam_End2D()
	end
end

load()
hook.Add("OnScreenSizeChanged", "Cosmo.ReInitBShadows", load)

Cosmo.Shadows = BSHADOWS