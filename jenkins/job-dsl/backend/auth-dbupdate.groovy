final String REPOSITORY_URL = 'https://github.com/smit9924/angular-fastapi-template-backend'
final String CREDENTIALS_ID = 'github-token'
final String JENKINSFILE = 'services/auth/jenkins/Jenkinsfile.database'

final List<String> BRANCHES = [
    'main',
    'feature/notification-service',
]

pipelineJob('Backend/auth-dbupdate') {

    displayName('Auth DB Update')

    description(
        '''
        Executes Alembic database migrations for the Auth service.

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
            'Select the source branch containing the Alembic migration.'
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