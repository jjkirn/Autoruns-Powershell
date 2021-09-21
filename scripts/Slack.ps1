#
# Based on information at https://www.powershellgallery.com/packages/PSSlack/0.0.17
#
# This is a simple example illustrating some common options
# when constructing a message attachment
# giving you a richer message
Param(
[String] $myText,
[String] $myPretext,
[String] $myUsername
)
# Write-Host "hello from Slack"

$myText = "hello from my Slack Test Program"
$myUsername = "Jim Kirn"
# $myPretext = "This is an example pre-text"

# Read Application Token from File
$Path = "C:\ar_scripts\slack-token.txt"

If (Test-Path -Path $Path) {
    $Token = ""
    $Token = Get-Content -Path $Path 
    # Write-Host "Token = " $Token
}
Else {
    Write-Host "Slack Token not Found! - " $Path
}

New-SlackMessageAttachment -Color $([System.Drawing.Color]::red) `
                           -Title 'Stuff goes here' `
                           -TitleLink https://www.youtube.com/watch?v=TmpRs7xN06Q `
                           -Text $myText `
                           -Pretext $myPretext `
                           -AuthorName $myUsername `
                           -AuthorIcon 'http://ramblingcookiemonster.github.io/images/tools/wrench.png' `
                           -Fallback 'Your client is bad' |
          New-SlackMessage -Channel '#general' `
                           -IconEmoji :computer: `
                           -AsUser `
                           -Username $myUsername |
         Send-SlackMessage -Token $Token

 #---------------------End of File --------------------------
