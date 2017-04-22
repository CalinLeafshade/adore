local sound = {}

local music

function sound.playMusic(name)
	if music then music:stop() end
	music = love.audio.newSource("game/music/" .. name)
	music:setLooping(true)
	music:play()
end

return sound
