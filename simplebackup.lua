local serverStorage = game:GetService("ServerStorage")

local backupDirectory = serverStorage:FindFirstChild("BackupScripts")

if backupDirectory == nil then
	backupDirectory = Instance.new("Folder")
	backupDirectory.Name = "BackupScripts"
	backupDirectory.Parent = serverStorage
end

local function findServiceForInstance(instance)
	local currentInstance: Instance = instance

	if currentInstance:IsDescendantOf(game.StarterPlayer) then
		while currentInstance and not currentInstance:IsA("StarterPlayerScripts") and not currentInstance:IsA("StarterCharacterScripts") do
			currentInstance = currentInstance.Parent
		end
	else
		while currentInstance and not game:FindFirstChild(tostring(currentInstance)) do
			currentInstance = currentInstance.Parent
		end
	end

	return currentInstance
end

local function isScriptEmpty(script)
	return not script.Source or not script.Source:match("%S")
end

local function GetTime()
	local ServerTime = os.time()
	local Date = os.date("!*t", ServerTime - 8 * 60 * 60)
	local FormattedTime = string.format("%d-%02d-%02d %02d:%02d:%02d", Date.year, Date.month, Date.day, Date.hour, Date.min, Date.sec)

	return FormattedTime
end

local function newBackup()
	local BackupMain = Instance.new("Folder", backupDirectory)
	BackupMain.Name = tostring(GetTime())

	for _, script in pairs(game:GetDescendants()) do
		if script:IsA("Script") or script:IsA("LocalScript") or script:IsA("ModuleScript") then
			if script:IsDescendantOf(backupDirectory) then
				continue
			end

			if isScriptEmpty(script) then
				continue
			end

			if script:FindFirstAncestorOfClass("Script") or script:FindFirstAncestorOfClass("ModuleScript") or script:FindFirstAncestorOfClass("LocalScript") then
				continue
			end 

			local base = findServiceForInstance(script)

			local serviceFolder = nil

			if game:GetService(tostring(base)) or game:GetService(tostring(base.Parent)) then
				if not BackupMain:FindFirstChild(tostring(base)) then
					serviceFolder = Instance.new("Folder", BackupMain)
					serviceFolder.Name = tostring(base)
				else
					serviceFolder = BackupMain[tostring(base)]
				end
			end

			local newfolder = nil

			if script:FindFirstAncestorOfClass("Folder") then
				if serviceFolder:FindFirstChild(script:FindFirstAncestorOfClass("Folder").Name) then
					newfolder = serviceFolder[script:FindFirstAncestorOfClass("Folder").Name]
				else
					newfolder = script:FindFirstAncestorOfClass("Folder"):Clone()
					newfolder.Parent = serviceFolder
					newfolder:ClearAllChildren()
				end
			end

			if serviceFolder then
				local newClone = script:Clone()

				newClone.Parent = newfolder or serviceFolder
			end
		end
	end
end

newBackup()
