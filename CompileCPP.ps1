# Utility variables
$vars =
@{
    workspaceFolder = (Get-Location | Convert-Path) + '\'
}

# Replace all ${variableName} in a string with their values from $vars
Function ReplaceKeywords($text) 
{
    $words = $text -split '\${(.+?)}'
    $output = ''
    Foreach ($word In $words)
    {
        $key = $vars[$word]
        If($key) { $output+=$key } Else { $output+=$word }
    }

    Return $output
}

Write-Host 'Searching for json configuration file' -ForegroundColor Green

# Get config.json
$configFile = $vars['workspaceFolder'] + 'config.json'

# If config.json is not found, quit
If(!(Test-Path $configFile))
{
    Write-Host 'No configuration file in current directory' -ForegroundColor Red
    Write-Host 'Quit' -ForegroundColor Red
    Exit
}

# Convert .json file into PS Object
$configContent = Get-Content $configFile | ConvertFrom-Json

# Get workspace/src folder
$sourceFolder = $configContent.sourceFolder

If(!$sourceFolder)
{
    Write-Host 'No assigned value for sourceFolder in config.json' -ForegroundColor Red
    Write-Host 'Quit'
    Exit
}

$sourceFolder = ReplaceKeywords($sourceFolder)
# If src folder is not found, quit
If(!(Test-Path -Path $sourceFolder))
{
    Write-Host $sourceFolder 'does not exist.' -ForegroundColor Red
    Write-Host 'Quit' -ForegroundColor Red
    Exit
}

# Searching for files in src folder to compile
Write-Host 'Searching for source files' -ForegroundColor Green
$sourceFiles = Get-ChildItem -Path $sourceFolder -Recurse | Convert-Path

# If not file is found, quit
If(!$sourceFiles)
{
    Write-Host 'No files founded' -ForegroundColor Red
    Write-Host 'Quit' -ForegroundColor Red
    Exit
}

$nbFiles = If($sourceFiles.GetType() -Eq [string]) { 1 } Else { $sourceFiles.Length }
Write-Host "$($nbFiles) files founded :" -ForegroundColor Magenta

# Get filename and extension wihtout path informations
# Ex: C:\project\src\application.cpp -> application.cpp
Write-Host $sourceFiles.ForEach({$_.split('\').Where({$_}, 'Last')})

# Output folder
$outputFolder = $vars['workspaceFolder']

# Output filename.exe
$outputName = $configContent.outputName
$outputName = If(!$outputName) { 'application' } Else { $outputName }
$outFile = $outputFolder + $outputName + '.exe'

Write-Host 'Configuration file founded' -ForegroundColor Magenta

$compiler = $configContent.compiler

If(!$compiler)
{
    Write-Host 'No compiler in config.json' -ForegroundColor Red
    Write-Host 'Quit' -ForegroundColor Red
    Exit
}

$spec = $configContent.spec
$include = $configContent.include
$lib = $configContent.lib

If($include)
{
    For ($i = 0; $i -Lt $include.length; $i++)
    {
        $include[$i] = ReplaceKeywords($include[$i])
        
    }
}

if($lib)
{
    For ($i = 0; $i -Lt $lib.length; $i++)
    {
        $lib[$i] = ReplaceKeywords($lib[$i])
        
    }
}


$arguments = $spec + $include + $sourceFiles + @('-o', $outputName) + $lib

# Show full command
Write-Host $compiler $arguments -ForegroundColor Cyan

# Show output file
Write-Host $outFile

Write-Host 'Compiling...' -ForegroundColor Green
& $compiler $arguments

Write-Host 'Executing!' -ForegroundColor Green
& $outFile -NoNewWindow
