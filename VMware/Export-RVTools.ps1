<# 
.SYNOPSIS 
   Performs full export from RVTools
.DESCRIPTION
   Performs full export from RVTools. Archives old versions.
.NOTES 
   File Name  : RVToolsExport.ps1 
   Author     : John Sneddon
   Version    : 1.0.1
.PARAMETER Servers
   Specify which vCenter server(s) to connect to
.PARAMETER BasePath
   Specify the path to export to. Server name and date appended.
.PARAMETER OldFileDays
   How many days to retain copies
#>

param
(
   $Servers = @("10.0.1.15"),
   $BasePath = "C:\",
   $OldFileDays = 7
)

$DateStr = (Get-Date).ToString("yyyy:MM:dd")

foreach ($Server in $Servers)
{
   # Create Directory
   New-Item -Path "$BasePath\$Server\$DateStr" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null 

   # Run Export
   . "C:\Program Files (x86)\Robware\RVTools\RVTools.exe" -passthroughAuth -s $Server -c ExportAll2csv -d "$BasePath\$Server\$DateStr"

   # Cleanup old files
   $Items = Get-ChildItem -Directory "$BasePath\$server"
   foreach ($item in $items)
   {
      $itemDate = ("{0}/{1}/{2}" -f $item.name.Substring(6,2),$item.name.Substring(4,2),$item.name.Substring(0,4))
      
      if ((((Get-date).AddDays(-$OldFileDays))-(Get-Date($itemDate))).Days -gt 0)
      {
         $item | Remove-Item -Recurse
      }
   }
}

# Changelog:
# 1.0.0 - Initial release
# 1.0.1 - Fixed cleanup routine with uninitialised variable $path