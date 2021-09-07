*** Settings ***
Documentation     Starter robot for the Beginners' course.
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Excel.Files
Library           RPA.PDF

*** Keywords ***
Open the Intranet website
    Open Chrome Browser     http://robotsparebinindustries.com

*** Keywords ****  
Log in
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    sales-form

*** Keywords ****
Fill And Submit The Form For One Person
    [Arguments]    ${sales_rep}
    Input Text    firstname    ${sales_rep}[First Name]
    Input Text    lastname    ${sales_rep}[Last Name]
    Input Text    salesresult    ${sales_rep}[Sales]
    ${target_as_string} =  Convert To String    ${sales_rep}[Sales Target]
    Select From List By Value    salestarget    ${target_as_string}
    Click Button    Submit

*** Keywords ***
Download excel file
    Download    https://robotsparebinindustries.com/SalesData.xlsx    overwrite=True

*** Keywords ***
Fill the Form using the Data from the Excel file
    Open Workbook    SalesData.xlsx
    ${sales_reps}=    Read Worksheet As Table    header=True
    Close Workbook
    FOR    ${sales_rep}    IN    @{sales_reps}
        Fill And Submit The Form For One Person    ${sales_rep}
    END

*** Keywords ***
Collect the Results
    Screenshot    css:div.sales-summary    ${CURDIR}${/}output${/}sales_summary.png

*** Keywords ***
Export table as PDF
    Wait Until Element Is Visible    id:sales-results
    ${sales_results_html}=    Get Element Attribute    id:sales-results    outerHTML
    Html To Pdf    ${sales_results_html}    ${CURDIR}${/}output${/}sales_results.pdf

*** Keywords ***
Log Out And Close The Browser
    Click Button    Log out
    Close Browser

*** Tasks ***
Insert the sales data for the week and export it as a PDF
    Open the Intranet website
    Log in
    Download excel file
    Fill the Form using the Data from the Excel file
    Collect the Results
    Export table as PDF
    [Teardown]  Log Out And Close The Browser
