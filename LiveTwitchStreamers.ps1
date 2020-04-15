$headers = @{ 'client-id'='PLACE_YOUR_CLIENT_ID_HERE' }


# This section checks for open urls so we do not keep opening more of the same screen. 

$urls = (New-Object -ComObject Shell.Application).Windows() |
Where-Object {$_.LocationUrl -match "(^https?://.+)|(^ftp://)"} |
Where-Object {$_.LocationUrl}
if($Full)
{
    $urls
}
elseif($Location)
{
    $urls | select Location*
}
elseif($Content)
{
    $urls | ForEach-Object {
        $ie.LocationName;
        $ie.LocationUrl;
        $_.Document.building.innerText
    }
}
else
{
    $urls | ForEach-Object {$_.LocationUrl}
}

#This section checks to see if a user is live. If it is live then open internet explorer and navigate to their twitch stream. 
foreach($TwitchUser in Get-Content $PSScriptRoot\twitchusers.txt) {
    $URI = "https://api.twitch.tv/helix/streams?user_login=$TwitchUser"
    $result = Invoke-RestMethod -Method Get -Uri $URI -Headers $headers
    $TwitchURL = "https://www.twitch.tv/$TwitchUser"


    if($result.data.type -eq 'live'){
        write-host("$TwitchUser is live.")
        if($urls.LocationURL -eq $TwitchURL){
            Write-Host("$TwitchUser is already open in browser")
        }else {
            start iexplore $TwitchURL
        }
    }else {
        write-host("$TwitchUser is not live.")
        if($urls.LocationURL -eq $TwitchURL){
            Write-Host("User is no longer live. Closing internet explorer. All live users will be re-opened")
            Invoke-Expression "taskkill /f /im iexplore.exe /t"
        }
    }

}
