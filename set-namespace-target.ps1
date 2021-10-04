# The purpose of this script is to enable/disable namespace targets. This will aid in migrations to new hardware.

# Import CSV
# Headers for the CSV should be the following
# Path,SharePath,State
# 
# Path: Should contain the namespace path. For example: \\domain.com\share\share
#
# SharePath: Should contain the share path that the target will point to. For example: \\servername\share\path
#
# State: Should note if the target should be enabled/disabled which is noted by either Online/Offline

# Getting the desktop path of the user launching the script. Just as a default starting path
$DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

# Prompt the user to select the CSV file for the script
Function Get-FileName($initialDirectory){
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = "CSV (*.csv) | *.csv"
    $OpenFileDialog.Title = "Select SET NAMESPACE CSV"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.FileName
}

$FilePath  = Get-FileName -initialDirectory $DesktopPath
$csv      = @() 
$csv      = Import-Csv -Path $FilePath 

# Set count for activity status
$i = 0

#Loop through all items in the CSV 
ForEach ($item In $csv) 
{

    # Put the objects into string variables, because new-dfsnfoldertarget likes strings
    [string]$Path = $item.Path
    [string]$SharePath = $item.SharePath
    [string]$State = $item.State

    # This little diddy will provide a progress bar!
    $i = $i+1
    Write-Progress -Activity "Setting $Path $SharePath to $State" -Status "Progress:" -PercentComplete ($i/$csv.Count*100)
    
    # Setting namespace targets to offline/online based on state in CSV
    Set-DfsnFolderTarget -Path $Path -TargetPath $SharePath -State $State
}
