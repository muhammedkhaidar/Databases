--1
SELECT UPPER(airline_name) FROM airline;

--2
SELECT REPLACE(airline_name, 'Air', 'Aero') FROM airline;

--3
SELECT airline_id, COUNT(flight_id) AS flight_number FROM flights
WHERE airline_id IN(1, 2)
GROUP BY airline_id;

--4
SELECT * FROM airport
WHERE (airport_name LIKE '%Reginal%' OR airport_name LIKE '%Regional%')
AND airport_name LIKE '%Air%';

--5
SELECT 
CONCAT(first_name, ' ', last_name) AS full_name,
TO_CHAR(date_of_birth, 'FMMonth DD, YYYY') AS formatted_dob
FROM passenger;

--6
SELECT DISTINCT flight_id, flight_no FROM flights
WHERE status = 'Delayed' 
AND actual_arrival > scheduled_arrival;

--7
SELECT * FROM flights
WHERE actual_arrival > scheduled_arrival;

--8
sELECT * FROM airline
WHERE airline_country IN ('France', 'Portugal', 'Poland')
AND created_at BETWEEN '2023-11-01' AND '2024-03-31';

--9
SELECT * FROM baggage
WHERE weight_in_kg > 25
ORDER BY weight_in_kg DESC
LIMIT 3;

--10
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM passengers
ORDER BY date_of_birth DESC
LIMIT 1;

--11
SELECT booking_platform, MIN(price) AS cheapest_price
FROM booking
GROUP BY booking_platform;

--12
SELECT * FROM airline
WHERE airline_code ~ '[0-9]';

--13
SELECT * FROM airline
ORDER BY created_at DESC
LIMIT 5;

--14
SELECT * FROM baggage_check
WHERE booking_id BETWEEN 200 AND 300
AND check_result <> 'Checked';

--15
SELECT * FROM baggage_check
WHERE EXTRACT(YEAR FROM update_at) = EXTRACT(YEAR FROM created_at)
AND EXTRACT(MONTH FROM update_at) = EXTRACT(MONTH FROM created_at)
AND update_at < created_at;