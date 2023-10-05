/* Coffee Park SQL Sample by Kyle Nicole Avellanosa. To be used for Dashboarding in BI tool (I used Tableau) */

use coffee_park;

/* For Order Activity Dashboard */
SELECT
	o.order_id,
    i.item_price,
    o.quantity,
    i.item_cat,
    i.item_name,
    o.created_at,
    a.del_address_1,
    a.del_city,
    a.del_zipcode,
    o.delivery
FROM orders o
LEFT JOIN items i ON o.item_id=i.item_id
LEFT JOIN address a ON o.add_id=a.add_id;

/* For stock1 (View) */
SELECT s1.ingre_id,s1.sku,s1.ingre_name,s1.ingre_weight,s1.ingre_meas,s1.ingre_price,s1.recipe_quantity,s1.order_quantity,
		s1.order_quantity*s1.recipe_quantity AS ordered_weight,
        s1.ingre_price/s1.ingre_weight AS unit_cost,
        (s1.order_quantity*s1.recipe_quantity)*(s1.ingre_price/s1.ingre_weight) AS ingredient_cost
        FROM
(SELECT
	i.sku,
    o.item_id,
    r.ingre_id,
    ing.ingre_meas,
    ing.ingre_name AS ingre_name,
    r.quantity AS recipe_quantity,
    SUM(o.quantity) AS order_quantity,
    ing.ingre_weight,
    ing.ingre_price
FROM orders o
LEFT JOIN items i ON o.item_id=i.item_id
LEFT JOIN recipe r ON i.sku=r.recipe_id
LEFT JOIN ingredients ing ON r.ingre_id=ing.ingre_id
GROUP BY i.sku,o.item_id,r.ingre_id,ing.ingre_meas,ing.ingre_name,r.quantity,ing.ingre_weight,ing.ingre_price) s1;

/* For stock2 (View) */
SELECT 
s2.ingre_id,
s2.ingre_name,
s2.total_weight_ordered,
inv.quantity AS inv_quantity,
ing.ingre_weight,
inv.quantity*ing.ingre_weight AS total_stock_weight,
(inv.quantity * ing.ingre_weight)-s2.total_weight_ordered AS remaining_weight_in_stock,
ing.ingre_meas
FROM 
(SELECT
ingre_id,
ingre_name,
SUM(ordered_weight) AS total_weight_ordered
from stock1
group by ingre_id,ingre_name) s2

LEFT JOIN inventory inv ON inv.item_id=s2.ingre_id
LEFT JOIN ingredients ing ON ing.ingre_id=s2.ingre_id;

/* For Staffing Dashboard */
SELECT
ro.date,
st.fname,
st.lname,
st.hrly_rate,
st.position,
sh.start_time,
sh.end_time,
((hour(timediff(sh.end_time,sh.start_time))*60)+(minute(timediff(sh.end_time,sh.start_time))))/60 AS hours_in_shift,
((hour(timediff(sh.end_time,sh.start_time))*60)+(minute(timediff(sh.end_time,sh.start_time))))/60 *st.hrly_rate AS staff_cost
FROM rota ro
LEFT JOIN shift sh ON ro.shift_id=sh.shift_id
LEFT JOIN staff st ON ro.staff_id=st.staff_id;

