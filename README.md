
# JEnv for Windows
## change your current Java version with 3 words

 - JEnv allows you to change your current JDK Version.
 - This is helpful for testing or if you have projects requiring
   different versions of java
 - For example you can build a gradle project
   which requires java8 without changing your enviroment variables and
   than switch back to work with java15
 - It's written in cmd and powershell so it can change the enviroment variables and can run on any windows10.

I hope you enjoy it

1) **Adds a new Java  environment**  
*jenv add `<name> <path>`*  
Example: `jenv add jdk15 D:\Programme\Java\jdk-15.0.1`
 
2) **Change your %PATH% and your %JAVA_HOME% for the current session**  
 *jenv use `<name>`*  
 Example: jenv use jdk15
 
3) **Change your %PATH% and your %JAVA_HOME% permanently**  
 *jenv change `<name>`*  
 Example: jenv change jdk15
 
4) **List all your Java environments**  
 *jenv list*  
 Example: jenv list

 5) **Remove an exsiting JDK from the JEnv list**  
 *jenv remove `<name>`*  
 Example: jenv remove jdk15

## Installation

 1. Download the jenv.bat and the jenv.ps1 file. You can inspect it with rightmouse edit to see if its malicious
 
 2. Put it into a folder which is in your path so it can be called by the command line.
 
 3. Now you can add your different java versions and swap between them.

 4. Call the jenv.bat file. Not the PowerShell file!
 
 5. I hope I could help you. Else open an issue

## Technical Details

You can also call the jenv.ps1 script from powershell.  
You cannot call the ps1 script from cmd  
An additional parameter to the PowerShell script was added. "--output" alias "-o" will create the tmp files for the batch. See images below  

![SystemEnvironmentVariablesHirachyShell](https://user-images.githubusercontent.com/55546882/130204196-1a800310-4454-49bd-8d80-161b0e7cca3f.PNG)

![SystemEnvironmentVariablesHirachyPowerShell PNG](https://user-images.githubusercontent.com/55546882/130204185-b54368cc-34db-40d1-a707-4c5477ca236b.PNG)
