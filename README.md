# AI Writing Space

A devcontainer workspace for AI-assisted research writing. Documents are
written in [Quarto](https://quarto.org/) (`.qmd`) and rendered to HTML, PDF,
or DOCX with citations, figures, and executable Python code cells.

## Start the environment

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
   (4.34 or newer) and [Visual Studio Code](https://code.visualstudio.com/).
2. In Docker Desktop, enable host networking: **Settings → Resources →
   Network → Enable host networking → Apply and restart**. (Incompatible with
   Enhanced Container Isolation — disable that if it is on.)
3. In VS Code, install the **Dev Containers** extension.
4. Open this folder and choose **Dev Containers: Reopen in Container**.
5. Once creation finishes, verify the toolchain:

   ```bash
   quarto --version
   python --version
   ```

The container runs with `--network=host`, so any service you start inside it
is reachable directly on its host port — e.g. a Quarto preview at
<http://localhost:4200>. Host services are reachable from the container via
`localhost` as well.

## Writing workflow

- Keep each paper or report in its own folder under `papers/`.
- Start from `papers/template.qmd` — it has YAML metadata, a bibliography
  hook, and a sample code cell.
- Citations use the `@key` syntax against a `.bib` file referenced in the
  YAML `bibliography:` field; the reference list is generated automatically.
- Render a document:

  ```bash
  quarto render papers/my-paper/my-paper.qmd
  ```

  Quarto infers the format from the output extension, or pass one explicitly:

  ```bash
  quarto render papers/my-paper/my-paper.qmd -o my-paper.pdf
  ```

- Preview in the browser:

  ```bash
  quarto preview papers/my-paper/my-paper.qmd
  ```

## Analysis

Python 3 with numpy, pandas, matplotlib, and scipy is available for data
analysis. Code cells in `.qmd` files execute with the container's Python and
embed tables and figures directly in the document.

## AI agents

The container preinstalls GitHub Copilot, Copilot Chat, ChatGPT (OpenAI),
Claude Code (Anthropic), and Google Antigravity. Use them for drafting,
literature synthesis, code cells, and revision — but verify every citation
and claim against the source before submitting.