select
  answer.concept_full_name as answer_concept_name,
  gender.gender as gender,
  reporting_age_group_new.name as age_group,
  
  IFNULL(result.total_count,0) as total_count
from
  concept_view AS question
  INNER JOIN concept_answer ON question.concept_id = concept_answer.concept_id AND question.concept_full_name IN ('Discharge-Inpatient outcome')
  INNER JOIN concept_view AS answer ON answer.concept_id = concept_answer.answer_concept
  AND answer.concept_full_name NOT IN ('DOR','LAMA/DAMA','Referred on request')
  INNER JOIN (SELECT DISTINCT value_reference AS type FROM visit_attribute) visit_type 
  INNER JOIN reporting_age_group_new ON reporting_age_group_new.report_group_name = 'Inpatient'
  INNER JOIN (SELECT 'M' as gender UNION SELECT 'F' AS gender) as gender
  LEFT OUTER JOIN (
    SELECT
      obs.value_coded as answer_concept_id,
      obs.concept_id as question_concept_id,
      person.gender as gender,
      reporting_age_group_new.name as age_group,
      count(*) as total_count
    FROM
      obs
      INNER JOIN concept_view question on obs.concept_id = question.concept_id and question.concept_full_name IN ('Discharge-Inpatient outcome')
      INNER JOIN person on obs.person_id = person.person_id
      INNER JOIN encounter on obs.encounter_id = encounter.encounter_id
      INNER  JOIN visit on encounter.visit_id = visit.visit_id
      INNER JOIN reporting_age_group_new on cast(obs.obs_datetime AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL reporting_age_group_new.min_years YEAR), INTERVAL reporting_age_group_new.min_days DAY))
                                        AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL reporting_age_group_new.max_years YEAR), INTERVAL reporting_age_group_new.max_days DAY))
                                        AND reporting_age_group_new.report_group_name = "Inpatient"
   WHERE CAST(visit.date_stopped  as DATE) BETWEEN DATE('#startDate#') AND DATE('#endDate#')
    group by obs.concept_id, obs.value_coded, reporting_age_group_new.name, person.gender
  ) result on question.concept_id = result.question_concept_id
              and answer.concept_id = result.answer_concept_id
              and gender.gender = result.gender
              and result.age_group = reporting_age_group_new.name
GROUP BY question.concept_full_name, answer.concept_full_name, gender.gender, reporting_age_group_new.name
-- ORDER BY answer.concept_full_name,reporting_age_group_new.sort_order,gender.gender;
ORDER BY answer.concept_full_name, FIELD(reporting_age_group_new.name, '≤ 7 Days','8 - 28 Days','29 Days ‐ 1 Year','01 ‐ 04 Years','05 ‐ 14 years','15 ‐ 19 Years','20 ‐ 29 Years','30 ‐ 39 Years','40 ‐ 49 Years','50 ‐ 59 Years','60 ‐ 69 Years','≥ 70 Years'), gender.gender ;