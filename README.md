
# JEnv for Windows Version 2 is here.
### A complete rewrite of V.1
## change your current Java version with 3 words

 - JEnv allows you to change your current JDK Version.
 - This is helpful for testing or if you have projects requiring
   different versions of java
 - For example you can build a gradle project
   which requires java8 without changing your environment variables and
   then switch back to work with java15
 - It's written in cmd and powershell so it can change the environment variables and can run on any Windows-10+.

I hope you enjoy it

## Installation
1) **Clone this repository**
2) **Add it to the path**
3) **Run `jenv` once so the script can do the rest**
4) **If your using cmd you need to call the batch file. If you use powershell its recommended to do so as well but it should also work if you call /src/jenv.ps1**
5) **Some reported problems putting JEnv into their C:/Programs folder due to required admin rights**
6) **I hope I could help you. Else open an issue**

## Usage (Note: local overwrites change. use overwrites local)
1) **Add a new Java  environment (requires absolute path)**  
*jenv add `<name> <path>`*  
Example: `jenv add jdk15 D:\Programme\Java\jdk-15.0.1`
 
2) **Change your java version for the current session**  
*jenv use `<name>`*  
Example: `jenv use jdk15`
 
3) **Clear the java version for the current session**  
*jenv use remove*  
Example: `jenv use remove`

4) **Change your java version globally**  
*jenv change `<name>`*  
Example: `jenv change jdk15`

5) **Always use this java version in this folder**
*jenv local `<name>`*  
Example: `jenv local jdk15  `

6) **Clear the java version for this folder**  
*jenv local remove*  
Example: `jenv local remove` 
 
7) **List all your Java environments**  
*jenv list*  
Example: `jenv list`

8) **Remove an existing JDK from the JEnv list**  
*jenv remove `<name>`*  
Example: `jenv remove jdk15`

 ## How does this work?
This script creates a java.bat file that calls the java.exe with the correct version
When the ps script changes env vars they get exported to tmp files and applied by the batch file
An additional parameter to the PowerShell script was added. "--output" alias "-o" will create the tmp files for the batch. See images below  

![SystemEnvironmentVariablesHirachyShell](https://user-images.githubusercontent.com/55546882/130204196-1a800310-4454-49bd-8d80-161b0e7cca3f.PNG)

![SystemEnvironmentVariablesHirachyPowerShell PNG](https://user-images.githubusercontent.com/55546882/130204185-b54368cc-34db-40d1-a707-4c5477ca236b.PNG)