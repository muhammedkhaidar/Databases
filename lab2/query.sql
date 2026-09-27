--1. + 2. + 4.
CREATE TABLE Airline_info (
	airline_id int PRIMARY KEY NOT NULL,
	ailine_code varchar(30) NOT NULL,
	irline_name varchar(50) NOT NULL,
	airline_country varchar(50) NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL,
	info varchar(50) NOT NULL
);

CREATE TABLE Airport (
	airport_id int PRIMARY KEY NOT NULL,
	airport_name varchar(50) NOT NULL,
	country varchar(50) NOT NULL,
	state varchar(50) NOT NULL,
	city varchar(50) NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);

CREATE TABLE Baggage_check (
	baggage_check_id int PRIMARY KEY NOT NULL,
	check_result varchar(50) NOT NULL,
	created_at timestamp,updated_at timestamp NOT NULL,
	booking_id int NOT NULL,
	passenger_id int NOT NULL
);

CREATE TABLE Baggage (
	baggage_id int PRIMARY KEY NOT NULL,
	weight_in_kg decimal(4,2) NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL,
	booking_id int NOT NULL
);

CREATE TABLE Boarding_pass (
	boarding_pass_id int PRIMARY KEY NOT NULL,
	booking_id int NOT NULL,
	seat varchar(50) NOT NULL,
	boarding_time timestamp NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);

CREATE TABLE Booking_flight (
	booking_flight_id int PRIMARY KEY NOT NULL,
	booking_id int NOT NULL,
	flight_id int NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);

CREATE TABLE Booking (
	booking_id int PRIMARY KEY NOT NULL,
	flight_id int NOT NULL,
	passenger_id int NOT NULL,
	booking_platform varchar(50) NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL,
	status varchar(50) NOT NULL,
	price decimal(7,2) NOT NULL
);

CREATE TABLE Flights (
	flight_id int PRIMARY KEY NOT NULL,
	sch_departure_time timestamp NOT NULL,
	sch_arrival_time timestamp NOT NULL,
	departing_airport_id int NOT NULL,
	arriving_airport_id int NOT NULL,
	departing_gate varchar(50) NOT NULL,
	arriving_gate varchar(50) NOT NULL,
	airline_id int NOT NULL,
	act_departure_time timestamp NOT NULL,
	act_arrival_time timestamp NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);

CREATE TABLE Passengers (
	passenger_id int PRIMARY KEY NOT NULL,
	first_name varchar(50) NOT NULL,
	last_name varchar(50) NOT NULL,
	date_of_birth date NOT NULL,
	gender varchar(50) NOT NULL,
	country_of_citizenship varchar(50) NOT NULL,
	country_of_residence varchar(50) NOT NULL,
	passport_number varchar(20) NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL
);

CREATE TABLE Security_Check (
	security_check_id int PRIMARY KEY NOT NULL,
	check_result varchar(20) NOT NULL,
	created_at timestamp NOT NULL,
	updated_at timestamp NOT NULL,
	passenger_id int NOT NULL
);

--5.
ALTER TABLE Airline_info RENAME TO Airline;

--6.
ALTER TABLE Booking RENAME COLUMN price TO ticket_price;

--7.
ALTER TABLE Flights ALTER COLUMN departing_gate TYPE text;

--8.
ALTER TABLE Airline DROP COLUMN info;

--9.
ALTER TABLE Security_check 
ADD CONSTRAINT fk_Security_check__passenger 
FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id);

ALTER TABLE Booking 
ADD CONSTRAINT fk_Booking__passenger 
FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id);

ALTER TABLE Baggage_check 
ADD CONSTRAINT fk_Baggage_check__passenger 
FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id);

ALTER TABLE Baggage_check 
ADD CONSTRAINT fk_Baggage_check__booking 
FOREIGN KEY (booking_id) REFERENCES Booking(booking_id);

ALTER TABLE Baggage 
ADD CONSTRAINT fk_Baggage__booking 
FOREIGN KEY (booking_id) REFERENCES Booking(booking_id);

ALTER TABLE Boarding_pass 
ADD CONSTRAINT fk_Boarding_pass__booking 
FOREIGN KEY (booking_id) REFERENCES Booking(booking_id);

ALTER TABLE Booking_flight 
ADD CONSTRAINT fk_Booking_flight__booking 
FOREIGN KEY (booking_id) REFERENCES Booking(booking_id);

ALTER TABLE Booking_flight 
ADD CONSTRAINT fk_Booking_flight__flight 
FOREIGN KEY (flight_id) REFERENCES Flights(flight_id);

ALTER TABLE Flights 
ADD CONSTRAINT fk_Flights__departing_airport 
FOREIGN KEY (departing_airport_id) REFERENCES Airport(airport_id);

ALTER TABLE Flights 
ADD CONSTRAINT fk_Flights__arriving_airport 
FOREIGN KEY (arriving_airport_id) REFERENCES Airport(airport_id);

ALTER TABLE Flights 
ADD CONSTRAINT fk_Flights__airline 
FOREIGN KEY (airline_id) REFERENCES airline(airline_id);