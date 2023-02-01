
local request = require("sns.awsrequest")
local xml = require("sns.xmlSimple").newParser()
local json = require("json")
local io = require("io")

local sns = {
  aws_key = nil,
  aws_secret = nil,
  aws_region = nil,
  aws_arn_ios = nil,
  aws_arn_android = nil,
  aws_service = "sns",
  aws_host = "amazonaws.com",

  log = nil
}

sns.VERSION = "1.0.0"

--#############################################################################
--# Enums
--#############################################################################


-- Regions
sns.US_EAST_1 = "us-east-1"
sns.US_EAST_2 = "us-east-2"
sns.US_WEST_1 = "us-west-1"
sns.US_WEST_2 = "us-west-2"
sns.CA_CENTRAL_1 = "ca-central-1"
sns.EU_WEST_1 = "eu-west-1"
sns.EU_WEST_2 = "eu-west-2"
sns.EU_CENTRAL_1 = "eu-central-1"
sns.AP_SOUTH_1 = "ap-south-1"
sns.AP_SOUTHEAST_1 = "ap-southeast-1"
sns.AP_SOUTHEAST_2 = "ap-southeast-2"
sns.AP_NORTHEAST_1 = "ap-northeast-1"
sns.AP_NORTHEAST_2 = "ap-northeast-2"
sns.SA_EAST_1 = "sa-east-1"

--#############################################################################
--# Init
--#############################################################################
function sns:new( config )
  self.aws_key = config.key
  self.aws_secret = config.secret
  self.aws_arn_ios = config.arnIOS
  self.aws_arn_android = config.arnAndroid
  self.aws_region = config.region or sns.US_EAST_1
end

--#############################################################################
--# Privates
--#############################################################################
function sns:_getAuthCreds()
  return {
    aws_key = self.aws_key,
    aws_secret = self.aws_secret,
    log = self.log
  }
end

function sns:_getHTTPDate()
  local gmt_time = os.time(os.date('*t'))
  return os.date('!%a, %d %b %Y %X GMT', gmt_time)
end


--#############################################################################
--# XML Parsing
--#############################################################################
function sns:get_error_msg( xml_txt )
  local xmlDoc = xml:ParseXmlText( xml_txt )
  if xmlDoc.ErrorResponse then
    local code, message
    error = xmlDoc.ErrorResponse.Error.Code:value()
    message = xmlDoc.ErrorResponse.Error.Message:value()
    return { error = error, message = message }
  end

  return nil
end

function sns:get_token_response( xml_txt )
  local xmlDoc = xml:ParseXmlText( xml_txt )
  if(xmlDoc.CreatePlatformEndpointResponse and xmlDoc.CreatePlatformEndpointResponse.ResponseMetadata   and xmlDoc.CreatePlatformEndpointResponse.ResponseMetadata.RequestId:value())then
    return { token = xmlDoc.CreatePlatformEndpointResponse.ResponseMetadata.RequestId:value(), message = "device registered", isError=false }
  end

  return nil
end





function sns:register( token, data, listener, userId, channelId  )

  local req = request:new(self:_getAuthCreds())
  local queryTbl = {
    Action="CreatePlatformEndpoint",
    PlatformApplicationArn=self.aws_arn_ios,
    Token=token,
    CustomUserData=data,
    Version="2010-03-31",
  }
  if(system.getInfo("platform") == "android") then
    queryTbl.PlatformApplicationArn  = self.aws_arn_android
  end
  local entry = 1
  if(userId)then
    queryTbl["Attributes.entry."..entry..".key"]="UserId"
    queryTbl["Attributes.entry."..entry..".value"]=userId
    entry = entry+1
  end
  if(channelId)then
    queryTbl["Attributes.entry."..entry..".key"]="ChannelId"
    queryTbl["Attributes.entry."..entry..".value"]=channelId
    entry = entry+1
  end
  req:setMethod("PUT")
  req:setService(self.aws_service)
  req:setRegion(self.aws_region)
  req:setHost("sns."..self.aws_region..".amazonaws.com")
  req:setHeaders(nil)
  req:setPath(nil)
  req:setQuery(queryTbl)
  req:setPayload(nil)
  req:setContentSha(nil)

  local function onResult( evt )
    local error_res = self:get_error_msg(evt.response)
    if error_res then
      return listener({
        error = error_res.error,
        message = error_res.message,
        status = status,
        isError = true,
      })
    end
    if(self:get_token_response(evt.response))then
      return listener(self:get_token_response(evt.response))
    end
    listener( evt )

  end

  req:send( nil, onResult )

end





return sns
