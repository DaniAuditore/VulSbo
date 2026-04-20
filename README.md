# VulSbo
University project for SBOMS

## Pipeline Execution Instructions

This project extracts SBOMs (Software Bill of Materials) and analyzes vulnerabilities from GitHub repositories using Syft and Grype.

### Prerequisites
- [Git](https://git-scm.com/)
- [GitHub CLI (gh)](https://cli.github.com/)
- [Syft](https://github.com/anchore/syft)
- [Grype](https://github.com/anchore/grype)
- Python 3.x
- PowerShell

### Setup
1. Clone this repository.
2. Install Python dependencies:
   ```powershell
   pip install -r requirements.txt
   ```
3. Authenticate with GitHub CLI:
   ```powershell
   gh auth login
   ```

### Execution Steps
The pipeline is divided into two extraction/processing scripts and one analysis notebook.

**1. Clone Repositories**
Run the extraction script to clone the target repositories into a temporary `data/raw/repos/` folder:
```powershell
.\scripts\01-extract.ps1
```

**2. Generate SBOMs & Vulnerability Reports**
Run the processing script to analyze the cloned repositories using Syft and Grype. Output JSON files will be stored in `data/raw/`:
```powershell
.\scripts\02-process.ps1
```

**3. Analyze Vulnerabilities**
Open the Jupyter Notebook to explore the quantitative analysis (severity distribution and top vulnerable packages):
```powershell
jupyter notebook analysis/vulnerability_metrics.ipynb
```
Run all cells in the notebook to view the metrics and visualizations.

### Cleanup
To clean up cloned repositories, delete the `data/raw/repos/` directory. JSON results are kept in `data/raw/` for future analysis.
