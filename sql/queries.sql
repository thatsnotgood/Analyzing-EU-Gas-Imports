/*
----------------------------------------
Market Structure Analysis:
----------------------------------------
*/

-- Market elasticity analysis using HHI (Herfindahl-Hirschman Index):
-- Lower HHI indicates more elastic market (more competition).
-- Higher HHI indicates less elastic market (more concentration).
SELECT 
    "import_country_code",
    COUNT(*) AS "n_transmissions",
    ROUND(AVG("TOTAL"), 2) AS "avg_volume",
    ROUND(AVG(
        "LNG_share"^2 + "PRO_share"^2 + "RU_share"^2 +
        "AZ_share"^2 + "DZ_share"^2 + "NO_share"^2 +
        "RS_share"^2 + "TR_share"^2 + "LY_share"^2), 4) AS "avg_HHI",
    ROUND(AVG("RU_share"), 4) AS "avg_RU_dependency",
    ROUND(AVG("LNG_share"), 4) AS "avg_LNG_dependency",
    ROUND(AVG("PRO_share"), 4) AS "avg_PRO_dependency",
    ROUND(AVG("NO_share"), 4) AS "avg_NO_dependency"
    FROM "documented_routes"
    WHERE "TOTAL" > 0
    AND "date" < '2022-02-24'    -- Pre-invasion period.
    GROUP BY "import_country_code"
    ORDER BY "avg_HHI" DESC;

-- Analysis of countries highly dependent on Russian gas:
WITH "RU_dependent_countries" AS (
    SELECT "import_country_code"
        FROM "documented_routes"
        WHERE "date" < '2022-02-24'
        GROUP BY "import_country_code"
        HAVING AVG("RU_share") >= 0.3500
)
SELECT 
    sc."country_code",
    ROUND(AVG(net."RU_share"), 2) AS "RU_share",
    COUNT(DISTINCT net."export_country_code") AS "n_trading_partners",
    ROUND(AVG(sc."storage_withdrawal"), 2) AS "avg_withdrawal",
    ROUND(AVG(sc."storage_injection"), 2) AS "avg_injection",
    ROUND(AVG(sc."house_heating"), 2) AS "avg_heating_usage",
    ROUND(AVG(sc."industrial"), 2) AS "avg_industrial_usage"
    FROM "RU_dependent_countries" AS rdc
    JOIN "EUGasSC" AS sc ON rdc."import_country_code"::TEXT = sc."country_code"::TEXT
    JOIN "EUGasNet" AS net ON sc."country_code"::TEXT = net."import_country_code"::TEXT 
        AND sc."date" = net."date"
    WHERE net."date" < '2022-02-24'
    GROUP BY sc."country_code"
    ORDER BY "RU_share" DESC;

-- Analysis of countries not highly dependent on Russian gas:
WITH "RU_non_dependent_countries" AS (
    SELECT "import_country_code"
        FROM "documented_routes"
        WHERE "date" < '2022-02-24'
        GROUP BY "import_country_code"
        HAVING AVG("RU_share") < 0.3500
)
SELECT 
    sc."country_code",
    ROUND(AVG(net."RU_share"), 2) AS "RU_share",
    COUNT(DISTINCT net."export_country_code") AS "n_trading_partners",
    ROUND(AVG(sc."storage_withdrawal"), 2) AS "avg_withdrawal",
    ROUND(AVG(sc."storage_injection"), 2) AS "avg_injection",
    ROUND(AVG(sc."house_heating"), 2) AS "avg_heating_usage",
    ROUND(AVG(sc."industrial"), 2) AS "avg_industrial_usage"
    FROM "RU_non_dependent_countries" AS rndc
    JOIN "EUGasSC" AS sc ON rndc."import_country_code"::TEXT = sc."country_code"::TEXT
    JOIN "EUGasNet" AS net ON sc."country_code"::TEXT = net."import_country_code"::TEXT
        AND sc."date" = net."date"
    WHERE net."date" < '2022-02-24'
    GROUP BY sc."country_code"
    ORDER BY "RU_share" DESC;

/*
----------------------------------------
Statistical Analysis:
----------------------------------------
*/

-- Analysis of RU_share distribution pre-invasion with statistical measures:
SELECT
    percentile_cont(0.10) WITHIN GROUP (ORDER BY "RU_share")::NUMERIC(5,4) AS "P10",
    percentile_cont(0.25) WITHIN GROUP (ORDER BY "RU_share")::NUMERIC(5,4) AS "P25",
    percentile_cont(0.50) WITHIN GROUP (ORDER BY "RU_share")::NUMERIC(5,4) AS "P50",
    percentile_cont(0.75) WITHIN GROUP (ORDER BY "RU_share")::NUMERIC(5,4) AS "P75",
    percentile_cont(0.90) WITHIN GROUP (ORDER BY "RU_share")::NUMERIC(5,4) AS "P90",
    ROUND(MIN("RU_share")::NUMERIC, 2) AS "min_share",
    ROUND(AVG("RU_share")::NUMERIC, 2) AS "mean_share",
    ROUND(MAX("RU_share")::NUMERIC, 2) AS "max_share",
    STDDEV("RU_share")::NUMERIC(5,4) AS "std_dev",
    VARIANCE("RU_share")::NUMERIC(5,4) AS "variance",
    COUNT(*) AS "n_samples"
    FROM "documented_routes"
    WHERE "date" < '2022-02-24'
        AND "RU_share" >= 0;

-- Analysis of RU_share distribution pre-invasion with standard deviation intervals:
WITH "stats" AS (
    SELECT
        AVG("RU_share") AS "mean",
        STDDEV("RU_share") AS "std_dev"
        FROM "documented_routes"
        WHERE "date" < '2022-02-24'
)
SELECT
    ("mean" - 2 * "std_dev")::NUMERIC(5,4) AS "RU_share_low_2sd",
    ("mean" - "std_dev")::NUMERIC(5,4) AS "RU_share_low_1sd",
    "mean"::NUMERIC(5,4) AS "RU_share_mean",
    ("mean" + "std_dev")::NUMERIC(5,4) AS "RU_share_high_1sd",
    ("mean" + 2 * "std_dev")::NUMERIC(5,4) AS "RU_share_high_2sd",
    "std_dev"::NUMERIC(5,4) AS "RU_share_sigma",
    (SELECT COUNT(*) FROM "documented_routes" WHERE "date" >= '2022-02-24') AS "n_samples"
    FROM "stats";

-- Analysis of RU_share distribution post-invasion with statistical measures:
SELECT
    percentile_cont(0.10) WITHIN GROUP (ORDER BY "RU_share")::NUMERIC(5,4) AS "P10",
    percentile_cont(0.25) WITHIN GROUP (ORDER BY "RU_share")::NUMERIC(5,4) AS "P25",
    percentile_cont(0.50) WITHIN GROUP (ORDER BY "RU_share")::NUMERIC(5,4) AS "P50",
    percentile_cont(0.75) WITHIN GROUP (ORDER BY "RU_share")::NUMERIC(5,4) AS "P75",
    percentile_cont(0.90) WITHIN GROUP (ORDER BY "RU_share")::NUMERIC(5,4) AS "P90",
    ROUND(MIN("RU_share")::NUMERIC, 2) AS "min_share",
    ROUND(AVG("RU_share")::NUMERIC, 2) AS "mean_share",
    ROUND(MAX("RU_share")::NUMERIC, 2) AS "max_share",
    STDDEV("RU_share")::NUMERIC(5,4) AS "std_dev",
    VARIANCE("RU_share")::NUMERIC(5,4) AS "variance",
    COUNT(*) AS "n_samples"
    FROM "documented_routes"
    WHERE "date" >= '2022-02-24'
        AND "RU_share" >= 0;

-- Analysis of RU_share distribution post-invasion with standard deviation intervals:
WITH "stats" AS (
    SELECT
        AVG("RU_share") AS "mean",
        STDDEV("RU_share") AS "std_dev"
        FROM "documented_routes"
        WHERE "date" >= '2022-02-24'
)
SELECT
    ("mean" - 2 * "std_dev")::NUMERIC(5,4) AS "RU_share_low_2sd",
    ("mean" - "std_dev")::NUMERIC(5,4) AS "RU_share_low_1sd",
    "mean"::NUMERIC(5,4) AS "RU_share_mean",
    ("mean" + "std_dev")::NUMERIC(5,4) AS "RU_share_high_1sd",
    ("mean" + 2 * "std_dev")::NUMERIC(5,4) AS "RU_share_high_2sd",
    "std_dev"::NUMERIC(5,4) AS "RU_share_sigma",
    (SELECT COUNT(*) FROM "documented_routes" WHERE "date" >= '2022-02-24') AS "n_samples"
    FROM "stats";

-- T-test to compare pre and post invasion means:
WITH "pre_invasion" AS (
    SELECT
        AVG("RU_share") AS "mean",
        STDDEV("RU_share") AS "std_dev",
        VARIANCE("RU_share") AS "var",
        COUNT(*) AS "n_samples"
        FROM "documented_routes"
        WHERE "date" < '2022-02-24'
),
"post_invasion" AS (
    SELECT
        AVG("RU_share") AS "mean",
        STDDEV("RU_share") AS "std_dev",
        VARIANCE("RU_share") AS "var",
        COUNT(*) AS "n_samples"
        FROM "documented_routes"
        WHERE "date" >= '2022-02-24'
)
SELECT
    pre."mean"::NUMERIC(5,4) AS "pre_mean",
    post."mean"::NUMERIC(5,4) AS "post_mean",
    pre."n_samples" AS "pre_samples",
    post."n_samples" AS "post_samples",
    (pre."mean" - post."mean") /
    SQRT(NULLIF((pre."var" / pre."n_samples") + (post."var" / post."n_samples"), 0)) AS "t_statistic"
    FROM
        "pre_invasion" AS pre,
        "post_invasion" AS post;

/*
----------------------------------------
Relationship Analysis:
----------------------------------------
*/

-- Find trading relationships that transformed from mean RU share pre-invasion Russian dependency to mean RU share post-invasion:
-- To identify relationships that showed significant but not complete reduction in Russian gas dependency.
SELECT DISTINCT
    "export_country_code",
    "import_country_code"
    FROM "documented_routes"
    WHERE "date" < '2022-02-24'
        AND "RU_share" >= 0.4100    -- mean RU share pre-invasion
EXCEPT
SELECT DISTINCT
    "export_country_code",
    "import_country_code"
    FROM "documented_routes"
    WHERE "date" >= '2022-02-24'
        AND "RU_share" BETWEEN 0.1500 AND 0.4099    -- mean RU share post-invasion range
    ORDER BY "export_country_code", "import_country_code";

-- Analyze how relationships transformed rather than ended:
/* Analysis focused on relationships that shifted from mean RU share pre-invasion
to new mean RU share post-invasion, identifying significant strategic adaptations.

Mean RU share pre-invasion (0.4100): Shows relationships with average Russian gas dependency.
Mean RU share post-invasion (0.1500): Captures relationships that reduced dependency to average post-invasion.
*/
SELECT
    "export_country_code",
    "import_country_code",
    AVG(CASE WHEN "date" < '2022-02-24' THEN "RU_share" END)::NUMERIC(5,4) AS "pre_invasion_RU_share",
    AVG(CASE WHEN "date" >= '2022-02-24' THEN "RU_share" END)::NUMERIC(5,4) AS "post_invasion_RU_share",
    COUNT(CASE WHEN "date" < '2022-02-24' THEN 1 END) AS "pre_invasion_trades",
    COUNT(CASE WHEN "date" >= '2022-02-24' THEN 1 END) AS "post_invasion_trades"
    FROM "documented_routes"
    WHERE ("export_country_code", "import_country_code") IN (
        SELECT "export_country_code", "import_country_code"
            FROM "documented_routes"
            WHERE "date" < '2022-02-24'
                AND "RU_share" >= 0.4100    -- mean RU share pre-invasion
        EXCEPT
        SELECT "export_country_code", "import_country_code"
            FROM "documented_routes"
            WHERE "date" >= '2022-02-24'
                AND "RU_share" BETWEEN 0.1500 AND 0.4099    -- mean RU share post-invasion range
            )
    GROUP BY "export_country_code", "import_country_code"
    ORDER BY "export_country_code", "import_country_code";

-- Analysis of trading relationship changes:
SELECT
    CASE
        WHEN "date" < '2022-02-24' THEN 'Pre-invasion'
        ELSE 'Post-invasion'
    END AS "period",
    COUNT(DISTINCT CONCAT("export_country_code", "import_country_code")) AS "unique_relationships",
    COUNT(*) AS "total_transmissions",
    COUNT(*)/COUNT(DISTINCT CONCAT("export_country_code", "import_country_code"))::NUMERIC AS "avg_transmissions_per_relationship"
    FROM "documented_routes"
    WHERE "RU_share" > 0.1500
    GROUP BY
        CASE
            WHEN "date" < '2022-02-24' THEN 'Pre-invasion'
            ELSE 'Post-invasion'
        END
    ORDER BY "period" DESC;

-- Analyze DK-SE to DE gas composition pre and post invasion:
SELECT
    CASE
        WHEN "date" < '2022-02-24' THEN 'Pre-invasion'
        ELSE 'Post-invasion'
    END AS "period",
    'DK-SE ----> DE' AS "route",
    AVG("RU_share")::NUMERIC(5,4) AS "avg_RU_share",
    AVG("LNG_share")::NUMERIC(5,4) AS "avg_LNG_share",
    AVG("PRO_share")::NUMERIC(5,4) AS "avg_PRO_share",
    AVG("NO_share")::NUMERIC(5,4) AS "avg_NO_share",
    COUNT(*) AS "n_transmissions"
    FROM "documented_routes"
    WHERE "export_country_code" = 'DK-SE'
        AND "import_country_code" = 'DE'
    GROUP BY
        CASE
            WHEN "date" < '2022-02-24' THEN 'Pre-invasion'
            ELSE 'Post-invasion'
        END
    ORDER BY "period" DESC;

-- Analyze Bulgaria's export relationships pre and post invasion:
SELECT
    CASE
        WHEN "date" < '2022-02-24' THEN 'Pre-invasion'
        ELSE 'Post-invasion'
    END AS "period",
    CONCAT('BG ----> ', "import_country_code") AS "route",
    AVG("RU_share")::NUMERIC(5,4) AS "avg_RU_share",
    AVG("LNG_share")::NUMERIC(5,4) AS "avg_LNG_share",
    AVG("PRO_share")::NUMERIC(5,4) AS "avg_PRO_share",
    AVG("NO_share")::NUMERIC(5,4) AS "avg_NO_share",
    COUNT(*) AS "n_transmissions"
    FROM "documented_routes"
    WHERE "export_country_code" = 'BG'
        AND "import_country_code" IN ('GR', 'RO')
    GROUP BY
        CASE
            WHEN "date" < '2022-02-24' THEN 'Pre-invasion'
            ELSE 'Post-invasion'
        END,
        "import_country_code"
    ORDER BY "route", "period" DESC;

/*
----------------------------------------
Data Quality Analysis:
----------------------------------------
*/

-- Analysis of uniform supply ratio occurrences in transmission routes:
-- Justifying the need for the "documented_routes" view defined in schema.sql.
SELECT
    "export_country_code", "import_country_code",
    COUNT(*) AS "total_transmissions",
    COUNT(*) FILTER (WHERE "RU_share" = 0.1111) AS "uniform_transmissions"
    FROM "EUGasNet"
    GROUP BY "export_country_code", "import_country_code"
    ORDER BY "uniform_transmissions" DESC;