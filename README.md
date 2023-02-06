# CompileCPP

Compile a CPP project. <br />
Requirement:
  - Must be executed in project folder.
  - Must have a config.json in folder.
  - config.json must have:
      - a value for "compiler"
      - a value for "sourceFolder"
<br />
You can use ${variableName} in config.json but you must implements their values in Powershell source file:
<code>
  $vars = @{
    variableName = value
    otherVariable = otherValue
  }
 </code>
