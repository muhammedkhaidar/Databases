--1
ALTER TABLE passengers
ADD CONSTRAINT check_passengers_age 
CHECK (date_of_birth <= CURRENT_DATE - INTERVAL '10 years');

--2
ALTER TABLE booking
ADD CONSTRAINT check_booking_price 
CHECK (price >= 0 AND price <= 50000);

--3
ALTER TABLE baggage
ADD CONSTRAINT check_baggage_weight 
CHECK (weight_in_kg BETWEEN 1 AND 23);

--4
ALTER TABLE airport
ADD CONSTRAINT check_airport_name_length 
CHECK (LENGTH(airport_name) >= 10);

--5
ALTER TABLE airline ADD CONSTRAINT unique_airline_id UNIQUE (airline_id);
ALTER TABLE airport ADD CONSTRAINT unique_airport_id UNIQUE (airport_id);
ALTER TABLE flights ADD CONSTRAINT unique_flight_no UNIQUE (flight_no);
ALTER TABLE passenger ADD CONSTRAINT unique_passport_number UNIQUE (passport_number);
ALTER TABLE booking ADD CONSTRAINT unique_booking_ref UNIQUE (booking_ref);

--6
ALTER TABLE passengers
ADD CONSTRAINT check_gender_age 
CHECK (
    (gender = 'M' AND date_of_birth <= CURRENT_DATE - INTERVAL '18 years')
	OR
    (gender = 'F' AND date_of_birth <= CURRENT_DATE - INTERVAL '19 years')
);

--7
ALTER TABLE passengers
ADD CONSTRAINT check_citizenship_age 
CHECK (
    (country_of_citizenship = 'Kazakhstan' AND date_of_birth <= CURRENT_DATE - INTERVAL '18 years')
	OR
    (country_of_citizenship = 'France' AND date_of_birth <= CURRENT_DATE - INTERVAL '17 years')
	OR
    (country_of_citizenship NOT IN ('Kazakhstan', 'France') AND date_of_birth <= CURRENT_DATE - INTERVAL '19 years')
);

--8
ALTER TABLE booking ADD COLUMN ticket_discount NUMERIC;

ALTER TABLE booking
ADD CONSTRAINT chk_ticket_discount 
CHECK (
    (created_at > '2024-01-01' AND ticket_discount = 0.05)
	OR
    (created_at <= '2024-01-01' AND ticket_discount = 0.10)
);

--9
ALTER TABLE booking ALTER COLUMN status SET DEFAULT 'Confirmed';

INSERT INTO booking (booking_id, passenger_id, booking_platform, created_at, price) 
VALUES (1001, 12, 'booking', CURRENT_TIMESTAMP, 35000);

--10
ALTER TABLE booking ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP;