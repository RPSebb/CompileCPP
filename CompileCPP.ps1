param($outName = 'application')

# Utility variables
$vars =
@{
    workspaceFolder = Get-Location | Convert-Path
    SDKLibraryFolder = 'C:\Program Files (x86)\Windows Kits\10\Lib\10.0.20348.0\um\x64'
}

$outFile = $vars['workspaceFolder'] + '\' + $outName + '.exe'

# Check if src folder exist else quit
$sourceDir = $vars["workspaceFolder"] + '\src\'

if(!(Test-Path -Path $sourceDir))
{
    Write-Host 'No src/ folder in current directory.' -ForegroundColor Red
    Write-Host 'Quit' -ForegroundColor Red
    Exit
}

# Searching for files to compile
Write-Host 'Searching for source files' -ForegroundColor Green
$sourceFiles = Get-ChildItem -Path $sourceDir -Recurse | Convert-Path

if(!$sourceFiles)
{
    Write-Host 'No files founded' -ForegroundColor Red
    Write-Host 'Quit' -ForegroundColor Red
    Exit
}

Write-Host "$($sourceFiles.length) files founded :" -ForegroundColor Magenta

Write-Host $sourceFiles.ForEach({$_.split('\').Where({$_}, 'Last')})

# Searching configuration file
Write-Host 'Searching for json configuration file' -ForegroundColor Green

$configFile = $vars['workspaceFolder'] + '\config.json'

$args = $sourceFiles + @('-o', $outName)

if(!(Test-Path $configFile))
{
    Write-Host 'No configuration file in current directory' -ForegroundColor Magenta
}
else
{
    Write-Host 'Configuration file founded' -ForegroundColor Magenta

    $configContent = Get-Content $configFile | ConvertFrom-Json

    $spec = $configContent.spec
    $include = $configContent.include
    $lib = $configContent.lib

    For ($i = 0; $i -lt $include.length; $i++)
    {
        $line = $include[$i] -split '\${(.*)}'
        if($line.length -gt 1)
        {
            $key = $line[1] + ''
            $include[$i] = $line[0] + $vars[$key] + $line[2]
        }
        
    }

    For ($i = 0; $i -lt $lib.length; $i++)
    {
        $line = $lib[$i] -split '\${(.*)}'
        if($line.length -gt 1)
        {
            $key = $line[1] + ''
            $lib[$i] = $line[0] + $vars[$key] + $line[2]
        }
        
    }

    $args = $spec + $include + $sourceFiles + @('-o', $outName) + $lib
}


Write-Host g++ $args -ForegroundColor Cyan
# Write-Host $outFile

Write-Host 'Compiling...' -ForegroundColor Green
& g++ $args

Write-Host 'Executing !' -ForegroundColor Green
& $outFile -NoNewWindow