#
# Send Slack Message - Working as of 4/18/21
#
#----------------------------------------------
Import-Module PSSlack

Function Send-Slack-Msg {
Param(
[String] $myText,
[String] $myTitleLink,
[String] $myTitle
)

# Read Application Token fromn File
$Path = "C:\ar_scripts\slack-token.txt"

if(Test-Path -Path $PATH) {
    $Token = ""
    $Token = Get-Content -Path $Path
    Write-Host "Token = " $Token
    }
else {
    Write-Host "Slack Token not Found! - " $Path
    }


Write-Host "calling Send-SlackMessage"


New-SlackMessageAttachment -Color $([System.Drawing.Color]::red) `
                            -Title $myTitle `
                            -TitleLink $myTitleLink `
                            -Text $myText `
                            -AuthorName "AutoRuns Bot" `
                            -AuthorIcon 'http://ramblingcookiemonster.github.io/images/tools/wrench.png' `
                            -Fallback 'Your client is bad' |
           New-SlackMessage -Channel '#general' `
                            -IconEmoji :computer: `
                            -AsUser `
                            -Username "AutoRuns Bot" |
          Send-SlackMessage -Token $Token

}
