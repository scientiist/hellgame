local AssetLoader = require("src.utils.AssetLoader")
local Sprite = require("src.datatypes.Sprite")


local spriteFolder = "assets/image/sprite/"
local spriteFiles = {
    player = {"player.png", 16}
}


local textureFolder = "assets/image/texture/"
local textureFiles = {
    red_brick = "red_brick.png",
    red_brick_pentagram = "red_brick_pentagram.png",
}

local fontFiles = {

}

local soundFiles = {

}
-------------------------
local assets = {
    sprites = {},
    textures = {},
}

for id, source in pairs(spriteFiles) do
    local imageSrc = spriteFolder .. source[1]

    local sprite = Sprite:new(imageSrc, 16)

    assets.sprites[id] = sprite
end





return assets