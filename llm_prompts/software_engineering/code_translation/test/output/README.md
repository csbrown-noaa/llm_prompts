# Code Translation Package: SAS to R

This package contains a translation of a SAS script to R, along with a test harness designed to verify the functional equivalence of the translation.

## File Descriptions

* **`Translated_Code.R`**: The pure, line-for-line R translation of the original SAS script.
* **`TRANSLATION_SYNOPSIS.md`**: A detailed log from the translator outlining decisions, required libraries, and any assumptions made during the translation process.
* **`_TEST_HARNESS_/`**: A directory containing everything needed to test the translation's integrity.
    * **`execution_script.sh`**: A bash script to run both the original and translated code against common mock data.
    * **`mock_data/`**: Contains mock CSV files (`mock_rfvmad_sm_sta.csv`, `mock_combined_species_Master.csv`) that simulate the original data inputs.
    * **`original_code_test_hooks/`**: Contains `original_script.sas`, a modified version of the original script that uses the mock data and outputs to a local test directory. It includes the necessary macro definitions internally.
    * **`translated_code_test_hooks/`**: Contains `translated_script_test.R`, a modified version of the translated R script that uses the mock data and outputs to a local test directory.
    * **`test_outputs/`**: An empty directory where the execution script will place the outputs from both the SAS and R scripts for comparison.

## How to Verify the Translation

1.  **Prerequisites**:
    * You must have **SAS** installed and accessible from the command line (e.g., the `sas` command).
    * You must have **R** installed and accessible from the command line (e.g., the `Rscript` command).
    * Install the required R libraries by running the following command in R:
        ```R
        install.packages(c("dplyr", "readr", "lme4", "ggplot2", "writexl", "stringr", "haven"))
        ```

2.  **Run the Test Harness**:
    * Open a bash terminal (or Git Bash/WSL on Windows).
    * Navigate to the `_TEST_HARNESS_` directory.
    * Make the execution script runnable: `chmod +x execution_script.sh`
    * Run the script: `./execution_script.sh`

3.  **Compare Outputs**:
    * The script will execute both the SAS and R test files.
    * Upon completion, it will instruct you to compare the contents of the `test_outputs/original_code/` and `test_outputs/translated_code/` directories.
    * The generated files (CSVs, plots, etc.) should be functionally identical.
