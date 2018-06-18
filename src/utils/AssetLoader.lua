-- Loads an image, turns a white background into alpha transparency
local function loadImage(self, imagePath)
	imageData = love.image.newImageData(imagePath)
	function mapFunction(x, y, r, g, b, a)
		if r == 1 and g == 1 and b == 1 then a = 0 end
		return r, g, b, a
	end
    imageData:mapPixel(mapFunction)
    local image = love.graphics.newImage(imageData)

    image:setFilter("nearest", "nearest")
	return image
end


return {
    loadImage = loadImage
}