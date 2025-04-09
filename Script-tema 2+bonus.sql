/* Write an SQL query that selects the following from the facebook_ads_basic_daily table:
ad_date – the date the ad was shown,
campaign_id – the unique campaign ID
1. Aggregate the data by date and campaign ID, and calculate the following metrics:
Total cost, Number of impressions, Number of clicks, Total conversion value

2. Using the aggregated values, calculate these performance indicators:

CPC (Cost Per Click)
CPM (Cost Per Mille / 1000 Impressions)
CTR (Click-Through Rate)
ROMI (Return on Marketing Investment)

Group the results by ad_date and campaign_id. */

SELECT 
ad_date, 
campaign_id, 
SUM(spend) AS total_spendings, 
SUM(impressions) AS total_impressions, 
SUM(clicks) AS total_clicks, 
SUM(leads) AS total_conversion,
ROUND (SUM(spend) / SUM(clicks) :: NUMERIC, 2) AS "CPC",
ROUND (SUM(spend)/ SUM(impressions) :: NUMERIC * 1000, 2) AS "CPM",
ROUND (SUM(clicks)/ SUM(impressions) :: NUMERIC *100, 2)  AS "CTR",
ROUND ((SUM(value)-SUM(spend))/ SUM(spend) :: NUMERIC * 100, 2)  AS "ROMI"
FROM facebook_ads_basic_daily
WHERE clicks > 0
GROUP BY ad_date, campaign_id;

/* Find the campaign with the highest ROMI, but only among those that spent more than 500,000 in total. */ 
SELECT campaign_id,
SUM(spend) AS total_spendings,
ROUND ((SUM(value)-SUM(spend))/ SUM(spend) :: NUMERIC * 100, 2)  AS "ROMI"
FROM facebook_ads_basic_daily
GROUP BY campaign_id
HAVING  SUM(spend) > 500000
ORDER BY ROUND ((SUM(value)-SUM(spend))/ SUM(spend) :: NUMERIC * 100, 2) DESC
LIMIT 1;
