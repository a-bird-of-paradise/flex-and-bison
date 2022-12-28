create database my_db;

create table my_db.my_table (
    ID BIGINT NOT NULL PRIMARY KEY,
    NAME varchar(255),
    Address1 varchar(255),
    Address2 varchar(255),
    Thing INT NOT NULL,
    Price DECIMAL(18,2)
);

select * from my_db.my_table where Thing = 3 order by Price desc;

SELECT
c.calendar_date,
c.calendar_year,
c.calendar_month,
c.calendar_dayname,
COUNT(DISTINCT sub.order_id) AS num_orders,
COUNT(sub.book_id) AS num_books,
SUM(sub.price) AS total_price,
SUM(COUNT(sub.book_id)) AS running_total_num_books,
LAG(COUNT(sub.book_id), 7) AS prev_books
FROM calendar_days c
LEFT JOIN (
  SELECT
  DATE_FORMAT(co.order_date, '%Y-%m') AS order_month,
  DATE_FORMAT(co.order_date, '%Y-%m-%d') AS order_day,
  co.order_id,
  ol.book_id,
  ol.price
  FROM cust_order co
  INNER JOIN order_line ol ON co.order_id = ol.order_id
) sub ON c.calendar_date = sub.order_day
GROUP BY c.calendar_date, c.calendar_year, c.calendar_month, c.calendar_dayname
ORDER BY c.calendar_date ASC;