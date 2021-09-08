*** Settings ***
Documentation   Orders robots from RobotSpareBin Industries Inc.
...             Saves the order HTML receipt as a PDF file.
...             Saves the screenshot of the ordered robot.
...             Embeds the screenshot of the robot to the PDF receipt.
...             Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Robocorp.Vault
Library    RPA.Tables
Library    RPA.Archive
Library    Dialogs

#*** Variables ***
#${secret} =    Get Secret    csv-file-download

#*** Keywords ***
#Open vault
#    ${secret} =    Get Secret    csv-file-download    

*** Keywords ***
Open browser 
    ${url}=    Get Value From User    Input website url    
    Open Chrome Browser    ${url}    maximized=True

*** Keywords ***
Download orders file
    #[Arguments]    ${url}
    ${secret} =    Get Secret    csv-file-download
    Download    ${secret}[url]  overwrite=True

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
Submit order
    FOR    ${i}    IN RANGE    20
        Click Button    Order
        ${cond}=    Is Element Visible    id:receipt    bool=False
        Exit For Loop If    ${cond} == True
    END
        
*** Keywords ***
Receipt
    [Arguments]    ${order}
    Wait Until Element Is Visible    id:receipt
    ${order_receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt}    ${CURDIR}${/}output${/}receipts${/}${order}${/}order_receipt.pdf

*** Keywords ***
Screenshot Robot preview
    [Arguments]     ${order}
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${CURDIR}${/}output${/}previews${/}${order}${/}Robot_Preview.png

*** Keywords ***
Embed Robot preview to PDF
    [Arguments]    ${order}
    Open Pdf    ${CURDIR}${/}output${/}receipts${/}${order}${/}order_receipt.pdf
    ${file}=    Create List
    ...    ${CURDIR}${/}output${/}receipts${/}${order}${/}order_receipt.pdf    
    ...    ${CURDIR}${/}output${/}previews${/}${order}${/}Robot_Preview.png
    Add Files To pdf    ${file}        ${CURDIR}${/}output${/}receipts${/}${order}${/}order_receipt.pdf
    Close Pdf    ${CURDIR}${/}output${/}receipts${/}${order}${/}order_receipt.pdf

*** Keywords ***
Order another robot
    Click Button    id:order-another

*** Keywords ***
Get Data from CSV and create orders
    ${data}=    Read table from CSV    ${CURDIR}${/}orders.csv  header=True
    FOR    ${order}    IN    @{data}
        Close Consitutional Rights Pop Up 
        Create Order    ${order}
        Submit order
        Receipt    ${order}[Order number]
        Screenshot Robot preview    ${order}[Order number]
        Embed Robot preview to PDF    ${order}[Order number]
        Order another robot
    END

*** Keywords ***
Create ZIP File
    Archive Folder With Zip    ${CURDIR}${/}output    ${CURDIR}${/}final_output.zip    recursive=True

*** Tasks ***
Main
    #Open vault
    Open browser
    Download orders file    
    Get Data from CSV and create orders
    Create ZIP File
    [Teardown]  Close Browser