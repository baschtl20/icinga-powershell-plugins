<#
.SYNOPSIS
   Checks how many files are in a directory.
.DESCRIPTION
   Invoke-IcingaCheckDirectory returns either 'OK', 'WARNING' or 'CRITICAL', based on the thresholds set.
   e.g 'C:\Users\Icinga\Backup' contains 200 files, WARNING is set to 150, CRITICAL is set to 300. In this case the check will return CRITICAL
   More Information on https://github.com/Icinga/icinga-powershell-plugins
.FUNCTIONALITY
   This module is intended to be used to check how many files and directories are within are specified path. 
   Based on the thresholds set the status will change between 'OK', 'WARNING' or 'CRITICAL'. The function will return one of these given codes.
.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3
   [OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All)
    \_ [OK]: C:\Users\Icinga\Downloads is 19
.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3
   [WARNING]: Check package "C:\Users\Icinga\Downloads" is [WARNING] (Match All)
    \_ [WARNING]: C:\Users\Icinga\Downloads is 24
.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -Warning 20 -Critical 30 -Verbosity 3 -ChangeYoungerThen 20d -ChangeOlderThen 10d
   [OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All)
    \_ [OK]: C:\Users\Icinga\Downloads is 1
.EXAMPLE
   PS>Invoke-IcingaCheckDirectory -Path "C:\Users\Icinga\Downloads" -FileNames "*.txt","*.sql" -Warning 20 -Critical 30 -Verbosity 3
   [OK]: Check package "C:\Users\Icinga\Downloads" is [OK] (Match All)
    \_ [OK]: C:\Users\Icinga\Downloads is 4
.PARAMETER Warning
   Used to specify a Warning threshold. In this case an integer value.
.PARAMETER Critical
   Used to specify a Critical threshold. In this case an integer value.
.PARAMETER Path
   Used to specify a path.
   e.g. 'C:\Users\Icinga\Downloads'
.PARAMETER FileNames
   Used to specify an array of filenames or expressions to match against.
   
   e.g '*.txt', '*.sql' # Fiends all files ending with .txt and .sql
.PARAMETER Recurse
   A switch, which can be set to filter through directories recursively.
.PARAMETER ChangeYoungerThan
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have a change date younger then 20 days are considered within the check.
.PARAMETER ChangeOlderThan
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have a change date older then 20 days are considered within the check.
.PARAMETER CreationYoungerThan
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have a creation date younger then 20 days are considered within the check.
.PARAMETER CreationOlderThan
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have a creation date older then 20 days are considered within the check.

.PARAMETER ChangeTimeEqual
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have been changed 20 days ago are considered within the check.

.PARAMETER CreationTimeEqual
   String that expects input format like "20d", which translates to 20 days. Allowed units: ms, s, m, h, d, w, M, y.

   Thereby all files which have been created 20 days ago are considered within the check.

.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-plugins
.NOTES
#>

function Invoke-IcingaCheckDirectory()
{
   param(
      [string]$Path,
      [array]$FileNames,
      [switch]$Recurse,
      $Critical           = $null,
      $Warning            = $null,
      [string]$ChangeTimeEqual,
      [string]$ChangeYoungerThan,
      [string]$ChangeOlderThan,
      [string]$CreationTimeEqual,
      [string]$CreationOlderThan,
      [string]$CreationYoungerThan,
      [string]$FileSizeGreaterThan,
      [string]$FileSizeSmallerThan,
      [ValidateSet(0, 1, 2, 3)]
      [int]$Verbosity     = 0,
      [switch]$NoPerfData
   );

   $DirectoryData  = Get-IcingaDirectoryAll -Path $Path -FileNames $FileNames -Recurse $Recurse `
                     -ChangeYoungerThan $ChangeYoungerThan -ChangeOlderThan $ChangeOlderThan `
                     -CreationYoungerThan $CreationYoungerThan -CreationOlderThan $CreationOlderThan `
                     -CreationTimeEqual $CreationTimeEqual -ChangeTimeEqual $ChangeTimeEqual;
   $DirectoryCheck = New-IcingaCheck -Name 'File Count' -Value $DirectoryData.Count;

   $DirectoryCheck.WarnOutOfRange(
      ($Warning)
   ).CritOutOfRange(
      ($Critical)
   ) | Out-Null;

   $DirectoryPackage = New-IcingaCheckPackage -Name $Path -OperatorAnd -Checks $DirectoryCheck -Verbose $Verbosity;

   return (New-IcingaCheckresult -Check $DirectoryPackage -NoPerfData $NoPerfData -Compile);
}
