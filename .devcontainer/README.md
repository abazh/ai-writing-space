# Dev Container

Open this repository in VS Code, then select **Dev Containers: Reopen in Container**.

The container is a single official `python:3-bookworm` image (no compose file, no custom Dockerfile) running with `--network=host`, so **every** service you start inside it is reachable directly on its host port — no port forwarding configuration needed, for any port. Host networking is an opt-in feature of Docker Desktop 4.34 or newer: enable it under **Settings → Resources → Network → Enable host networking** (it is incompatible with Enhanced Container Isolation). Networking also works in reverse: host services are reachable from the container via `localhost`.

It provides Python 3, the Quarto CLI, pandoc, and a small analysis stack (numpy, pandas, matplotlib, scipy). AI agent extensions — GitHub Copilot, Copilot Chat, ChatGPT (OpenAI), Claude Code (Anthropic), and Google Antigravity — are preinstalled. Dev Containers automatically copies your host Git configuration.

Your home directory is persisted in a Docker volume, so Quarto, pip packages, and editor state survive container recreation.