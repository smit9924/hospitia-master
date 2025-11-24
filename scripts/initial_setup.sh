# Create docker network 
# Make project specific container allow to interact with eachother
docker network create dev-net || true

# Install necessary vs code extensions to setup development environment
# Install Dev Containers extension
code --install-extension ms-vscode-remote.remote-containers

# Install WSL extension
code --install-extension ms-vscode-remote.remote-wsl