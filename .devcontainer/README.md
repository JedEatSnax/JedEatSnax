# Podman + SELinux Dev Container Setup

1. Git must be initialized if the repository is newly created
```bash
git init
```

2. Create a Podman wrapper
```bash
mkdir -p ~/.local/bin

cat > ~/.local/bin/podman-devcontainer <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "buildx" && "${2:-}" == "build" ]]; then
    shift 2
    exec /usr/bin/podman buildx build \
        --security-opt=label=disable \
        "$@"
fi

exec /usr/bin/podman "$@"
EOF

chmod +x ~/.local/bin/podman-devcontainer
```

3. Configure VS Code settings to use wrapper
```json
{
    "dev.containers.dockerPath": "/home/jed/.local/bin/podman-devcontainer"
}
```