select ifnull(u.username,'Total') as User,sum(visit_fee) as Collection from visit v
 inner join users u on u.user_id = v.creator 
 where v.voided = 0 and date(v.date_created) between '#startDate#' and '#endDate#'
 and v.patient_id not in (
 select pa.person_id from  person_attribute pa where pa.person_attribute_type_id = 26 and pa.voided =0
 )
 group by u.username WITH ROLLUP