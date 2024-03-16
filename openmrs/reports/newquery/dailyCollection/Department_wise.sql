SELECT 
  COALESCE(u.username, 'Grand Total') AS username,
  SUM(IF(o.value_coded='9236', 1, 0)) AS 'OPD',
  SUM(IF(o.value_coded='9237', 1, 0)) AS 'Emergency',
  SUM(IF(o.value_coded='9260', 1, 0)) AS 'EHS',
  SUM(IF(o.value_coded='9261', 1, 0)) AS 'Follow-UP',
  SUM(IF(o.value_coded='9262', 1, 0)) AS 'Free Follow-UP',
  SUM(IF(o.value_coded='9269', 1, 0)) AS 'POOR',  
  SUM(IF(o.value_coded='9266', 1, 0)) AS 'Disable',
  SUM(IF(o.value_coded='9270', 1, 0)) AS 'Senior Citizen',
  SUM(IF(o.value_coded='9267', 1, 0)) AS 'FCHB',
  SUM(IF(o.value_coded='9276', 1, 0)) AS 'Below 10',
  SUM(IF(o.value_coded='9274', 1, 0)) AS 'Free Ticket',
  SUM(IF(o.value_coded='9277', 1, 0)) AS 'Above 60',
  SUM(IF(o.value_coded='9522', 1, 0)) AS 'Free Health Camp'
  FROM obs o
INNER JOIN users u ON u.user_id = o.creator
WHERE o.concept_id=9235 AND DATE(o.obs_datetime) BETWEEN '#startDate#' AND '#endDate#' AND o.value_coded IN (9236,9237,9260,9261,9262,9269,9266,9270,9267,9276,9274,9277,9522) AND o.voided = 0 
GROUP BY u.username WITH ROLLUP

