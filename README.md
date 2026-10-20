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
   quarto check jupyter
   ```

The container uses host networking so services in the container and on the
host can reach each other through `localhost`. On Docker Desktop this requires
version 4.34 or newer and enabling **Settings → Resources → Network → Enable
host networking**. Docker-in-Docker installs Docker Engine 29.9.0 and runs the
container in privileged mode. Use this setup with repositories you trust.

## Shared template and personal work

This repository is the shared environment for students. Reusable starter files
live in tracked `templates/`. Personal papers belong in `papers/`, and temporary
experiments can go in `scratch/`; both folders are ignored by Git.

Ignored work is not backed up or versioned by this repository. Keep long-term
or assessed work in a separate Git repository with its own backup.

## Writing workflow

- Keep each paper or report in its own folder under `papers/`.
- Copy `templates/template.qmd` and `templates/refs.bib` into your paper
  folder — they provide YAML metadata, sample citations, and a code cell.

  ```bash
  mkdir -p papers/my-paper
  cp templates/template.qmd papers/my-paper/my-paper.qmd
  cp templates/refs.bib papers/my-paper/refs.bib
  ```
- Rendered documents go to `_site/`, leaving source folders clear of build
  output.
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

## LaTeX editing and PDF preview

For direct LaTeX writing, copy `templates/latex-template/` into your own
folder under `papers/`:

```bash
mkdir -p papers
cp -R templates/latex-template papers/my-latex-paper
```
 LaTeX Workshop builds on save using TinyTeX and
`latexmk`, with PDF and auxiliary files in that paper's ignored `build/` folder.

1. Open `papers/my-latex-paper/main.tex` and save it, or run **LaTeX Workshop:
   Build LaTeX project** from the Command Palette.
2. Run **LaTeX Workshop: View LaTeX PDF file** and move the PDF tab beside the
   source editor. The preview refreshes after successful builds.
3. Use **LaTeX Workshop: SyncTeX from cursor** to locate the source position
   in the PDF. The viewer also supports navigation back to the LaTeX source.

To verify the compiler from a terminal:

```bash
latexmk -v
cd papers/my-latex-paper
latexmk -pdf -synctex=1 -interaction=nonstopmode -halt-on-error -outdir=build main.tex
```

If a custom template needs additional TeX packages, install them with
`tlmgr install <package>`. Quarto continues to build `.qmd` documents separately
into `_site/`; its generated PDFs can also be opened in LaTeX Workshop's viewer.
This provides local editing and preview; simultaneous collaboration and tracked
changes are not included. Current LaTeX Workshop releases require VS Code 1.114
or newer.

## Analysis

Python 3.13 with Jupyter, numpy, pandas, matplotlib, and scipy is available for
data analysis. Code cells in `.qmd` files execute with the container's Python
and embed tables and figures directly in the document. Quarto includes the
Pandoc version it uses; the environment also installs TinyTeX for PDF output.

## AI agents

The container preinstalls ChatGPT (OpenAI), Claude Code (Anthropic), and
Google Antigravity extensions. It also installs the `engineering` and
`find-skills` agent skills globally for Codex, Antigravity, Antigravity CLI,
and Claude Code. Sign in to the agent services you use. Verify every citation
and claim against its source before submitting.
