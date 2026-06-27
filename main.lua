-- qlpreview.yazi — macOS Quick Look thumbnail previewer for Yazi
-- Uses qlmanage -t to render previews via native macOS Quick Look engines.
-- Non-blocking: preload runs async with 15s timeout per file;
-- peek just displays the cache (matching built-in image.lua pattern).

local M = {}

function M:peek(job)
	local cache = ya.file_cache(job)
	if not cache or not fs.cha(cache) then
		return -- preload hasn't finished yet, yazi will re-call peek after preload returns
	end

	local _, err = ya.image_show(cache, job.area)
	ya.preview_widget(job, err)
end

function M:seek(job)
	ya.emit("peek", { 0, only_if = job.file.url })
end

function M:preload(job)
	local cache = ya.file_cache(job)
	if not cache then
		return false
	end
	if fs.cha(cache) then
		return true -- already cached
	end

	local filepath = tostring(job.file.path)
	local filename = tostring(job.file.name)
	local cache_path = tostring(cache)

	-- Isolated temp dir per preload job so parallel runs never collide
	local tmpdir = "/tmp/qlpreview-" .. ya.uid()
	Command("mkdir"):arg("-p"):arg(tmpdir):output()

	-- Run qlmanage with a 15-second timeout via perl alarm.
	-- If Quick Look engine can't handle the file or hangs, perl kills the process.
	local output, err = Command("perl")
		:arg("-e")
		:arg("alarm 15; exec @ARGV")
		:arg("qlmanage")
		:arg("-t")
		:arg("-s"):arg("4096")
		:arg("-o"):arg(tmpdir)
		:arg(filepath)
		:stderr(Command.PIPED)
		:output()

	if not output or not output.status.success then
		return false -- yazi won't re-peek, preview stays empty
	end

	local thumb = tmpdir .. "/" .. filename .. ".png"
	if not fs.cha(Url(thumb)) then
		return false
	end

	-- Write directly to yazi cache (office.yazi pattern)
	local cp = Command("cp")
		:arg(thumb)
		:arg(cache_path)
		:stderr(Command.PIPED)
		:output()

	os.remove(thumb) -- cleanup

	if not cp or not cp.status.success then
		return false
	end

	return true -- yazi will re-call peek to display the cached image
end

return M
