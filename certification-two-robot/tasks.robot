# +

*** Settings ***
Documentation   Orders robots from RobotSpareBin Industries Inc.
...             Saves the order HTML receipt as a PDF file.
...             Saves the screenshot of the ordered robot.
...             Embeds the screenshot of the robot to the PDF receipt.
...             Creates ZIP archive of the receipts and the images.

Library    RPA.Browser
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.PDF
Library    RPA.Robocloud.Secrets
# -

*** Variables ***
${SECRET} =    Get Secret    credentials


*** Keywords ***
Download Excel file
    

*** Keywords ***
Open browser and close pop up
    Open Chrome Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    OK

*** Tasks ***
Open browser and close pop up