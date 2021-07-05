# JEnv for Windows
##change your current Java version with 3 words

 - JEnv allows you to change your current JDK Version.
 - This is helpful for testing or if you have projects requiring
   different versions of java
 - For example you can build a gradle project
   which requires java8 without changing your enviroment variables and
   than switch back to work with java15
 - Its written in cmd and powershell to change the enviroment variables. Was painful :(

I hope you enjoy it

1) **Adds a new JDK to you list:**
*jenv add `<name> <path>`*
Example: `jenv add jdk15 D:\Programme\Java\jdk-15.0.1`
 

 
2) **Change your %PATH% and your %JAVA_HOME% for the current session**
 *jenv use `<name>`*
 Example: jenv use jdk15
 
3) **Change your %PATH% and your %JAVA_HOME% permanently**
 *jenv change `<name>`*
 Example: jenv change jdk15

## Installation

 1. Download the jenv.bat file. You can inspect it with rightmouse edit to see if its malicious
 
 2. Put it into a folder which is in your path so it can be called by
    the command line.
 
 3. Now remove all except of one Java-Locations from
    your paths. The script will edit the user enviroment variables and
    only works if there is a version of java added.
 
 4. Also it requires the same Java enviroment as JAVA_HOME.
 
 5. Now you can add your different java versions and swap between them.
 
 6. No need to fear that your path gets deleted. No setx was used
 
 7. I hope I could help you. Else open an issue

 


