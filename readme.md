# Maven Bash Completion

Maven by default does not distribute with a Bash auto completion script, only [a very simple guide](http://maven.apache.org/guides/mini/guide-bash-m2-completion.html) is provided. This script gives you more to help your daily Maven build.

## Installation

* Download bash_completion.bash and save it to any place you want, like *~/.maven_bash_completion.bash*.
* Make your login shell load the script automatically by adding the line below to *~/.bash_profile* (note the space after dot):  
`. ~/.maven_bash_completion.bash`

## Usage

To list common lifecycle phases:  
`$ mvn [TAB][TAB]` (list all common used lifecycle phases)  
`$ mvn cl[TAB][TAB]` (complete to 'clean')  

To list prefix of common used plugins:  
`$ mvn ar[TAB][TAB]` (complete to 'archetype:')  
`$ mvn depe[TAB][TAB]` (complete to 'dependency:')  

To list available goals for common used plugins:  
`$ mvn help:[TAB][TAB]` (list all available goals of maven-help-plugin)  
`$ mvn dependency:[TAB][TAB]` (list all available goals of maven-dependency-plugin)  

To list available options:  
`$ mvn -[TAB][TAB]`  

To list -D options (like -DskipTests):  
`$ mvn -D[TAB][TAB]`  

To list available profiles:  
`$ mvn -P[TAB][TAB]`