--VIEW

--1. Create a view to show details of all flights that are departing on a specific date.
CREATE VIEW flights_on_specific_date AS 
SELECT * 
FROM flights 
WHERE DATE(scheduled_departure) = '2026-06-01';

--2. Create a view that shows bookings for flights scheduled to depart within the next week.
CREATE VIEW bookings_next_week AS 
SELECT b.* 
FROM booking_flight b 
JOIN flights f ON b.flight_id = f.flight_id 
WHERE f.scheduled_departure >= CURRENT_DATE 
  AND f.scheduled_departure < CURRENT_DATE + INTERVAL '7 days';

--3. Create a view to show the top 5 most popular flight routes based on the number of bookings.
CREATE VIEW top_5_flight_routes AS 
SELECT f.departure_airport_id, f.arrival_airport_id, COUNT(b.booking_id) AS booking_count 
FROM flights f 
JOIN booking_flight b ON f.flight_id = b.flight_id 
GROUP BY f.departure_airport_id, f.arrival_airport_id 
ORDER BY booking_count DESC 
LIMIT 5;

--4. Create a view that lists all flights for a specific airline.
CREATE VIEW flights_for_specific_airline AS 
SELECT f.* 
FROM flights f 
JOIN airline a ON f.airline_id = a.airline_id 
WHERE a.airline_name = 'IPC';

--5. Modify the view created in task 4 to show only flights departing within the next 7 days for a specific airline.
CREATE OR REPLACE VIEW flights_for_specific_airline AS 
SELECT f.* 
FROM flights f 
JOIN airline a ON f.airline_id = a.airline_id 
WHERE a.airline_name = 'IPC' 
  AND f.scheduled_departure >= CURRENT_DATE 
  AND f.scheduled_departure < CURRENT_DATE + INTERVAL '7 days';

--6. Create a view to show flights that are delayed by more than 24 hours.
CREATE VIEW delayed_flights_24h AS 
SELECT * 
FROM flights 
WHERE actual_departure > scheduled_departure + INTERVAL '24 hours';

--7. Create a view in which you can display the full name and country of origin of passengers who made bookings on Leffler-Thompson platform. Then show the list of those passengers.
CREATE VIEW leffler_thompson_passengers AS 
SELECT DISTINCT p.first_name, p.last_name, p.country_of_citizenship 
FROM passengers p 
JOIN booking b ON p.passenger_id = b.passenger_id 
WHERE b.booking_platform = 'Leffler-Thompson';

SELECT * FROM leffler_thompson_passengers;

--8. Create a view that shows top 10 most visited countries.
CREATE VIEW top_10_visited_countries AS 
SELECT a.country, COUNT(b.booking_id) AS visit_count 
FROM booking_flight b 
JOIN flights f ON b.flight_id = f.flight_id 
JOIN airport a ON f.arrival_airport_id = a.airport_id 
GROUP BY a.country 
ORDER BY visit_count DESC 
LIMIT 10;

--9. Update any of the created views by adding new information in the view table. Show results.
CREATE OR REPLACE VIEW leffler_thompson_passengers AS 
SELECT DISTINCT p.first_name, p.last_name, p.country_of_citizenship, p.passport_number 
FROM passengers p 
JOIN booking b ON p.passenger_id = b.passenger_id 
WHERE b.booking_platform = 'Leffler-Thompson';

SELECT * FROM leffler_thompson_passengers;

--10. Drop all existing views.
DROP VIEW IF EXISTS 
    flights_on_specific_date, 
    bookings_next_week, 
    top_5_flight_routes, 
    flights_for_specific_airline, 
    delayed_flights_24h, 
    leffler_thompson_passengers, 
    top_10_visited_countries;



--ROLES

--1. Create the group roles flight_manager and flight_analyst, then show the list of roles.
CREATE ROLE flight_manager;
CREATE ROLE flight_analyst;

SELECT rolname FROM pg_roles WHERE rolname IN ('flight_manager', 'flight_analyst');

--2. Create the users first_user and second_user and add them to the group roles.
CREATE USER first_user WITH PASSWORD 'securepassword1';
CREATE USER second_user WITH PASSWORD 'securepassword2';

GRANT flight_manager TO first_user;
GRANT flight_analyst TO second_user;

--3. Grant flight_analyst SELECT on the flights, airlines and bookings tables.
GRANT SELECT ON flights, airline, booking TO flight_analyst;

--4. Grant flight_manager SELECT, INSERT and UPDATE on bookings, and SELECT on the other tables.
GRANT SELECT, INSERT, UPDATE ON booking TO flight_manager;
GRANT SELECT ON flights, airline, passengers TO flight_manager;

--5. Connect as second_user, read flights and try to delete from bookings.
SET ROLE second_user;
SELECT * FROM flights;
DELETE FROM booking WHERE booking_id = 1;
RESET ROLE;

--6. Connect as first_user, insert and update a booking, and try to delete one.
SET ROLE first_user;
INSERT INTO booking (booking_id, passenger_id, booking_platform, created_at, update_at, status, price) values (501, 156, 'Frami Inc', '2026-11-6', '2026-11-16', 'Male', 1234.67);
UPDATE booking SET booking_platform = 'ModifiedPlatform' WHERE booking_id = 501;
DELETE FROM booking WHERE booking_id = 501;
RESET ROLE;

--7. Grant column-level SELECT on only the full name and country columns of passengers.
GRANT SELECT (first_name, last_name, country_of_citizenship) ON passengers TO flight_analyst;

--8. Revoke SELECT on bookings from flight_analyst and show that access is denied.
REVOKE SELECT ON booking FROM flight_analyst;

SET ROLE second_user;
SELECT * FROM booking;
RESET ROLE;

--9. Alter the roles: change a password, set a connection limit and rename a role.
ALTER USER first_user WITH PASSWORD 'new_secure_password';
ALTER ROLE flight_manager CONNECTION LIMIT 5;
ALTER ROLE flight_analyst RENAME TO senior_flight_analyst;

--10. Drop all created roles.
DROP ROLE IF EXISTS first_user, second_user, flight_manager, senior_flight_analyst;