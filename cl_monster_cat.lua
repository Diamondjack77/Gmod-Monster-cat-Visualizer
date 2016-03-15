local songFilePath = "sound/frame.mp3" --Song directory

local station = nil

surface.CreateFont( "Song Title", {
	font = "GillSands-Bold", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 120,
	weight = 800000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "Song Title2", {
	font = "GillSands-Bold", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 47,
	weight = 800000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local s = sound.PlayFile("sound/frame.mp3" , 
	"mono" , function(sc , err , errname)

		if(IsValid(sc)) then
			
			station = sc
			station:Play()

		end

end)


hook.Add("Think" , "updateAudioPos" , function()

	if station ~= nil then

		station:SetPos(LocalPlayer():GetPos())

	end

end)

local realBands = {} 
for i = 1 , 64 do
	
	realBands[i] = 0

end

local albumart = Material("newpp.png" , "noclamp smooth")
local part = Material("part.png" , "noclamp smooth")

local parts = {}

for i = 1 , 512 do
	
	parts[i]  = {}

	local prop = math.random(4,8)

	parts[i].size = prop
	parts[i].speed = parts[i].size/0.5
	parts[i].x = math.random(ScrW())
	parts[i].y = math.random(ScrH())

end

local blur = Material("pp/blurscreen")
function DrawBlurRect(x, y, w, h)
	local X, Y = 0,0

	surface.SetDrawColor(255,255,255)
	surface.SetMaterial(blur)

	for i = 1, 1 do
		blur:SetFloat("$blur", 1.5)
		blur:Recompute()

		render.UpdateScreenEffectTexture()

		render.SetScissorRect(x, y, x+w, y+h, true)
			surface.DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
   
   draw.RoundedBox(0,x,y,w,h,Color(0,0,0,1))
   surface.SetDrawColor(0,0,0)
   surface.DrawOutlinedRect(x,y,w,h)
   
end

hook.Add("HUDPaint" , "paintVisualizer" , function()

	local bands = {}
	local bandThickness = 18
	local bandMaxHeight = ((ScrH()/3) * 2) - 75 
	local amp = 5000
	local dext = 2
	local offset = 0

	station:FFT(bands , FFT_8192)

	for i = 1 , 64 do  
	

		if bands[i + offset] * amp > bandMaxHeight then
			
			bands[i + offset] = bandMaxHeight / amp

		end   


		if bands[i + offset] * amp < 2 then
			
			bands[i + offset] = 2

		else

			bands[i + offset] = bands[i + offset] * amp

		end

				realBands[i] = Lerp(30*FrameTime(),realBands[i],bands[i + offset])

		if i < 63  and i > 2 then 
			
			local a = realBands[i]
			local b = realBands[i + 1]
			local c = realBands[i - 1]
			realBands[i] = (a+b+c) / 3

		elseif i < 3 then
			
			local a = realBands[i]
			local b = realBands[i + 1]
			local c = 0
			realBands[i] = (a+b+c) / 3

		end



	end

	local w = (ScrW()) - 200

	local xPos = 100

	draw.RoundedBox(0,0,0,ScrW() , ScrH(),Color(0,0,0,255))

	surface.SetMaterial(part)
	surface.SetDrawColor(255,255,255,255)

	for k , v  in pairs(parts) do
		
		surface.DrawTexturedRect(v.x , v.y , v.size , v.size)
		parts[k].x = parts[k].x + (v.speed * FrameTime())

		if parts[k].x > ScrW() then
			
			parts[k].x = 0

		end


	end

	DrawBlurRect(0,0, ScrW() , ScrH())

	for i = 1 , 64 do
		
		draw.RoundedBox(0,xPos,math.ceil((ScrH()/3) * 2) - realBands[i] , bandThickness , realBands[i],Color(255,40,40))

		xPos = xPos + (w/64)

	end

	draw.RoundedBox(0,100 , ((ScrH()/3) * 2)  + 10, 180,180,Color(255,40,40))
	surface.SetMaterial(albumart)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(105 , ((ScrH()/3) * 2)  + 15 , 180-10 , 180-10)

	draw.SimpleText("MONSTERCAT VISUALIZER","Song Title",100  + 190, ((ScrH()/3) * 2) ,Color(255,255,255))

	draw.SimpleText("CREATED BY <CODE BLUE> (SONG NAME : BETTER FRAME OF MIND) ","Song Title2",100  + 190, ((ScrH()/3) * 2) + 125,Color(255,255,255))

end)