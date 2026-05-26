local ServicesFolder = script.Parent.Services

local services = {}
local initThreads = {}

for _, module in ServicesFolder:GetDescendants() do
	if not module:IsA("ModuleScript") then
		continue
	end

	local success, service = pcall(require, module)
	if not success then
		warn("[ServiceLoader] Failed to require:", module.Name, service)
		continue
	end

	services[module.Name] = service

	if type(service.init) == "function" then
		local thread = task.spawn(function()
			local ok, err = pcall(service.init, service)
			if not ok then
				warn(`[ServiceLoader] Init failed ({module.Name}):`, err)
			end
		end)

		initThreads[#initThreads + 1] = thread
	end
end

for _, thread in initThreads do
	task.wait()
end

for name, service in services do
	if type(service.start) == "function" then
		task.spawn(function()
			local ok, err = pcall(service.start, service)
			if not ok then
				warn(`[ServiceLoader] Start failed ({name}):`, err)
			end
		end)
	end
end
