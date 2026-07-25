final String REPOSITORY_URL = 'https://github.com/smit9924/angular-fastapi-template-backend'
final String CREDENTIALS_ID = 'github-token'
final String JENKINSFILE = 'services/auth/jenkins/Jenkinsfile'

final List<String> BRANCHES = [
    'main',
]

pipelineJob('Backend/auth') {

    displayName('Auth')

    description(
        '''
        Builds and deploys the Auth service.

        This job is managed by Job DSL.
        Do not edit it manually from the Jenkins UI.
        '''.stripIndent()
    )

    logRotator {
        daysToKeep(1)
        numToKeep(2)
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