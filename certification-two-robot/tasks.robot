# +
*** Settings ***
Documentation   Orders robots from RobotSpareBin Industries Inc.
...             Saves the order HTML receipt as a PDF file.
...             Saves the screenshot of the ordered robot.
...             Embeds the screenshot of the robot to the PDF receipt.
...             Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Robocloud.Secrets
Library    RPA.Tables
Library    RPA.Archive
# -

*** Variables ***
${SECRET} =    Get Secret    credentials

*** Keywords ***
Open browser
    #Open Browser    https://robotsparebinindustries.com/#/robot-order   Edge   
    Open Chrome Browser    https://robotsparebinindustries.com/#/robot-order    maximized=True

*** Keywords ***
Download orders file
    Download    https://robotsparebinindustries.com/orders.csv  overwrite=True

*** Keywords ***
Close Consitutional Rights Pop Up
    Click Button    OK

*** Keywords ***
Create Order
    [Arguments]    ${order}
    Select From List By Index    head   ${order}[Head]
    Select Radio Button    body    id-body-${order}[Body]
    Input Text    xpath://*[contains(@placeholder, 'Enter the part number for the legs')]    ${order}[Legs]
    Input Text    address   ${order}[Address]
    Click Button    preview

*** Keywords ***
Screenshot Robot preview
    [Arguments]     ${order}
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${CURDIR}${/}output${/}Robot_Preview_${order}.png

*** Keywords ***
Submit order
    Click Button    Order
    ${alert}=    Is Element Visible    id:receipt
    IF    ${alert} == False
        FOR    ${counter}    IN RANGE    20    
            Click Button    Order
            IF    ${alert} == True
                Exit For Loop
            END
        END
    END
        
*** Keywords ***
Receipt
    [Arguments]    ${order}
    Screenshot Robot preview    ${order}
    Wait Until Element Is Visible    id:receipt
    Screenshot    id:receipt    ${CURDIR}${/}output${/}pictures${/}${order}${/}Robot_Receipt_${order}.png
    ${file_list}=    Create List    ${CURDIR}${/}output${/}pictures${/}${order}${/}Robot_Preview_${order}.png    ${CURDIR}${/}output${/}pictures${/}${order}${/}Robot_Receipt_${order}.png
    Add Files To Pdf    ${file_list}    ${CURDIR}${/}output${/}${order}${/}Robot_Order_${order}.pdf

*** Keywords ***
Get Data from CSV and create orders
    ${data}=    Read table from CSV    ${CURDIR}${/}orders.csv  header=True
    Log    ${data}
    FOR    ${order}    IN    @{data}
        Close Consitutional Rights Pop Up 
        Create Order    ${order}
        Submit order
        Receipt    ${order}
    END

*** Keywords ***
Create ZIP File
    Archive Folder With Zip    ${CURDIR}${/}output    ${CURDIR}${/}final_output.zip    recursive=True

*** Tasks ***
Main
    Open browser
    Download orders file
    Get Data from CSV and create orders
    Create ZIP File
    [Teardown]  Close Browser
