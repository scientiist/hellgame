local function clamp(self, number, min, max)
    return math.min(math.max(min, number), max)
end

return {
    clamp = clamp
}