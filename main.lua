require "voice"
require "entropy"
--print console directly
io.stdout:setvbuf("no")

width = 900  
height = 675 

--love.window.setMode(width,height,{vsync=true,fullscreen=true,fullscreentype = "desktop",borderless = true, y=0}) 
love.window.setMode(width,height,{vsync=false,fullscreen=false,fullscreentype = "desktop",borderless = false}) 
canvas = love.graphics.newCanvas(width,height)
canvas2 = love.graphics.newCanvas(width,height)


function log2(p) 
	return math.log(p)/math.log(2)
end

function frac(p)
	return p - math.floor(p)
end

BPM = 80
time = 0
bTime = 0

zoom = 128

songtime = 0

temp = 0.03

voice_selected = 1

mouseX, mouseY = 0,0

function love.load()
	math.randomseed(os.time())
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle("rough")
	
	local paths = love.filesystem.getDirectoryItems("samples")
	samples = {}
	for k,v in ipairs(paths) do
		samples[v] = love.sound.newSoundData("samples/" .. v)
	end


	voice = {}
	
	for i = 1,7 do
		voice[i] = Voice:new()
	end

	do_entropy()

	pitch = {}
	for i,v in ipairs(voice) do
		local p = i*(360)-2000 --+ love.math.randomNormal(100)
		pitch[i] = p
		v:setPitch(p)
		v:play()
	end
end

function love.mousepressed(x, y, button, istouch)
	voice[voice_selected]:play()
	--local p = math.random()*2400
	--pitch[math.random(#pitch)] = p
	--local n = math.random(#pitch)
	--pitch[n] = pitch[n] + love.math.randomNormal(150, 0)
	--local n = math.random(#pitch)
	--pitch[n] = pitch[n] + love.math.randomNormal(200, 0)
	--local n = math.random(#pitch)
	--pitch[n] = pitch[n] + love.math.randomNormal(200, 0)
	--[[for i in ipairs(pitch) do
		pitch[i] = pitch[i] + love.math.randomNormal(200, 0)
	end]]
	if(button == 2) then
		for i in ipairs(pitch) do
			pitch[i] = pitch[i] + love.math.randomNormal(80, 0)
		end
	end
end

function love.wheelmoved(x, y)
    if y > 0 then
        --zoom = zoom*1.2
        temp = temp*1.2
    elseif y < 0 then
       -- zoom = zoom/1.2
       temp = temp/1.2
    end
end

function love.update(dt)
	mousepX,mousepY = mouseX, mouseY
	mouseX,mouseY = love.mouse.getPosition( )
	time = time+dt*(BPM/60)*4
	songtime = songtime+dt

	--temp = 0.12*(math.sin(songtime*0.2)^8)

	for i,v in ipairs(voice) do
		v:update(dt)
	end

	if time>1 then
		time = time-1
		if bTime%16==0 then
	        --newChord()
	        bTime = 0
	    end
	    
	    beat()

	    bTime = bTime+1
	end

	

	if(love.mouse.isDown(1)) then
		pitch[voice_selected] = pitch[voice_selected] + 1200*(mousepY - mouseY)/zoom
	else
		local min = 100000
		for i, v in ipairs(voice) do
			local dy = math.abs(mouseY - (height*0.5 - zoom*(v:getPitch()/1200)))
			if(dy < min) then
				min = dy
				voice_selected = i
			end
		end
	end



	searchPitches()
	table.sort(pitch)
	for i,v in ipairs(pitch) do
		voice[i]:setPitch(v)
	end
end

function searchPitches()
	--optimisation routine

	newPitch = {}
	for i,v in ipairs(pitch) do
		newPitch[i] = v + love.math.randomNormal(4, 0)
	end
	--if(math.random()<.5) then
		local n = math.random(#voice)
		newPitch[n] = pitch[n] + love.math.randomNormal(25, 0)--50
	--end



	local p1 = calc_potential(pitch)
	local p2 = calc_potential(newPitch)
	if(p2 < p1) then
		pitch = newPitch
	else
		prob = math.exp(-(p2 - p1)/temp)
		--print(prob)
		if(math.random()<prob) then
			pitch = newPitch
		end
	end


end

function searchPitches2(n)
	local pre = calc_potential(pitch)

	local min = pre
	for i = 1, n do
		newPitch = {}
		for i,v in ipairs(pitch) do
			newPitch[i] = v + love.math.randomNormal(50, 0)
		end
		local pnew = calc_potential(newPitch)
		if(pnew < min) then
			pitch = newPitch
			min = pnew
		end
	end

	table.sort(pitch)
end

function beat()
	--[[if(bTime%4 == 0) then
		for i in ipairs(pitch) do
			pitch[i] = pitch[i] + love.math.randomNormal(20, 0)
		end
		searchPitches2(1000)
	end
	--
	--[[if((bTime/2)%1 == 0) then

		if((bTime/2)%8) >= 4 then
			voice[5-(bTime/2)%4]:play()
		else
			voice[1+(bTime/2)%4]:play()
		end
	end]]
end

function love.draw()
	love.graphics.setBlendMode( "alpha" )
	love.graphics.setCanvas(canvas)
	love.graphics.clear(0,0,0,0)

	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", width*0.8-50, 0, 50, height)

	love.graphics.setBlendMode("add")
	for i,v in ipairs(voice) do
		c = {0,.8,.8}

		--[[local h = 10/(.01+(v.sample:tell("seconds")))
		love.graphics.setColor(150+h,150+h,150+h)
		if(math.abs(frac(v:getPitch()) - frac(mel:getPitch())) < 0.01) then
			love.graphics.setColor(255,255,50)
		end
		love.graphics.rectangle("fill",64,10+32*i,256*(2^(-v:getPitch())),30)]]
		blend = function (a,b,c)
			return {a[1]*c+b[1]*(1-c),
					a[2]*c+b[2]*(1-c),
					a[3]*c+b[3]*(1-c)} 
		end

		local decay = 0.3+0.7*math.exp(-1*(v.sample:tell("seconds")))

		love.graphics.setColor(blend({1,.2,.2},{0,0,0},decay))
		if(voice_selected == i) then
			love.graphics.setColor(blend({1,.6,1},{0,0,0},decay))
		end

		local w = 8
		local x = width*0.8
		local y = height*0.5 - zoom*(v:getPitch()/1200)


		love.graphics.line(x-w,y,x+w,y)

		
		for n = 2,64 do
			local dy = zoom*log2(n)
			local a = 0.3*math.exp(-0.1*n)*decay
			love.graphics.setColor(c[1]*a,c[2]*a,c[3]*a)
			love.graphics.line(x-w,y+dy,x+w,y+dy)
			love.graphics.setColor(c[2]*a,c[3]*a,c[1]*a)
			love.graphics.line(x-w,y-dy,x+w,y-dy)
		end
	end
	love.graphics.setBlendMode( "alpha" )
	love.graphics.setColor(1,1,1)
	love.graphics.draw(canvas2, -2, 0)
	love.graphics.setCanvas(canvas2)
	love.graphics.clear(0,0,0,0)
	love.graphics.draw(canvas, 0, 0)

	love.graphics.setCanvas()
	love.graphics.draw(canvas, 0, 0)

	graph()
	love.graphics.setColor(1,1,1)
	love.graphics.print("temp: " .. math.floor(temp*1000)/1000,5,5)
	love.graphics.print("potential: " .. math.floor(calc_potential(pitch)*100)/100,5,50)

	
	for i = 2,#pitch do
		for j = 1,i-1 do
			love.graphics.print(math.floor(pitch[i]-pitch[i-j]),5+36*(j-1),250-25*i+10*j)
		end
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit( )
	end
end