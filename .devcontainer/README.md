# Dev Container

Open this repository in VS Code, then select **Dev Containers: Reopen in Container**.

The container uses Microsoft's Python 3.13 Bookworm Dev Container image (no Compose file or custom Dockerfile). It runs with `--network=host`, so services in the container and host can reach each other through `localhost`. On Docker Desktop, host networking requires version 4.34 or newer and must be enabled under **Settings → Resources → Network → Enable host networking**. Docker Desktop's Enhanced Container Isolation is incompatible with both host networking and Docker-in-Docker.

The Docker-in-Docker feature runs a privileged container and installs Docker Engine 29.9.0 as a separate daemon. Keep this enabled only for workspaces you trust.

The environment provides Quarto, its bundled Pandoc, TinyTeX for PDF output, Node.js 22, Jupyter, and numpy, pandas, matplotlib, and scipy for code cells. It also installs the Quarto, Python, Pylance, Jupyter, Prettier, and ESLint VS Code extensions, plus ChatGPT, Claude Code, and Google Antigravity.

LaTeX Workshop provides direct `.tex` editing and PDF preview. The post-create script installs Perl and TinyTeX's `latexmk`, exposes the TeX commands to the editor and terminals, and verifies `latexmk` runs. Workspace settings enable builds on save, SyncTeX, and output in each paper's ignored `build/` directory. See the root README for the sample workflow.

The post-create script installs the `engineering` and `find-skills` agent skills globally for Codex, Antigravity, Antigravity CLI, and Claude Code. Skill content is fetched from the upstream repositories when a new container is created.

The `ai-writing-space-home` Docker volume mounted at `/home/vscode` preserves user-level Python packages, TinyTeX, and global agent skills. Node.js and Quarto are installed into the container and are installed again when the container is rebuilt. Dev Containers also makes your host Git configuration available inside the container.
