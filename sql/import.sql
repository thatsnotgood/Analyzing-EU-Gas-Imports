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

-- Create staging table for importing .csv file contents:
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

-- Import .csv file contents into database via staging table:
\copy "EUGasSC_staging" FROM '../../../EUGasSC.csv' WITH (FORMAT csv, HEADER true);

-- Create type for EU Gas-Market Participants:
CREATE TYPE "eu_gas_market_stakeholder" AS ENUM (
    -- EU Member States
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

CREATE TEMPORARY TABLE IF NOT EXISTS "EUGasNet_staging" (
    "date" DATE NOT NULL,
    "fromCountry" "eu_gas_market_stakeholder" NOT NULL,
    "toCountry" "eu_gas_market_stakeholder" NOT NULL,
    "LNG_share" DECIMAL(5,4) DEFAULT NULL,
    "PRO_share" DECIMAL(5,4) DEFAULT NULL,
    "RU_share" DECIMAL(5,4) DEFAULT NULL,
    "AZ_share" DECIMAL(5,4) DEFAULT NULL,
    "DZ_share" DECIMAL(5,4) DEFAULT NULL,
    "NO_share" DECIMAL(5,4) DEFAULT NULL,
    "RS_share" DECIMAL(5,4) DEFAULT NULL,
    "TR_share" DECIMAL(5,4) DEFAULT NULL,
    "LY_share" DECIMAL(5,4) DEFAULT NULL,
    "TotalFlow" INT DEFAULT NULL,
);