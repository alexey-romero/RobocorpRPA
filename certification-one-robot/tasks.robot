*** Settings ***
Documentation   Robot that logs into RobotSpareBinIndustries.
Library    RPA.Browser
Library    OperatingSystem

*** Keywords ***
Open the website
    Open Chrome Browser    http://robotsparebinindustries.com/

Log in
    Input Text    username    maria
    Input Password    password    thousallnotpass
    Submit Form

*** Tasks ***
Open a browser and log into the website   
    Open the website
    Log in