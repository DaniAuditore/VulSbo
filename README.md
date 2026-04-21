# VulSbo
University project for SBOMS

## Pipeline Execution Instructions

This project extracts SBOMs (Software Bill of Materials) and analyzes vulnerabilities from GitHub repositories using Syft and Grype.

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Setup
1. Clone this repository.
2. Build and start the Docker container:
   ```bash
   docker compose up -d
   ```
3. Enter the container to run scripts:
   ```bash
   docker compose exec jupyter bash
   ```
4. Authenticate with GitHub CLI (inside the container):
   ```bash
   gh auth login
   ```

### Execution Steps
The pipeline is divided into two extraction/processing scripts and one analysis notebook. You must run the scripts inside the Docker container.

**1. Clone Repositories**
Run the extraction script to clone the target repositories into `data/raw/repos/`. By default, it fetches up to 50 active repositories from `OWASP`:
```bash
./scripts/01-extract.sh
```

> **💡 Pro Tip (Express Version):** If you want a faster, more targeted analysis (e.g., for a smaller organization), you can pass the organization name as an argument. For example, to analyze `expressjs`:
> ```bash
> ./scripts/01-extract.sh expressjs
> ```

**2. Generate SBOMs & Vulnerability Reports**
Run the processing script to analyze the cloned repositories using Syft and Grype. Output JSON files will be stored in `data/processed/sboms/` and `data/raw/`:
```bash
./scripts/02-process.sh
```

**3. Analyze Vulnerabilities**
The Jupyter Notebook server is automatically started by Docker on port 8888.
Open your browser and navigate to `http://localhost:8888`.
Explore the quantitative analysis (severity distribution and top vulnerable packages) by opening:
```
analysis/vulnerability_metrics.ipynb
```
Run all cells in the notebook to view the metrics and visualizations.

### Cleanup
To clean up cloned repositories, delete the `data/raw/repos/` directory.
To stop the Docker container:
```bash
docker compose down
```