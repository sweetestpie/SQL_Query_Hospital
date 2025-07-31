-- preview data
SELECT *
FROM patients
LIMIT 5;

-- show doctor who have exp more than 5 years
SELECT first_name,last_name, specialization, years_experience
FROM doctors
WHERE years_experience > 5
ORDER BY years_experience DESC;

-- joint table show patient name and doctor name appointment
SELECT 	patients.first_name AS patientsName,
		doctors.first_name AS doctorName,
		appointments.appointment_date
FROM appointments
JOIN patients ON patients.patient_id = appointments.patient_id
JOIN doctors ON doctors.doctor_id = appointments.doctor_id
ORDER BY appointment_date;

--sum how many time, each of appointment in each type
SELECT treatment_type, count(*) AS treatment_count,sum(cost) AS total_cost
FROM treatments
GROUP BY treatment_type
ORDER BY treatment_count;

--revenue for the month (included treatment from billing)
SELECT strftime('%Y-%m', bill_date) AS Billing_month,
		sum(amount) AS Total_revenue
FROM billing
GROUP BY Billing_month
ORDER BY Billing_month;

--total revenue from each doctor
SELECT doctors.first_name ||' '||doctors.last_name AS DoctorName,
		sum(billing.amount) AS revenue
FROM billing
JOIN treatments ON treatments.treatment_id = billing.treatment_id
JOIN appointments ON treatments.appointment_id = appointments.appointment_id
join doctors ON doctors.doctor_id = appointments.doctor_id
GROUP BY DoctorName
ORDER BY revenue DESC;

--patient who have most appointment
SELECT patients.first_name ||' '|| patients.last_name AS PatientName,
count(*) AS total_appointment
FROM appointments
JOIN patients ON patients.patient_id = appointments.patient_id
GROUP BY PatientName 
ORDER BY total_appointment DESC
LIMIT 10;

--for patient who did appointment but not showing up don't show name
SELECT *
FROM appointments
WHERE status = 'No-show';

--for patient who did appointment but not showing up (show name)
SELECT patients.first_name||' '||patients.last_name AS PatientName,
		count(*) AS missed
FROM appointments
JOIN patients ON patients.patient_id = appointments.patient_id
WHERE status = 'No-show' 
GROUP BY PatientName
ORDER BY missed DESC
LIMIT 5;

--for patient who did appointment but cancel and showing up
SELECT patients.first_name||' '||patients.last_name AS PatientName,
		count(*) AS missed
FROM appointments
JOIN patients ON patients.patient_id = appointments.patient_id
WHERE NOT status = 'Scheduled' 
GROUP BY PatientName
ORDER BY missed DESC
LIMIT 5;

--income doctor 
SELECT doctors.first_name||' '||doctors.last_name AS DoctorName,
		sum(cost) AS Cost_per
FROM treatments
JOIN appointments ON appointments.appointment_id = treatments.appointment_id
JOIN  doctors ON doctors.doctor_id = appointments.doctor_id
GROUP BY DoctorName
ORDER BY Cost_per DESC;

--KPI income per doctor and time of appointments
SELECT doctors.first_name||' '||doctors.last_name AS DoctorName,
		count(distinct appointments.appointment_id) AS num_appointment,
		sum(billing.amount) AS total_revenue
FROM billing
JOIN treatments ON billing.treatment_id = treatments.treatment_id
JOIN appointments ON treatments.appointment_id = appointments.appointment_id
JOIN doctors ON doctors.doctor_id = appointments.doctor_id
GROUP BY DoctorName
ORDER BY total_revenue;

DROP VIEW IF EXISTS monthly_revenue;
-- view for income per month
CREATE VIEW monthly_revenue AS 
SELECT strftime('%Y-%m', bill_date) AS month,
       SUM(amount) AS total
FROM billing
GROUP BY month;

--view for doctor_kpi
CREATE VIEW doctor_kpis AS
SELECT doctors.first_name||' '||doctors.last_name AS DoctorName,
		count(distinct appointments.appointment_id) AS num_appointment,
		sum(billing.amount) AS total_revenue
FROM billing
JOIN treatments ON billing.treatment_id = treatments.treatment_id
JOIN appointments ON treatments.appointment_id = appointments.appointment_id
JOIN doctors ON doctors.doctor_id = appointments.doctor_id
GROUP BY DoctorName
ORDER BY total_revenue;
