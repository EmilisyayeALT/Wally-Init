local HandlerFolder = script.Parent.Handlers

local services = {}
local initThreads = {}

for _, module in HandlerFolder:GetDescendants() do
	if not module:IsA("ModuleScript") then
		continue
	end

	local success, handler = pcall(require, module)
	if not success then
		warn("[HandlerFolder] Failed to require:", module.Name, handler)
		continue
	end

	services[module.Name] = handler

	if type(handler.init) == "function" then
		local thread = task.spawn(function()
			local ok, err = pcall(handler.init, handler)
			if not ok then
				warn(`[HandlerFolder] Init failed ({module.Name}):`, err)
			end
		end)

		initThreads[#initThreads + 1] = thread
	end
end

for _, thread in initThreads do
	task.wait()
end

for name, handler in services do
	if type(handler.start) == "function" then
		task.spawn(function()
			local ok, err = pcall(handler.start, handler)
			if not ok then
				warn(`[HandlerFolder] Start failed ({name}):`, err)
			end
		end)
	end
end
