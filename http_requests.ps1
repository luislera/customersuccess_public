function TokenGen {
    ##########################################################
    # Access Token Request
    ##########################################################

    # OAuth Body Access Token Request
    $authBody = 
    @{
        client_id = $env:appId;
        client_secret = $env:clientSecret;    
        # The v2 endpoint for OAuth uses scope instead of resource
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
function PvaPublish{
    ##########################################################
    # First HTTP request, a POST to bots($botId)/PvaPublish
    ##########################################################

    $uriParams = "bots($($env:botId))/Microsoft.Dynamics.CRM.PvaPublish"

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
    $apiCallResponse = $apiCallRequest
    return $apiCallResponse
}
function PvaPublishStatus{
    ##########################################################
    # Second HTTP request, a POST to bots($botId)/PvaPublishStatus, using the jobId obtained from previous request.
    ##########################################################
    param ([string] $jobId)

    $uriParams = "bots($($env:botId))/Microsoft.Dynamics.CRM.PvaPublishStatus"
    $apiCallParams =
    @{
        URI = "$($env:dataverseEnvUrl)/api/data/v9.2/$($uriParams)"
        Headers = @{
            "Authorization" = "$($authResponse.token_type) $($authResponse.access_token)"
            "Content-Type" = "application/json"
        }
        #Body = @{"PublishBotJob" = "$($jobId)"}
        Method = 'POST'
    }
        $Body = @{"PublishBotJob" = "$($jobId)"}
        $apiCallRequest = Invoke-RestMethod @apiCallParams -Body ($Body | ConvertTo-Json) -ErrorAction Stop
        $apiCallResponse = $apiCallRequest
        Write-Host($apiCallResponse.state)
        return $apiCallResponse
}
#hash table / dictionary with all the posible states provided
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
$Continue = "Submitted","Snapshotting","Validating","Publishing"
#Token Generation
$authResponse = TokenGen
#Call PvaPublish
$PvaPublishResponse = PvaPublish
#Save the job id into a variable
$jobId= $PvaPublishResponse.PublishBotJobResponse.jobId
#Save the state into a variable
$initial_state = $PvaPublishResponse.PublishBotJobResponse.state

Write-Host("Publishing process started! Initial State: $initial_state")
if($initial_state -ne $PublishingState.Finished){
    $current_state = $initial_state
    #loop while the Publishing State is not Finished
    while($Continue -contains $current_state){
        #Start-Sleep -Seconds 5
        switch($current_state) {
            { $PublishingState.Submitted, $PublishingState.Publishing, $PublishingState.Snapshotting, $PublishingState.Validating } {
                $response = PvaPublishStatus $jobId
                $current_state = $response.state ; break
            }
            ($PublishingState.Finished) {break} 
            Default {break}
        }
    }
    if ($current_state -ne $PublishingState.Finished){
        Write-Host("Error!")
    }
    else {
        Write-Host("Success!")
    }
    Write-Host("Publishing process finished with [$current_state] state!")
}