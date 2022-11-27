
//Import table Customers
LOAD CSV WITH HEADERS FROM "file:///catemedb/Customers.csv" AS row
CREATE (n:Customers)
SET n = row, n.CustID = row.CustID,
n.CustName = row.CustName, n.Phone = row.Phone,
n.Address = row.Address, n.Suburb = row.Suburb,
n.Rank = toInteger(row.Rank);

//Add constraint and index to CustID
Create constraint CustConstr if not exists for (c: Customers) require c.CustID is unique;

//Import table Orders
LOAD CSV WITH HEADERS FROM "file:///catemedb/Orders.csv" AS row
create (n: Orders)
SET n = row,
n.OrderID = row.OrderID,
n.OrderDate = date(apoc.date.format(apoc.date.parse(row.OrderDate,'ms', 'mm/dd/yyyy'),'ms','yyyy-mm-dd')),
n.PickupTime = row.PickupTime,
n.Notes = row.Notes, n.CustID = row.CustID,
n.StaffID = row.StaffID,n.OrderType = row.OrderType,
n.DisID = row.DisID;

//Add constraint and index to OrderID
Create constraint OrdConstr if not exists for (o: Orders) require o.OrderID is unique;

//link Customers and Orders (one to many)
Match(c:Customers), (o:Orders) where c.CustID = o.CustID create (c)-[:Purchased]->(o);

//Import table OrderType
LOAD CSV WITH HEADERS FROM "file:///catemedb/OrderType.csv" AS row
create (n: OrderType)
SET n = row,
n.OrderTypeID = row.OrderTypeID,
n.OrderName = row.OrderName;

//Add constraint and index on OrderTypeID
Create constraint OrdTypeConstr if not exists for (o: OrderType) require o.OrderTypeID is unique;

//link Orders and OrderType (one to many)
Match(o:Orders), (t:OrderType) where o.OrderTypeID = t.OrderTypeID create (o)-[:ClassifiedAs]->(t);

//Import table Staff
LOAD CSV WITH HEADERS FROM "file:///catemedb/Staff.csv" AS row
create (n: Staff)
SET n = row,
n.StaffID = row.StaffID,
n.Name = row.Name, n.Phone = row.Phone,
n.Address = row.Address, n.RoleID = row.RoleID;

//Add constraint and index on StaffID
Create constraint StaffConstr if not exists for (s: Staff) require s.StaffID is unique;

//Link between Staff and Orders (one to many)
Match(s:Staff), (o:Orders) where s.StaffID = o.StaffID create (s)-[:Booked]->(o);

//Import table Role
LOAD CSV WITH HEADERS FROM "file:///catemedb/Role.csv" AS row
create (n: Role)
SET n = row,
n.RoleID = row.RoleID,
n.Description = row.Description, 
n.BaseRate = toFloat(row.BaseRate);

//Add constraint and index on RoleID
Create constraint RoleConstr if not exists for (r: Role) require r.RoleID is unique;

//Link between Staff and Role (one to many)
Match(s:Staff), (r:Role) where s.RoleID = r.RoleID create (s)-[:AssignedTo]->(r);

//Import table Payment
LOAD CSV WITH HEADERS FROM "file:///catemedb/Payment.csv" AS row
create (n: Payment)
SET n = row,
n.PayID = row.PayID,
n.Amount = toFloat(row.Amount), 
n.Surcharge = toFloat(row.Surcharge),
n.Method = row.Method,
n.OrderID = row.OrderID,
n.StaffID = row.StaffID;

//Add constraint and index on PayID
Create constraint PayConstr if not exists for (p: Payment) require p.PayID is unique;

//Link Payment and Orders (one to one)
Match(p:Payment), (o:Orders) where p.OrderID = o.OrderID create (p)-[:AssociatedWith]->(o);

//Link Payment and Staff (one to many)
Match(p:Payment), (s:Staff) where p.StaffID = s.StaffID create (s)-[:Handled]->(p);

//Import table MenuItems
LOAD CSV WITH HEADERS FROM "file:///catemedb/MenuItems.csv" AS row
create (n: MenuItems)
SET n = row,
n.ItemID = row.ItemID,
n.Name = row.Name,
n.Price = toFloat(row.Price),
n.Ingredient = row.Ingredient,
n.Status = toInteger(row.Status),
n.CatID = row.CatID;

//Add constraint and index on ItemID
Create constraint MenuConstr if not exists for (m: MenuItems) require m.ItemID is unique;

//Link MenuItems and Orders i.e. OrderDetail (many to many)
LOAD CSV WITH HEADERS FROM "file:///catemedb/OrderDetail.csv" AS row
MATCH (order:Orders {OrderID: row.OrderID})
MATCH (item:MenuItems {ItemID: row.ItemID})
MERGE (order)-[c:Contained]->(item)
ON CREATE SET c.Quantity = toInteger(row.Quantity), c.Notes = row.Notes;

//Import table Category
LOAD CSV WITH HEADERS FROM "file:///catemedb/Category.csv" AS row
create (n: Category)
SET n = row,
n.CatID = row.CatID,
n.Name = row.Name;

//Add constraint and index on CatID
Create constraint CatConstr if not exists for (c: Category) require c.CatID is unique;

//Link MenuItems and Category (one to many)
Match(m:MenuItems), (c:Category) where m.CatID = c.CatID create (m)-[:BelongTo]->(c);

//Import table Discount
LOAD CSV WITH HEADERS FROM "file:///catemedb/Discount.csv" AS row
create (n: Discount)
SET n = row,
n.DisID = row.DisID,
n.Notes = row.Notes,
n.DFrom = date(apoc.date.format(apoc.date.parse(row.DFrom,'ms', 'mm/dd/yyyy'),'ms','yyyy-mm-dd')),
n.DTo = date(apoc.date.format(apoc.date.parse(row.DTo,'ms', 'mm/dd/yyyy'),'ms','yyyy-mm-dd'));

//Add constraint and index on DisID
Create constraint DisConstr if not exists for (d: Discount) require d.DisID is unique;

//Link between Orders and Discount (one to many)
Match(o:Orders), (d:Discount) where o.DisID = d.DisID create (o)-[:Applied]->(d);

//Import table ItemDiscount
LOAD CSV WITH HEADERS FROM "file:///catemedb/ItemDiscount.csv" AS row
create (n: ItemDiscount)
SET n = row,
n. ItemDCID= row. ItemDCID,
n.MinPrice = toFloat(row.MinPrice);

//Add constraint and index on ItemDCID
Create constraint ItemDisConstr if not exists for (i:ItemDiscount) require i.ItemDCID is unique;

//Link ItemDiscount and Discount (one to one)
Match(i:ItemDiscount), (d:Discount) where i.ItemDCID = d.DisID create (i)-[:RelatedTo]->(d);

//Link ItemDicount to MenuItems (many to many)
LOAD CSV WITH HEADERS FROM "file:///catemedb/ItemDiscountDetails.csv" AS row
MATCH (i1:ItemDiscount {ItemDCID: row.ItemDCID})
MATCH (i2:MenuItems {ItemID: row.ItemID})
MERGE (i1)-[c:Connected]->(i2)
ON CREATE SET c.Rate = toFloat(row.Rate);


//Import table DillDiscount
LOAD CSV WITH HEADERS FROM "file:///catemedb/BillDiscount.csv" AS row
create (n: BillDiscount)
SET n = row,
n.BillID= row.BillID,
n.MinBill = toFloat(row.MinBill),
n.Rate = toFloat(row.Rate);

//Add constraint and index on BillID
Create constraint BillDisConstr if not exists for (b:BillDiscount) require b.BillID is unique;

//Link BillDiscount and  Dicount (one to one)
Match(b:BillDiscount), (d:Discount) Where b.BillID = d.DisID create (b)-[:LinkedTo]->(d);

