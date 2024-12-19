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
    PRIMARY KEY("id")
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

-- Create finalized EUGasNet table with adjusted column names:
-- Note: TOTAL represents gas transmission volume measured in kilowatt-hours (kWh).
-- Note: Share columns ('_share') represent source composition ratios of transmitted gas (i.e., proportion from each source like LNG, Russia, Norway etc.), where all shares sum to approximately 1.0000 for each transmission.
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
    "TOTAL" NUMERIC(15,4) DEFAULT NULL, -- Total transmission amount (kWh).
    PRIMARY KEY("id")
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
    "fromCountry" AS "export_country_code", -- Rename to clarify: Export country's code.
    "toCountry" AS "import_country_code", -- Rename to clarify: Import country's code.
    "LNG_share", "PRO_share", "RU_share",
    "AZ_share", "DZ_share", "NO_share",
    "RS_share", "TR_share", "LY_share",
    "TotalFlow" AS "TOTAL" -- Rename to clarify: Following consistent naming convention for totals. Total gas transmission.
FROM "EUGasNet_staging";

-- Create indexes for query optimization:

-- (1) Single-column indexes:

-- EUGasSC indexes:
CREATE INDEX "ix_sc_country_code" ON "EUGasSC" ("country_code");
CREATE INDEX "ix_sc_date" ON "EUGasSC" ("date");

-- EUGasNet indexes:
CREATE INDEX "ix_net_date" ON "EUGasNet" ("date");
CREATE INDEX "ix_net_exporter" ON "EUGasNet" ("export_country_code");
CREATE INDEX "ix_net_importer" ON "EUGasNet" ("import_country_code");
CREATE INDEX "ix_net_ru_share" ON "EUGasNet" ("RU_share");

-- (2) Composite EUGasNet index:
CREATE INDEX "ix_net_date_ru_share" ON "EUGasNet" ("date", "RU_share");
CREATE INDEX "ix_net_ru_composite" ON "EUGasNet" ("export_country_code", "import_country_code", "RU_share", "date");

-- Create materialized view for isolating documented gas transmission routes:
/* Purpose: 
(1) Excludes routes where ALL transmissions have RU_share = 0.1111 (1/9).
(2) This view improves query performance by pre-computing routes with distinct supply-shares.

Rationale: 
When the supply-source is unknown, the dataset assigns equal shares (1/9) to all '_share' columns. 
These routes represent statistically uniform distributions (1/9 share) suggesting unknown origin, and are thus filtered out to focus on documented transmission patterns with distinct supply-shares.
*/
CREATE MATERIALIZED VIEW "documented_routes" AS
SELECT *
FROM "EUGasNet"
WHERE ("export_country_code", "import_country_code") IN (
    SELECT 
        "export_country_code",
        "import_country_code"
    FROM "EUGasNet"
    GROUP BY "export_country_code", "import_country_code"
    HAVING COUNT(*) > COUNT(*) FILTER (WHERE "RU_share" = 0.1111)
);
-- Note: View should be refreshed monthly when new data is made available:
-- REFRESH MATERIALIZED VIEW "documented_routes";