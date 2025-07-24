
CREATE DATABASE IF NOT EXISTS HealthcareDB;
USE HealthcareDB;

DROP TABLE IF EXISTS Billing, Medical_Records, Appointments, Doctors, Patients;

-- Patients Table
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    DOB DATE,
    Gender ENUM('Male', 'Female', 'Other'),
    Phone VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    Address TEXT
);

-- Doctors Table
CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Specialization VARCHAR(100),
    Phone VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    Experience INT
);

-- Appointments Table
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT,
    DoctorID INT,
    AppointmentDate DATETIME,
    Status ENUM('Scheduled', 'Completed', 'Cancelled'),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- Medical Records Table
CREATE TABLE Medical_Records (
    RecordID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT,
    Diagnosis TEXT,
    Treatment TEXT,
    RecordDate DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

-- Billing Table
CREATE TABLE Billing (
    BillID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT,
    Amount DECIMAL(10,2),
    PaymentStatus ENUM('Paid', 'Pending'),
    BillDate DATE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

-- Insert Sample Patients
INSERT INTO Patients (Name, DOB, Gender, Phone, Email, Address) VALUES
('John Doe', '1990-05-14', 'Male', '9876543210', 'john.doe@email.com', '123 Main St'),
('Jane Smith', '1985-10-23', 'Female', '9123456789', 'jane.smith@email.com', '456 Elm St');

-- Insert Sample Doctors
INSERT INTO Doctors (Name, Specialization, Phone, Email, Experience) VALUES
('Dr. Emily Johnson', 'Cardiologist', '9988776655', 'emily.j@email.com', 10),
('Dr. Mark Wilson', 'Dermatologist', '9874563210', 'mark.w@email.com', 8);

-- Insert Appointments
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, Status) VALUES
(1, 1, '2025-02-15 10:30:00', 'Scheduled'),
(2, 2, '2025-02-16 14:00:00', 'Completed');

-- Insert Medical Records
INSERT INTO Medical_Records (PatientID, Diagnosis, Treatment, RecordDate) VALUES
(1, 'Hypertension', 'Prescribed medication', '2025-01-10'),
(2, 'Acne', 'Dermatology treatment', '2025-01-12');

-- Insert Billing Records
INSERT INTO Billing (PatientID, Amount, PaymentStatus, BillDate) VALUES
(1, 5000.00, 'Paid', '2025-01-11'),
(2, 2500.00, 'Pending', '2025-01-13');


-- 1. Update Queries
UPDATE Patients
SET Phone = '9998887776'
WHERE Name = 'John Doe';

UPDATE Appointments
SET Status = 'Completed'
WHERE AppointmentID = 1;

-- 2. Order By Queries
SELECT * FROM Patients
ORDER BY DOB ASC;

SELECT Name, Specialization, Experience FROM Doctors
ORDER BY Experience DESC;

-- 3. Group By Queries
SELECT d.Name AS DoctorName, COUNT(a.AppointmentID) AS TotalAppointments
FROM Appointments a
JOIN Doctors d ON a.DoctorID = d.DoctorID
GROUP BY d.Name;

SELECT PaymentStatus, SUM(Amount) AS TotalAmount
FROM Billing
GROUP BY PaymentStatus;

-- 4. Row Number Queries (MySQL 8+)
SELECT Name, Experience,
       ROW_NUMBER() OVER (ORDER BY Experience DESC) AS Rank
FROM Doctors;

SELECT *, 
       ROW_NUMBER() OVER (PARTITION BY PatientID ORDER BY RecordDate DESC) AS rn
FROM Medical_Records;

-- 5. Limit Queries
SELECT * FROM Appointments
ORDER BY AppointmentDate DESC
LIMIT 5;

SELECT * FROM Billing
ORDER BY Amount DESC
LIMIT 1;

SELECT p.Name, b.Amount, b.BillDate
FROM Billing b
JOIN Patients p ON b.PatientID = p.PatientID
WHERE b.PaymentStatus = 'Pending';
