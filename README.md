# SNS-Solar2D
 AWS SNS Library

This library is only for registering devices for SNS


### Setup
 You need to setup your own Platform SNS(AWS>SNS>Mobile>Push Notifications)

For key and secret that is setup under IAM>Users>Your user here>Security Credentials> Access keys

I recommend creating a new user and policy for SNS

Here is the json view of the custom policy I used
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "sns:CreatePlatformEndpoint",
            "Resource": "*"
        }
    ]
}
```


You need to init your SNS library like so
 ```
 local sns = require "sns.core"
 sns:new({
 	key = "Replace with your aws key",
 	secret = "Replace with your aws key",
 	arnIOS="arn:aws:sns:us-east-1:your app here",
 	arnAndroid="arn:aws:sns:us-east-1:your app here"
 })
 ```

### Register Device
```
--Somewhere in your code
notifications.registerForPushNotifications(  )
--

--setup device
local function onNotification(event)
	if event.type == "remoteRegistration" then
		sns:register(event.token, "CustomUserDataHere", function(e)
			if(e.isError)then
				--did not add
			else
				--did add
			end
			print(json.encode(e))
		end, "UserIdOptionalHere", "ChannelOptionalHere")
	end
end

-- Set up a notification listener.
Runtime:addEventListener("notification", onNotification)
```


### Credit

I used a lot of @develephant code from his s3 plugin in this library.
^Thank you

https://github.com/develephant/s3-lite-plugin
