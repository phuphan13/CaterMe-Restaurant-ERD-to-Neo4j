//Query 1 - Show MenuItem with price greater than 15$
match(m:MenuItems)
where m.Price >=15 
return m.Name as Name,m.ItemID as ItemID, m.Price as Price order by m.Price desc;


//Query 2 - The owner to know which type of method is prefered by the Customers
match(p:Payment) 
return p.Method as Method, count(p.Method) as Frequency;


//Query 3 - Show the number of order per day in October 2022
Match(o:Orders)<-[r:AssociatedWith]-(p:Payment) 
return o.OrderDate as OrderDate, count(o.OrderID) as Quantity, sum(p.Amount) as DailyIncome order by o.OrderDate asc;


//Query 4 - Find the top selling product by revenue at Cater Me
Match(m:MenuItems)<-[co:Contained]-() 
with m,co.Quantity * m.Price as Revenue
return  m.Name as Name, sum(Revenue) as Total_Revenue
order by sum(Revenue) desc;


//Query 5 - Find all registered customers who have total payment more than 40$ in Oct 2022 
Match(c:Customers)-[pu:Purchased]->(o:Orders)
where c.CustID <>"Cus000" and o.OrderDate >= date("2022-10-01") and o.OrderDate <=date("2022-10-07")
Match(o:Orders)<-[a:AssociatedWith]-(p:Payment)
with c, sum(p.Amount) as totalAmt, sum(toInteger(p.Surchage)) as charge
where totalAmt+charge >40
return c.CustID as CustomerID, c.CustName as Name, c.Phone as Phone, c.Address as Address, c.Suburb as Suburb, c.Rank as Rank, (totalAmt+charge) as Total_Pay
order by totalAmt+charge desc;


//Query 6 - Find the food that has highest sale revenue in October 2022
Match(ca:Category)<-[b:BelongTo]-(m:MenuItems)<-[co:Contained]-(o:Orders) 
with m,o,ca,co.Quantity * m.Price as Revenue
where o.OrderDate >=date("2022-10-01") and o.OrderDate <=date("2022-10-30")
return m.ItemID as ItemID, m.Name as Name,m.Price as Price, ca.Name as Category, sum(Revenue) as Revenue
order by sum(Revenue) desc limit 1;

//Question 4 

//Jaccard coefficient for similarity check

//Based on the item that customers purchased
match(c1:Customers)-[:Purchased]->(Orders)-[:Contained]->(m1:MenuItems)
with c1, collect(id(m1)) as MenuItem1
match(c2:Customers)-[:Purchased]->(Orders)-[:Contained]->(m2:MenuItems) where c1.CustID <> c2.CustID and c1.CustID <>"Cus000" and c2.CustID <>"Cus000"
with c1, MenuItem1,c2, collect(id(m2)) as MenuItem2
return c1.CustName as Customer1, c2.CustName as Customer2, 
gds.similarity.jaccard(MenuItem1, MenuItem2) as Food_similarity
order by Food_similarity Desc;


//Based on the order type of the respective orther
match(c1:Customers)-[:Purchased]->(Orders)-[:ClassifiedAs]->(o1:OrderType)
with c1, collect(id(o1)) as Type1
match(c2:Customers)-[:Purchased]->(Orders)-[:ClassifiedAs]->(o2:OrderType) where c1.CustID <> c2.CustID and c1.CustID <>"Cus000" and c2.CustID <>"Cus000"
with c1, Type1,c2, collect(id(o2)) as Type2
return c1.CustName as Customer1, c2.CustName as Customer2, 
gds.similarity.jaccard(Type1, Type2) as OrderType_similarity
order by OrderType_similarity Desc;


