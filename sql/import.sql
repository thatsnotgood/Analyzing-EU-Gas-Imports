/* Data Attribution:

This project contains information from the 'EUGasSC' and 'EUGasNet' datasets,
made available under the Creative Commons Attribution 4.0 International License. Details below:

Title: EU27 & UK gas supply-transmission-consumption structures with driving factors of consumption change
Version: 2.0
Authors: Zhou, C., Zhu, B., Ciais, P., Arous, S. B., Davis, S. J., & Liu, Z.
Year: 2024
Source: https://doi.org/10.5281/zenodo.11175364
License: Creative Commons Attribution 4.0 International (CC BY 4.0)

Changes made: 
(1) Raw CSV data transformed into an optimized PostgreSQL database with modified column names, 
    custom indexes and constraints, analytical views, and market analysis queries.
(2) Original data (EUGasSC.csv & EUGasNet.csv) was accessed and transformed into PostgreSQL schema in December 2024.
(3) Attribution is placed in this file (import.sql) as it handles the direct importation from the source CSV files.

Schema Version: 1.0 (December 2024)
*/

-- Create type for designated European Gas Zone(s):
CREATE TYPE "european_gas_zone" AS ENUM (
    'AT', 'BE', 'BG', 'CZ', 'DE', 'DK', 'SE', 'FI',
    'FR', 'GR', 'HR', 'HU', 'IE', 'IT', 'LT', 'LV',
    'EE', 'NL', 'PL', 'PT', 'RO', 'SI', 'SK', 'ES',
    'UK', -- United Kingdom, not an EU member-state.
    'BE-LU', -- Belgium-Luxembourg Balancing Zone.
    'DK-SE', -- Denmark-Sweden Balancing Zone.
    'LV-EE'  -- Latvia-Estonia Balancing Zone.
    -- Noteworthy Countries omitted: Cyprus (geo-location), Luxembourg and Malta (small market size).
); 

-- Create staging table schema for importing EUGasSC.csv file contents:
-- Note: All integer values measured in kilowatt-hours (kWh).
CREATE TEMPORARY TABLE IF NOT EXISTS "EUGasSC_staging" (
    "date" DATE NOT NULL,
    "country" "european_gas_zone" NOT NULL,
    "TOTAL" BIGINT DEFAULT NULL, -- Total gas consumption.
    "RU" BIGINT DEFAULT NULL, -- Gas supply from Russia imports.
    "LNG" BIGINT DEFAULT NULL, -- Gas supply from LNG imports.
    "PRO" BIGINT DEFAULT NULL, -- Gas supply from European Union production.
    "AZ" INT DEFAULT NULL, -- Gas supply from Azerbaijan imports.
    "DZ" INT DEFAULT NULL, -- Gas supply from Algeria imports.
    "NO" BIGINT DEFAULT NULL, -- Gas supply from Norway imports.
    "RS" INT DEFAULT NULL, -- Gas supply from Serbia imports.
    "LY" INT DEFAULT NULL, -- Gas supply from Libya imports.
    "TR" INT DEFAULT NULL, -- Gas supply from Turkey imports.
    "storageSupply" BIGINT DEFAULT NULL, -- Gas supply withdrawn from storage.
    "toStorage" BIGINT DEFAULT NULL, -- Gas supply injected into storage.
    "RU_from_storage" BIGINT DEFAULT NULL, -- Gas supply from stored Russia imports.
    "LNG_from_storage" BIGINT DEFAULT NULL, -- Gas supply from stored LNG imports.
    "PRO_from_storage" BIGINT DEFAULT NULL, -- Gas supply from stored EU production.
    "AZ_from_storage" INT DEFAULT NULL, -- Gas supply from stored Azerbaijan imports.
    "DZ_from_storage" INT DEFAULT NULL, -- Gas supply from stored Algeria imports.
    "NO_from_storage" BIGINT DEFAULT NULL, -- Gas supply from stored Norway imports.
    "RS_from_storage" INT DEFAULT NULL, -- Gas supply from stored Serbia imports.
    "LY_from_storage" INT DEFAULT NULL, -- Gas supply from stored Libya imports.
    "TR_from_storage" INT DEFAULT NULL, -- Gas supply from stored Turkey imports.
    "house_heating" BIGINT DEFAULT NULL, -- Gas consumption in household heating.
    "public_heating" INT DEFAULT NULL, -- Gas consumption in public building heating.
    "others" INT DEFAULT NULL, -- Gas consumption in other sector(s).
    "industrial" BIGINT DEFAULT NULL, -- Gas consumption in industrial sector.
    "power" INT DEFAULT NULL -- Gas consumption in power generation.
);

-- Import EUGasSC.csv file contents into database via staging table:
\copy "EUGasSC_staging" FROM '../../../EUGasSC.csv' WITH (FORMAT csv, HEADER true);

-- Create type for EU Gas-Market Participants:
CREATE TYPE "eu_gas_market_stakeholder" AS ENUM (
    -- EU member-states:
    'AT', 'BG', 'CZ', 'DE', 'ES', 'FI', 'FR', 'GR', 'HR', 'HU',
    'IE', 'IT', 'LT', 'NL', 'PL', 'PT', 'RO', 'SI', 'SK',
    'UK', -- United Kingdom, not an EU member-state.
    -- EU Gas Balancing Zones:
    'BE-LU', -- Belgium-Luxembourg Balancing Zone.
    'DK-SE', -- Denmark-Sweden Balancing Zone.
    'LV-EE', -- Latvia-Estonia Balancing Zone.
    -- Foreign EU Gas-Trade Partners:
    'AZ', 'CH', 'DZ', 'LY', 'NO', 'RS', 'RU', 'TR'
);

-- Create second staging table schema for importing EUGasNet.csv file contents:
-- Note: TOTAL represents gas transmission volume measured in kilowatt-hours (kWh).
-- Note: Share columns ('_share') represent source composition ratios of transmitted gas (i.e., proportion from each source like LNG, Russia, Norway etc.), where all shares sum to approximately 1.0000 for each transmission.
CREATE TEMPORARY TABLE IF NOT EXISTS "EUGasNet_staging" (
    "date" DATE NOT NULL,
    "fromCountry" "eu_gas_market_stakeholder" NOT NULL, -- Exporting country code.
    "toCountry" "eu_gas_market_stakeholder" NOT NULL, -- Importing country code.
    "LNG_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from LNG.
    "PRO_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from European Union production.
    "RU_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Russia production.
    "AZ_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Azerbaijan production.
    "DZ_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Algeria production.
    "NO_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Norway production.
    "RS_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Serbia production.
    "TR_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Turkey production.
    "LY_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Libya production.
    "TotalFlow" NUMERIC(15,4) DEFAULT NULL -- Total transmission amount (kWh).
);

-- Import EUGasNet.csv file contents into database via staging table:
\copy "EUGasNet_staging" FROM '../../../EUGasNet.csv' WITH (FORMAT csv, HEADER true);