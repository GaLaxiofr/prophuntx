local netReq 	= "PHX.scan_ReqTaunts"
local netRecv	= "PHX.scan_SendTauntLists"

if SERVER then
	util.AddNetworkString( netReq )
	util.AddNetworkString( netRecv )
end

--local DefaultPath 	= "sound/taunts_gmi"
local DefaultPath	= "taunts_phx"

-- Reference: http://lua-users.org/wiki/StringRecipes
local function format(first, rest)
   return first:upper()..rest:lower()
end

local function NiceTitle( str )
	str = str:gsub("(%a)([%w_']*)", format)
	return str
end

local Taunts = {}

-- BUG: team.GetName isn't available at early moment, even though moving the inclusion after GM:CreateTeam() ...
local TeamName = {
	[1]	= "Hunters",
	[2]	= "Props"
}

if SERVER then	
	local function AddToTable( idTeam, tauntCat, data )
		PHX.VerboseMsg("[PHX] Adding to Taunt Table: Team[" .. idTeam .. "], Category:" .. tauntCat .. ", Total Taunt Data: " .. tostring(table.Count(data)))
		Taunts[tauntCat] = {}
		Taunts[tauntCat][idTeam] = data
	end
	
	local function addtaunt( teamID, tFile, fCat, format, tblTemp, sTauntPath )
		for _,FileExt in SortedPairs( tFile ) do
			local namenoex = FileExt 				-- just initialize with default "taunt_name.wav"
			if string.find(FileExt, "^taunt_") then	-- this was only used for my taunts for better organizing. otherwise you can name it whatever you want.
				namenoex = string.gsub(FileExt, "taunt_([%w_]+)%."..format.."$", "%1")
			else
				namenoex = string.gsub(FileExt, "([%w_]+)%."..format.."$", "%1")
			end
			
			local nicename = NiceTitle( string.Replace(namenoex, "_", " ") ) -- origin: string.upper
			local path = sTauntPath .. "/" .. tostring(teamID) .. "/" .. fCat .. "/" .. FileExt
			
			tblTemp[ nicename ] = path
		end
	end

	function PHX:TauntScanFolder( tauntPath )		
		if !file.Exists("sound/" .. tauntPath, "GAME") then
			ErrorNoHalt("PHX Taunt Scanner Error: Path " .. tauntPath .. " does not exists!"); return;
		end
		
		local err = 0
		
		-- Hunter = 1, Prop = 2
		for TEAM_ID=1,2 do
		
		  if file.Exists("sound/" .. tauntPath .. "/" ..tostring(TEAM_ID), "GAME") then 
		
			  local _,dir = file.Find( "sound/" .. tauntPath .. "/" .. tostring(TEAM_ID) .. "/*", "GAME" )
			  
			  for _,cat in pairs( dir ) do
				local curData = {}
				
				local fmp3,_ = file.Find( "sound/" .. tauntPath .. "/" .. tostring(TEAM_ID) .. "/" .. cat .. "/*.mp3", "GAME" )
				local fwav,_ = file.Find( "sound/" .. tauntPath .. "/" .. tostring(TEAM_ID) .. "/" .. cat .. "/*.wav", "GAME" )
				local fogg,_ = file.Find( "sound/" .. tauntPath .. "/" .. tostring(TEAM_ID) .. "/" .. cat .. "/*.ogg", "GAME" )
				
				-- search for MP3s
				addtaunt(TEAM_ID, fmp3, cat, "mp3", curData, tauntPath)
				-- search for WAVs
				addtaunt(TEAM_ID, fwav, cat, "wav", curData, tauntPath)
				-- search for OGGs
				addtaunt(TEAM_ID, fogg, cat, "ogg", curData, tauntPath)
				
				AddToTable(TEAM_ID, NiceTitle( string.Replace(cat, "_", " ") ), curData) -- origin: string.upper
				
			  end
			  
		  else
			
			err = err + 1
			PHX.VerboseMsg("[PHX Taunt Scanner] " .. TeamName[TEAM_ID] .. "'s taunt seems to be empty, nothing to add.")
			
		  end
		  
		  if err == 2 then
			print("[PHX Taunt Scanner] Both Teams have no taunts detected in folder '".. tauntPath .."'. Are you trying to add empty folder?")
		  end
		
		end
	
	end
	
	--[[
		== Adding External Taunt Scan Folder (Usually for Workshop) ==
		
		/!\ CURRENTLY DOES NOT SUPPORT TAUNT LOADER /!\
		
		Usage: list.Set("PHX.TauntScanFolder", "Taunt Name", "folder_name")
		Example: list.Set("PHX.TauntScanFolder", "Awesome Taunt XD", "my_custom_taunts_folder") -- Taunt Folder must be located in: <root>/garrysmod/sound/my_custom_taunts_folder/
		
		== RULES ==
		- Your Custom Folder must contain "1" and "2" Folder. They are used for Team Hunter (ID 1) and Team Props (ID 2)
		- Each Teams Folder must containts folder as a category name. Example: "my_custom_prop_category"
		- Each Category folders must only contains file names. Acceptable File Extensions are: 
			[*] MP3s
			[*] WAVs
			[*] OGGs
			[-] Any subfolders will be ignored.
		- ALL FOLDER & FILE NAMING RULES [IMPORTANT]:
			[*]	Must 'lower case' letters. No Exception!
			[-] No White Spaces
			[-] No Upper Case Letters
			[-] No Weird Symbols.
			[-] In Linux OS, File Names MUST be lower case!
		- Careful by not to use any UTF-8 characters. This is caused by "Title Formating" that uses LUA String Patterns to format file names into "Nice Title".
		  This is not guaranteed 100% will work for non-English words.
		    (this may results a residue of file extensions. e.g: '<some non-english-words>.mp3' instead of '<Some Nice English Words>' in the taunt list.)
		
		File Structures Examples:
		
		sound/
			my_custom_taunts_folder/	(This is your BASE FOLDER. If you want to make it more organized, You can add Subfolders as a base folder and they must contains "1" and "2" folders exists!)
										
										Note: Subfolders ARE NOT SCANNED AUTOMATICALLY! You have to Re-Add the path to the list! e.g: 
											list.Set("PHX.TauntScanFolder", "Awesome Taunt #1", "my_custom_taunts_folder")
											list.Set("PHX.TauntScanFolder", "Awesome Taunt #2", "my_custom_taunts_folder/subfolder1")
											list.Set("PHX.TauntScanFolder", "Awesome Taunt #3", "my_custom_taunts_folder/subfolder2")
											list.Set("PHX.TauntScanFolder", "Awesome Taunt #4", "my_custom_taunts_folder/subfolder1/anotherfolder")
										
				/1  (this is for team hunters. Existing files in this folder will be ignored)
					category_example_1/
						taunt_names1.wav (can be .mp3 or .ogg too, Folders will be skipped)
					category_example_2/
						random_name.wav (can be .mp3 or .ogg too, Folders will be skipped)
				/2	(this is for team props - Same Rules from Hunter for files and folders.)
					category_example_1/
						taunt_names1.wav
					category_example_2/
						random_name.wav
				/subfolder1
					/1
						category
							/example.wav
					/2
						/category
							/example.wav
					...
	]]--
	
	if PHX:QCVar( "ph_enable_taunt_scanner" ) then	-- Disabled = no operation will be done. You also need to restart map to enable this feature!
		-- Add Default path
		PHX:TauntScanFolder( DefaultPath )
		
		-- Add External paths, if any.
		for tauntName, tauntFolder in SortedPairs( list.Get("PHX.TauntScanFolder") ) do	-- please sort.
			PHX.VerboseMsg("[PHX] [Addon: ".. tauntName .."] Scanning custom Taunt folder: 'sound/"..tauntFolder.."'...")
			PHX:TauntScanFolder( tauntFolder )
		end
	end
	
	--Add to PHX Taunt Table. Use "Initialize" instead.
	local data,lz,size
	hook.Add("Initialize", "PHX.InitScannedTauntData", function()
		if PHX:QCVar( "ph_enable_taunt_scanner" ) then
			-- Start Adding.
			for category, data in SortedPairs( Taunts ) do
				PHX:ManageTaunt( category, data )
			end
			
			-- Prepare data and compress tables to clients. This is only available after the map is fully loaded.
			-- Do Not Re-broadcast!
			data = util.TableToJSON( Taunts )
			lz 	 = util.Compress( data )
			size = lz:len()
		else
			print("[PHX] Taunt Scanner Status: Disabled.")
		end		
	end)
	
	hook.Add("PlayerInitialSpawn", "PHX.SetupScannedTauntData", function(ply)
		--wait for client to request the data. They can't request anymore after they receive the data unless they have to reconnect.
		--Keep this available even though taunt scanner is disabled.
		ply.HasTauntScannedData = false
	end)
	
	net.Receive( netReq, function( len, ply )
		if !PHX:QCVar( "ph_enable_taunt_scanner" ) then
			ply:PrintMessage(HUD_PRINTCONSOLE, "[PHX] Taunt Scanner is Disabled.")
			return
		end
	
		if !ply.HasTauntScannedData then
			PHX.VerboseMsg("[PHX] Sending Taunt Data to player: " .. ply:Nick() .. ", Size: " .. tostring(size) .. " Bytes")
		    timer.Simple(0.1, function()
				net.Start(netRecv)
				net.WriteUInt(size, 32)
				net.WriteData(lz, size)
				net.Send(ply)
				ply.HasTauntScannedData = true
			end)
		end
		-- you can't request anymore unless reconnect to get a refresh list!
	end )
end


if CLIENT then
	hook.Add( "InitPostEntity", "PHX.requestTauntScanner", function()
		net.Start( netReq )
		net.SendToServer()
	end )
	
	net.Receive(netRecv, function()
		PHX.VerboseMsg("[PHX] Received taunt data, Processing...")
		local size = net.ReadUInt(32)
		local json = util.Decompress( net.ReadData(size) )
		local Conv = util.JSONToTable( json )
		
		if PHX and PHX.ManageTaunt ~= nil then
			for cat, data in pairs(Conv) do
				PHX:ManageTaunt(cat, data)
			end
		end
		
		PHX.VerboseMsg("[PHX] Taunts successfully added! - Have Fun and Enjoy!")
	end)
end