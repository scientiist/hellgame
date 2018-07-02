local Tile = {}

setmetatable(Tile,{
    __index = Tile,
    __tostring = function(a) return "Tile" end
})


function Tile:new(data)
    
    --[[ 
        tile data fields:
            id,
            name,
            sprite,
            animate,
            variant,
            solid,
    ]]--

    local newTile = {}

    newTile.id = data.id
    newTile.name = data.name or "GenericTile"
    newTile.sprite = data.sprite
    newTile.variant = data.variant or 1
    newTile.animate = data.animate or false
    newTile.solid = data.solid or true
    newTile.internalAnimationState = 0


    return setmetatable(newTile, getmetatable(self))
end

function Tile:render(x, y)

end