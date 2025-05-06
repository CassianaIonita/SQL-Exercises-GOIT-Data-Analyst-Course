/*  In a CTE query, combine the data from tables to obtain:

ad_date – the date the ad was displayed on Google and Facebook
url_parameters – the part of the campaign link URL that contains the UTM parameters
spend, impressions, reach, clicks, leads, value – daily metrics for the campaigns and ad sets

!If any of the metric values in the table are null, replace them with zero (0).

From the resulting CTE, perform an aggregation:
ad_date – the date of the ad
utm_campaign – the value of the utm_campaign parameter extracted from the url_parameters field, meeting the following conditions:

- it is converted to lowercase
- if the utm_campaign value is equal to "nan", it should appear as null in the result table

Return the total spend, number of impressions, number of clicks, and total conversion value for a specific date and campaign.
Also calculate: CTR, CPC, CPM, and ROMI. */
WITH all_data AS
(
SELECT ad_date,
SUBSTRING(url_parameters, 49) AS utm_param,
COALESCE(spend, 0) AS spend, 
COALESCE(impressions, 0) AS impressions,
COALESCE(reach, 0) AS reach,
COALESCE(clicks, 0) AS clicks,
COALESCE(leads, 0) AS leads,
COALESCE(value, 0) AS value
FROM facebook_ads_basic_daily fabd
UNION ALL 
SELECT ad_date,
SUBSTRING(url_parameters, 47),
COALESCE(spend, 0) AS spend, 
COALESCE(impressions, 0),
COALESCE(reach, 0),
COALESCE(clicks, 0),
COALESCE(leads, 0),
COALESCE(value, 0)
FROM google_ads_basic_daily gabd)
SELECT ad_date,
CASE
	WHEN utm_param != 'nan'
	THEN LOWER(utm_param) 
	ELSE NULL 
	END AS utm_campaign,
SUM(spend) AS total_spend,
SUM(impressions) AS total_impressions,
SUM(clicks) AS total_clicks,
SUM(leads) AS total_leads,
SUM(value) AS total_value,
CASE 
	WHEN SUM(clicks) != 0 THEN ROUND(SUM(spend)/SUM(clicks) :: NUMERIC, 2)
	ELSE 0
END AS "CPC",
CASE  
	WHEN SUM(impressions) != 0 THEN ROUND((SUM(spend) / SUM(impressions) :: NUMERIC * 1000), 2)
	ELSE 0
END AS "CPM",
CASE  
	WHEN  SUM(impressions) != 0 THEN ROUND ((SUM(clicks) / SUM(impressions) :: NUMERIC * 100), 2)
	ELSE 0
END AS "CTR",
CASE  
	WHEN sum (spend) != 0 THEN ROUND(((SUM(value)-SUM(spend))/SUM(spend) :: NUMERIC * 100), 2)
	ELSE 0
END AS "ROMI"
FROM all_data
WHERE ad_date IS NOT NULL
GROUP BY 1, 2
ORDER BY 1;
