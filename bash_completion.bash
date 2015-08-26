function_exists() {
  declare -F "$1" > /dev/null
  return $?
}

function_exists _get_comp_words_by_ref || _get_comp_words_by_ref ()
{
  local exclude cur_ words_ cword_;
  if [ "$1" = "-n" ]; then
    exclude=$2;
    shift 2;
  fi;
  __git_reassemble_comp_words_by_ref "$exclude";
  cur_=${words_[cword_]};
  while [ $# -gt 0 ]; do
    case "$1" in
      cur)   cur=$cur_                 ;;
      prev)  prev=${words_[$cword_-1]} ;;
      words) words=("${words_[@]}")    ;;
      cword) cword=$cword_             ;;
    esac;
    shift;
  done
}

function_exists __ltrim_colon_completions || __ltrim_colon_completions() {
  if [[ "$1" == *:* && "$COMP_WORDBREAKS" == *:* ]]; then
    # Remove colon-word prefix from COMPREPLY items
    local colon_word=${1%${1##*:}}
    local i=${#COMPREPLY[*]}
    while [[ $((--i)) -ge 0 ]]; do
      COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"}
    done
  fi
}

function_exists __find_mvn_projects || __find_mvn_projects() {
  while read -r LINE ; do
    local withoutPom="${LINE%/pom.xml}"
    local module="${withoutPom#./}"
    if [[ -z ${module} ]]; then
      echo '.'
    else
      echo "${module}"
    fi
  done < <(find . -name 'pom.xml' -type f -not -path '*/target/*' -prune)
}

function_exists _realpath || _realpath () {
  if [[ -f "$1" ]]; then
    # file *must* exist
    if builtin cd "${1%/*}" &>/dev/null ; then
      # file *may* not be local
      # exception is ./file.ext
      # try 'cd .; cd -;' *works!*
      local tmppwd="$PWD"
      builtin cd - &> /dev/null
    else
      # file *must* be local
      local tmppwd="$PWD"
    fi
  else
    # file *cannot* exist
    return 1 # failure
  fi

  # suppress shell session termination messages on macOS
  shell_session_save() {
    false
  }

  # reassemble realpath
  echo "$tmppwd"/"${1##*/}"
  return 1 #success
}

function_exists __pom_hierarchy || __pom_hierarchy() {
  local pom
  pom=$(_realpath "pom.xml")
  POM_HIERARCHY+=( "$pom" )
  while [[ -n "$pom" ]] && command grep -q "<parent>" "$pom"; do
    ## look for a new relativePath for parent pom.xml
    local parent_pom_relative=''

    parent_pom_relative=$(command grep -o -e "<relativePath>[^<]*</relativePath>" "$pom" | command sed -e 's@^<relativePath>@' -e 's@</relativePath>@@g' )

    ## <parent> is present but not defined, assume ../pom.xml
    if [[ -z "$parent_pom_relative" ]]; then
      parent_pom_relative="../pom.xml"
    fi

    ## if pom exists continue else break
    parent_pom=$(_realpath "${pom%/*}/$parent_pom_relative")
    if [[ -n "$parent_pom" ]]; then
      pom=$parent_pom
    else
      break
    fi
    POM_HIERARCHY+=("$pom")
  done
}

_mvn_common_lifecycles() {
  cat <<-XYZ
# clean phase
pre-clean
clean
post-clean
# default lifecycle
validate
initialize
generate-sources
process-sources
generate-resources
process-resources
compile
process-classes
generate-test-sources
process-test-sources
generate-test-resources
process-test-resources
test-compile
process-test-classes
test
prepare-package
package
pre-integration-test
integration-test
post-integration-test
verify
install
deploy
# site lifecycle
pre-site
site
post-site
site-deploy
XYZ
}

# ideally, these would be a file to include, but BASH_SOURCE won't reference the absolute path to this file
# and this means that user would have to copy those file too.
_mvn_common_plugins() {
  # yup, the list is long !
  cat <<-XYZ
android:apk
android:apklib
android:clean
android:deploy
android:deploy-dependencies
android:devices
android:dex
android:emulator-start
android:emulator-stop
android:emulator-stop-all
android:generate-sources
android:help
android:instrument
android:manifest-update
android:pull
android:push
android:redeploy
android:run
android:undeploy
android:unpack
android:version-update
android:zipalign
ant:ant
ant:clean
antrun:run
appengine:backends_configure
appengine:backends_delete
appengine:backends_rollback
appengine:backends_start
appengine:backends_stop
appengine:backends_update
appengine:debug
appengine:devserver
appengine:devserver_start
appengine:devserver_stop
appengine:endpoints_get_client_lib
appengine:endpoints_get_discovery_doc
appengine:enhance
appengine:rollback
appengine:set_default_version
appengine:start_module_version
appengine:stop_module_version
appengine:update
appengine:update_cron
appengine:update_dos
appengine:update_indexes
appengine:update_queues
appengine:vacuum_indexes
archetype:crawl
archetype:create-from-project
archetype:generate
assembly:assembly
assembly:single
build-helper:add-resource
build-helper:add-source
build-helper:add-test-resource
build-helper:add-test-source
build-helper:attach-artifact
build-helper:bsh-property
build-helper:cpu-count
build-helper:help
build-helper:local-ip
build-helper:maven-version
build-helper:parse-version
build-helper:regex-properties
build-helper:regex-property
build-helper:released-version
build-helper:remove-project-artifact
build-helper:reserve-network-port
build-helper:timestamp-property
buildnumber:create
buildnumber:create-timestamp
buildnumber:help
buildnumber:hgchangeset
cargo:deploy
cargo:help
cargo:run
cargo:start
cargo:stop
cargo:undeploy
checkstyle:check
checkstyle:checkstyle
cobertura:cobertura
dependency:analyze
dependency:analyze-dep-mgt
dependency:analyze-duplicate
dependency:analyze-only
dependency:analyze-report
dependency:build-classpath
dependency:copy
dependency:copy-dependencies
dependency:get
dependency:go-offline
dependency:help
dependency:list
dependency:list-repositories
dependency:properties
dependency:purge-local-repository
dependency:resolve
dependency:resolve-plugins
dependency:sources
dependency:tree
dependency:unpack
dependency:unpack-dependencies
deploy:deploy-file
ear:ear
ear:generate-application-xml
eclipse:clean
eclipse:eclipse
ejb:ejb
enforcer:display-info
enforcer:enforce
editorconfig:format
editorconfig:validate
exec:exec
exec:java
failsafe:integration-test
failsafe:verify
findbugs:findbugs
findbugs:gui
findbugs:help
flyway:baseline
flyway:clean
flyway:info
flyway:migrate
flyway:repair
flyway:validate
formatter:format
formatter:help
formatter:validate
gpg:sign
gpg:sign-and-deploy-file
grails:clean
grails:config-directories
grails:console
grails:create-controller
grails:create-domain-class
grails:create-integration-test
grails:create-pom
grails:create-script
grails:create-service
grails:create-tag-lib
grails:create-unit-test
grails:exec
grails:generate-all
grails:generate-controller
grails:generate-views
grails:help
grails:init
grails:init-plugin
grails:install-templates
grails:list-plugins
grails:maven-clean
grails:maven-compile
grails:maven-functional-test
grails:maven-grails-app-war
grails:maven-test
grails:maven-war
grails:package
grails:package-plugin
grails:run-app
grails:run-app-https
grails:run-war
grails:set-version
grails:test-app
grails:upgrade
grails:validate
grails:validate-plugin
grails:war
gwt:browser
gwt:clean
gwt:compile
gwt:compile-report
gwt:css
gwt:debug
gwt:eclipse
gwt:eclipseTest
gwt:generateAsync
gwt:help
gwt:i18n
gwt:mergewebxml
gwt:resources
gwt:run
gwt:run-codeserver
gwt:sdkInstall
gwt:source-jar
gwt:soyc
gwt:test
help:active-profiles
help:all-profiles
help:describe
help:effective-pom
help:effective-settings
help:evaluate
help:expressions
help:help
help:system
hibernate3:hbm2ddl
hibernate3:help
idea:clean
idea:idea
install:install-file
jacoco:check
jacoco:dump
jacoco:help
jacoco:instrument
jacoco:merge
jacoco:prepare-agent
jacoco:prepare-agent-integration
jacoco:report
jacoco:report-integration
jacoco:restore-instrumented-classes
javadoc:aggregate
javadoc:jar
javadoc:javadoc
jboss-as:add-resource
jboss-as:deploy
jboss-as:deploy-artifact
jboss-as:deploy-only
jboss-as:execute-commands
jboss-as:redeploy
jboss-as:redeploy-only
jboss-as:run
jboss-as:shutdown
jboss-as:start
jboss-as:undeploy
jboss-as:undeploy-artifact
jboss:deploy
jboss:redeploy
jboss:start
jboss:stop
jboss:undeploy
jetty:deploy-war
jetty:effective-web-xml
jetty:run
jetty:run-exploded
jetty:run-forked
jetty:run-war
jetty:start
jetty:stop
jgitflow:build-number
jgitflow:feature-finish
jgitflow:feature-start
jgitflow:hotfix-finish
jgitflow:hotfix-start
jgitflow:release-finish
jgitflow:release-start
jxr:jxr
liberty:create-server
liberty:deploy
liberty:dump-server
liberty:java-dump-server
liberty:package-server
liberty:run-server
liberty:start-server
liberty:stop-server
liberty:undeploy
license:check
license:format
liquibase:changelogSync
liquibase:changelogSyncSQL
liquibase:clearCheckSums
liquibase:dbDoc
liquibase:diff
liquibase:dropAll
liquibase:help
liquibase:listLocks
liquibase:migrate
liquibase:migrateSQL
liquibase:releaseLocks
liquibase:rollback
liquibase:rollbackSQL
liquibase:status
liquibase:tag
liquibase:update
liquibase:updateSQL
liquibase:updateTestingRollback
nexus-staging:close
nexus-staging:deploy
nexus-staging:deploy-staged
nexus-staging:deploy-staged-repository
nexus-staging:drop
nexus-staging:help
nexus-staging:promote
nexus-staging:rc-close
nexus-staging:rc-drop
nexus-staging:rc-list
nexus-staging:rc-list-profiles
nexus-staging:rc-promote
nexus-staging:rc-release
nexus-staging:release
pmd:check
pmd:cpd
pmd:cpd-check
pmd:pmd
properties:read-project-properties
properties:set-system-properties
properties:write-active-profile-properties
properties:write-project-properties
release:branch
release:clean
release:perform
release:prepare
release:rollback
release:stage
release:update-versions
repository:bundle-create
repository:bundle-pack
repository:help
scala:add-source
scala:cc
scala:cctest
scala:compile
scala:console
scala:doc
scala:doc-jar
scala:help
scala:run
scala:script
scala:testCompile
scm:add
scm:checkin
scm:checkout
scm:status
scm:update
site:deploy
site:run
site:site
site:stage
site:stage-deploy
sonar:help
sonar:sonar
source:aggregate
source:jar
source:jar-no-fork
spotbugs:check
spotbugs:gui
spotbugs:help
spotbugs:spotbugs
spring-boot:repackage
spring-boot:run
surefire:test
tomcat6:deploy
tomcat6:help
tomcat6:redeploy
tomcat6:run
tomcat6:run-war
tomcat6:run-war-only
tomcat6:stop
tomcat6:undeploy
tomcat7:deploy
tomcat7:help
tomcat7:redeploy
tomcat7:run
tomcat7:run-war
tomcat7:run-war-only
tomcat7:undeploy
tomcat:deploy
tomcat:help
tomcat:start
tomcat:stop
tomcat:undeploy
versions:commit
versions:display-dependency-updates
versions:display-plugin-updates
versions:display-property-updates
versions:lock-snapshots
versions:resolve-ranges
versions:revert
versions:set
versions:unlock-snapshots
versions:update-child-modules
versions:update-parent
versions:update-properties
versions:use-latest-releases
versions:use-latest-snapshots
versions:use-latest-versions
versions:use-next-releases
versions:use-next-snapshots
versions:use-next-versions
versions:use-releases
vertx:fatJar
vertx:init
vertx:pullInDeps
vertx:runMod
war:exploded
war:inplace
war:manifest
war:war
wildfly:add-resource
wildfly:deploy
wildfly:deploy-artifact
wildfly:deploy-only
wildfly:execute-commands
wildfly:redeploy
wildfly:redeploy-only
wildfly:run
wildfly:shutdown
wildfly:start
wildfly:undeploy
wildfly:undeploy-artifact
XYZ
}

_mvn() {
    local cur prev
    COMPREPLY=()
    _get_comp_words_by_ref -n : cur prev
    if [[ ${cur} == -D* ]] ; then
      local -a options=( "-Dmaven.test.skip=true" "-DskipTests" "-DskipITs" "-Dtest" "-Dit.test" "-DfailIfNoTests" "-Dmaven.surefire.debug"
                         "-DenableCiProfile" "-Dpmd.skip=true" "-Dcheckstyle.skip=true" "-Dtycho.mode=maven" "-Dmaven.javadoc.skip=true"
                         "-Dgwt.compiler.skip" "-Dcobertura.skip=true" "-Dfindbugs.skip=true" "-DperformRelease=true" "-Dgpg.skip=true"
                         "-DforkCount" )
      mapfile -t COMPREPLY < <(compgen -S ' ' -W "${options[*]}" -- "${cur}" )
    elif [[ ${prev} == -P || ${prev} == --activate-profiles ]] ; then
      local -a POM_HIERARCHY=( ~/.m2/settings.xml )
      __pom_hierarchy
      # let grep check if file exists
      # -s, --no-messages         suppress error messag
      # -o == only matching
      local -a profiles
      mapfile -t profiles < <(command grep -s -e '<profile>' -A 1 "${POM_HIERARCHY[@]}" |
                              command grep -E -o -e '<id>[^<]+</id>' |
                              command sed  -E -e 's@^<id>@@g' -e 's@</id>$@@g')
      mapfile -t COMPREPLY < <(
        if [[ "${cur}" == *,* ]] ; then
          compgen -S ',' -W "${profiles[*]}" -P "${cur%,*}," -- "${cur##*,}"
        else
          compgen -S ',' -W "${profiles[*]}" -- "${cur}"
        fi
      )
    elif [[ ${cur} == --* ]] ; then
      local -a long_options=(
        "--also-make" "--also-make-dependents" "--batch-mode" "--strict-checksums" "--lax-checksums" "--check-plugin-updates"
        "--define" "--errors" "--encrypt-master-password" "--encrypt-password" "--file" "--fail-at-end" "--fail-fast"
        "--fail-never" "--global-settings" "--help" "--log-file" "--non-recursive" "--no-plugin-registry" "--no-plugin-updates"
        "--no-snapshot-updates" "--offline" "--activate-profiles" "--projects" "--quiet" "--resume-from" "--settings"
        "--threads" "--toolchains" "--update-snapshots" "--update-plugins" "--show-version" "--version" "--debug"
      )
      mapfile -t COMPREPLY < <(compgen -S ' ' -W "${long_options[*]}" -- "${cur}" )
    elif [[ ${cur} == -* ]] ; then
      local -a short_options=(
        "-am" "-amd" "-B" "-C" "-c" "-cpu" "-D" "-e" "-emp" "-ep" "-f"
        "-fae" "-ff" "-fn" "-gs" "-h" "-l" "-N" "-npr" "-npu" "-nsu" "-o" "-P" "-pl" "-q" "-rf"
        "-s" "-T" "-t" "-U" "-up" "-V" "-v" "-X" )
      mapfile -t COMPREPLY < <(compgen -S ' ' -W "${short_options[*]}" -- "${cur}" )
    elif [[ ${prev} == -pl ]] ; then
      local -a maven_projects
      mapfile -t maven_projects < <(__find_mvn_projects)
      mapfile -t COMPREPLY < <(
        if [[ "${cur}" == *,* ]] ; then
          compgen -W "${maven_projects[*]}" -S ',' -P "${cur%,*}," -- "${cur##*,}"
        else
          compgen -W "${maven_projects[*]}" -S ',' -- "${cur}"
        fi
      )
    elif [[ ${prev} == -rf || ${prev} == --resume-from ]] ; then
      mapfile -t COMPREPLY < <(compgen -d -S ' ' -- "${cur}")
    else
      #
      # first we print the word to complete,
      #  then we remove comment
      #  then we remove spaces at beginning/end of lines
      #  then we ignore empty line
      #  then we filter
      while read -r line; do
        if [[ -n "$line" && "$line" == "$cur"* ]]; then
          COMPREPLY+=( "$line" )
        fi
      done < <(
        {
          if [[ "$cur" == *:* ]]; then
            _mvn_common_plugins
          else
            _mvn_common_lifecycles
            # we remove the goal part, but we leave the ':' (serve as a way to identify a plugin versus
            # a phase). Bash will also remove duplicate and sort, we don't have to sort --unique.
            _mvn_common_plugins | sed -E -e 's@:.+@:@g'
          fi
        } | command sed -E -e 's@^\s*#.*$@@g' -e 's@^\s+@@g' -e 's@\s+$@@g'
      )
    fi
    __ltrim_colon_completions "$cur"
}

complete -o default -F _mvn -o nospace mvn
complete -o default -F _mvn -o nospace mvnDebug
complete -o default -F _mvn -o nospace mvnw
