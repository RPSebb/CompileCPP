# CompileCPP

Compile a CPP project.
Must be executed in project folder.
Must have a config.json in folder.
config.json must have:
  - a value for "compiler"
  - a value for "sourceFolder"
You can use ${variableName} in config.json but you must implements their values in Powershell source file ($vars).
