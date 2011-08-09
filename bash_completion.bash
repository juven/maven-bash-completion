_mvn() 
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="-am|-amd|-B|-C|-c|-cpu|-D|-e|-emp|-ep|-f|-fae|-ff|-fn|-gs|-h|-l|-N|-npr|-npu|-nsu|-o|-P|-pl|-q|-rf|-s|-T|-t|-U|-up|-V|-v|-X"

    common_lifecycle_phases="clean|process-resources|compile|process-test-resources|test-compile|test|package|install|deploy|site"
    common_plugins="deploy|failsafe|install|site|surefire|checkstyle|javadoc|jxr|pmd|ant|antrun|archetype|assembly|dependency|enforcer|gpg|help|release|repository|source|eclipse|idea|jetty|cargo|jboss|tomcat|exec|versions"
    
    plugin_goals_deploy="deploy:deploy-file"
    plugin_goals_failsafe="failsafe:integration-test|failsafe:verify"
    plugin_goals_install="install:install-file"
    plugin_goals_site="site:site|site:deploy|site:run|site:stage|site:stage-deploy"
    plugin_goals_surefire="surefire:test"
    
    plugin_goals_checkstyle="checkstyle:checkstyle|checkstyle:check"
    plugin_goals_javadoc="javadoc:javadoc|javadoc:jar|javadoc:aggregate"
    plugin_goals_jxr="jxr:jxr"
    plugin_goals_pmd="pmd:pmd|pmd:cpd|pmd:check|pmd:cpd-check"

    plugin_goals_ant="ant:ant|ant:clean"
    plugin_goals_antrun="antrun:run"
    plugin_goals_archetype="archetype:generate|archetype:create-from-project|archetype:crawl"
    plugin_goals_assembly="archetype:single"
    plugin_goals_dependency="dependency:analyze|dependency:list|dependency:resolve|dependency:tree"
    plugin_goals_enforcer="enforcer:enforce"
    plugin_goals_gpg="gpg:sign|gpg:sign-and-deploy-file"
    plugin_goals_help="help:active-profiles|help:all-profiles|help:describe|help:effective-pom|help:effective-settings|help:evaluate|help:expressions|help:system"
    plugin_goals_release="release:clean|release:prepare|release:rollback|release:perform|release:stage|release:branch|release:update-versions"
    plugin_goals_repository="repository:bundle-create|repository:bundle-pack"
    plugin_goals_source="source:aggregate|source:jar|source:jar-no-fork"
    
    plugin_goals_eclipse="eclipse:clean|eclipse:eclipse"
    plugin_goals_idea="idea:clean|idea:idea"
    
    plugin_goals_jetty="jetty:run|jetty:run-exploded"
    plugin_goals_cargo="cargo:start|cargo:run|cargo:stop|cargo:deploy|cargo:undeploy|cargo:help"
    plugin_goals_jboss="jboss:start|jboss:stop|jboss:deploy|jboss:undeploy|jboss:redeploy"
    plugin_goals_tomcat="tomcat:start|tomcat:stop|tomcat:deploy|tomcat:undeploy|tomcat:undeploy"
    plugin_goals_exec="exec:exec|exec:java"
    plugin_goals_versions="verions:set|versons:commit|versions:revert"

    options="-Dmaven.test.skip=true|-DskipTests|-Dmaven.surefire.debug|-DenableCiProfile|-Dpmd.skip=true|-Dcheckstyle.skip=true"

    local IFS=$'|\n'

    if [[ ${cur} == -D* ]] ; then
      COMPREPLY=( $(compgen -S ' ' -W "${options}" -- ${cur}) )
    elif [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -S ' ' -- ${cur}) )
    elif [[ ${prev} == -pl ]] ; then
        if [[ ${cur} == *,* ]] ; then
            COMPREPLY=( $(compgen -d -S ',' -P "${cur%,*}," -- ${cur##*,}) )
        else
            COMPREPLY=( $(compgen -d -S ',' -- ${cur}) )
        fi
    elif [[ ${cur} == *:* ]] ; then
        for plugin in $common_plugins; do
          if [[ ${cur} == ${plugin}:* ]]; then
            var_name="plugin_goals_${plugin}"
            COMPREPLY=( $(compgen -W "${!var_name}" -S ' ' -- ${cur}) )
          fi
        done
    else
        if echo "${common_lifecycle_phases}" | /bin/grep -q "${cur}"; then
          COMPREPLY=( $(compgen -S ' ' -W "${common_lifecycle_phases}" -- ${cur}) )
        elif echo "${common_plugins}" | /bin/grep -q "${cur}"; then
          COMPREPLY=( $(compgen -S ':' -W "${common_plugins}" -- ${cur}) )
        fi
    fi
}

complete -o default -F _mvn -o nospace mvn

COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
