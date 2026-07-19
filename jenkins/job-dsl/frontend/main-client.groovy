final String REPOSITORY_URL = 'https://github.com/smit9924/angular-fastapi-template-frontend.git'
final String CREDENTIALS_ID = 'github-token'
final String JENKINSFILE = 'clients/main/jenkins/Jenkinsfile'

final List<String> BRANCHES = [
    'main',
]

pipelineJob('Frontend/main-client') {

    displayName('Main Client')

    description(
        '''
        Builds and deploys the Angular Main Client.

        This job is managed by Job DSL.
        Do not edit it manually from the Jenkins UI.
        '''.stripIndent()
    )

    logRotator {
        daysToKeep(30)
        numToKeep(20)
    }

    parameters {
        choiceParam(
            'SOURCE_BRANCH',
            BRANCHES,
            'Select the source branch to build.'
        )
    }

    definition {
        cpsScm {

            scm {
                git {

                    remote {
                        url(REPOSITORY_URL)
                        credentials(CREDENTIALS_ID)
                    }

                    branch('*/${SOURCE_BRANCH}')
                }
            }

            scriptPath(JENKINSFILE)

            lightweight(true)
        }
    }
}