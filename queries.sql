use world;

-- Create the contracts table
CREATE TABLE contracts (
    employeeid INT,
    startdate DATE,
    enddate DATE
);

-- Insert data into the contracts table
INSERT INTO contracts (employeeid, startdate, enddate)
VALUES
    (1, '2020-01-01', '2020-12-31'),
    (1, '2021-01-01', '2021-12-31'),
    (1, '2022-01-01', '2022-12-31'),
    (2, '2020-01-01', '2020-12-31'),
    (2, '2021-01-01', '2021-11-30'),
    (2, '2022-01-01', '2022-12-31'),
    (3, '2020-04-30', '2020-12-31'),
    (3, '2021-01-01', '2021-11-30');

-- Days of gap (no contract) within total employment
SELECT
    employeeid,
    MAX(gap_days) AS max_gap_days
FROM (
    SELECT 
        employeeid,
        COALESCE(
            DATEDIFF(
                LEAD(startdate) OVER (PARTITION BY employeeid ORDER BY startdate), 
                enddate
            ) - 1, 
            0
        ) AS gap_days
    FROM contracts
) AS contract_gaps
GROUP BY employeeid;

-- First startdate OR startdate since gap if there is a gap
SELECT
    employeeid,
    MIN(startdate) AS first_start_date_or_since_gap
FROM (
    SELECT 
        employeeid,
        startdate,
        COALESCE(
            LAG(enddate) OVER (PARTITION BY employeeid ORDER BY startdate) + INTERVAL 1 DAY, 
            '1970-01-01'
        ) AS enddate_plus_one
    FROM contracts
) AS contract_with_lag
WHERE startdate > enddate_plus_one
    OR enddate_plus_one = '1970-01-01'
GROUP BY employeeid;
