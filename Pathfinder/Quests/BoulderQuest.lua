local cpath = select(1, ...) or "" -- callee path
local function rmlast(str) return str:sub(1, -2):match(".+[%./]") or "" end -- removes last dir / file from the callee path
local cdpath = rmlast(cpath) -- callee dir path
local cpdpath = rmlast(cdpath) -- callee parent dir path

local pf = require (cpdpath .. "MoveToApp")
local Lib = require (cpdpath .. "Lib/Lib")
local Game = require (cpdpath .. "Lib/Game")
local Table = require (cpdpath .. "Lib/Table")

local BoulderQuest = {}

local map = nil

starters = {"Bulbasaur", "Charmander", "Squirtle"}
boulderTraining1 = {"Route 1", "Route 22", "Route 2_C"}
boulderTraining2 = {"Route 2_A", "Viridian Forest"}
--boulderNpcList = {"Gary", "Youngster Joey", "Jr. Trainer Sherman", "Lass Nancy", "Old Man San Tsu", "Bugcatcher Yolo", "Bugcatcher Riley", "Bugcatcher Charles", "Youngster John", "Dave", "Zackery", "Jr. Trainer Steve", "Jr. Trainer Rocky", "Hiker Edwin"}

local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

function BoulderQuest.path()
local map = getMapName()

	if getTeamSize() == 0 then
		pauseMessage = "Current Quest: Boulder Badge - Going to talk to Prof. Oak to choose our first Pokemon!"
		Lib.log1time(pauseMessage)
		if getMapName() == "Start" then
			if isNpcOnCell(21,38) then
				return talkToNpcOnCell(21,38)
			elseif not moveToCell(26,87) then
				log("Waiting 45 seconds")
				return sleep(45)
			end
		end
		if getMapName() ~= "Start" then
			if not pf.moveTo(map, "Oaks Lab") then
				if oak == false then
					if starter == "Random" then
						return talkToNpcOnCell(math.random(9, 11), 6)
					elseif starter == "Bulbasaur" then
						return talkToNpcOnCell(9, 6)
					elseif starter == "Charmander" then
						return talkToNpcOnCell(10, 6)
					elseif starter == "Squirtle" then
						return talkToNpcOnCell(11, 6)
					end
				else
					return talkToNpcOnCell(7,4)
				end
			end
		end
	end
	
	if getTeamSize() > 0 then
			
		if not hasItem("Pokedex") then
			if not pf.moveTo(map, "Oaks Lab") then
				return talkToNpcOnCell(7,4) -- Oak
			end
		end
		
		if mom == false then
			if not pf.moveTo(map, "Player House Pallet") then
				return talkToNpcOnCell(7,6)
			end
			
		elseif items == false then
			if not hasItem("Pokeball") then
				if not pf.moveTo(map, "Player Bedroom Pallet") then
					if isNpcOnCell(7,3) then
						return talkToNpcOnCell(7,3)
					elseif isNpcOnCell(6,3) then
						return talkToNpcOnCell(6,3)
					end
				end
			else
				items = true
			end
			
		elseif isNpcVisible("#133") then
			return talkToNpc("#133")
		elseif isNpcVisible("Jackson") then
			return talkToNpc("Jackson")	
		
		elseif Game.isSorted(levelPokesTo) then
			Lib.log1time("Sorting Finished")
			return true
		
		elseif Game.needPokecenter() then
			Lib.log1time("Using Pokecenter")
			return pf.useNearestPokecenter(map)
		
		elseif getMoney() > 10000 and getItemQuantity("Pokeball") < 10 then
			Lib.log1time("Buying 50 Poké Balls")
			return pf.useNearestPokemart(map, "Pokeball", 50)
		elseif getMoney() > 4000 and getItemQuantity("Pokeball") < 10 then
			Lib.log1time("Buying 20 Poké Balls")
			return pf.useNearestPokemart(map, "Pokeball", 20)
		elseif getMoney() > 2000 and getItemQuantity("Pokeball") < 10 then
			Lib.log1time("Buying 10 Poké Balls")
			return pf.useNearestPokemart(map, "Pokeball", 10)
		elseif isShopOpen() then 
			return closeShop()
			
		elseif Game.minTeamLevel() < 8 then
			levelPokesTo = 8
			pauseMessage = "Current Quest: Boulder Badge - Training team until all pokemon are at least level 8."
			Lib.log1time(pauseMessage)
			return updateTargetArea(boulderTraining1, "Grass")
			
		elseif Game.minTeamLevel() >= 8 and Game.minTeamLevel() < 13 then
			levelPokesTo = 13
			pauseMessage = "Current Quest: Boulder Badge - Training team until all pokemon are at least level 13."
			Lib.log1time(pauseMessage)
			return updateTargetArea(boulderTraining2, "Grass")
		end
	end
end

function onDialogMessage(message)
	if stringContains(message, "which pokemon do you want") then
		oak = false
	end
	
	if stringContains(message, "I better talk to her before I get goin'!") then
		mom = false
	end

	if stringContains(message, "Remember that I love you") then
		mom = true
	end
	
	if stringContains(message, "Remember to pick up the items I have left nearby your desk upstairs!") then
		items = false
	end
end

return BoulderQuest