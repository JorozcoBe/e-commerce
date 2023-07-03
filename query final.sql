                SELECT
                       D.product_category_name as category,
                       COUNT(D.product_id) as product_count,
                       date_format(A.order_purchase_timestamp, '%Y-%m') AS YearMonth,
                       COUNT(DISTINCT A.order_id) AS Num_purchase
                FROM   olist.olist_orders_dataset AS A
                LEFT
                JOIN  olist.olist_order_items_dataset AS B
                ON     A.order_id = B.order_id
                LEFT JOIN olist.olist_products_dataset AS D
				ON B.product_id = D.product_id
                WHERE  A.order_status = 'delivered'
                GROUP 
                BY YearMonth
                ORDER 
                BY YearMonth;
                
-- 2nd descriptive

SELECT 
                date_format(d.order_purchase_timestamp,'%Y-%m') AS YearMonth,
                a.product_category_name as category,
                e.payment_type as Payment_type,
                COUNT(DISTINCT d.order_id) AS Num_order,
                SUM(e.payment_value) AS Revenue
              FROM olist.olist_orders_dataset AS d
              LEFT JOIN olist.olist_order_items_dataset AS c ON c.order_id = d.order_id
              LEFT JOIN olist.olist_products_dataset AS a ON c.product_id = a.product_id
              -- LEFT JOIN olist.product_category_name_translation AS b ON a.product_category_name=b.product_category_name
              LEFT JOIN olist.olist_order_payments_dataset AS e ON d.order_id = e.order_id
              -- WHERE  Category IS NOT NULL   
              WHERE    d.order_status <> 'canceled'
              AND    d.order_status <> 'unavailable'
              AND    d.order_delivered_customer_date IS NOT NULL
              -- AND    STRFTIME('%Y-%m', d.order_purchase_timestamp) = '2018-01'
              -- AND    STRFTIME('%Y', d.order_purchase_timestamp) = '2018'
              GROUP
              BY  YearMonth
              -- BY Payment_type
              ORDER
              BY  YearMonth;
-- 3rd descriptive 

SELECT  category,
                product_count,
                score_5,
                count_all,
                ROUND(CAST(score_5 AS float) / CAST(count_all AS float) * 100, 2) AS percentage
        FROM    (
                SELECT
                       D.product_category_name as category,
                       COUNT(D.product_id) as product_count,
                       SUM(CASE WHEN A.review_score = 5 THEN 1 ELSE 0 END) AS score_5,
                       COUNT(DISTINCT A.order_id) AS count_all
                FROM   order_reviews AS A
                LEFT
                JOIN   orders AS B
                ON     A.order_id = B.order_id
                LEFT JOIN order_items AS C
			          ON B.order_id = C.order_id
			          LEFT JOIN products AS D
			          ON C.product_id = D.product_id
                WHERE  B.order_status = 'delivered'
                AND    STRFTIME('%Y', A.review_answer_timestamp) = '2018'
                GROUP
                BY     category
                ORDER 
                BY product_count DESC 
                LIMIT 10
                ) P
