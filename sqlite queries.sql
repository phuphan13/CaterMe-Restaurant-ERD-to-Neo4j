--Select all the rows from 7 to 290 to create table and insert data

--========================================================================================================================================
--DDL SCRIPTS FOR DROPPING AND CREATING TABLES

-- Dropping all existing tables
DROP TABLE IF EXISTS PreOrders;
DROP TABLE IF EXISTS OrderDetail;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS OrderType;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS ItemDiscountDetails;
DROP TABLE IF EXISTS ItemDiscount;
DROP TABLE IF EXISTS BillDiscount;
DROP TABLE IF EXISTS MenuItems;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Discount;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Role;


CREATE TABLE IF NOT EXISTS Customers (
    CustID NVARCHAR(6) NOT NULL PRIMARY KEY,
    CustName NVARCHAR(50) NOT NULL,
    Phone NVARCHAR(11) NOT NULL,
    Address NVARCHAR(50) NOT NULL,
    Suburb NVARCHAR(20) NOT NULL,
    Rank NVARCHAR(10) NOT NULL DEFAULT 0 --it is used to rank customer loyalty program
);

--*** NOTE: It looks like our SQLite version doesn't support Alter table to add constraint or alter column as queries below
--ALTER TABLE Customers ALTER Rank SET DEFAULT 0; 

CREATE TABLE IF NOT EXISTS Category (
    CatID NVARCHAR(2) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS MenuItems (
    ItemID NVARCHAR(4) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Price FLOAT NOT NULL,
    Ingredient NVARCHAR(100) NOT NULL DEFAULT '',
    Status INTERGER(1) NOT NULL DEFAULT 0,
    CatID NVARCHAR(2) NOT NULL,    
    FOREIGN KEY (CatID) REFERENCES Category(CatID) 
);

CREATE TABLE IF NOT EXISTS Discount (
    DisID NVARCHAR(2) PRIMARY KEY,
    Notes NVARCHAR(50) NOT NULL,
    DFrom DateTime NOT NULL,
    DTo DateTime NOT NULL
);

CREATE TABLE IF NOT EXISTS BillDiscount (
    BillID NVARCHAR(2) PRIMARY KEY,
    MinBill FLOAT NOT NULL,
    Rate FLOAT NOT NULL,
    FOREIGN KEY (BillID) REFERENCES Discount(DisID) ON DELETE CASCADE ON UPDATE CASCADE --constraint when deletion/update made on the DisID from Discount table 
);

CREATE TABLE IF NOT EXISTS ItemDiscount (
    ItemDCID NVARCHAR(2) PRIMARY KEY,
    MinPrice FLOAT NOT NULL DEFAULT 0, --min price to be applied the discount per item
    FOREIGN KEY (ItemDCID) REFERENCES Discount(DisID) ON DELETE CASCADE ON UPDATE CASCADE --constraint when deletion/update made on the DisID from Discount table
    
);

CREATE TABLE IF NOT EXISTS ItemDiscountDetails (   
    ItemDCID NVARCHAR(2) NOT NULL,
    ItemID NVARCHAR(4) NOT NULL,
    Rate FLOAT NOT NULL,
    PRIMARY KEY (ItemDCID, ItemID),
    FOREIGN KEY (ItemDCID) REFERENCES ItemDiscount(ItemDCID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ItemID) REFERENCES MenuItems(ItemID) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS OrderType (
    OrderTypeID NVARCHAR(2) PRIMARY KEY, 
    Name NVARCHAR(50) NOT NULL CONSTRAINT CC2 CHECK(Name IN ('In-house Order','Phone','Website','Uber Eats','DoorDash','MenuLog'))
);

CREATE TABLE IF NOT EXISTS Orders(
    OrderID NVARCHAR(7) PRIMARY KEY,
    OrderDate DATETIME NOT NULL,
    PickupTime TIME DEFAULT NULL,
    Notes NVARCHAR(50) NOT NULL DEFAULT '',
    CustID NVARCHAR(6) NOT NULL,
    StaffID NVARCHAR(2) NOT NULL,
    OrderTypeID NVARCHAR(2) NOT NULL,
    DisID NVARCHAR(2) DEFAULT NULL,
    FOREIGN KEY (CustID) REFERENCES Customers(CustID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    FOREIGN KEY (OrderTypeID) REFERENCES OrderType(OrderTypeID),
    FOREIGN KEY (DisID) REFERENCES Discount(DisID)
);


CREATE TABLE IF NOT EXISTS OrderDetail (
    OrderID NVARCHAR(7) NOT NULL,
    ItemID NVARCHAR(4) NOT NULL,
    Quantity INTERGER NOT NULL,
    Notes NVARCHAR(50) NOT NULL,
    PRIMARY KEY (OrderID, ItemID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ItemID) REFERENCES MenuItems(ItemID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Payment (
    PayID NVARCHAR(7) PRIMARY KEY,
    Amount FLOAT NOT NULL,
    Surchage FLOAT DEFAULT 0 NOT NULL,
    Method NVARCHAR(10) NOT NULL CONSTRAINT CC1 CHECK(Method IN ('Cash','Card','Bank')),
    OrderID NVARCHAR(7) NOT NULL,
    StaffID NVARCHAR(2),--Staff who handle payment, is not required to be same as staff who take and book order
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
    
);

CREATE TABLE IF NOT EXISTS Role (
    RoleID NVARCHAR(2) PRIMARY KEY,
    Description NVARCHAR(20) NOT NULL CONSTRAINT CC3 CHECK(Description IN ('Admin','Supervisor','Front Staff')),
    BaseRate FLOAT NOT NULL
);

CREATE TABLE IF NOT EXISTS Staff(
    StaffID NVARCHAR(2) PRIMARY KEY, 
    Name NVARCHAR(20) NOT NULL,
    Phone NVARCHAR(10) NOT NULL,
    Address NVARCHAR(50) NOT NULL,
    RoleID NVARCHAR(2) NOT NULL,
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);

--===============================================================================================================================================
--DML SCRIPTS FOR INSERTING DATA

--Customers 
INSERT INTO Customers(CustID, CustName, Phone, Address, Suburb) VALUES('Cus000','Anonymous','Anonymous','Anonymous','Anonymous');
INSERT INTO Customers(CustID, CustName, Phone, Address, Suburb) VALUES('Cus001','Frank, Tim','08-63836744','9 Charlotte Street','Parap');
INSERT INTO Customers(CustID, CustName, Phone, Address, Suburb) VALUES('Cus002','Hendricks, Dan','04-34941764','120 Mitchell Street','Larrakeyah');
INSERT INTO Customers(CustID, CustName, Phone, Address, Suburb) VALUES('Cus003','Nitka, Clarence','04-01037898','21 Killuppa Crescent','Leanyer');
INSERT INTO Customers(CustID, CustName, Phone, Address, Suburb) VALUES('Cus004','Pascoe, Paul','04-23063383','46 Macredie street','Nakara');
INSERT INTO Customers(CustID, CustName, Phone, Address, Suburb) VALUES('Cus005','McDonald, Tom','08-02817398','30 Halkitis court','Coconut Grove');
INSERT INTO Customers(CustID, CustName, Phone, Address, Suburb) VALUES('Cus006','Samuel, Hopkins','08-02772942','2/2 Ambrosiro court','Parap');

--Roles and Staff
INSERT INTO Role(RoleID, Description, BaseRate) VALUES('01','Admin',2.0);
INSERT INTO Role(RoleID, Description, BaseRate) VALUES('02','Supervisor',1.25);
INSERT INTO Role(RoleID, Description, BaseRate) VALUES('03','Front Staff',1.0);
INSERT INTO Staff(StaffID, Name, Phone, Address,RoleID) VALUES('01','Linsey','04-24583999','Nightcliff foreshore','01');
INSERT INTO Staff(StaffID, Name, Phone, Address,RoleID) VALUES('02','Alvin','04-23078255','Parap Market','02');
INSERT INTO Staff(StaffID, Name, Phone, Address,RoleID) VALUES('03','Huong','04-31037712','Bayview Boulevard','03');
INSERT INTO Staff(StaffID, Name, Phone, Address,RoleID) VALUES('04','Julie','04-22446997','Coconut Grove','03');

--Category and Menu Items
INSERT INTO Category(CatID, Name) VALUES('01','Appetizers');
INSERT INTO Category(CatID, Name) VALUES('02','Banh Mi');
INSERT INTO Category(CatID, Name) VALUES('03','Noodle Soups');
INSERT INTO Category(CatID, Name) VALUES('04','Vermicelli Noodle Salad');
INSERT INTO Category(CatID, Name) VALUES('05','Broken Rice');
INSERT INTO Category(CatID, Name) VALUES('06','Drinks');
INSERT INTO Category(CatID, Name) VALUES('07','Desserts');
INSERT INTO Category(CatID, Name) VALUES('08','Platters');
   
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT01','Pork Spring Rolls (2pcs)',5.0,'Rolll filled with vegetables, pork mince wrapped in a thin, crispy exterior','01');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT02','Rice Paper Rolls - Pork (2pcs)',7.0,'Pork meat or chop wrapped in rice paper with salad, vermicelli, and hoisin peanut sauce','01');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT03','Rice Paper Rools - Prawn (2pcs)',7.5,'Prawn wrapped in rice paper with salad, vermicelli, and hoisin peanut sauce','01');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT04','Rice Paper Rools - Tofu (2pcs)',6.0,'Tofu wrapped in rice paper with salad, vermicelli, and hoisin peanut sauce','01');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT05','Banh Mi Crispy Roasted Pork',12.0,'Banh Mi with cripy pork, garlic, fish sauce and black peppe','02');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT06','Banh Mi Grilled Pork',10.0,'Banh Mi with grilled pork, garlic, fish sauce and black peppe','02');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT07','Banh Mi Fried Eggs',10.0,'Banh Mi with fried eggs, garlic, fish sauce and black peppe','02');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT08','Banh Mi Grilled Chicken',10.0,'Banh Mi with grilled chicken, garlic, fish sauce and black pepper','02');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT09','Pho Sliced Beef',16.0,'ietnamese Pho with sliced beef, and herb','03');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT10','Pho Sliced Beef and MeatBalls',16.5,'Vietnamese Pho with sliced beef, meatballs, and herb','03');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT11','Vietnamese Spicy Beef Noodle Soup',17.0,'Soup is paired with tender slices of beef and pork, topped with herbs','03');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT12','Pork and Crab Noodle Soup',17.0,'Soup with tomatoes, shrimp paste, fish sauce, meat broth, topped with tofu, pork/crab','03');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT13','Vermicelli Cripy Roasted Pork',16.0,'Vermicelli Cripy Roasted Pork and veggies','04');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT14','Vermicelli Lemongrass Tofu',14.0,'Vermicelli Lemongrass Tofu and veggies','04');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT15','Vermicelli Fried Tofu, Pork and Shrimp Paste',17.0,'Vermicelli Fried Tofu, Pork and Shrimp Paste','04');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT16','Rice with Grilled Prok Chops',16.5,'Rice loaded with grilled pork chops and veggies','05');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT17','Rice with Grilled Chicken',16.0,'Rice loaded with grilled chicken meat and veggies','05');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT18','Rice Combo Special',20.0,'Rice loaded with grilled pork meat, chops, eggs and veggies','05');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT19','Vietnamese Iced Coffee',6.0,'Traditional coffee drink recipe in Viet Nam and easy cafe sua da recipe','06');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT20','Iced Tea - Watermelon',5.0,'Fresh watermelon juice mixed with cold tea to make this','06');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT21','Hot Chocolate',4.5,'Hot cocoa or drinking chocolate, is heated chocolate milk','06');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT22','Flat White',4.5,'Coffee drink consisting of espresso with microfoam','06');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT23','Mix Fruit Iced Dessert',7.0,' Ice block molds with berries, bananas and kiwi','07');
INSERT INTO MenuItems(ItemID, Name, Price, Ingredient, CatID) VALUES('IT24','Fruit Cocktail',7.0,'Fresh fruits, strawberry juice, a homemade rose-water Ashta','07');

--Discount scheme
INSERT INTO Discount(DisID, Notes, DFrom, DTo) VALUES('01','Total bill for wet season - Rank 0 Customers',DateTime('2022-10-05 00:00:00'),DateTime('2022-10-15 23:59:00'));
INSERT INTO Discount(DisID, Notes, DFrom, DTo) VALUES('02','Total bill for wet season - Rank 1 Customers',DateTime('2022-10-05 00:00:00'),DateTime('2022-10-15 23:59:00'));
INSERT INTO Discount(DisID, Notes, DFrom, DTo) VALUES('03','Happy Friday for Pho noodles', DateTime('2022-10-05 00:00:00'),DateTime('2022-10-15 23:59:00'));
INSERT INTO Discount(DisID, Notes, DFrom, DTo) VALUES('04','Happy Friday for Rice combo', DateTime('2022-10-05 00:00:00'),DateTime('2022-10-15 23:59:00'));

INSERT INTO BillDiscount(BillID, MinBill, Rate) VALUES('01',50.0, 5.0);
INSERT INTO BillDiscount(BillID, MinBill, Rate) VALUES('02',80.0, 10.0);

INSERT INTO ItemDiscount(ItemDCID, MinPrice) VALUES('03',16.0);
INSERT INTO ItemDiscount(ItemDCID, MinPrice) VALUES('04',16.5);

--Discount applied to food items
INSERT INTO ItemDiscountDetails(ItemDCID, ItemID, Rate) VALUES('03','IT09',5.0);
INSERT INTO ItemDiscountDetails(ItemDCID, ItemID, Rate) VALUES('04','IT18',5.0);

--OrderType, Payment, Orders and OrderDetail
INSERT INTO OrderType(OrderTypeID, Name) VALUES('01','In-house Order');
INSERT INTO OrderType(OrderTypeID, Name) VALUES('02','Phone');
INSERT INTO OrderType(OrderTypeID, Name) VALUES('03','Website');
INSERT INTO OrderType(OrderTypeID, Name) VALUES('04','Uber Eats');
INSERT INTO OrderType(OrderTypeID, Name) VALUES('05','DoorDash');
INSERT INTO OrderType(OrderTypeID, Name) VALUES('06','MenuLog');

INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID) VALUES('Ord0001','Cus000',DateTime('2022-10-04 10:30:22'),'02','01');
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID) VALUES('Ord0002','Cus000',DateTime('2022-10-04 11:20:10'),'02','01');
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID) VALUES('Ord0003','Cus001',DateTime('2022-10-04 12:30:31'),'03','01');
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID) VALUES('Ord0004','Cus002',DateTime('2022-10-04 13:25:00'),'04','04');
INSERT INTO Orders(OrderID, CustID, OrderDate, PickupTime, StaffID, OrderTypeID) VALUES('Ord0005','Cus000',DateTime('2022-10-04 13:55:00'),Time('15:30'),'04','02');
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID) VALUES('Ord0006','Cus003',DateTime('2022-10-05 10:15:05'),'02','01');
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID) VALUES('Ord0007','Cus004',DateTime('2022-10-05 10:30:25'),'02','01');
INSERT INTO Orders(OrderID, CustID, OrderDate, PickupTime, StaffID, OrderTypeID) VALUES('Ord0008','Cus000',DateTime('2022-10-05 10:58:31'),Time('15:30'),'02','02');
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID) VALUES('Ord0009','Cus005',DateTime('2022-10-05 12:30:31'),'03','01');
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID) VALUES('Ord0010','Cus006',DateTime('2022-10-05 13:10:31'),'03','01');
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID) VALUES('Ord0011','Cus000',DateTime('2022-10-05 13:10:31'),'04','01');
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID) VALUES('Ord0012','Cus000',DateTime('2022-10-05 13:55:31'),'04','01');
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID) VALUES('Ord0013','Cus000',DateTime('2022-10-06 10:45:30'),'02','04');
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID, DisID) VALUES('Ord0014','Cus005',DateTime('2022-10-07 10:22:30'),'02','01','03'); --with itemdiscount
/*new added*/
INSERT INTO Orders(OrderID, CustID, OrderDate, StaffID, OrderTypeID, DisID) VALUES('Ord0015','Cus001',DateTime('2022-10-07 12:30:00'),'03','01','01');--with billdiscount



--Orders made by anonymous customers - i.e. Customers dont want to provide their information
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0001','IT11',2,'No chilli');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0001','IT19',1,'Less ice');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0005','IT18',2,'');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0006','IT15',1,'More salad');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0006','IT21',1,'');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0007','IT18',1,'');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0007','IT19',1,'More ice');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0008','IT18',1,'');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0011','IT01',1,'');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0011','IT05',1,'More chilli');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0012','IT06',1,'More chilli');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0012','IT07',1,'More chilli');



--Orders made by registered customers
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0002','IT08',1,'No chilli, carrot');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0003','IT10',1,'');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0003','IT12',1,'Extra chilli, pepper');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0003','IT18',1,'');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0003','IT21',1,'Extra sweet');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0009','IT10',1,'');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0010','IT10',1,'');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0014','IT01',1,'');
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0014','IT09',1,'More soups'); 
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0014','IT19',1,'');
--New added for assignment 3
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0015','IT18',3,'More rice');

--Orders from Uber Eats
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0004','IT05',2,'No chilli both'); 
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0004','IT09',1,''); 
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0004','IT20',1,''); 
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0013','IT12',2,''); 
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0013','IT05',1,''); 
INSERT INTO OrderDetail(OrderID, ItemID, Quantity, Notes) VALUES('Ord0013','IT02',1,''); 

--order made from Delivery App, or website staffID is not required as it will be done via payment gateway
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0001',40.0,'Cash','Ord0001','02');
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0002',10.0,'Card','Ord0002','02');
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0003',58.0,'Card','Ord0003','03');
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0004',45.0,'Bank','Ord0004',NULL);--order from Uber, staffID is not required
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0005',40.0,'Cash','Ord0005','04');
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0006',21.5,'Card','Ord0006','02');
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0007',26.0,'Card','Ord0007','02');
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0008',20.0,'Card','Ord0008','02');
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0009',16.5,'Card','Ord0009','03');
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0010',16.5,'Card','Ord0010','03');
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0011',17.0,'Card','Ord0011','04');
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0012',20.0,'Card','Ord0012','04');
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0013',53.0,'Bank','Ord0013',NULL); --order from Uber, staffID is not required
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0014',26.2,'Bank','Ord0014','02');--payment with item discount
--New added for assignment 3
INSERT INTO Payment(PayID, Amount, Method, OrderID, StaffID) VALUES('pID0015',57.0,'Cash','Ord0015','03'); --payment with bill discount


--===============================================================================================================================================
--DQL SCRIPTS FOR QUERYING

--Query 1 - simple
-- Making a lunch combo of AUD18 to boost sales.  
SELECT Name, ItemID, Price 
FROM MenuItems 
WHERE Price >= 15 
ORDER BY Price ASC; 

--Query 2 - simple
--The owner to know which type of method is prefered by the Customers: 
SELECT Method, COUNT(Method) As Frequency 
FROM Payment 
GROUP BY Method 
ORDER BY Frequency ASC; 

--Query 3 - Moderate
--Show the number of order per day in October 2022
SELECT strftime('%d-%m-%Y', OrderDate) AS Order_day, COUNT(DISTINCT o.OrderID) as Num_orders, SUM(p.Amount) as Daily_income 
    FROM Orders o 
    INNER JOIN Payment p ON o.OrderID = p.OrderID 
    WHERE o.OrderDate BETWEEN DATE('2022-10-01') AND Date('2022-10-30')
    GROUP BY strftime('%d-%m-%Y', OrderDate) 
    ORDER BY o.OrderDate; 

--Query 4 - Moderate
--Find the top selling product by revenue at Cater Me.  
SELECT Name, RANK() OVER(ORDER BY Revenue_per_item DESC) AS Top_selling_product 
FROM 
    ( SELECT me.Name, od.ItemID, SUM(Quantity), Price, Price*SUM(Quantity) AS Revenue_per_item 
      FROM OrderDetail od 
      INNER JOIN MenuItems me ON od.ItemID = me.ItemID 
      GROUP BY od.ItemID
    ); 


--Query 5 - Complex
--Find all registered customers who have total payment more than 40$ in Oct 2022 
SELECT t1.*
FROM Customers as t1 
INNER JOIN (SELECT CustID from Orders as t2
            INNER JOIN Payment as t3 
            ON t2.OrderID = t3.OrderID
            WHERE t2.CustID !='Cus000' and t2.OrderDate between Date('2022-10-01') and Date('2022-10-30')
            Group By t2.CustID
            HAVING Sum(t3.Amount + t3.Surchage) > 40) as t4
ON t1.CustID = t4.CustID;


--Query 6 - Complex
--Find the food that has highest sale revenue in October 2022
SELECT t1.ItemID, t1.Name as 'Dish', t1.Price, t2.Name as 'Category' 
FROM MenuItems as t1 
INNER JOIN Category t2 on t1.CatID = t2.CatID
WHERE t1.itemID in (
                    SELECT t3.ItemID 
                    FROM OrderDetail as t3
                    INNER JOIN MenuItems t4 
                    INNER JOIN Orders as t5
                    ON t3.ItemID = t4.ItemID AND t3.OrderID = t5.OrderID
                    WHERE t5.OrderDate between Date('2022-10-01') and Date('2022-10-30')
                    GROUP BY t3.ItemID
                    ORDER BY sum(t3.Quantity * t4.Price) DESC LIMIT 1
                  );        

