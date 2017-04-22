package.loaded["adore.persist"] = {
  persist = function() end,
  register = function() end,
  mixin = {}
}

package.loaded["adore.inventories"] = {
  new = function() return {} end
}

package.loaded["adore.graphics"] = {
  colour = function() return {} end
}

package.loaded["adore.camera"] = {
}

package.loaded["adore.mouse"] = {
}



local actor = require("adore.actor")

describe("adore.actor", function()

  local a
  before_each(function()
    a = actor("Andrea")
  end)

  it("instantiates without error", function() end)

  it("returns the correct value for clickable", function()
    a.clickable = false
    assert.is_false(a:getClickable())
  end)

  it("correctly sets clickable", function()
    a:setClickable(false)
    assert.is_false(a.clickable)
  end)

  it("correctly sets the scene", function()
    a:setScene("room")
    assert.is_equal(a.scene, "room")
  end)

  it("can use a table to set position", function()
    a:setScene("room", {x = 100, y = 200})
    assert.is_equal(a.position.x, 100)
    assert.is_equal(a.position.y, 200)
  end)

  it("can use values to set position", function()
    a:setScene("room", 100, 200)
    assert.is_equal(a.position.x, 100)
    assert.is_equal(a.position.y, 200)
  end)

end)
