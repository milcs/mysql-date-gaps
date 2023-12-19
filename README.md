# mysql-date-gaps
ChatGPT Practical Example: Solving MySQL Challenge by Finding Date Gaps

# Requirements

Use of Chat GPT to solve practical challange in relational database mysql.

## Description 
Assume we have many employees. 
- Each employee has many contracts.
- Each contract is composed of a start date and an end date. 
- Some employees have been working continuously, while some other employees have a gap in between two or more contracts.

We are looking to:
- Write mysql query that shows the number of days under no contracts (gap of contracts) somewhere between their first and last contract. 
- Write mysql query that gives the first ever start date for each employee since the beginning of their employment, OR since the last gap in their contracts. 

## Examples data and query results:

| employeeId | startdate   | enddate     |
|------------|-------------|-------------|
| 1          | 2020-01-01  | 2020-12-31  |
| 1          | 2021-01-01  | 2021-12-31  |
| 1          | 2022-01-01  | 2022-12-31  |
| 2          | 2020-01-01  | 2020-12-31  |
| 2          | 2021-01-01  | 2021-11-30  |
| 2          | 2022-01-01  | 2022-12-31  |
| 3          | 2020-04-30  | 2020-12-31  |
| 3          | 2021-01-01  | 2021-11-30  |

# Solution
## mysql Create/Insert Statemets

```mysql
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
```

## Query 1 - Number of days under no contracts (gap of contracts)
Query:
```sql
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
ORDER BY employeeid, startdate;
```

Results:
```
+------------+----------+
| employeeid | gap_days |
+------------+----------+
|          1 |        0 |
|          1 |        0 |
|          2 |       31 |
|          2 |        0 |
|          3 |        0 |
|          3 |        0 |
+------------+----------+
```

## Query 2 - List first ever start date for each employee since the beginning of their employment, OR since the last gap in their contracts. 

Query:
```sql
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
```

Results:
```
+------------+----------------------------+
| employeeid | first_start_date_or_since_gap|
+------------+----------------------------+
|          1 | 2020-01-01                 |
|          2 | 2020-01-01                 |
|          3 | 2020-04-30                 |
+------------+----------------------------+

```

## Use ChatGPT to do all the Work!
See the chat:
https://chat.openai.com/share/846020ed-e785-4421-a2ce-eef1eb962777
