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

 1. Download the jenv.bat file You can inspect it with rightmouse edit
 2. Put it into a folder which is in your path so it can be called by
   3. the command line Now remove all except of one Java-Locations from
 4.   your paths. The script will edit the user enviroment variables and
   5. only works if there is a version of java added. Also it requires the
   6. same java version set as JAVA_HOME Now you can add your different
   7. java versions and swap between them No need to fear that your path
   8. gets deletet. No setx was used
   9. I hope I could help you. Else open an issue

 


