<!-- markdownlint-disable first-line-h1 -->
<!-- markdownlint-disable html -->
<!-- markdownlint-disable no-duplicate-header -->

<a name="readme-top"></a>

## Analyzing European Union Gas Imports

<div align="center">

**Built With:**

[![PostgreSQL][PostgreSQL]][PostgreSQL_url]
[![Python][Python]][Python_url]
[![Psycopg3][Psycopg3]][Psycopg3_url]
[![Pandas][Pandas]][Pandas_url]

**Licenses:**

[![MIT License][MITLicense]][MITLicense_url]
[![CC BY 4.0][CCBY4.0License]][CCBY4.0License_url]

</div>

## Project Overview

## Data Source

## Database

---

**Schema:**

---

**ENUM Types:**

---

**Unique & Check Constraints:**

---

**Indexes:**

---

**Performance Optimization:**

---

**Materialized View:**

---

**Sample Queries:**

---

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Data Dictionary

## Analysis & Visualizations

---

**Market Analysis:**

Check out the full analysis in the [Market Notebook][Market_notebook].

---

**Transmission Route Analysis:**

Check out the full analysis in the [Transmission Routes Notebook][Routes_notebook].

---

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Installation & Setup

## Project Structure

## License

**This project is under dual licensing:**

**Code and Analysis:**

The database schema, SQL queries, Python script, Jupyter Notebooks, and all other original work in this repository are released under the [MIT License][MITLicense_url].

**Dataset Attribution:**

This project employs data from the EUGasSC and EUGasNet datasets, which are released under the Creative Commons Attribution 4.0 International [(CC BY 4.0) license][CCBY4.0License_url].

For more context about this dataset and its methodology, you can read the authors' original [article](https://essd.copernicus.org/articles/15/949/2023/essd-15-949-2023.html). 

Dataset details:

- Title: EU27 & UK gas supply-transmission-consumption structures with driving factors of consumption change
- Version: 2.0
- Authors: Zhou, C., Zhu, B., Ciais, P., Arous, S. B., Davis, S. J., & Liu, Z.
- Year: 2024
- DOI: https://doi.org/10.5281/zenodo.11175364

The original datasets were accessed and modified in December 2024. The following changes were made:

- Integration into a PostgreSQL database schema.
- Implementation of custom indexes and constraints for optimization.
- Creation of analytical views.
- Development of market and transmission route queries.

Any use of this project must maintain both licenses appropriately: [MIT License][MITLicense_url] for code and the [CC BY 4.0 license][CCBY4.0License_url] for the original dataset. Attribution for the original dataset must be clearly visible and accessible.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->

[PostgreSQL]: https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=fff&style=flat
[PostgreSQL_url]: https://www.postgresql.org/
[Python]: https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff&style=flat
[Python_url]: https://www.python.org/
[Psycopg3]: https://img.shields.io/badge/Psycopg3-3.2.3-4169E1.svg
[Psycopg3_url]: https://www.psycopg.org/psycopg3/
[Pandas]: https://img.shields.io/badge/pandas-150458?logo=pandas&logoColor=fff&style=flat
[Pandas_url]: https://pandas.pydata.org/

[CCBY4.0License]: https://img.shields.io/badge/License-CC%20BY%204.0-yellow.svg
[CCBY4.0License_url]: https://creativecommons.org/licenses/by/4.0/
[MITLicense]: https://img.shields.io/badge/License-MIT-yellow.svg
[MITLicense_url]: https://github.com/thatsnotgood/Analyzing-EU-Gas-Imports/blob/master/LICENSE

[Market_notebook]: https://github.com/thatsnotgood/Analyzing-EU-Gas-Imports/blob/master/notebooks/market_analysis.ipynb
[Routes_notebook]: https://github.com/thatsnotgood/Analyzing-EU-Gas-Imports/blob/master/notebooks/transmission_route_analysis.ipynb