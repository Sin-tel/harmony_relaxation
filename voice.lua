Voice = {}

love.audio.setEffect('reverb', {
	type = 'reverb',
	gain = 0.3,
	decaytime = 6.0,
})

love.audio.setEffect('delay', {
	type = 'echo',
	volume = 0.2,
	delay = 0.157,
	tapdelay = 0.044,
	damping = 0.5,
	feedback = .3,
	spread = 1.0,
})

function Voice:new(p,v) 
	local new = {}
	setmetatable(new,self)
	self.__index = self


	--load samples, try saw, piano, choir
	local path = p or "saw2"
	path = path .. ".wav"

	--global transpose in octaves, change depending on sample
	new.transpose = 0

	new.sample = love.audio.newSource(samples[path], "static")
	new.sample:setEffect('reverb')
	new.sample:setEffect('delay')

	new.sample:setVolume(v or 0.6)
	new.pitch = 0
	new.sample:setLooping( true )

	
	return new
end

function Voice:setPitch(pitch) 
	self.pitch = self.pitch*0.8 + pitch*0.2
	local p = 2^(self.pitch/1200)
	self.sample:setPitch(p*(2^self.transpose))
end

function Voice:getPitch()
	return self.pitch
end

function Voice:play() 
	
	--local p = 2^self.pitch
	--self.sample:setPitch(p)
	self.sample:seek(0)
	self.sample:play()
end

function Voice:update(dt) 
	--self:setPitch(self.pitch + love.math.randomNormal(2/1200))
	--self:setPitch(self.pitch + 0.001*math.sin(songtime*25))


end