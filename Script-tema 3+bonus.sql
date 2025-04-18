SELECT *
FROM facebook_ads_basic_daily;

SELECT *
FROM facebook_adset;

SELECT *
FROM facebook_campaign;

SELECT *
FROM Google_ads_basic_daily;


/* In an SQL query using a CTE, combine the data from the given tables to obtain:

ad_date – the date the ad was shown on Google and Facebook
campaign_name – the name of the campaign on Google and Facebook
spend, impressions, reach, clicks, leads, value – the campaign and ad set metrics for those specific days */

WITH all_data AS 
(SELECT fabd.ad_date, fc.campaign_name, fa.adset_name, spend, impressions, reach, clicks, leads, value
FROM facebook_ads_basic_daily fabd
INNER JOIN facebook_adset fa
	ON fabd.adset_id = fa.adset_id
INNER JOIN facebook_campaign fc
	ON fabd.campaign_id = fc.campaign_id
UNION
SELECT ad_date, campaign_name,adset_name, spend, impressions, reach, clicks, leads, value
FROM google_ads_basic_daily gabd)
	SELECT *
	FROM all_data;

/* Perform a selection from the resulting combined table (CTE):

ad_date – the date the ad was displayed
campaign_name – the name of the campaign
aggregated values for the following metrics, grouped by date and campaign ID: 
total cost, number of impressions, number of clicks, total conversion value */

WITH all_data AS
(SELECT fabd.ad_date, fc.campaign_name, fa.adset_name, spend, impressions, reach, clicks, leads, value
FROM facebook_ads_basic_daily fabd
INNER JOIN facebook_adset fa
	ON fabd.adset_id = fa.adset_id
INNER JOIN facebook_campaign fc
	ON fabd.campaign_id = fc.campaign_id
UNION
SELECT ad_date, campaign_name,adset_name, spend, impressions, reach, clicks, leads, value
FROM google_ads_basic_daily gabd)
	SELECT ad_date, 
	campaign_name, 
	SUM(spend) total_cost, 
	SUM(impressions) number_of_impressions,
	SUM(clicks) number_of_clicks,
	SUM(value) total_conversion_value
	FROM all_data
	GROUP BY ad_date, campaign_name
	ORDER BY ad_date, campaign_name;


/* By combining data from the four tables, find the campaign with the highest ROMI among all campaigns with a total spend greater than 500,000.
Within that campaign, identify the ad set (adset_name) with the highest ROMI. */

WITH all_data AS
(SELECT fabd.ad_date, fc.campaign_name, fa.adset_name, spend, impressions, reach, clicks, leads, value
FROM facebook_ads_basic_daily fabd
INNER JOIN facebook_adset fa
	ON fabd.adset_id = fa.adset_id
INNER JOIN facebook_campaign fc
	ON fabd.campaign_id = fc.campaign_id
UNION
SELECT ad_date, campaign_name,adset_name, spend, impressions, reach, clicks, leads, value
FROM google_ads_basic_daily gabd)
	SELECT campaign_name, adset_name,
	SUM(spend) AS total_spend,
	ROUND ((SUM(value)-SUM(spend))/ SUM(spend) :: NUMERIC *100, 2) AS "ROMI"
	FROM all_data ad
	GROUP BY campaign_name, adset_name
	HAVING SUM(spend) > 500000
	ORDER BY 4 DESC
	LIMIT 1;
