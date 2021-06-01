*** Settings ***
#Documentation    Template robot main suite.
Documentation     Screenshot robot.

Library    RPA.Browser

*** Tasks ***

#Minimal task
#   Log  Done.

Open a browser and take a screenshot
    Open Available Browser    http://robocorp.com/docs
    Screenshot
    Close All Browsers