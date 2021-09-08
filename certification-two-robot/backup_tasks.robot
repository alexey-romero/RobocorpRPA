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
#${OUTPUT_DIR}=    ${CURDIR}${/}output


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
Submit order
    FOR    ${i}    IN RANGE    20
        Click Button    Order
        ${cond}=    Is Element Visible    id:receipt    bool=False
        Exit For Loop If    ${cond} == True
    END
    
    
    
    #${cond}=    Is Element Visible    id:receipt  
    #IF    ${cond} == False
    #    FOR    ${i}    IN RANGE    20
    #        Click Button    Order
    #        ${cond}=    Is Element Visible    id:receipt
    #        Exit For Loop If    ${cond} == True
    #    END
    #END
    
    #FOR    ${cond}    IN RANGE    20    
    #    Click Button    Order
    #    Exit For Loop If    ${cond}
    #END
        
*** Keywords ***
Receipt
    [Arguments]    ${order}
    #Screenshot Robot preview    ${order}
    Wait Until Element Is Visible    id:receipt
    #${order_receipt}=    Screenshot    id:receipt
    #Html To Pdf    ${order_receipt}    ${OUTPUT_DIR}{/}order_receipt.pdf
    ${order_receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt}    ${CURDIR}${/}output${/}receipts${/}order_receipt.pdf    
    #${OUTPUT_DIR}
    #Screenshot    id:receipt    ${CURDIR}${/}output${/}receipts${/}Robot_Receipt.png
    #${file_list}=    Create List    ${CURDIR}${/}output${/}previews${/}Robot_Receipt.png    ${CURDIR}${/}output${/}receipts${/}Robot_Receipt.png
    #Add Files To Pdf    ${file_list}    ${CURDIR}${/}output${/}${order}${/}Robot_Order_${order}.pdf

*** Keywords ***
Screenshot Robot preview
    [Arguments]     ${order}
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${CURDIR}${/}output${/}previews${/}Robot_Preview.png

*** Keywords ***
Embed Robot preview to PDF
    [Arguments]    
    Open Pdf    ${CURDIR}${/}output${/}receipts${/}order_receipt.pdf
    ${file}=    Create List    
    ...    ${CURDIR}${/}output${/}previews${/}Robot_Preview.png
    Add Files To pdf    ${file}        ${CURDIR}${/}output${/}receipts${/}order_receipt.pdf
    #Save Pdf    ${CURDIR}${/}output${/}receipts${/}order_receipt.pdf
    Close Pdf    ${CURDIR}${/}output${/}receipts${/}order_receipt.pdf

*** Keywords ***
Order another robot
    Click Button    id:order-another

*** Keywords ***
Get Data from CSV and create orders
    ${data}=    Read table from CSV    ${CURDIR}${/}orders.csv  header=True
    Log    ${data}
    FOR    ${order}    IN    @{data}
        Close Consitutional Rights Pop Up 
        Create Order    ${order}
        Submit order
        Receipt    ${order}
        Screenshot Robot preview    ${order}
        Embed Robot preview to PDF    
        Order another robot
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
    