CREATE TABLE department (
dept_id INT PRIMARY KEY,
dept_name VARCHAR(20) not null
    );

INSERT INTO department (dept_id, dept_name)
VALUES
(1,'Internal'),
(2,'Surgery'),
(3,'Gynaecology'),
(4,'Hematology'),
(5,'Administration'),
(6,'Laboratoty');



CREATE TABLE role (
role_id INT PRIMARY KEY,
role_name VARCHAR(20) not null unique,
is_active BOOLEAN not null
    );

INSERT INTO role (role_id, role_name, is_active)
VALUES
(11,'Surgeon', True),
(12,'Internist', True),
(13,'Receptionist', True),
(14,'Laborant', True),
(15,'Gynecologist', True),
(16,'Hematologist', False);



CREATE TABLE employee (
empl_id INT PRIMARY KEY,
empl_name VARCHAR(40) not null,
empl_snam VARCHAR(40) not null,
phone VARCHAR(20) not null,
dept_id INT,
role_id INT,
FOREIGN KEY(dept_id) REFERENCES department,
FOREIGN KEY(role_id) REFERENCES role
    );

INSERT INTO employee (empl_id, empl_name, empl_snam, phone, dept_id, role_id)
VALUES
(101, 'Alexander', 'Redlit', '0044506543122', 1, 12),
(102, 'Jonas', 'Lines', '004667643980', 2, 11),
(103, 'Janusz', 'Polak', '0048609876543', 3, 15),
(104, 'Emily', 'Kox', '0044678764899', 5, 13);



CREATE TABLE status (
status_id INT PRIMARY KEY,
status_name VARCHAR(20) not null
    );

INSERT INTO status (status_id, status_name)
VALUES
(10001,'planned'),
(20002,'completed'),
(30003,'cancelled');


CREATE TABLE patient (
pat_id NUMERIC PRIMARY KEY not null,
pat_name VARCHAR(40) not null,
pat_sname VARCHAR(40) not null,
insurance_id INT,
phone VARCHAR(20),
city VARCHAR(40) not null,
postcode VARCHAR(40) not null,
street VARCHAR(40) not null,
street_nb VARCHAR(40) not null,
apartment VARCHAR(40) not null
    );

INSERT INTO patient (pat_id, pat_name, pat_sname, insurance_id, phone, city, postcode, street, street_nb, apartment)
VALUES
(84092627655, 'Justin', 'Biber', '435765', '004667643980', 'Leeds', '0877', 'Elsmere', '13E', '0'),
(65051167541, 'Melany', 'Trump', '115789', '', 'Manchester', '0187', 'Peaks Valley', '6', 'A'),
(55081798763, 'Amanda', 'River', 0, '004650765918', 'Glasgow', '0981', 'Greens', '2', '11'),
(72080187989, 'Tiffany', 'Almeida', '876787', '004830297661', 'Gdansk', '80-225', 'Samurajska', '1', '29');


CREATE TABLE medicine (
med_id INT PRIMARY KEY,
med_name VARCHAR(40) not null,
base_price NUMERIC,
ref_price NUMERIC
    );


INSERT INTO medicine (med_id, med_name, base_price, ref_price)
VALUES
(1001,'Apap 10mg', 56.50, 12.00),
(1002,'Gripex 2000', 13.25, 13.25),
(1003,'Tussipex 100mg', 78.00, 10.00),
(1004,'Paracetamol extra400mg', 13.00, 13.00),
(1005,'Adrenaline 10mg', 76.00, 65.00),
(1006,'Hemex 5mg', 165.80, 7.80);


CREATE TABLE appointment (
app_id INT PRIMARY KEY,
pat_id NUMERIC not null,
empl_id INT not null,
status_id INT not null,
app_date DATE not null,
FOREIGN KEY(pat_id) REFERENCES patient,
FOREIGN KEY(empl_id) REFERENCES employee,
FOREIGN KEY(status_id) REFERENCES status
    );

INSERT INTO appointment (app_id, pat_id, empl_id, status_id, app_date)
VALUES
(1, 84092627655, 101, 10001, '2019-08-23'),
(2, 55081798763, 103, 20002, '2019-07-01'),
(3, 72080187989, 101, 30003, '2019-05-12'),
(4, 72080187989, 102, 20002, '2019-08-31');


CREATE TABLE prescription (
receipt_id INT PRIMARY KEY,
app_id INT not null,
pat_id NUMERIC not null,
med_id INT not null,
quantity VARCHAR(10),
is_refund BOOLEAN not null,
FOREIGN KEY(app_id) REFERENCES appointment,
FOREIGN KEY(pat_id) REFERENCES patient,
FOREIGN KEY(med_id) REFERENCES medicine
    );

INSERT INTO prescription (receipt_id, app_id, pat_id, med_id, quantity, is_refund)
VALUES
(900000, 1, 55081798763, 1001, 1, 'TRUE'),
(900001, 4, 72080187989, 1004, 4, 'FALSE');