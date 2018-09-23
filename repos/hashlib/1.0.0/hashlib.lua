args = {...}

local consts ={
  23490878441290,
  23909348231616,
  58495726758485,
  84915375923746,
  47592376648382,
  47485927589582
}
char_map = {

}
math.randomseed(consts[1])
for i = 0,255 do
  char_map[string.char(i)] = math.floor(math.random()*100000)

end
local addative = ""

local chunkLength = 48

local function numToBin(n)
  local current = n
  local bin_value = ""
  while current > 1 do

    bin_value = bin_value .. tostring(math.floor(current) % 2)
    current = current / 2
  end
  return bin_value
end
local function binToNum(b)
  if(b ~= nil) then
    local sum = 0
    b:reverse()
    for i = 1,#b do

      if(b:sub(i,i) == "1") then
        sum = sum + (2^i)
      end
    end
    return sum
  else
    return 0
  end
end
local function modBin(b1,b2)
  o = ""

  for i = 1,#b1 do
    o = numToBin(bit.bxor(binToNum(b1),binToNum(b2)))
  end
  return o
end
local function letterToNum(c)
  return char_map[c]
end
local function toChunks(bin)
  chunks = {}
  tmp = ""
  for i=1,#bin do
    tmp = tmp .. bin:sub(i,i)
    if((i-1)%chunkLength == chunkLength - 1) then
      table.insert(chunks,tmp)
      tmp = ""
    end
  end
  return chunks
end
local function sumChunks(chunks)
  sum = ""
  for i=1,#chunks-1 do
    sum = modBin(chunks[i],chunks[i+1])
  end
  return sum
end
local function stringToBin(s)
  local bin_array = ""
  for i=1,#s do
    bin_array = bin_array .. numToBin(letterToNum(s:sub(i,i)))
  end
  return bin_array

end
local function bshash(str)
  local bin_array = ""
  local chunks = {}
  local chunk_sum = 0
  str = str .. addative
  for i=1,#consts do
    bin_array = bin_array .. numToBin(consts[i]) .. stringToBin(str)
  end

  chunks = toChunks(bin_array)

  return binToNum(sumChunks(chunks))

end
function shash(str)
  local hash = str
  for i = 1,25 do
    hash = bshash(hash .. str)
  end
  return hash
end

if(#args == 1) then

  test = args[1]
  hash = shash(test)

  print(hash)

end