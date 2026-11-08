-- 1. Create an index on the actual_departure column in the flights table.
CREATE INDEX idx_flights_actual_departure 
ON flights(actual_departure);


-- 2. Create a unique index to ensure flight_no and scheduled_departure combinations are unique.
CREATE UNIQUE INDEX idx_flights_flight_no_sched_dep 
ON flights(flight_no, scheduled_departure);


-- 3. Create a composite index on the departure_airport_id and arrival_airport_id columns.
CREATE INDEX idx_flights_dep_arr_airports 
ON flights(departure_airport_id, arrival_airport_id);


-- 4. Evaluate the difference in query performance with and without indexes. Measure performance differences.
SELECT * FROM flights 
WHERE departure_airport_id = 10 AND arrival_airport_id = 11;

SELECT * FROM 

-- 5. Use EXPLAIN ANALYZE to check index usage in a query filtering by departure_airport and arrival_airport.
EXPLAIN ANALYZE 
SELECT * FROM flights 
WHERE departure_airport_id = 10 AND arrival_airport_id = 11;


-- 6. Create a unique index for the passport_number of the Passengers table. Check if created. Insert two new passengers.
CREATE UNIQUE INDEX idx_passengers_passport_number 
ON passengers(passport_number);

INSERT INTO passengers (passenger_id, first_name, last_name, passport_number, date_of_birth, country_of_citizenship) 
VALUES (2001, 'Ivan', 'Ivanov', 'N1234567', '1990-05-12', 'Kazakhstan');

INSERT INTO passengers (passenger_id, first_name, last_name, passport_number, date_of_birth, country_of_citizenship) 
VALUES (2002, 'Anna', 'Petrova', 'N7654321', '1985-10-20', 'Kazakhstan');


-- 7. Create an index for the Passengers table using first_name, last_name, date_of_birth, country_of_citizenship.
CREATE INDEX idx_passengers_composite 
ON passengers(first_name, last_name, date_of_birth, country_of_citizenship);

EXPLAIN ANALYZE 
SELECT * FROM passengers 
WHERE country_of_citizenship = 'Philippines' 
  AND date_of_birth >= '1984-01-01' 
  AND date_of_birth <= '1984-12-31';


-- 8. Write a SQL query to list indexes for table Passengers. After delete the created indexes.
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'passengers';

DROP INDEX idx_passengers_passport_number;
DROP INDEX idx_passengers_composite;


-- 9. Create an index on passenger_id of booking. Compare plan and execution time before and after with EXPLAIN ANALYZE.
EXPLAIN ANALYZE 
SELECT * FROM booking WHERE passenger_id = 100;

CREATE INDEX idx_booking_passenger_id ON booking(passenger_id);

EXPLAIN ANALYZE 
SELECT * FROM booking WHERE passenger_id = 100;


-- 10. Create a composite index on booking_flight (booking_id, flight_id). Join booking, booking_flight, and flights for price > 9000.
CREATE INDEX idx_booking_flight_composite 
ON booking_flight(booking_id, flight_id);

EXPLAIN ANALYZE 
SELECT f.flight_no, b.price 
FROM booking b
JOIN booking_flight bf ON b.booking_id = bf.booking_id
JOIN flights f ON bf.flight_id = f.flight_id
WHERE b.price > 9000;


-- 11. Create an index on the status column of flights. Run EXPLAIN ANALYZE for 'Departed' and 'Boarding'.
CREATE INDEX idx_flights_status ON flights(status);

EXPLAIN ANALYZE SELECT * FROM flights WHERE status = 'Departed';
EXPLAIN ANALYZE SELECT * FROM flights WHERE status = 'Boarding';


-- 12. Create an index on weight_in_kg of baggage. Compare range queries weight_in_kg > 49 and weight_in_kg > 5.
CREATE INDEX idx_baggage_weight ON baggage(weight_in_kg);

EXPLAIN ANALYZE SELECT * FROM baggage WHERE weight_in_kg > 49;
EXPLAIN ANALYZE SELECT * FROM baggage WHERE weight_in_kg > 5;


-- 13. Create an index on airport_name of airport. Check with EXPLAIN ANALYZE for LIKE 'A%' and LIKE '%Airport'.
CREATE INDEX idx_airport_name ON airport(airport_name);

EXPLAIN ANALYZE SELECT * FROM airport WHERE airport_name LIKE 'A%';
EXPLAIN ANALYZE SELECT * FROM airport WHERE airport_name LIKE '%Airport';


-- 14. Create a composite index on country and city of airport. Run queries filtering by country only, city only, and both.
CREATE INDEX idx_airport_country_city ON airport(country, city);

EXPLAIN ANALYZE SELECT * FROM airport WHERE country = 'Kazakhstan';
EXPLAIN ANALYZE SELECT * FROM airport WHERE city = 'Almaty';
EXPLAIN ANALYZE SELECT * FROM airport WHERE country = 'Kazakhstan' AND city = 'Almaty';


-- 15. Create a functional index on LOWER(last_name) of passengers. Compare WHERE LOWER(last_name) = 'irnis' and last_name = 'Irnis'.
CREATE INDEX idx_passengers_lower_lastname ON passengers(LOWER(last_name));

EXPLAIN ANALYZE SELECT * FROM passengers WHERE LOWER(last_name) = 'irnis';
EXPLAIN ANALYZE SELECT * FROM passengers WHERE last_name = 'Irnis';


-- 16. Create a covering index on booking for passenger_id and price. Check for Index-Only Scan.
CREATE INDEX idx_booking_covering ON booking(passenger_id) INCLUDE (price);

EXPLAIN ANALYZE SELECT price FROM booking WHERE passenger_id = 100;


-- 17. Handle duplicates and create a unique index on airline_code of airline.
SELECT airline_code, COUNT(*) 
FROM airline 
GROUP BY airline_code 
HAVING COUNT(*) > 1;