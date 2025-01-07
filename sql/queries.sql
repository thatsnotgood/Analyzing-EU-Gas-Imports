/* ==== Market Structure Analysis: ====
*/

-- Market elasticity analysis using HHI (Herfindahl-Hirschman Index):
-- Lower HHI indicates more elastic market (more competition).
-- Higher HHI indicates less elastic market (more concentration).
SELECT
    "import_country_code",
    COUNT(*) AS "transmissions_count",
    ROUND(AVG("TOTAL"), 2) AS "avg_transmission_volume",
    ROUND(
        AVG(
            "LNG_share"^2 + "PRO_share"^2 + "RU_share"^2 +
            "AZ_share"^2 + "DZ_share"^2 + "NO_share"^2 +
            "RS_share"^2 + "TR_share"^2 + "LY_share"^2
        ), 4
    ) AS "avg_HHI",
    ROUND(AVG("RU_share"), 4) AS "avg_RU_share",
    ROUND(AVG("LNG_share"), 4) AS "avg_LNG_share",
    ROUND(AVG("PRO_share"), 4) AS "avg_EU_share"
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
    ROUND(AVG(net."RU_share"), 2) AS "avg_RU_share",
    COUNT(DISTINCT net."export_country_code") AS "trade_partnerships_count",
    ROUND(AVG(sc."storage_withdrawal"), 2) AS "avg_withdrawal",
    ROUND(AVG(sc."storage_injection"), 2) AS "avg_injection",
    ROUND(AVG(sc."house_heating"), 2) AS "avg_heating_usage",
    ROUND(AVG(sc."industrial"), 2) AS "avg_industrial_usage"
    FROM "RU_dependent_countries" AS rdc
    JOIN "EUGasSC" AS sc
        ON rdc."import_country_code"::TEXT = sc."country_code"::TEXT
    JOIN "EUGasNet" AS net
        ON sc."country_code"::TEXT = net."import_country_code"::TEXT
        AND sc."date" = net."date"
    WHERE net."date" < '2022-02-24'
    GROUP BY sc."country_code"
    ORDER BY "avg_RU_share" DESC;

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
    ROUND(AVG(net."RU_share"), 2) AS "avg_RU_share",
    COUNT(DISTINCT net."export_country_code") AS "trade_partnerships_count",
    ROUND(AVG(sc."storage_withdrawal"), 2) AS "avg_withdrawal",
    ROUND(AVG(sc."storage_injection"), 2) AS "avg_injection",
    ROUND(AVG(sc."house_heating"), 2) AS "avg_heating_usage",
    ROUND(AVG(sc."industrial"), 2) AS "avg_industrial_usage"
    FROM "RU_non_dependent_countries" AS rndc
    JOIN "EUGasSC" AS sc
        ON rndc."import_country_code"::TEXT = sc."country_code"::TEXT
    JOIN "EUGasNet" AS net
        ON sc."country_code"::TEXT = net."import_country_code"::TEXT
        AND sc."date" = net."date"
    WHERE net."date" < '2022-02-24'
    GROUP BY sc."country_code"
    ORDER BY "avg_RU_share" DESC;

/* ==== Statistical Analysis: ====
*/

-- Analysis of RU_share distribution pre-invasion with statistical & inter-quartile ranges:
SELECT
    percentile_cont(0.10) WITHIN GROUP (
        ORDER BY "RU_share"
    )::NUMERIC(5,4) AS "P10_RU_share",
    percentile_cont(0.25) WITHIN GROUP (
        ORDER BY "RU_share"
    )::NUMERIC(5,4) AS "P25_RU_share",
    percentile_cont(0.50) WITHIN GROUP (
        ORDER BY "RU_share"
    )::NUMERIC(5,4) AS "P50_RU_share",
    percentile_cont(0.75) WITHIN GROUP (
        ORDER BY "RU_share"
    )::NUMERIC(5,4) AS "P75_RU_share",
    percentile_cont(0.90) WITHIN GROUP (
        ORDER BY "RU_share"
    )::NUMERIC(5,4) AS "P90_RU_share",
    ROUND(MIN("RU_share")::NUMERIC, 2) AS "min_RU_share",
    ROUND(AVG("RU_share")::NUMERIC, 2) AS "pre_avg_RU_share",
    ROUND(MAX("RU_share")::NUMERIC, 2) AS "max_RU_share",
    STDDEV("RU_share")::NUMERIC(5,4) AS "sd",
    VARIANCE("RU_share")::NUMERIC(5,4) AS "variance",
    COUNT(*) AS "sample_count"
    FROM "documented_routes"
    WHERE "date" < '2022-02-24'
        AND "RU_share" >= 0;

-- Analysis of RU_share distribution pre-invasion with standard deviation ranges
WITH "stats" AS (
    SELECT
        AVG("RU_share") AS "avg_RU_share",
        STDDEV("RU_share") AS "sd"
        FROM "documented_routes"
        WHERE "date" < '2022-02-24'
)
SELECT
    ("avg_RU_share" - 2 * "sd")::NUMERIC(5,4) AS "RU_share_minus_2sd",
    ("avg_RU_share" - "sd")::NUMERIC(5,4) AS "RU_share_minus_1sd",
    "avg_RU_share"::NUMERIC(5,4) AS "pre_avg_RU_share",
    ("avg_RU_share" + "sd")::NUMERIC(5,4) AS "RU_share_plus_1sd",
    ("avg_RU_share" + 2 * "sd")::NUMERIC(5,4) AS "RU_share_plus_2sd",
    "sd"::NUMERIC(5,4) AS "sd",
    (
        SELECT COUNT(*) FROM "documented_routes" WHERE "date" < '2022-02-24'
    ) AS "sample_count"
    FROM "stats";

-- Analysis of RU_share distribution post-invasion with statistical & inter-quartile ranges:
SELECT
    percentile_cont(0.10) WITHIN GROUP (
        ORDER BY "RU_share"
    )::NUMERIC(5,4) AS "P10_RU_share",
    percentile_cont(0.25) WITHIN GROUP (
        ORDER BY "RU_share"
    )::NUMERIC(5,4) AS "P25_RU_share",
    percentile_cont(0.50) WITHIN GROUP (
        ORDER BY "RU_share"
    )::NUMERIC(5,4) AS "P50_RU_share",
    percentile_cont(0.75) WITHIN GROUP (
        ORDER BY "RU_share"
    )::NUMERIC(5,4) AS "P75_RU_share",
    percentile_cont(0.90) WITHIN GROUP (
        ORDER BY "RU_share"
    )::NUMERIC(5,4) AS "P90_RU_share",
    ROUND(MIN("RU_share")::NUMERIC, 2) AS "min_RU_share",
    ROUND(AVG("RU_share")::NUMERIC, 2) AS "post_avg_RU_share",
    ROUND(MAX("RU_share")::NUMERIC, 2) AS "max_RU_share",
    STDDEV("RU_share")::NUMERIC(5,4) AS "sd",
    VARIANCE("RU_share")::NUMERIC(5,4) AS "variance",
    COUNT(*) AS "sample_count"
    FROM "documented_routes"
    WHERE "date" >= '2022-02-24'
        AND "RU_share" >= 0;

-- Analysis of RU_share distribution post-invasion with standard deviation ranges
WITH "stats" AS (
    SELECT
        AVG("RU_share") AS "avg_RU_share",
        STDDEV("RU_share") AS "sd"
        FROM "documented_routes"
        WHERE "date" >= '2022-02-24'
)
SELECT
    ("avg_RU_share" - 2 * "sd")::NUMERIC(5,4) AS "RU_share_minus_2sd",
    ("avg_RU_share" - "sd")::NUMERIC(5,4) AS "RU_share_minus_1sd",
    "avg_RU_share"::NUMERIC(5,4) AS "post_avg_RU_share",
    ("avg_RU_share" + "sd")::NUMERIC(5,4) AS "RU_share_plus_1sd",
    ("avg_RU_share" + 2 * "sd")::NUMERIC(5,4) AS "RU_share_plus_2sd",
    "sd"::NUMERIC(5,4) AS "sd",
    (
        SELECT COUNT(*) FROM "documented_routes" WHERE "date" >= '2022-02-24'
    ) AS "sample_count"
    FROM "stats";

-- T-test to compare pre and post invasion means:
WITH "pre_invasion" AS (
    SELECT
        AVG("RU_share") AS "avg_RU_share",
        STDDEV("RU_share") AS "sd",
        VARIANCE("RU_share") AS "variance",
        COUNT(*) AS "sample_count"
        FROM "documented_routes"
        WHERE "date" < '2022-02-24'
),
"post_invasion" AS (
    SELECT
        AVG("RU_share") AS "avg_RU_share",
        STDDEV("RU_share") AS "sd",
        VARIANCE("RU_share") AS "variance",
        COUNT(*) AS "sample_count"
        FROM "documented_routes"
        WHERE "date" >= '2022-02-24'
)
SELECT
    pre."avg_RU_share"::NUMERIC(5,4) AS "pre_avg_RU_share",
    post."avg_RU_share"::NUMERIC(5,4) AS "post_avg_RU_share",
    pre."sample_count" AS "pre_sample_count",
    post."sample_count" AS "post_sample_count",
    (
        pre."avg_RU_share" - post."avg_RU_share"
    ) / SQRT(
        NULLIF(
            (pre."variance" / pre."sample_count") + 
            (post."variance" / post."sample_count"),
            0
        )
    ) AS "t_statistic"
    FROM
        "pre_invasion" AS pre,
        "post_invasion" AS post;

/* ==== Relationship Analysis: ====
*/

-- Identify trading relationships with significant reduction 
-- in Russian gas dependency (pre- to post-invasion).
SELECT DISTINCT
    "export_country_code",
    "import_country_code"
    FROM "documented_routes"
    WHERE "date" < '2022-02-24'
        -- Mean RU share pre-invasion range
        AND "RU_share" >= 0.4100
EXCEPT
SELECT DISTINCT
    "export_country_code",
    "import_country_code"
    FROM "documented_routes"
    WHERE "date" >= '2022-02-24'
        -- Mean RU share post-invasion range
        AND "RU_share" BETWEEN 0.1500 AND 0.4099
    ORDER BY "export_country_code", "import_country_code";

-- Analyze how relationships transformed rather than ended:
/* Analysis focused on relationships that shifted from mean RU share 
pre-invasion to new mean RU share post-invasion, identifying significant 
strategic adaptations.

Mean RU share pre-invasion (0.4100): Shows relationships with average Russian 
gas dependency.
Mean RU share post-invasion (0.1500): Captures relationships that reduced 
dependency to average post-invasion.
*/
SELECT
    "export_country_code",
    "import_country_code",
    AVG(
        CASE WHEN "date" < '2022-02-24' THEN "RU_share" END
    )::NUMERIC(5,4) AS "pre_avg_RU_share",
    AVG(
        CASE WHEN "date" >= '2022-02-24' THEN "RU_share" END
    )::NUMERIC(5,4) AS "post_avg_RU_share",
    COUNT(CASE WHEN "date" < '2022-02-24' THEN 1 END) AS "pre_transmissions_count",
    COUNT(CASE WHEN "date" >= '2022-02-24' THEN 1 END) AS "post_transmissions_count"
    FROM "documented_routes"
    WHERE ("export_country_code", "import_country_code") IN (
        SELECT "export_country_code", "import_country_code"
            FROM "documented_routes"
            WHERE "date" < '2022-02-24'
                -- Mean RU share pre-invasion
                AND "RU_share" >= 0.4100
        EXCEPT
        SELECT "export_country_code", "import_country_code"
            FROM "documented_routes"
            WHERE "date" >= '2022-02-24'
                -- Mean RU share post-invasion range
                AND "RU_share" BETWEEN 0.1500 AND 0.4099
            )
    GROUP BY "export_country_code", "import_country_code"
    ORDER BY "export_country_code", "import_country_code";

-- Analysis of trading relationship changes:
SELECT
    CASE
        WHEN "date" < '2022-02-24' THEN 'pre_invasion'
        ELSE 'post_invasion'
    END AS "period",
    COUNT(
        DISTINCT CONCAT(
            "export_country_code", "import_country_code"
        )
    ) AS "trade_partnerships_count",
    COUNT(*) AS "transmissions_count",
    COUNT(*) / COUNT(
        DISTINCT CONCAT(
            "export_country_code", "import_country_code"
        )
    )::NUMERIC AS "avg_transmissions_per_trade_partnership"
    FROM "documented_routes"
    WHERE "RU_share" > 0.1500
    GROUP BY
        CASE
            WHEN "date" < '2022-02-24' THEN 'pre_invasion'
            ELSE 'post_invasion'
        END
    ORDER BY "period" DESC;

-- Analyze DK-SE to DE gas composition pre and post invasion:
SELECT
    CASE
        WHEN "date" < '2022-02-24' THEN 'pre_invasion'
        ELSE 'post_invasion'
    END AS "period",
    'DK-SE ----> DE' AS "route",
    AVG("RU_share")::NUMERIC(5,4) AS "avg_RU_share",
    AVG("LNG_share")::NUMERIC(5,4) AS "avg_LNG_share",
    AVG("PRO_share")::NUMERIC(5,4) AS "avg_EU_share",
    AVG("NO_share")::NUMERIC(5,4) AS "avg_NO_share",
    COUNT(*) AS "transmissions_count"
    FROM "documented_routes"
    WHERE "export_country_code" = 'DK-SE'
        AND "import_country_code" = 'DE'
    GROUP BY
        CASE
            WHEN "date" < '2022-02-24' THEN 'pre_invasion'
            ELSE 'post_invasion'
        END
    ORDER BY "period" DESC;

-- Analyze Bulgaria's export relationships pre and post invasion:
SELECT
    CASE
        WHEN "date" < '2022-02-24' THEN 'pre_invasion'
        ELSE 'post_invasion'
    END AS "period",
    CONCAT('BG ----> ', "import_country_code") AS "route",
    AVG("RU_share")::NUMERIC(5,4) AS "avg_RU_share",
    AVG("LNG_share")::NUMERIC(5,4) AS "avg_LNG_share",
    AVG("PRO_share")::NUMERIC(5,4) AS "avg_EU_share",
    AVG("NO_share")::NUMERIC(5,4) AS "avg_NO_share",
    COUNT(*) AS "transmissions_count"
    FROM "documented_routes"
    WHERE "export_country_code" = 'BG'
        AND "import_country_code" IN ('GR', 'RO')
    GROUP BY
        CASE
            WHEN "date" < '2022-02-24' THEN 'pre_invasion'
            ELSE 'post_invasion'
        END,
        "import_country_code"
    ORDER BY "route", "period" DESC;

/* ==== Data Quality Analysis: ====
*/

-- Analysis of uniform supply ratio occurrences in transmission routes:
-- Justifying the need for the "documented_routes" view defined in schema.sql.
SELECT
    "export_country_code", "import_country_code",
    COUNT(*) AS "sample_count",
    COUNT(*) FILTER (WHERE "RU_share" = 0.1111) AS "uniform_transmissions"
    FROM "EUGasNet"
    GROUP BY "export_country_code", "import_country_code"
    ORDER BY "uniform_transmissions" DESC;