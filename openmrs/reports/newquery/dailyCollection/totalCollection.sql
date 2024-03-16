SELECT 'Collection' as particular, sum(visit_fee) as total  from visit where DATE(date_started) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE);
