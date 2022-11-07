function GetToken {
    ##########################################################
    # Access Token Request
    ##########################################################

    $client_id = $appId;
    Write-Host("client_id: $client_id")
    $client_secret = $clientSecret;
    Write-Host("client_secret: $client_secret")
    $client_id.ToCharArray()

    # OAuth Body Access Token Request
    $authBody =
    @{
        client_id = $client_id;
        client_secret = $client_secret;
        scope = "$($env:dataverseEnvUrl)/.default"
        grant_type = 'client_credentials'
    }

    $oAuthTokenEndpoint = "https://login.microsoftonline.com/$($env:tenantId)/oauth2/v2.0/token"

    # Parameters for OAuth Access Token Request
    $authParams =
    @{
        URI = $oAuthTokenEndpoint
        Method = 'POST'
        ContentType = 'application/x-www-form-urlencoded'
        Body = $authBody
    }

    # Get Access Token
    $authRequest = Invoke-RestMethod @authParams -ErrorAction Stop
    return $authRequest
}


function GetBotId{
    ##########################################################
    # Get the botId using the bot name
    ##########################################################
    param ([string] $botName)

    $apiCallParams =
    @{
        URI = "$($env:dataverseEnvUrl)/api/data/v9.2/bots"
        Headers = @{
            "Authorization" = "$($authResponse.token_type) $($authResponse.access_token)"
            "Content-Type" = "application/json"
        }
        Method = 'GET'
    }

    $apiCallRequest = Invoke-RestMethod @apiCallParams -ErrorAction Stop
    $botId = 0

    foreach ($bot in $apiCallRequest.value)
    {
        if ($botName -eq $bot.name)
        {
            $botId = $bot.botid
            break
        }
    }

    return $botId
}

function PvaPublish{
    ##########################################################
    # First HTTP request, a POST to bots($botId)/PvaPublish
    ##########################################################
    param ([string] $botId)

    $uriParams = "bots($($botId))/Microsoft.Dynamics.CRM.PvaPublish"

    $apiCallParams =
    @{
        URI = "$($env:dataverseEnvUrl)/api/data/v9.2/$($uriParams)"
        Headers = @{
            "Authorization" = "$($authResponse.token_type) $($authResponse.access_token)"
            "Content-Type" = "application/json"
        }
        Method = 'POST'
    }

    $apiCallRequest = Invoke-RestMethod @apiCallParams -ErrorAction Stop
    return $apiCallRequest
}

function PvaPublishStatus{
    ##########################################################
    # Second HTTP request, a POST to bots($botId)/PvaPublishStatus, using the jobId obtained from previous request.
    ##########################################################
    param ([string] $botId, [string] $jobId)

    $uriParams = "bots($($botId))/Microsoft.Dynamics.CRM.PvaPublishStatus"
    $apiCallParams =
    @{
        URI = "$($env:dataverseEnvUrl)/api/data/v9.2/$($uriParams)"
        Headers = @{
            "Authorization" = "$($authResponse.token_type) $($authResponse.access_token)"
            "Content-Type" = "application/json"
        }
        Method = 'POST'
    }

    $Body = @{"PublishBotJob" = "$($jobId)"}
    $apiCallRequest = Invoke-RestMethod @apiCallParams -Body ($Body | ConvertTo-Json) -ErrorAction Stop
    Write-Host($apiCallRequest.state)
    return $apiCallRequest
}

# Set dictionary with all the posible states provided
$PublishingState =
@{
    Unspecified = "Unspecified"
    Submitted = "Submitted"
    Snapshotting = "Snapshotting"
    Validating = "Validating"
    Publishing = "Publishing"
    Finished = "Finished"
    FinishedWithErrors = "FinishedWithErrors"
    Canceled = "Canceled"
    NotCanceled = "NotCanceled"
    NotFound = "NotFound"
    NotAcceptedAlreadyRunning = "NotAcceptedAlreadyRunning"
}

$Continue = "Submitted","Snapshotting","Validating","Publishing","NotAcceptedAlreadyRunning"

# Obtain the token
$authResponse = GetToken

# Get the botId using the bot name
$botId = GetBotId $($env:botName)

if ($botId -eq 0)
{
    Write-Host("Bot with name $($env:botName) could not be found")
    Exit 1
}

# Call PvaPublish
$PvaPublishResponse = PvaPublish $botId

# Save the job id into a variable
$jobId= $PvaPublishResponse.PublishBotJobResponse.jobId

if ($jobId -eq 0)
{
    Write-Host("Invalid Job Id")
    Exit 1
}

# Save the initial state into a variable
$state = $PvaPublishResponse.PublishBotJobResponse.state

Write-Host("Publishing process started with [$state] state")

# Continue while the state is inside the array defined above
while($Continue -contains $state)
{
    Start-Sleep -Seconds 5
    $response = PvaPublishStatus $botId $jobId
    $state = $response.state
    Write-Host($state)
}

if ($state -ne $PublishingState.Finished)
{
    Write-Host("Publishing process exited with error. State: [$state]")
    Exit 1
}
Write-Host("Publishing process finished with [$state] state")

