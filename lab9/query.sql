-- 1. Create a stored procedure to insert a new flight into the flights table.
CREATE OR REPLACE PROCEDURE sp_insert_flight(
    p_flight_number VARCHAR,
    p_airline_id INT,
    p_departure_airport VARCHAR,
    p_arrival_airport VARCHAR,
    p_departure_time TIMESTAMP,
    p_arrival_time TIMESTAMP,
    p_status VARCHAR DEFAULT 'Scheduled'
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO flights (
        flight_number,
        airline_id,
        departure_airport,
        arrival_airport,
        departure_time,
        arrival_time,
        status
    )
    VALUES (
        p_flight_number,
        p_airline_id,
        p_departure_airport,
        p_arrival_airport,
        p_departure_time,
        p_arrival_time,
        p_status
    );
END;
$$;


-- 2. Create a stored procedure to update the status of a flight.
CREATE OR REPLACE PROCEDURE sp_update_flight_status(
    p_flight_id INT,
    p_new_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE flights
    SET status = p_new_status
    WHERE flight_id = p_flight_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'Flight with flight_id % not found.', p_flight_id;
    END IF;
END;
$$;


-- 3. Create a stored procedure that returns a list of flights departing from a specific airport.
CREATE OR REPLACE PROCEDURE sp_get_departing_flights(
    p_departure_airport VARCHAR,
    INOUT p_cursor refcursor DEFAULT 'departing_flights_cur'
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_cursor FOR
        SELECT *
        FROM flights
        WHERE departure_airport = p_departure_airport
        ORDER BY departure_time;
END;
$$;


-- 4. Create a function to calculate the average delay time of flights arriving at a specific airport.
CREATE OR REPLACE FUNCTION fn_avg_arrival_delay_minutes(
    p_arrival_airport VARCHAR
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_avg_delay NUMERIC;
BEGIN
    SELECT AVG(
        GREATEST(
            EXTRACT(EPOCH FROM (actual_arrival_time - scheduled_arrival_time)) / 60.0,
            0
        )
    )
    INTO v_avg_delay
    FROM flights
    WHERE arrival_airport = p_arrival_airport
      AND actual_arrival_time IS NOT NULL
      AND scheduled_arrival_time IS NOT NULL;

    RETURN COALESCE(v_avg_delay, 0);
END;
$$;


-- 5. Create a stored procedure that lists all passengers for a given flight number.
CREATE OR REPLACE PROCEDURE sp_get_passengers_by_flight(
    p_flight_number VARCHAR,
    INOUT p_cursor refcursor DEFAULT 'flight_passengers_cur'
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_cursor FOR
        SELECT DISTINCT
            p.passenger_id,
            p.first_name,
            p.last_name,
            p.passport_number,
            p.citizenship
        FROM passengers p
        JOIN booking b ON p.passenger_id = b.passenger_id
        JOIN booking_flight bf ON b.booking_id = bf.booking_id
        JOIN flights f ON bf.flight_id = f.flight_id
        WHERE f.flight_number = p_flight_number
        ORDER BY p.last_name, p.first_name;
END;
$$;


-- 6. Create a stored procedure to find the passenger who has taken the greatest number of flights.
CREATE OR REPLACE PROCEDURE sp_top_passenger_by_flights(
    INOUT p_cursor refcursor DEFAULT 'top_passenger_cur'
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_cursor FOR
        SELECT
            p.passenger_id,
            p.first_name,
            p.last_name,
            COUNT(bf.flight_id) AS flight_count
        FROM passengers p
        JOIN booking b ON p.passenger_id = b.passenger_id
        JOIN booking_flight bf ON b.booking_id = bf.booking_id
        GROUP BY p.passenger_id, p.first_name, p.last_name
        ORDER BY flight_count DESC, p.passenger_id ASC
        LIMIT 1;
END;
$$;


-- 7. Create a stored procedure to find all flights that are delayed by more than 24 hours.
CREATE OR REPLACE PROCEDURE sp_flights_delayed_over_24h(
    INOUT p_cursor refcursor DEFAULT 'delayed_24h_cur'
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_cursor FOR
        SELECT
            f.*,
            (f.actual_departure_time - f.scheduled_departure_time) AS delay_duration
        FROM flights f
        WHERE f.actual_departure_time IS NOT NULL
          AND f.scheduled_departure_time IS NOT NULL
          AND (f.actual_departure_time - f.scheduled_departure_time) > INTERVAL '24 hours'
        ORDER BY delay_duration DESC;
END;
$$;


-- 8. Create a function that counts the number of flights for each airline.
CREATE OR REPLACE FUNCTION fn_flight_count_per_airline()
RETURNS TABLE (
    airline_id INT,
    airline_name VARCHAR,
    flight_count BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.airline_id,
        a.name AS airline_name,
        COUNT(f.flight_id) AS flight_count
    FROM airline a
    LEFT JOIN flights f ON a.airline_id = f.airline_id
    GROUP BY a.airline_id, a.name
    ORDER BY flight_count DESC, a.name;
END;
$$;


-- 9. Create a stored procedure to calculate the average ticket price for a specific flight.
CREATE OR REPLACE PROCEDURE sp_avg_ticket_price_for_flight(
    p_flight_id INT,
    OUT p_avg_price NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT AVG(b.price)
    INTO p_avg_price
    FROM booking b
    JOIN booking_flight bf ON b.booking_id = bf.booking_id
    WHERE bf.flight_id = p_flight_id;

    p_avg_price := COALESCE(p_avg_price, 0);
END;
$$;


-- 10. Create a stored procedure to find the flight with the highest ticket price. The procedure should return the flight number, the departure and arrival airports, and the ticket price for the most expensive flight.
CREATE OR REPLACE PROCEDURE sp_highest_ticket_price_flight(
    OUT p_flight_number VARCHAR,
    OUT p_departure_airport VARCHAR,
    OUT p_arrival_airport VARCHAR,
    OUT p_ticket_price NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        f.flight_number,
        f.departure_airport,
        f.arrival_airport,
        b.price
    INTO
        p_flight_number,
        p_departure_airport,
        p_arrival_airport,
        p_ticket_price
    FROM booking b
    JOIN booking_flight bf ON b.booking_id = bf.booking_id
    JOIN flights f ON bf.flight_id = f.flight_id
    WHERE b.price IS NOT NULL
    ORDER BY b.price DESC
    LIMIT 1;
END;
$$;


-- 11. Create a stored procedure to insert a new passenger into the passengers table. Accept first name, last name, date of birth, gender, citizenship, country of residence, and passport number.
CREATE OR REPLACE PROCEDURE sp_insert_passenger(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_date_of_birth DATE,
    p_gender VARCHAR,
    p_citizenship VARCHAR,
    p_country_of_residence VARCHAR,
    p_passport_number VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO passengers (
        first_name,
        last_name,
        date_of_birth,
        gender,
        citizenship,
        country_of_residence,
        passport_number
    )
    VALUES (
        p_first_name,
        p_last_name,
        p_date_of_birth,
        p_gender,
        p_citizenship,
        p_country_of_residence,
        p_passport_number
    );
END;
$$;


-- 12. Create a stored procedure to update a passenger's country of residence using passenger_id.
CREATE OR REPLACE PROCEDURE sp_update_passenger_residence(
    p_passenger_id INT,
    p_country_of_residence VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE passengers
    SET country_of_residence = p_country_of_residence
    WHERE passenger_id = p_passenger_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'Passenger with passenger_id % not found.', p_passenger_id;
    END IF;
END;
$$;


-- 13. Create a stored procedure to delete a booking using booking_id. Before deleting it, check whether related records exist in booking_flight, baggage, baggage_check, or boarding_pass.
CREATE OR REPLACE PROCEDURE sp_delete_booking_safe(
    p_booking_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_has_booking_flight BOOLEAN;
    v_has_baggage BOOLEAN;
    v_has_baggage_check BOOLEAN;
    v_has_boarding_pass BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM booking_flight WHERE booking_id = p_booking_id
    ) INTO v_has_booking_flight;

    SELECT EXISTS (
        SELECT 1 FROM baggage WHERE booking_id = p_booking_id
    ) INTO v_has_baggage;

    SELECT EXISTS (
        SELECT 1
        FROM baggage_check bc
        JOIN baggage bg ON bc.baggage_id = bg.baggage_id
        WHERE bg.booking_id = p_booking_id
    ) INTO v_has_baggage_check;

    SELECT EXISTS (
        SELECT 1
        FROM boarding_pass bp
        JOIN booking_flight bf ON bp.booking_flight_id = bf.booking_flight_id
        WHERE bf.booking_id = p_booking_id
    ) INTO v_has_boarding_pass;

    IF v_has_booking_flight OR v_has_baggage OR v_has_baggage_check OR v_has_boarding_pass THEN
        RAISE EXCEPTION
            'Cannot delete booking %: related records exist (booking_flight=%, baggage=%, baggage_check=%, boarding_pass=%).',
            p_booking_id, v_has_booking_flight, v_has_baggage, v_has_baggage_check, v_has_boarding_pass;
    END IF;

    DELETE FROM booking
    WHERE booking_id = p_booking_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'Booking % does not exist.', p_booking_id;
    END IF;
END;
$$;


-- 14. Create a function that returns the total number of passengers from a given country of citizenship.
CREATE OR REPLACE FUNCTION fn_passenger_count_by_citizenship(
    p_citizenship VARCHAR
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count BIGINT;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM passengers
    WHERE citizenship = p_citizenship;

    RETURN COALESCE(v_count, 0);
END;
$$;


-- 15. Create a function that calculates the total revenue generated by bookings for a given airline. Use booking, booking_flight, and flights tables.
CREATE OR REPLACE FUNCTION fn_airline_booking_revenue(
    p_airline_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_revenue NUMERIC;
BEGIN
    SELECT COALESCE(SUM(b.price), 0)
    INTO v_total_revenue
    FROM booking b
    WHERE b.booking_id IN (
        SELECT DISTINCT bf.booking_id
        FROM booking_flight bf
        JOIN flights f ON bf.flight_id = f.flight_id
        WHERE f.airline_id = p_airline_id
    );

    RETURN v_total_revenue;
END;
$$;


-- 16. Create a stored procedure that displays all bookings made by a specific passenger. Include booking_id, booking date, booking status, booking platform, and price.
CREATE OR REPLACE PROCEDURE sp_get_passenger_bookings(
    p_passenger_id INT,
    INOUT p_cursor refcursor DEFAULT 'passenger_bookings_cur'
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_cursor FOR
        SELECT
            b.booking_id,
            b.booking_date,
            b.status AS booking_status,
            b.booking_platform,
            b.price
        FROM booking b
        WHERE b.passenger_id = p_passenger_id
        ORDER BY b.booking_date DESC, b.booking_id DESC;
END;
$$;


-- 17. Create a stored procedure that finds passengers who have booked more than a specified number of flights. Accept the minimum number of flights as an input parameter.
CREATE OR REPLACE PROCEDURE sp_passengers_with_more_flights_than(
    p_min_flights INT,
    INOUT p_cursor refcursor DEFAULT 'frequent_flyers_cur'
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN p_cursor FOR
        SELECT
            p.passenger_id,
            p.first_name,
            p.last_name,
            COUNT(bf.flight_id) AS booked_flights_count
        FROM passengers p
        JOIN booking b ON p.passenger_id = b.passenger_id
        JOIN booking_flight bf ON b.booking_id = bf.booking_id
        GROUP BY p.passenger_id, p.first_name, p.last_name
        HAVING COUNT(bf.flight_id) > p_min_flights
        ORDER BY booked_flights_count DESC, p.passenger_id;
END;
$$;


-- 18. Create a function that returns the number of flights arriving at a given airport within a specified date range.
CREATE OR REPLACE FUNCTION fn_arriving_flights_in_range(
    p_arrival_airport VARCHAR,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_flight_count BIGINT;
BEGIN
    SELECT COUNT(*)
    INTO v_flight_count
    FROM flights
    WHERE arrival_airport = p_arrival_airport
      AND arrival_time::DATE BETWEEN p_start_date AND p_end_date;

    RETURN COALESCE(v_flight_count, 0);
END;
$$;


-- 19. Create a stored procedure that updates the status of all bookings older than a specified date to a new status. Accept the date and new status as input parameters.
CREATE OR REPLACE PROCEDURE sp_update_old_bookings_status(
    p_cutoff_date TIMESTAMP,
    p_new_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE booking
    SET status = p_new_status
    WHERE booking_date < p_cutoff_date;
END;
$$;


-- 20. Create a function that returns a passenger's full name and total number of bookings using passenger_id. Handle the case when the passenger does not exist.
CREATE OR REPLACE FUNCTION fn_passenger_full_name_and_bookings(
    p_passenger_id INT
)
RETURNS TABLE (
    full_name TEXT,
    total_bookings BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM passengers WHERE passenger_id = p_passenger_id
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN QUERY
        SELECT
            'Passenger not found'::TEXT AS full_name,
            0::BIGINT AS total_bookings;
        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        (p.first_name || ' ' || p.last_name)::TEXT AS full_name,
        COUNT(b.booking_id)::BIGINT AS total_bookings
    FROM passengers p
    LEFT JOIN booking b ON p.passenger_id = b.passenger_id
    WHERE p.passenger_id = p_passenger_id
    GROUP BY p.passenger_id, p.first_name, p.last_name;
END;
$$;