/*
 * Creates the top-level folder structure for Jenkins.
 * This script is idempotent:
 * - If a folder doesn't exist, it will be created.
 * - If it already exists, it will be updated.
 */

folder('Frontend') {
    displayName('Frontend')
    description('Pipelines for frontend applications.')
}

folder('Backend') {
    displayName('Backend')
    description('Pipelines for backend services.')
}