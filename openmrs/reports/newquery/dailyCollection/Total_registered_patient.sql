SELECT count(pi.identifier) As "Registred Patient"
                FROM
                (SELECT DISTINCT
                    concat("", v.uuid) AS activeVisitUuid,
                    patient_id         AS patientId
                    FROM visit v
                    WHERE v.date_stopped IS NULL AND v.voided = 0 AND date(v.date_started)  between '#startDate#' and '#endDate#'
                ) AS v
                JOIN person_name pn ON v.patientId = pn.person_id AND pn.voided = 0
                JOIN patient_identifier pi ON v.patientId = pi.patient_id
