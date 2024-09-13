local ProfileService = require(game.ServerScriptService.ProfileService) -- Require ProfileService Module

local ServerDataTemplate = { -- Example of a data template, can be virtually anything.
	GlobalBank = {
		Balance = 0,
		Employees = {}
	}
}

local Profiles = {}

local ServerStore = ProfileService.GetProfileStore(
	"OfficialServerData",
	ServerDataTemplate
)

local function LoadServerData()
	local ServerProfile = ServerStore:LoadProfileAsync("ServerData") -- Load the Profile

	if ServerProfile then -- check to see if the profile exists
		ServerProfile:Reconcile() -- update to the most current data
		Profiles["ServerData"] = ServerProfile -- add to the table of Profiles that exist
		print(Profiles["ServerData"].Data) -- print live data to look at
	end

	task.spawn(function() -- (may not be required, I like having it to make sure it executes right awawy)
		while task.wait(150) do -- every 2 mins and 30 seconds reload the profile
			if ServerProfile then -- If the profile exists (vanity check to make sure)
				ServerProfile:Release() -- Release the profile to reload it
				Profiles["ServerData"] = nil -- Remove existence of ServerData in Profiles table
				ServerProfile = nil -- Remove existence of the actual Profile
			end

			if not Profiles["ServerData"] then -- if the profile has been released (vanity check to make sure)
				ServerProfile = ServerStore:LoadProfileAsync("ServerData") -- Reload the Profile
				if ServerProfile then -- check to see if the profile exists
					ServerProfile:Reconcile() -- update to the most current data
					Profiles["ServerData"] = ServerProfile -- re-add to the table of Profiles that exist
					print(Profiles["ServerData"].Data) -- print live data to look at
				end
			end
		end
	end)
end

LoadServerData() -- call it to make sure it's loaded
