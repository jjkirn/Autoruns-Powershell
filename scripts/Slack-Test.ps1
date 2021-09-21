#
#  Simple Slack message test  - Working as of 4/18/21
#
Import-Module C:\ar_scripts\Send-Slack-Msg.psm1

$myText2 = "Hello from 4.18.21 `r"
$myTitleLink2 = "http://192.168.1.120"
[String] $myTitle2 = ": Autoruns Test"

Send-Slack-Msg($myText2, $myTitleLink2, $myTitle2)

Write-Host "Did this work?"
