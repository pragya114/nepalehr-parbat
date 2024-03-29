SELECT  cbimci.caste_ethnicity AS 'Caste/Ethnicity',
        Fully_immunized_female AS 'Fully immunized-Female',
		Fully_immunized_male AS 'Fully immunized-Male',
		cbimci_female AS 'Enroll in CBIMCI programme-Female',
		cbimci_male AS 'Enroll in CBIMCI programme-Male',
        underweight_female AS 'Underweight Children(<2years)-Female',
        underweight_male AS 'Underweight Children(<2years)-Male',
        delivery_count AS 'Institutional Delivery',
        abortion_count AS 'Abortion Cases',
        op_cases_female AS 'Out patient cases-Female',
        op_cases_male AS 'Out patient cases-Male',
        ip_cases_female AS 'In patient cases-Female',
        ip_cases_male AS 'In patient cases-Male',
		tb_cases_female AS 'TB patient cases-Female',
        tb_cases_male AS 'TB patient cases-Male',
		leprosy_cases_female AS 'Leprosy patient cases-Female',
        leprosy_cases_male AS 'Leprosy patient cases-Male'
      
FROM
(SELECT
	caste_list.answer_concept_name AS caste_ethnicity,
	SUM(IF(person.gender = 'F', 1, 0)) AS Fully_immunized_female,
    SUM(IF(person.gender = 'M', 1, 0)) AS Fully_immunized_male
FROM visit
INNER JOIN person ON visit.patient_id = person.person_id
	AND DATE(visit.date_stopped) BETWEEN '#startDate#' AND '#endDate#'
    AND TIMESTAMPDIFF(MONTH, DATE(person.birthdate), visit.date_stopped) <= 24
INNER JOIN person_attribute ON person_attribute.person_id = person.person_id
INNER JOIN person_attribute_type ON person_attribute.person_attribute_type_id = person_attribute_type.person_attribute_type_id
	AND person_attribute_type.name = 'Caste'    
INNER JOIN encounter ON visit.visit_id = encounter.visit_id
INNER JOIN coded_obs_view ON encounter.encounter_id = coded_obs_view.encounter_id
	AND coded_obs_view.concept_full_name IN ('Vaccine-Measles or rubella')
    AND coded_obs_view.value_concept_full_name IN ('Number-2')
    AND coded_obs_view.voided is FALSE
RIGHT OUTER JOIN (SELECT answer_concept_name, answer_concept_id FROM concept_answer_view WHERE question_concept_name = 'Caste' ) AS caste_list ON caste_list.answer_concept_id = person_attribute.value
GROUP BY caste_list.answer_concept_name) AS Fully_immunized
INNER JOIN

(SELECT
	caste_list.answer_concept_name AS caste_ethnicity,
	SUM(IF(person.gender = 'F', 1, 0)) AS cbimci_female,
    SUM(IF(person.gender = 'M', 1, 0)) AS cbimci_male
 
FROM visit
INNER JOIN person ON visit.patient_id = person.person_id
	AND DATE(visit.date_stopped) BETWEEN '#startDate#' AND '#endDate#'
INNER JOIN person_attribute ON person_attribute.person_id = person.person_id
INNER JOIN person_attribute_type ON person_attribute.person_attribute_type_id = person_attribute_type.person_attribute_type_id AND person_attribute_type.name = 'Caste'
INNER JOIN encounter ON visit.visit_id = encounter.visit_id
INNER JOIN obs_view ON encounter.encounter_id = obs_view.encounter_id
	AND obs_view.concept_full_name IN ('CBIMNCI (<2 months child)', 'CBIMNCI (2 to 59 months child)')
    AND obs_view.voided is FALSE
RIGHT OUTER JOIN (SELECT answer_concept_name, answer_concept_id FROM concept_answer_view WHERE question_concept_name = 'Caste' ) AS caste_list ON caste_list.answer_concept_id = person_attribute.value
GROUP BY caste_list.answer_concept_name) AS cbimci on cbimci.caste_ethnicity = Fully_immunized.caste_ethnicity
INNER JOIN

-- Underweight Children (<2 year)
(SELECT
	caste_list.answer_concept_name AS caste_ethnicity,
	SUM(IF(person.gender = 'F', 1, 0)) AS underweight_female,
    SUM(IF(person.gender = 'M', 1, 0)) AS underweight_male
FROM visit
INNER JOIN person ON visit.patient_id = person.person_id
	AND DATE(visit.date_stopped) BETWEEN '#startDate#' AND '#endDate#'
    AND TIMESTAMPDIFF(MONTH, DATE(person.birthdate), visit.date_stopped) <= 24
INNER JOIN person_attribute ON person_attribute.person_id = person.person_id
INNER JOIN person_attribute_type ON person_attribute.person_attribute_type_id = person_attribute_type.person_attribute_type_id
	AND person_attribute_type.name = 'Caste'    
INNER JOIN encounter ON visit.visit_id = encounter.visit_id
INNER JOIN coded_obs_view ON encounter.encounter_id = coded_obs_view.encounter_id
	AND coded_obs_view.concept_full_name IN ('IMAM-Indicator')
    AND coded_obs_view.value_concept_full_name IN ('Low weight', 'SAM')
    AND coded_obs_view.voided is FALSE
RIGHT OUTER JOIN (SELECT answer_concept_name, answer_concept_id FROM concept_answer_view WHERE question_concept_name = 'Caste' ) AS caste_list ON caste_list.answer_concept_id = person_attribute.value
GROUP BY caste_list.answer_concept_name) AS underweight ON underweight.caste_ethnicity = cbimci.caste_ethnicity
INNER JOIN
-- Institiutional Delivery
(SELECT
	caste_list.answer_concept_name AS caste_ethnicity,
    IFNULL(COUNT(DISTINCT (person.person_id)), 0) AS delivery_count
FROM visit
INNER JOIN person ON visit.patient_id = person.person_id
INNER JOIN person_attribute ON person_attribute.person_id = person.person_id
INNER JOIN person_attribute_type ON person_attribute.person_attribute_type_id = person_attribute_type.person_attribute_type_id
	AND person_attribute_type.name = 'Caste'
INNER JOIN encounter ON visit.visit_id = encounter.visit_id
INNER JOIN obs_view delivery_date ON encounter.encounter_id = delivery_date.encounter_id
    AND DATE(encounter.encounter_datetime) BETWEEN '#startDate#' AND '#endDate#' AND delivery_date.voided is FALSE
INNER JOIN coded_obs_view AS inst_delivery ON inst_delivery.obs_group_id = delivery_date.obs_group_id
	AND inst_delivery.concept_full_name = 'Delivery-Delivery service done by'
RIGHT OUTER JOIN (SELECT answer_concept_name, answer_concept_id FROM concept_answer_view WHERE question_concept_name = 'Caste' ) AS caste_list ON caste_list.answer_concept_id = person_attribute.value
GROUP BY caste_list.answer_concept_name) AS delivery ON delivery.caste_ethnicity = underweight.caste_ethnicity
INNER JOIN
-- Abortion cases
(SELECT
	caste_list.answer_concept_name AS caste_ethnicity,
        IFNULL(COUNT(DISTINCT (person.person_id)), 0) AS abortion_count
FROM visit
INNER JOIN person ON visit.patient_id = person.person_id
	AND DATE(visit.date_stopped) BETWEEN '#startDate#' AND '#endDate#'
INNER JOIN person_attribute ON person_attribute.person_id = person.person_id
INNER JOIN person_attribute_type ON person_attribute.person_attribute_type_id = person_attribute_type.person_attribute_type_id
	AND person_attribute_type.name = 'Caste'
INNER JOIN encounter ON visit.visit_id = encounter.visit_id
INNER JOIN coded_obs_view ON encounter.encounter_id = coded_obs_view.encounter_id
	AND coded_obs_view.concept_full_name = 'SA-visit type'
    AND coded_obs_view.value_concept_full_name IS NOT NULL
    AND coded_obs_view.voided is FALSE
RIGHT OUTER JOIN (SELECT answer_concept_name, answer_concept_id FROM concept_answer_view WHERE question_concept_name = 'Caste' ) AS caste_list ON caste_list.answer_concept_id = person_attribute.value
GROUP BY caste_list.answer_concept_name) AS abortion ON abortion.caste_ethnicity = delivery.caste_ethnicity
INNER JOIN

-- Out patient cases
(select caste_list.answer_concept_name AS caste_ethnicity,
	 SUM(IF(person.gender = 'M', 1, 0)) as op_cases_male,
	 SUM(IF(person.gender = 'F', 1, 0)) as op_cases_female
	from
(SELECT
	 distinct person.person_id,
     person.gender as gender

FROM visit
    INNER JOIN person ON visit.patient_id = person.person_id
	AND DATE(person.date_created) BETWEEN '#startDate#' AND '#endDate#'
	AND TIMESTAMPDIFF(YEAR, person.birthdate, visit.date_started) > 5
JOIN visit_type vt ON visit.visit_type_id = vt.visit_type_id AND vt.name NOT IN('ER','IPD')) person
INNER JOIN person_attribute ON person_attribute.person_id = person.person_id
INNER JOIN person_attribute_type ON person_attribute.person_attribute_type_id = person_attribute_type.person_attribute_type_id
	AND person_attribute_type.name = 'Caste'    
RIGHT OUTER JOIN (SELECT answer_concept_name, answer_concept_id FROM concept_answer_view WHERE question_concept_name = 'Caste' ) AS caste_list ON caste_list.answer_concept_id = person_attribute.value
GROUP BY caste_list.answer_concept_name) AS op_cases ON abortion.caste_ethnicity = op_cases.caste_ethnicity
INNER JOIN

-- In patient cases
(SELECT
	caste_list.answer_concept_name AS caste_ethnicity,
	SUM(IF(person.gender = 'F', 1, 0)) AS ip_cases_female,
    SUM(IF(person.gender = 'M', 1, 0)) AS ip_cases_male
FROM visit
INNER JOIN person ON visit.patient_id = person.person_id
INNER JOIN person_attribute ON person_attribute.person_id = person.person_id
INNER JOIN person_attribute_type ON person_attribute.person_attribute_type_id = person_attribute_type.person_attribute_type_id
	AND person_attribute_type.name = 'Caste'    
INNER JOIN encounter ON visit.visit_id = encounter.visit_id
	AND DATE(encounter.encounter_datetime) BETWEEN '#startDate#' AND '#endDate#'
INNER JOIN coded_obs_view ON encounter.encounter_id = coded_obs_view.encounter_id
	AND coded_obs_view.concept_full_name IN ('Discharge-Inpatient outcome')
    AND coded_obs_view.voided is FALSE
RIGHT OUTER JOIN (SELECT answer_concept_name, answer_concept_id FROM concept_answer_view WHERE question_concept_name = 'Caste' ) AS caste_list ON caste_list.answer_concept_id = person_attribute.value
GROUP BY caste_list.answer_concept_name) AS ip_cases ON op_cases.caste_ethnicity = ip_cases.caste_ethnicity
INNER JOIN

-- In TB cases
(SELECT
	caste_list.answer_concept_name AS caste_ethnicity,
	SUM(IF(person.gender = 'F', 1, 0)) AS tb_cases_female,
    SUM(IF(person.gender = 'M', 1, 0)) AS tb_cases_male
FROM visit
INNER JOIN person ON visit.patient_id = person.person_id
INNER JOIN person_attribute ON person_attribute.person_id = person.person_id
INNER JOIN person_attribute_type ON person_attribute.person_attribute_type_id = person_attribute_type.person_attribute_type_id
	AND person_attribute_type.name = 'Caste'    
INNER JOIN encounter ON visit.visit_id = encounter.visit_id
	AND DATE(encounter.encounter_datetime) BETWEEN '#startDate#' AND '#endDate#'
INNER JOIN coded_obs_view ON encounter.encounter_id = coded_obs_view.encounter_id
	AND coded_obs_view.concept_full_name IN ('TB intake-Diagnosis category')
    AND coded_obs_view.voided is FALSE
RIGHT OUTER JOIN (SELECT answer_concept_name, answer_concept_id FROM concept_answer_view WHERE question_concept_name = 'Caste' ) AS caste_list ON caste_list.answer_concept_id = person_attribute.value
GROUP BY caste_list.answer_concept_name) AS tb_cases ON ip_cases.caste_ethnicity = tb_cases.caste_ethnicity
INNER JOIN
-- In Leprosy cases
(SELECT
	caste_list.answer_concept_name AS caste_ethnicity,
	SUM(IF(person.gender = 'F', 1, 0)) AS leprosy_cases_female,
    SUM(IF(person.gender = 'M', 1, 0)) AS leprosy_cases_male
FROM visit
INNER JOIN person ON visit.patient_id = person.person_id
INNER JOIN person_attribute ON person_attribute.person_id = person.person_id
INNER JOIN person_attribute_type ON person_attribute.person_attribute_type_id = person_attribute_type.person_attribute_type_id
	AND person_attribute_type.name = 'Caste'    
INNER JOIN encounter ON visit.visit_id = encounter.visit_id
	AND DATE(encounter.encounter_datetime) BETWEEN '#startDate#' AND '#endDate#'
INNER JOIN coded_obs_view ON encounter.encounter_id = coded_obs_view.encounter_id
	AND coded_obs_view.concept_full_name IN ('Leprosy-Case type')
    AND coded_obs_view.voided is FALSE
RIGHT OUTER JOIN (SELECT answer_concept_name, answer_concept_id FROM concept_answer_view WHERE question_concept_name = 'Caste' ) AS caste_list ON caste_list.answer_concept_id = person_attribute.value
GROUP BY caste_list.answer_concept_name) AS leprosy_cases ON tb_cases.caste_ethnicity = leprosy_cases.caste_ethnicity;

