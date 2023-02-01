local notifications = require( "plugin.notifications.v2" )
local sns = require "sns.core"
local json = require "json"
local widget = require "widget"
local sns = require "sns.core"
sns:new({
	key = "Replace with your aws key",
	secret = "Replace with your aws key",
	arnIOS="arn:aws:sns:us-east-1:your app here",
	arnAndroid="arn:aws:sns:us-east-1:your app here"
})

local _W, _H = display.actualContentWidth, display.actualContentHeight
local _CX, _CY = display.contentCenterX, display.contentCenterY

local width = _W * 0.8
local size = _H * 0.1
local buttonFontSize = 16
local spacing = _H * 0.12

widget.newButton{
	x = _CX, y = _CY,
	width = width, height = size,
    fillColor = { default={1,1,1,1}, over={1,1,1,0.1} },
	label = 'Register Device',
	fontSize = buttonFontSize,
	onRelease = function()
		notifications.registerForPushNotifications(  )
	end
}

local function onNotification(event)
	if event.type == "remoteRegistration" then
		sns:register(event.token, "CustomUserDataHere", function(e)
			if(e.isError)then
				--did not add
			else
				--did add
			end
			print(json.encode(e))
		end, "UserIdHere", "ChannelIdHere")

	else
		-- A push notification has just been received. Print it to the log.
		print("### --- Notification Event ---")
		printTable(event)
	end
end

-- Set up a notification listener.
Runtime:addEventListener("notification", onNotification)
