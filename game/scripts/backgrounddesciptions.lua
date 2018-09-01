local headerFont = love.graphics.newFont(20)
local desFont = love.graphics.newFont(14)

adore.event("nativeDraw", function() 
  local scene = adore.scenes.getCurrent()
  if scene then
    love.graphics.setFont(headerFont)
    love.graphics.print("Scene: " .. scene.name, 2,2)
    love.graphics.setFont(desFont)
    love.graphics.print(scene.desciption or "No description", 2, headerFont:getHeight() + 5)
  end
end)