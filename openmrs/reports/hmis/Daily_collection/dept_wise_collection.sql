select 
 all_details.visit_type as 'Visit Type',
 count(1) as 'Patient Count',
 sum(all_details.fee) as 'Total Collection'
from


(select 
person_details.identifier as 'Patient Id',
person_details.Name,
person_details.Date,
person_details.User ,
person_details.patient_id,
vt.name as visit_type,
vt.visit_fee as fee from

(SELECT 
    pi.identifier,
	pi.patient_id as patient_id,

    IF(pn.middle_name IS NULL,
        CONCAT(pn.given_name, ' ', pn.family_name),
        CONCAT(pn.given_name, ' ', pn.middle_name, ' ', pn.family_name)) AS 'Name',
    v.date_started AS 'Date',
    v.visit_type_id as 'Type',
    u.username AS 'User'

FROM
    patient_identifier pi
        JOIN
    person_name pn ON pn.person_id = pi.patient_id
        JOIN
        
    visit v ON v.patient_id = pn.person_id
        AND CAST(v.date_started AS DATE) BETWEEN '#startDate#' AND '#endDate#'
        INNER JOIN
    users u ON u.user_id = v.creator ) person_details  
        left join
	visit_type vt ON vt.visit_type_id = person_details.type)  all_details
	
	where patient_id not in (SELECT 
								pi.patient_id

								FROM
								patient_identifier pi
									JOIN
								person_attribute pa on pa.person_attribute_type_id ='26' and pa.person_id=pi.patient_id
								join
								visit v ON v.patient_id = pa.person_id
									AND CAST(v.date_started AS DATE) BETWEEN  '#startDate#' AND '#endDate#'
								INNER JOIN
								users u ON u.user_id = v.creator
							)
    
    group by all_details.visit_type
    
    
    UNION 
    
    select 
 "Total" as 'Visit Type',
 count(1) as 'Patient Count',
 sum(all_details.fee) as 'Total Collection'
from


(select 
person_details.identifier as 'Patient Id',
person_details.Name,
person_details.Date,
person_details.User ,
person_details.patient_id,
vt.name as visit_type,
vt.visit_fee as fee from

(SELECT 
    pi.identifier,
	pi.patient_id as patient_id,

    IF(pn.middle_name IS NULL,
        CONCAT(pn.given_name, ' ', pn.family_name),
        CONCAT(pn.given_name, ' ', pn.middle_name, ' ', pn.family_name)) AS 'Name',
    v.date_started AS 'Date',
    v.visit_type_id as 'Type',
    u.username AS 'User'

FROM
    patient_identifier pi
        JOIN
    person_name pn ON pn.person_id = pi.patient_id
        JOIN
        
    visit v ON v.patient_id = pn.person_id
        AND CAST(v.date_started AS DATE) BETWEEN '#startDate#' AND '#endDate#'
        INNER JOIN
    users u ON u.user_id = v.creator ) person_details  
        left join
	visit_type vt ON vt.visit_type_id = person_details.type)  all_details
	
	where patient_id not in (SELECT 
								pi.patient_id

								FROM
								patient_identifier pi
									JOIN
								person_attribute pa on pa.person_attribute_type_id ='26' and pa.person_id=pi.patient_id
								join
								visit v ON v.patient_id = pa.person_id
									AND CAST(v.date_started AS DATE) BETWEEN  '#startDate#' AND '#endDate#'
								INNER JOIN
								users u ON u.user_id = v.creator
							)
    
    
