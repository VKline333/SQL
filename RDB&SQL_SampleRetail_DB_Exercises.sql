---- C-11 WEEKLY AGENDA-7 RD&SQL STUDENT

---- 1. List all the cities in the Texas and the numbers of customers in each city.----
---Teksas'taki tüm þehirleri ve her þehirdeki müþteri sayýsýný listeleyin.

select *
from sale.customer
where state='TX'

select city, count(customer_id) as number_of_customer
from sale.customer
where state='TX'
group by city


---- 2. List all the cities in the California which has more than 35 customer, by showing the cities which have more customers first.---
--Kaliforniya'da 35'ten fazla müþterisi olan tüm þehirleri, önce daha fazla müþterisi olan þehirleri göstererek listeleyin.

select city, count(customer_id) as number_of_customer
from sale.customer
where state='CA'
group by city
having count(customer_id)>35
order by number_of_customer desc


select city, count(customer_id) as number_of_customer
from sale.customer
where state='CA' and count(customer_id)>35    -- where clause agg fonksiyonu çalýþtýrmýyor ve having clause kullanýlmasý gerekiyor
group by city
order by number_of_customer desc

---- 3. List the top 10 most expensive products----
--En pahalý 10 ürünü listeleyin

select top 10 product_name, list_price
from product.product
order by list_price desc


---- 4. List store_id, product name and list price and the quantity of the products which are located in the store id 2 and the quantity is greater than 25----
-- store id 2'de bulunan ve miktarý 25'ten büyük olan ürünlerin, 
--store_id, product name and list price and the quantity of the products sütunlarýný listeleyin.

select store_id, product_name, quantity, list_price
from [product].[product] p, [product].[stock] s
where p.product_id=s.product_id and s.store_id = 2 and s.quantity > 25


---- 5. Find the sales order of the customers who lives in Boulder order by order date--
--Boulder'de yaþayan müþterilerin satýþ sipariþini sipariþ tarihine göre bulun

--solution 1--

select sc.first_name, sc.last_name, sc.city, so.order_id, so.order_date
from [sale].[customer] sc,[sale].[orders] so
where sc.customer_id = so.customer_id and sc.city = 'Boulder'
order by so.order_date 

--solution 2--

SELECT	sc.first_name, sc.last_name, sc.city, so.order_id, so.order_date
FROM	sale.customer sc
JOIN	sale.orders so
		ON sc.customer_id=so.customer_id
WHERE	sc.city='Boulder'
ORDER BY so.order_date

---- 6. Get the sales by staffs and years using the AVG() aggregate function.
--AVG() aggregate fonksiyonunu kullanarak personele ve yýllara göre satýþlarý elde edin.

--solution 1--

select ss.staff_id, first_name, last_name, year(so.order_date), 
		avg(soi.quantity*soi.list_price*(1-soi.discount)) as sales_quantity
from [sale].[orders] so
join [sale].[order_item] soi
on so.order_id = soi.order_id
join [sale].[staff] ss
on ss.staff_id = so.staff_id
group by ss.staff_id, first_name, last_name, year(so.order_date)
order by ss.staff_id, year(so.order_date),sales_quantity

--solution 2--

select ss.staff_id, first_name, last_name, year(so.order_date), 
		avg(soi.quantity*soi.list_price*(1-soi.discount)) as sales_quantity
from [sale].[orders] so, [sale].[order_item] soi, [sale].[staff] ss
where so.order_id = soi.order_id and ss.staff_id = so.staff_id
group by ss.staff_id, first_name, last_name, year(so.order_date)
order by ss.staff_id, year(so.order_date),sales_quantity

---- 7. What is the sales quantity of product according to the brands and sort them highest-lowest----
--Ürünlerin satýþ miktarý markalara göre nedir ? en yüksek-en düþük seviyelere göre sýralayýn.

--solution 1--

select brand_name, product_name, count(quantity) as quantity_of_product
from product.product p
join product.brand b
on p.brand_id=b.brand_id
join [sale].[order_item] s
on p.product_id=s.product_id
group by brand_name, product_name
order by quantity_of_product desc

--solution 2--

SELECT brand_name, p.product_name, COUNT(quantity) as 'quantity of products'
FROM product.brand b, product.product p, sale.order_item o
where b.brand_id = p.brand_id
	and o.product_id=p.product_id
GROUP BY brand_name, p.product_name
order by COUNT(P.product_id) desc

---- 8. What are the categories that each brand has?----
--Her markanýn sahip olduðu kategoriler nelerdir?

--solution 1--

select brand_name, category_name
from product.product p
join product.brand b
on p.brand_id=b.brand_id
join  product.category c
on p.category_id=c.category_id
group by brand_name, category_name
order by brand_name 

--solution 2--

select brand_name, category_name
from product.product p, product.brand b, product.category c
where b.brand_id=p.brand_id and 
	  p.category_id = c.category_id
group by brand_name, category_name
order by brand_name

---- 9. Select the avg prices according to brands and categories----
--Markalara ve kategorilere göre ortalama fiyatlarý seçin

--solution 1--

select [brand_name],[category_name], avg([list_price]) as avg_price
from [product].[product] p
join [product].[brand] b 
on p.brand_id=b.brand_id
join [product].[category] c
on p.category_id=c.category_id
group by brand_name, category_name
order by brand_name, category_name

--solution 2--

select brand_name, category_name, avg(p.list_price) as avg_price
from product.product p, product.brand b, product.category c
where b.brand_id=p.brand_id and 
	  p.category_id = c.category_id
group by brand_name, category_name
order by brand_name, category_name

---- 10. Select the annual amount of product produced according to brands----
--Markalara göre üretilen yýllýk ürün miktarýný seçin

--solution 1--

select brand_name, model_year, sum(s.quantity) as annual_amount
from [product].[product] p
join [product].[stock] s
on p.product_id=s.product_id
join [product].[brand] b
on p.brand_id=b.brand_id
group by brand_name, model_year
order by brand_name, model_year

--solution 2--

select b.brand_name,p.model_year, sum(s.quantity) 'annual amount'
from product.product p, product.brand b, product.stock s
where p.brand_id=b.brand_id and p.product_id=s.product_id
group by b.brand_name,p.model_year
order by brand_name, model_year

---- 11. Select the store which has the most sales quantity in 2016.----
--2016 yýlýnda en fazla satýþ miktarýna sahip maðazayý seçin.

select top 1 s.store_name, sum(i.quantity)
from sale.store s
inner join sale.orders o
on s.store_id = o.store_id
inner join sale.order_item i
on o.order_id = i.order_id
where  year(o.order_date) = '2016' 
group by s.store_name
order by sum(i.quantity) desc;

---- 12 Select the store which has the most sales amount in 2018.----
--2018'de en fazla satýþ tutarýna sahip maðazayý seçin

--solution 1--

select top 1 s.store_name, sum(i.list_price) as amount_sales
from sale.store s
inner join sale.orders o
on s.store_id = o.store_id
inner join sale.order_item i
on o.order_id = i.order_id
where  year(o.order_date) = '2018' 
group by s.store_name
order by sum(i.list_price) desc;

--solution 2--

select top 1 s.store_name, sum(i.list_price) as amount_sales
from sale.store s, sale.orders o, sale.order_item i
where s.store_id = o.store_id and o.order_id = i.order_id and year(o.order_date) = '2018' 
group by s.store_name
order by sum(i.list_price) desc;

---- 13. Select the personnel which has the most sales amount in 2019.----
--2019 yýlýnda en fazla satýþ tutarýna sahip personeli seçin.

--solution 1--

select top 1 s.first_name, s.last_name, sum(i.list_price) as amount_sales
from sale.staff s
inner join sale.orders o
on s.staff_id = o.staff_id
inner join sale.order_item i
on o.order_id = i.order_id
where  year(o.order_date) = '2019' 
group by s.first_name, s.last_name
order by sum(i.list_price) desc;

--solution 2--

select top 1 s.first_name+' '+s.last_name, sum(i.list_price) as amount_sales
from sale.staff s, sale.orders o, sale.order_item i
where s.staff_id = o.staff_id and o.order_id = i.order_id and year(o.order_date) = '2019' 
group by s.first_name+' '+s.last_name
order by sum(i.list_price) desc;