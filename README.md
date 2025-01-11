<!-- markdownlint-disable first-line-h1 -->
<!-- markdownlint-disable html -->
<!-- markdownlint-disable no-duplicate-header -->

<a name="readme-top"></a>

## Analyzing European Union Gas Imports (2016-2024)

A data-driven analysis of EU gas trade patterns, supply sources, and strategic pivots following the 2022 Russian invasion of Ukraine.

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

This project analyzes Europe's gas import, supply, and consumption data from 2016 to 2024, focusing on transmission routes, supply sources, and trade partnerships. Employing PostgreSQL and Python, the analysis investigates how the European Union and neighboring countries pivoted their gas trade strategies, particularly in response to the Russian invasion of Ukraine on February 24, 2022. Using data from the `EUGasSC` and `EUGasNet` datasets<sup><a href="#fn1">1</a></sup>, the analysis covers market elasticity, Europe's Russian gas dependency, and changes in trade partnerships before and after the war's commencement, providing insights into Europe's evolving gas market paradigm.

**Key features:**
- A custom and optimized PostgreSQL database.
- Python-based database connection adaptor and visualization.
- Statistical analysis of market restructuring and supplier diversification efforts.
- Time series analysis comparing gas trade patternships pre- and post-Russian invasion of Ukraine (`2022-02-24`).

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

### Business Rules

- All gas volumes are measured in kilowatt-hours (kWh)—1 TWh = 1,000,000,000 kWh. Volumes are daily aggregates, not instantaneous measurements at a given timeframe.
- Dataset Range: `2016-01-01` to `2024-04-30`.
- Supply ratios in transmission routes approximately sum to 1.0000 (±0.0005).
- Storage operations (withdrawal/injection) are tracked separately.
- Negative values are not permitted in any volume measurements.
- EUGasSC tracks natural gas consumption by sector: households, public buildings, industry, power generation, and other economic activities.

### Table Relationships

**EUGasSC (Supply & Consumption):**
- Primary: Daily country-level gas supply and consumption.
- Relates to: `EUGasNet` table via its `import_country_code` column on `country_code`.

**EUGasNet (Transmission & Trade Network):**
- Primary: Daily transmission route details and gas supply ratio distribution.
- Filtered Materialized View: `documented_routes` (excludes transmission rows with uniform supply ratios).
- Relates to: `EUGasSC` table via its `country_code` column on `import_country_code`.

### Materialized View: Affordances and Limitations

A route in the dataset represents a unique export-import country pair (e.g., CZ to DE). The data follows a calendar-like structure, with each route's transmissions documented daily. Each route contains multiple transmissions (rows), where each row represents a gas flow trade on a specific day.

When the country of origin for a gas flow is unknown, the dataset employs a placeholder distribution. This assigns equal shares (1/9 ratio, as there are nine supplier countries in the dataset) to all '_share' columns for that transmission in the `EUGasNet` table.

It's important to note that this uniform distribution does not reflect real-world supply patterns. In reality, we expect to observe variance in supply ratios across countries and over time.

To ensure accurate analysis of EU gas trade pivots following the invasion of Ukraine, the materialized view (denoted as `documented_routes`) excludes routes with uniform transmissions. This prevents skewing of statistical results by focusing on transmission patterns with distinct, documented supply-shares. However, this approach results in the loss of some routes (e.g., RU -> DE or DZ -> IT) where source data is not publicly available.

This filtering is necessary because placeholder values (0.1111) cannot be meaningfully distinguished from actual documented supply-shares in the statistical analysis code.

### Missing Data Handling

- Zero Values: Treated as actual zeros, not missing data.
- Storage Data: Null permitted (indicates no storage capacity data found).

### Country Codes & Geographic Coverage

**EU Member-States:**
- AT (Austria), BE (Belgium), BG (Bulgaria), CZ (Czech Republic), DE (Germany), DK (Denmark), EE (Estonia), ES (Spain), FI (Finland), FR (France), GR (Greece), HR (Croatia), HU (Hungary), IE (Ireland), IT (Italy), LT (Lithuania), LV (Latvia), NL (Netherlands), PL (Poland), PT (Portugal), RO (Romania), SI (Slovenia), SK (Slovakia).

**Market Balancing Zones:**
- BE-LU: Belgium-Luxembourg Balancing Zone<sup><a href="#fn2">2</a></sup>.
- DK-SE: Denmark-Sweden Balancing Zone<sup><a href="#fn3">3</a></sup>.
- LV-EE: Latvia-Estonia Balancing Zone<sup><a href="#fn4">4</a></sup>.

**Non-EU Trade Partners:**
- AZ (Azerbaijan), CH (Switzerland), DZ (Algeria), LY (Libya), NO (Norway), RS (Serbia), RU (Russia), TR (Türkiye).

**Notable Exclusions:**
- CY (Cyprus): Geographical isolation from European gas network.
- LU (Luxembourg): Integrated in the BE-LU balancing zone.
- MT (Malta): Limited market size and network connectivity.

The database employs ISO 3166-1 alpha-2 country codes for standard identification, with compounded codes for identifying balanced market zones. 
All gas volumes and transmission data are tracked at both the individual country and balancing zone levels.

### Updates on the Database

- Last Import: December 2024 (Version 1.0).
- Audit Log: No modifications post-import.

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
- Authors: Chuanlong Zhou, Biqing Zhu, Philippe Ciais, Simon Ben Arous, Steven J. Davis, and Zhu Liu.
- Year: 2024
- DOI: https://doi.org/10.5281/zenodo.11175364

The original datasets were accessed and modified in December 2024. The following changes were made:

- Integration into a PostgreSQL database schema.
- Implementation of custom indexes and constraints for optimization.
- Creation of analytical views, including the `documented_routes` view for filtering out transmissions consisting of uniform supply ratios.
- Development of market and transmission route queries.
- Data wrangling with Postgres and Python.
- Creation of Jupyter Notebooks for interactive analysis and result presentation.

Any use of this project must maintain both licenses appropriately: [MIT License][MITLicense_url] for the code and the [CC BY 4.0 license][CCBY4.0License_url] for the original dataset. Attribution for the original dataset must be clearly visible and accessible.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
[PostgreSQL]: https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=fff&style=flat
[PostgreSQL_url]: https://www.postgresql.org/
[Python]: https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff&style=flat
[Python_url]: https://www.python.org/
[Psycopg3]: https://img.shields.io/badge/Psycopg_3-3.2.3-4169E1.svg
[Psycopg3_url]: https://www.psycopg.org/psycopg3/
[Pandas]: https://img.shields.io/badge/pandas-150458?logo=pandas&logoColor=fff&style=flat
[Pandas_url]: https://pandas.pydata.org/

[CCBY4.0License]: https://img.shields.io/badge/License-CC%20BY%204.0-yellow.svg
[CCBY4.0License_url]: https://creativecommons.org/licenses/by/4.0/
[MITLicense]: https://img.shields.io/badge/License-MIT-yellow.svg
[MITLicense_url]: https://github.com/thatsnotgood/Analyzing-EU-Gas-Imports/blob/master/LICENSE

[Market_notebook]: https://github.com/thatsnotgood/Analyzing-EU-Gas-Imports/blob/master/notebooks/market_analysis.ipynb
[Routes_notebook]: https://github.com/thatsnotgood/Analyzing-EU-Gas-Imports/blob/master/notebooks/transmission_route_analysis.ipynb

<!-- MARKDOWN FOOTNOTES -->
## Footnotes

<div id="fn1">
<sup>1</sup>Zhou, Chuanlong, Biqing Zhu, Philippe Ciais, Simon Ben Arous, Steven J. Davis, and Zhu Liu. 2024. “EU27&UK Gas Supply-Transmission-Consumption Structures with Driving Factors of Consumption Change.” doi:10.5281/zenodo.11175364.
</div>
<div id="fn2">
<sup>2</sup>“A Single Integrated Gas Market for Belgium and Luxembourg.” 2015. Fluxys. https://www.fluxys.com/en/natural-gas-and-biomethane/shipper-journey/fluxys-belgium-and-balansys-roles-and-responsibilities (January 2, 2025).
</div>
<div id="fn3">
<sup>3</sup>“Joint Balancing Zone between Sweden and Denmark.” 2019. Energinet. https://en.energinet.dk/gas/shippers/swedegas-joint-balancing-zone/ (January 2, 2025).
</div>
<div id="fn4">
<sup>4</sup>“Baltic Regional Gas Market Coordination Group.” 2020. European Union Agency for the Cooperation of Energy Regulators. https://www.acer.europa.eu/gas/network-codes/gas-regional-initiatives/baltic-regional-gas-market-coordination-group (January 2, 2025).
</div>