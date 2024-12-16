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

-- Create finalized EUGasSC table with adjusted column names:
-- Note: All integer values measured in kilowatt-hours (kWh).
CREATE TABLE IF NOT EXISTS "EUGasSC" (
    "id" SERIAL,
    "date" DATE NOT NULL,
    "country_code" "european_gas_zone" NOT NULL,
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
    "storage_withdrawal" BIGINT DEFAULT NULL, -- Gas supply withdrawn from storage.
    "storage_injection" BIGINT DEFAULT NULL, -- Gas supply injected into storage.
    "RU_from_storage" BIGINT DEFAULT NULL, -- Gas supply from stored Russia imports.
    "LNG_from_storage" BIGINT DEFAULT NULL, -- Gas supply from stored LNG imports.
    "PRO_from_storage" BIGINT DEFAULT NULL, -- Gas supply from stored European Union production.
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
    "power" INT DEFAULT NULL, -- Gas consumption in power generation.
    PRIMARY KEY ("id")
);

-- Insert data from staging table to final table "EUGasSC":
INSERT INTO "EUGasSC" (
    "date", 
    "country_code", 
    "TOTAL", 
    "RU", "LNG", "PRO", "AZ", "DZ", "NO", "RS", "LY", "TR",
    "storage_withdrawal", "storage_injection", 
    "RU_from_storage", "LNG_from_storage", "PRO_from_storage",
    "AZ_from_storage", "DZ_from_storage", "NO_from_storage", 
    "RS_from_storage", "LY_from_storage", "TR_from_storage", 
    "house_heating", "public_heating", "others", "industrial", "power"
)
SELECT 
    "date",
    "country" AS "country_code", -- Rename to clarify: the values denote country codes.
    "TOTAL", 
    "RU", "LNG", "PRO", "AZ", "DZ", "NO", "RS", "LY", "TR",
    "storageSupply" AS "storage_withdrawal", -- Rename to clarify: gas withdrawn from storage.
    "toStorage" AS "storage_injection", -- Rename to clarify: gas injected into storage.
    "RU_from_storage", "LNG_from_storage", "PRO_from_storage",
    "AZ_from_storage", "DZ_from_storage", "NO_from_storage",
    "RS_from_storage", "LY_from_storage", "TR_from_storage",
    "house_heating", "public_heating", "others", "industrial", "power"
FROM "EUGasSC_staging";

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

-- Create finalized EUGasNet table with adjusted column names:
-- Note: TOTAL represents gas transmission volume measured in kilowatt-hours (kWh).
-- Note: Share columns ('_share') represent supply-origin ratios of transmitted gas, where the sum of all shares for each transaction approximately equals 1.0000.
CREATE TABLE IF NOT EXISTS "EUGasNet" (
    "id" SERIAL,
    "date" DATE NOT NULL,
    "export_country_code" "eu_gas_market_stakeholder" NOT NULL, -- Exporting country code.
    "import_country_code" "eu_gas_market_stakeholder" NOT NULL, -- Importing country code.
    "LNG_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from LNG.
    "PRO_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from European Union production.
    "RU_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Russia production.
    "AZ_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Azerbaijan production.
    "DZ_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Algeria production.
    "NO_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Norway production.
    "RS_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Serbia production.
    "TR_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Turkey production.
    "LY_share" DECIMAL(5,4) DEFAULT NULL, -- Supply ratio from Libya production.
    "TOTAL" NUMERIC(15,4) DEFAULT NULL -- Total transmission amount (kWh).
);

-- Insert data from staging table to final table "EUGasNet":
INSERT INTO "EUGasNet" (
    "date",
    "export_country_code", "import_country_code",
    "LNG_share", "PRO_share", "RU_share",
    "AZ_share", "DZ_share", "NO_share",
    "RS_share", "TR_share", "LY_share",
    "TOTAL"
)
SELECT
    "date",
    "fromCountry" AS "export_country_code", 
    "toCountry" AS "import_country_code",
    "LNG_share", "PRO_share", "RU_share",
    "AZ_share", "DZ_share", "NO_share",
    "RS_share", "TR_share", "LY_share",
    "TotalFlow" AS "TOTAL"
FROM "EUGasNet_staging";