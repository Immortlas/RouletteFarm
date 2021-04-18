script_name('RouletteFarm')
script_author('DeneKyn')
script_version("1.3")

local sampev = require 'lib.samp.events'
local imgui = require 'mimgui'
local ffi = require 'ffi'
local vkeys = require 'vkeys'
local inicfg = require 'inicfg'
local encoding = require "encoding"
encoding.default = "CP1251"
u8 = encoding.UTF8

local new = imgui.new
local renderWindow = new.bool()

local mainIni = inicfg.load({
  chest_open =
  {
    common = true,
    donate = true,
    platinum = true,
    valentine = false,
    elon_mask = true
  },
	settings =
	{
		chat = false,
		time_on_screen = false,
		time_x = 300,
		time_y = 300
	}
})

local settings = {
	enabled = false,
	skip_dialog = false,
	chat = new.bool(mainIni.settings.chat),
	time_on_screen = new.bool(mainIni.settings.time_on_screen),
	click_use = false,
	open_chest = false,
	open_valentine = false,
	inactivity = 0,
	change_time_position = false,
	time_x = mainIni.settings.time_x,
	time_y = mainIni.settings.time_y
}

local chest = {
	common = {sec = 0, td_id = 0, td_time_id = 0, check_time = false, open = new.bool(mainIni.chest_open.common), name = "common", kd = 7200},
	donate = {sec = 0, td_id = 0, td_time_id = 0, check_time = false, open = new.bool(mainIni.chest_open.donate), name = "donate", kd = 14400},
	platinum = {sec = 0, td_id = 0, td_time_id = 0, check_time = false, open = new.bool(mainIni.chest_open.platinum), name = "platinum", kd = 7200},
	valentine = {sec = 0, td_id = 0, td_time_id = 0, check_time = false, open = new.bool(mainIni.chest_open.valentine), name = "valentine", kd = 3600},
	elon_mask = {sec = 0, td_id = 0, td_time_id = 0, check_time = false, open = new.bool(mainIni.chest_open.elon_mask), name = "Elon_Mask", kd = 1800},
}
local buttons = {
	close_invent = 0,
	use = 0,
	valentine_get = 2048,
	valentine_close = 2064
}

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
			imgui.PushTextWrapPos(600)
				imgui.TextUnformatted(description)
			imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
end)

local settings_y = 60

local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
		local sizeX, sizeY = getScreenResolution()
				print(main_y)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(250, 295), imgui.Cond.FirstUseEver)
        imgui.Begin("Roulette Farm", renderWindow, imgui.WindowFlags.NoResize)
        imgui.Text(u8"Ящики")
		imgui.BeginChild("##rullet", imgui.ImVec2(230, 108), true, imgui.WindowFlags.NoScrollbar)
			if imgui.Checkbox(u8'Обычный', chest.common.open) then
				mainIni.chest_open.common = chest.common.open[0]
				inicfg.save(mainIni)
			end
			imgui.SameLine()
			imgui.TextQuestion("( ? )", u8"Ящик, который выдается за прохождение начальных квестов")
			if chest.common.sec > 0 then
			imgui.SameLine(160)
			imgui.Text(string.format("%dm : %ds ", math.floor(chest.common.sec/60), chest.common.sec%60))
			end

			if imgui.Checkbox(u8'Донатный', chest.donate.open) then
				mainIni.chest_open.donate = chest.donate.open[0]
				inicfg.save(mainIni)
			end
			imgui.SameLine()
			imgui.TextQuestion("( ? )", u8"Ящик, который покупается в донат-меню за 6.000 AZ монет")
			if chest.donate.sec > 0 then
			imgui.SameLine(160)
			imgui.Text(string.format("%dm : %ds ", math.floor(chest.donate.sec/60), chest.donate.sec%60))
			end

			if imgui.Checkbox(u8'Платиновый', chest.platinum.open) then
				mainIni.chest_open.platinum = chest.platinum.open[0]
				inicfg.save(mainIni)
			end
			imgui.SameLine()
			imgui.TextQuestion("( ? )", u8"Ящик, который выдается после того, как вы отыграете 360 часов")
			if chest.platinum.sec > 0 then
			imgui.SameLine(160)
			imgui.Text(string.format("%dm : %ds ", math.floor(chest.platinum.sec/60), chest.platinum.sec%60))
			end
			
			if imgui.Checkbox(u8'Илон Маск', chest.elon_mask.open) then
				mainIni.chest_open.elon_mask = chest.elon_mask.open[0]
				inicfg.save(mainIni)
			end
			imgui.SameLine()
			imgui.TextQuestion("( ? )", u8"Ящик Илона Маска, который покупается в донат-меню за 5.000 AZ монет")
			if chest.elon_mask.sec > 0 then
			imgui.SameLine(160)
			imgui.Text(string.format("%dm : %ds ", math.floor(chest.elon_mask.sec/60), chest.elon_mask.sec%60))
			end
		imgui.EndChild()

		imgui.Text(u8"Настройки")
		imgui.BeginChild("##settings", imgui.ImVec2(230, settings_y), true, imgui.WindowFlags.NoScrollbar)
			if imgui.Checkbox(u8'Сообщения в чат', settings.chat) then
				mainIni.settings.chat = settings.chat[0]
				inicfg.save(mainIni)
			end
			imgui.SameLine()
			imgui.TextQuestion("( ? )", u8"Вывод сообщени¤, связанный с рабоотй скриптом, в чат сампа")

			if imgui.Checkbox(u8'Время до открытия', settings.time_on_screen) then
				mainIni.settings.time_on_screen = settings.time_on_screen[0]
				inicfg.save(mainIni)
			end
			imgui.SameLine()
			imgui.TextQuestion("( ? )", u8"Вывод на экран времени до открытия рулетки")

			if settings.time_on_screen[0] and settings.enabled then
				settings_y = 85
				main_y = 100
				if imgui.Button(u8"Изменить местоположение", imgui.ImVec2(200, 20)) then
					chat_msg(string.format("Нажмите клавишу Space, чтобы сохранить позицию"), 0xFFE4B5)
					settings.change_time_position = true
				end
			else
				settings_y = 60
			end
		imgui.EndChild()

		imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 2)
		local close_button_text = settings.enabled and u8"Деактивировать" or u8"Активировать"
		if imgui.Button(close_button_text, imgui.ImVec2(120, 20)) then
			start()
		end
        imgui.End()
    end
)

function start()
	settings.enabled = not settings.enabled
		if settings.enabled then
			create_textdraw()
			chat_msg("Activated", 0xFF4040)
			for _, val in pairs(chest) do
				val.sec = 0
				val.td_id = 0
				val.td_time_id = 0
				val.check_time = true
			end
			sampSendChat("/invent")			
		else
			sampTextdrawDelete(222)
			chat_msg("Deactivated", 0xFF4040)
			chest = {
				common = {sec = 0, td_id = 0, td_time_id = 0, check_time = false, open = new.bool(mainIni.chest_open.common), name = "common", kd = 7200},
				donate = {sec = 0, td_id = 0, td_time_id = 0, check_time = false, open = new.bool(mainIni.chest_open.donate), name = "donate", kd = 14400},
				platinum = {sec = 0, td_id = 0, td_time_id = 0, check_time = false, open = new.bool(mainIni.chest_open.platinum), name = "platinum", kd = 7200},
				valentine = {sec = 0, td_id = 0, td_time_id = 0, check_time = false, open = new.bool(mainIni.chest_open.valentine), name = "valentine", kd = 3600},
				elon_mask = {sec = 0, td_id = 0, td_time_id = 0, check_time = false, open = new.bool(mainIni.chest_open.elon_mask), name = "Elon Mask", kd = 3600},
			}
			settings.click_use = false
			settings.open_chest = false
			settings.open_valentine = false	
			settings.inactivity = 0
		end
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	autoupdate("https://raw.githubusercontent.com/Immortlas/RouletteFarm/main/vesrion.json", '['..string.upper(thisScript().name)..']: ', "https://github.com/Immortlas/RouletteFarm")
	repeat
    wait(0)
	until sampIsLocalPlayerSpawned()
	sampRegisterChatCommand("rlt_info", print_info)
	sampRegisterChatCommand("rlt", function()
		renderWindow[0] = not renderWindow[0]
	end)

	while true do
		wait(0)

		if settings.enabled and settings.change_time_position then
				sampSetCursorMode(2)
				settings.time_x, settings.time_y = convertWindowScreenCoordsToGameScreenCoords(getCursorPos())
				sampTextdrawSetPos(222, settings.time_x, settings.time_y)
				if isKeyDown(32) then
					mainIni.settings.time_x = settings.time_x
					mainIni.settings.time_y = settings.time_y
					inicfg.save(mainIni)
					settings.change_time_position = false
					sampSetCursorMode(0)
				end
			end

		if settings.time_on_screen[0] then
			sampTextdrawSetString(222, textdraw_string())
		else
			sampTextdrawSetString(222, "")
		end

		if settings.inactivity >= 30 then
			settings.click_use = false
			settings.open_chest = false
			settings.open_valentine = false
			settings.skip_dialog = false
			settings.inactivity = 0
		end

		if settings.enabled and sampIsLocalPlayerSpawned() and not settings.change_time_position then
			wait(1000)
			if (chest.common.sec == 0 and chest.common.open[0]) or (chest.donate.sec == 0 and chest.donate.open[0]) or (chest.platinum.sec == 0 and chest.platinum.open[0]) or (chest.valentine.sec == 0 and chest.valentine.open[0]) then
				settings.inactivity = settings.inactivity + 1
			else
				settings.inactivity = 0
			end

			for _, val in pairs(chest) do			
				if val.check_time and val.open[0] and not settings.open_chest and settings.enabled then					
					if sampTextdrawIsExists(buttons.close_invent) then
					chat_msg("Close invent", 0xFFE4B5)
					wait(100)
					sampSendClickTextdraw(buttons.close_invent)
					end
					open_invent_with_skip_dialog()
					break
				end
			end
		end
	end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if settings.skip_dialog then
		sampSendDialogResponse(dialogId, 0, 0, "")
		sampSendDialogResponse(dialogId, 0, 0, "")
		settings.skip_dialog = false
		return false
	end
end

function sampev.onShowTextDraw(id, data)
	if settings.enabled and sampIsLocalPlayerSpawned() then

		if data.modelId == 1353 then  -- Платиновый сундук
			chest.platinum.td_id = id
			chest.platinum.td_time_id = id + 1
			if chest.platinum.check_time and chest.platinum.open[0] then
				get_chest_time(chest.platinum)
			end
		end

		if data.modelId == 1240 and tostring(data.zoom) == "0.89999902248383" then -- Сундук валентина
			chest.valentine.td_id = id
			chest.valentine.td_time_id = id + 1
			if chest.valentine.check_time and chest.valentine.open[0] then
				get_chest_time(chest.valentine)
			end
		end

		if data.modelId == 19613 then -- Сундук за 6.000 AZ
			chest.donate.td_id = id
			chest.donate.td_time_id = id + 1
			if chest.donate.check_time and chest.donate.open[0] then
				get_chest_time(chest.donate)
			end
		end

		if data.modelId == 19918 then -- Обычный сундук
			chest.common.td_id = id
			chest.common.td_time_id = id + 1
			if chest.common.check_time and chest.common.open[0] then
				get_chest_time(chest.common)
			end
		end
		
		if data.modelId == 1733 then -- Илона Маска сундук
			chest.elon_mask.td_id = id
			chest.elon_mask.td_time_id = id + 1
			if chest.elon_mask.check_time and chest.elon_mask.open[0] then
				get_chest_time(chest.elon_mask)
			end
		end

		if data.text == 'USE' and  data.style == 1 and  data.letterColor == -3355444 then
			buttons.use = id+1
			if settings.click_use then
				lua_thread.create(function() wait(100)
				settings.click_use = false
				chat_msg("Click use box", 0xFFE4B5)
				sampSendClickTextdraw(buttons.use)
				if settings.open_valentine then
					settings.click_get_valentnie = true
				else
					chat_msg("Close invent ", 0xFFE4B5)
					sampSendClickTextdraw(buttons.close_invent)
					settings.open_chest = false
				end
				end)
			end
		end

		if data.text == 'CLOSE' and data.style == 2 and  data.letterColor == -1  then
			buttons.close_invent = id-1
		end

		if id == buttons.valentine_get and settings.open_valentine then
			chat_msg("Get and close valentine", 0xFFE4B5)
			lua_thread.create(function() wait(100)
			settings.open_valentine = false
			sampSendClickTextdraw(buttons.valentine_get)
			wait(200)
			sampSendClickTextdraw(buttons.valentine_close)
			settings.open_chest = false
			end)
		end
	end
end

function get_chest_time(box)
	lua_thread.create(function() wait(100)
	local data_td = sampTextdrawGetString(box.td_time_id)
	local wTime = string.match(data_td, "(%d+)%s+")

	if string.match(data_td, "min") and not settings.open_chest then
		chat_msg("Close invent", 0xFFE4B5)
		wait(500)
		sampSendClickTextdraw(buttons.close_invent)
		rltTimer(box, (tonumber(wTime)+1)*60)
	elseif string.match(data_td, "sec") and not settings.open_chest then
		chat_msg("Close invent", 0xFFE4B5)
		wait(500)
		sampSendClickTextdraw(buttons.close_invent)
		rltTimer(box, 60)
	elseif not settings.open_chest then
		settings.open_chest = true
		chat_msg(string.format("Time to open %s", box.name), 0xFFE4B5)
		sampSendClickTextdraw(box.td_id)
		if box.name == "valentine" then
			settings.open_valentine = true
		end
		settings.click_use = true
		rltTimer(box, box.kd)
	end
	end)
end

function rltTimer(c, wait_time)
	c.check_time = false
	chat_msg(string.format("Start timer [%d] for %s", wait_time, c.name), 0xFFE4B5)
	local timer = os.clock() + wait_time
	c.sec = math.floor((timer - os.clock()))
	while c.sec > 0 do
		c.sec = math.floor((timer - os.clock()))
		wait(1000)
		print(c.name.." - "..math.floor(c.sec/60)..":"..c.sec%60)
	end

	c.check_time = true
end

function chat_msg(text, color)
	if settings.chat[0] then
		sampAddChatMessage(string.format("[%s]: %s", thisScript().name, text), color)
	end
end

function create_textdraw()
	if settings.time_on_screen[0] then
		sampTextdrawCreate(222, "", settings.time_x, settings.time_y)
		sampTextdrawSetLetterSizeAndColor(222, 0.2, 1, 0xFFff6347)
		sampTextdrawSetOutlineColor(222, 0.5, 0xFF000000)
		sampTextdrawSetAlign(222, 1)
		sampTextdrawSetStyle(222, 2)
	end
end

function open_invent_with_skip_dialog()	
		settings.skip_dialog = true
		sampSendChat("/stats")
		while settings.skip_dialog do wait(0) end
		sampSendChat("/invent")	
end

function textdraw_string()
	local td_text = ""
	if chest.common.open[0] then
		td_text = td_text..string.format("%s-%d:%d~n~", chest.common.name, math.floor(chest.common.sec/60), chest.common.sec%60)
	end
	
	if chest.donate.open[0] then
		td_text = td_text..string.format("%s-%d:%d~n~", chest.donate.name, math.floor(chest.donate.sec/60), chest.donate.sec%60)
	end
	
	if chest.platinum.open[0] then
		td_text = td_text..string.format("%s-%d:%d~n~", chest.platinum.name, math.floor(chest.platinum.sec/60), chest.platinum.sec%60)
	end	
	
	if chest.elon_mask.open[0] then
		td_text = td_text..string.format("%s-%d:%d~n~", chest.elon_mask.name, math.floor(chest.elon_mask.sec/60), chest.elon_mask.sec%60)
	end	
	return td_text
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        sampTextdrawDelete(222)
    end
end

function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      sampAddChatMessage((prefix..'Обновление завершено!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': Обновление не требуется.')
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end
