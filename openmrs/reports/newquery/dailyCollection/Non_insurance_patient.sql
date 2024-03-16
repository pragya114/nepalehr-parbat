SELECT pi.identifier,
       concat_ws(' ', pn.given_name, pn.middle_name, pn.family_name) AS 'Full Name',
       u.username AS USER,
       visit_fee AS Fee,
       cn.name AS 'Visit_Type',
       o.obs_datetime AS 'DateTime'
FROM visit v
INNER JOIN users u ON u.user_id = v.creator
INNER JOIN patient_identifier pi ON pi.patient_id = v.patient_id
INNER JOIN person_name pn ON pn.person_id = v.patient_id
INNER JOIN encounter e ON e.visit_id = v.visit_id
AND e.voided =0
INNER JOIN obs o ON o.encounter_id = e.encounter_id
AND o.voided = 0
INNER JOIN concept_name cn ON cn.concept_id = o.value_coded
AND cn.voided =0
AND cn.concept_name_type = 'FULLY_SPECIFIED'
INNER JOIN concept_name cn1 ON cn1.concept_id = o.concept_id
AND cn1.name = 'Ticket Fee'
AND cn1.voided =0
AND cn1.concept_name_type = 'FULLY_SPECIFIED'
WHERE v.voided = 0
  AND date(v.date_created) BETWEEN '#startDate#' AND '#endDate#'
  AND v.patient_id not in
    (SELECT pa.person_id
     FROM person_attribute pa
     WHERE pa.person_attribute_type_id = 26
       AND pa.voided = 0 )