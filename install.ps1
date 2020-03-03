Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser	
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope LocalMachine
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    "Running Powershell with full privileges"

    $Dest = 'C:\windows-security-package.zip'

    "`nDownloading Package..."

    #Download Zip Package
    (New-Object Net.WebClient).DownloadFile('https://github.com/themarcusaurelius/windows-package/archive/master.zip', 'C:\windows-security-package.zip')

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    "`nPackage Downloaded"

    "`nExtracting Zip File..."

    #Defines where the extracted folder where go
    $ExtractDir = 'c:\'

    #Extracts the zip folder and sends to the new folder
    $ExtShell = New-Object -ComObject Shell.Application
    $files = $ExtShell.Namespace($Dest).Items()
    $ExtShell.Namespace($ExtractDir).CopyHere($files)

    #Removes original zip folder
    Remove-Item -LiteralPath 'c:\windows-security-package.zip' -Recurse -Confirm:$false

    #Rename Folder
    Rename-Item 'C:\windows-package-master' 'C:\windows-monitoring'

    #CD's into Folder to set the execution policies
    Set-Location -Path 'c:\windows-monitoring\filebeat'
    Set-ExecutionPolicy Unrestricted
    "`nFilebeat Execution policy set - Success"

    Set-Location -Path 'c:\windows-monitoring\winlogbeat'
    Set-ExecutionPolicy Unrestricted
    "Winlogbeat Execution policy set - Success"

    Set-Location -Path 'c:\windows-monitoring\auditbeat'
    Set-ExecutionPolicy Unrestricted
    "Auditbeat Execution policy set - Success"

    Set-Location -Path 'c:\windows-monitoring\metricbeat'
    Set-ExecutionPolicy Unrestricted
    "Metricbeat Execution policy set - Success"

    Set-Location -Path 'c:\windows-monitoring'

    #GUI To Insert User Credentials
    #Pop-up Box that Adds Credentials 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

    #============ Box ============#
    $objForm = New-Object System.Windows.Forms.Form 
    $objForm.Text = "Vizion.ai Credentials Form"
    $objForm.Size = New-Object System.Drawing.Size(300,400) 
    $objForm.StartPosition = "CenterScreen"

    $objForm.KeyPreview = $True
    $objForm.Add_KeyDown({
        if ($_.KeyCode -eq "Enter" -or $_.KeyCode -eq "Escape"){
            $objForm.Close()
        }
    })

    #============= Buttons =========#
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(75,280)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.Add_Click({$objForm.Close()})
    $objForm.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(150,280)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.Add_Click({$objForm.Close()})
    $objForm.Controls.Add($CancelButton)

    #============= Header ==========#
    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,10) 
    $objLabel.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel.Text = "Please enter the following:"
    $objForm.Controls.Add($objLabel)

    #============ First Input =======#
    $objLabel1 = New-Object System.Windows.Forms.Label
    $objLabel1.Location = New-Object System.Drawing.Size(10,40) 
    $objLabel1.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel1.Text = "Kibana URL"
    $objForm.Controls.Add($objLabel1)

    $objTextBox = New-Object System.Windows.Forms.TextBox 
    $objTextBox.Location = New-Object System.Drawing.Size(10,60) 
    $objTextBox.Size = New-Object System.Drawing.Size(260,20) 
    $objForm.Controls.Add($objTextBox) 

    #============ Second Input =======#
    $objLabel2 = New-Object System.Windows.Forms.Label
    $objLabel2.Location = New-Object System.Drawing.Size(10,100) 
    $objLabel2.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel2.Text = "Username:"
    $objForm.Controls.Add($objLabel2)

    $objTextBox2 = New-Object System.Windows.Forms.TextBox 
    $objTextBox2.Location = New-Object System.Drawing.Size(10,120) 
    $objTextBox2.Size = New-Object System.Drawing.Size(260,20) 
    $objForm.Controls.Add($objTextBox2)

    # #============ Third Input =======#
    $objLabel3 = New-Object System.Windows.Forms.Label
    $objLabel3.Location = New-Object System.Drawing.Size(10,160) 
    $objLabel3.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel3.Text = "Password:"
    $objForm.Controls.Add($objLabel3)

    $objTextBox3 = New-Object System.Windows.Forms.TextBox 
    $objTextBox3.Location = New-Object System.Drawing.Size(10,180) 
    $objTextBox3.Size = New-Object System.Drawing.Size(260,20) 
    $objForm.Controls.Add($objTextBox3)

    #============ Fourth Input =======#
    $objLabel4 = New-Object System.Windows.Forms.Label
    $objLabel4.Location = New-Object System.Drawing.Size(10,220) 
    $objLabel4.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel4.Text = "Vizion Elasticsearch API Endpoint:"
    $objForm.Controls.Add($objLabel4)

    $objTextBox4 = New-Object System.Windows.Forms.TextBox 
    $objTextBox4.Location = New-Object System.Drawing.Size(10,240) 
    $objTextBox4.Size = New-Object System.Drawing.Size(260,20) 
    $objForm.Controls.Add($objTextBox4)

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objForm.Activate()})
    [void]$objForm.ShowDialog()

    #Load Winlogbeat Credentials And Run
    "`nAdding Winlogbeat Credentials...`n"
    Set-Location -Path 'c:\windows-monitoring\winlogbeat'

    #Opens up YML file and inserts Kibana Host URL       
    (Get-Content winlogbeat.yml) |       
        ForEach-Object {$_ -Replace 'host: ""', "host: ""$($objTextBox.Text)"""} |
            Set-Content winlogbeat.yml

    #Opens Up YML and sets Password
    (Get-Content winlogbeat.yml) |       
        ForEach-Object {$_ -Replace 'password: ""', "password: ""$($objTextBox3.Text)""" } |
            Set-Content winlogbeat.yml

    #Opens Up YML and sets Username
    (Get-Content winlogbeat.yml) |       
        ForEach-Object {$_ -Replace 'username: ""', "username: ""$($objTextBox2.Text)""" } |
            Set-Content winlogbeat.yml

    #Opens up YML file and inserts Elasticsearch API Endpoint
    (Get-Content winlogbeat.yml) |
        ForEach-Object {$_ -Replace 'elasticsearch-api-endpoint', "$($objTextBox4.Text)"} |
            Set-Content winlogbeat.yml

    #Runs the config test to make sure all data has been inputted correctly
    .\winlogbeat.exe -e -configtest

    #Loads winlogbeat Preconfigured Dashboards
    .\winlogbeat.exe setup --dashboards

    #Installs winlogbeat as a service
    .\install-service-winlogbeat.ps1

    #Runs winlogbeat as a Service
    #Start-service winlogbeat

    #Load Metricbeat credentials and run
    "`nAdding Metricbeat Credentials"

    Set-Location -Path 'C:\windows-monitoring\metricbeat'

    #Opens up YML file and inserts Kibana URL
    (Get-Content metricbeat.yml) |
        ForEach-Object {$_ -Replace 'host: ""', "host: ""$($objTextBox.Text)"""} |
            Set-Content metricbeat.yml

    #Opens Up YML and sets Password
    (Get-Content metricbeat.yml) |       
        ForEach-Object {$_ -Replace 'password: ""', "password: ""$($objTextBox3.Text)""" } |
            Set-Content metricbeat.yml

    #Opens Up YML and sets Username
    (Get-Content metricbeat.yml) |       
        ForEach-Object {$_ -Replace 'username: ""', "username: ""$($objTextBox2.Text)""" } |
            Set-Content metricbeat.yml

    #Opens up YML file and inserts Elasticsearch API Endpoint
    (Get-Content metricbeat.yml) |
        ForEach-Object {$_ -Replace 'elasticsearch-api-endpoint', "$($objTextBox4.Text)"} |
            Set-Content metricbeat.yml

    #Runs the config test to make sure all data has been inputted correctly
    .\metricbeat.exe -e -configtest

    #Load Metricbeat Preconfigured Dashboards
    .\metricbeat.exe setup --dashboards

    #Install metricbeat as a service
    .\install-service-metricbeat.ps1

    #Runs metricbeat as a Service
    #Start-service metricbeat

    #Show that metricbeat is running
    Get-Service metricbeat

    #Load Auditbeat credentials and run
    "`nAdding Auditbeat Credentials"

    Set-Location -Path 'C:\windows-monitoring\auditbeat'

    #Opens up YML file and inserts Kibana URL
    (Get-Content auditbeat.yml) |
        ForEach-Object {$_ -Replace 'host: ""', "host: ""$($objTextBox.Text)"""} |
            Set-Content auditbeat.yml

    #Opens Up YML and sets Password
    (Get-Content auditbeat.yml) |       
        ForEach-Object {$_ -Replace 'password: ""', "password: ""$($objTextBox3.Text)""" } |
            Set-Content auditbeat.yml

    #Opens Up YML and sets Username
    (Get-Content auditbeat.yml) |       
        ForEach-Object {$_ -Replace 'username: ""', "username: ""$($objTextBox2.Text)""" } |
            Set-Content auditbeat.yml

    #Opens up YML file and inserts Elasticsearch API Endpoint
    (Get-Content auditbeat.yml) |
        ForEach-Object {$_ -Replace 'elasticsearch-api-endpoint', "$($objTextBox4.Text)"} |
            Set-Content auditbeat.yml

    #Runs the config test to make sure all data has been inputted correctly
    .\auditbeat.exe -e -configtest

    #Load auditbeat Preconfigured Dashboards
    .\auditbeat.exe setup --dashboards

    #Install auditbeat as a service
    .\install-service-auditbeat.ps1

    #Runs auditbeat as a Service
    #Start-service auditbeat

    #Show that auditbeat is running
    Get-Service auditbeat

    

    Set-Location -Path 'C:\Users\Administrator\Desktop\autoBeats'
}
else {
    Start-Process -FilePath "powershell" -ArgumentList "$('-File ""')$(Get-Location)$('\')$($MyInvocation.MyCommand.Name)$('""')" -Verb runAs
}