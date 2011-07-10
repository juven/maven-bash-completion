# Maven Bash Completion

Maven by default does not distribute with a Bash auto completion script, only [a very simple guide][http://maven.apache.org/guides/mini/guide-bash-m2-completion.html] is provided. This script gives you more to help your daily Maven build.

## Installation

* Download bash_completion.bash and save it a place you want, like *~/.maven_bash_completion.bash*.
* Make your login shell load the script automatically by adding the line below to *~/.bash_profile*:
`. ~/.maven_bash_completion.bash`

## Usage

To list common lifecycle phases:
`$ mvn [TAB][TAB]`

To list available options:
`$ mvn -[TAB][TAB]`

To list available goals for common used plugins:
`$ mvn help:[TAB][TAB]`


