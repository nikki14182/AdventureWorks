-- 1. Retrieve all rows and columns from employee table. Sort results in ascending order by job title.
select *
from HumanResources.Employee
order by JobTitle;

-- 2. Retrieve all rows and columns from employee table using table aliasing. Sort output in ascending order by last name.
select *
from Person.Person as Employees
order by LastName;

-- 3. Return all rows and a subset of columns (FirstName, LastName, businessentityid) from person table. Rename third column heading to Employee_id. 
-- Arrange output in ascending order by last name.
select FirstName, LastName, BusinessEntityID as 'Employee_id'
from Person.Person
order by LastName;

-- 4. Return only the rows for product that have a sellstartdate that is not NULL and a productline of 'T'. Return productid, productnumber, and name. 
-- Arrange output in ascending order ny name.
select ProductID, ProductNumber, Name
from Production.Product
where SellStartDate is not NULL and ProductLine = 'T'
order by Name;

-- 5. Return all rows from salesorderheader table and calculate the percentage of tax on the subtotal. 
-- Return salesorderid, customerid, orderdate, subtotal, percentage of tax. Results set in ascending order by subtotal.
select SalesOrderID, CustomerID, OrderDate, SubTotal, (TaxAmt * 100 /SubTotal) as TaxPercentage
from Sales.SalesOrderHeader
order by SubTotal desc;

-- 6. Create list of unique jobtitles in employee table. Return jobtitle column.
select distinct jobtitle
from HumanResources.Employee;

-- 7. Calculate total frieght paid by each customer. Return customerid and total freight. Order by customer id.
select  CustomerID, sum(Freight) as TotalFreight
from Sales.SalesOrderHeader
group by CustomerID
order by CustomerID;

-- 8. Find average and sum of the subtotal for every customer. Return customerid, average, and sum of the subtotal.
select CustomerID, SalesPersonID, avg(SubTotal) as avg_subtotal, sum(SubTotal) as sum_subtotal
from Sales.SalesOrderHeader
group by CustomerID,SalesPersonID
order by CustomerID desc;

-- 9. Retrieve total quantity of each productid on shelf 'A' or 'C' of 'H'. Filter results for sum quantity is more than 500. Retrun productid and sum of quantity. 
-- Sort by productid in ascending order
select ProductID, sum(Quantity) as TotalQuantity
from Production.ProductInventory
where Shelf in ('A', 'C', 'H') 
group by ProductID
having sum(Quantity) > 500
order by ProductID;

-- 10. Find total quantity for a group of location id multiplied by 10.
select sum(Quantity) as TotalQuantity
from Production.ProductInventory
group by (LocationID * 10);

-- 11. Find persons whose last name starts with letter 'L'. Return BusinessEntityID, FirstName, LastName, and PhoneNumber. Sort by last name and first name.
select phone.BusinessEntityID, person.FirstName, person.LastName, phone.PhoneNumber
from Person.Person as person
left join Person.PersonPhone as phone
on person.BusinessEntityID = phone.BusinessEntityID
where LastName like 'L%'
order by person.LastName, person.FirstName;

-- 12. Find sum of subtotal column. Group sum on distinct salespersonid and customerid. Rolls up the results into subtotal and running total. 
-- Return salespersonid, customerid, and sume of subtotal column.
select SalesPersonID, CustomerID, sum(SubTotal) as 'sum_subtotal'
from Sales.SalesOrderHeader
group by rollup (SalesPersonID, CustomerID);

-- 13. Find sum of quantity of all combination of group distinct locationid and shelf column. Return locationid, shelf, and sum of quantity as TotalQuantity.
select LocationID, Shelf, sum(Quantity) as 'TotalQuantity'
from Production.ProductInventory
group by cube(LocationID,Shelf);

-- 14. Find sum of quantity with subtotal for each locationid. Group results for all combination of distinct locationid and shelf column. 
-- Roll up results into subtotal and running total. Return locationid, shelf, sum of quantity
select LocationID, Shelf, sum(Quantity) as 'TotalQuantity'
from Production.ProductInventory
group by grouping sets (rollup (LocationID, Shelf), cube(LocationID, Shelf));

-- 15. Find total quantity for each locationid and calculate the grand total for all locations. Return locationid and total quantity. Group by location id.
select LocationID, sum(Quantity) as TotalQuantity
from Production.ProductInventory
group by grouping sets (LocationID, ());

-- 16. Retrieve number of employees from each City. Return city and number of employees. Sort by city.
select a.City, count(b.AddressID) NoOfEmployees 
from Person.BusinessEntityAddress as b   
    inner join Person.Address as a  
        on b.AddressID = a.AddressID  
group by a.City  
order by a.City;

-- 17. Retrieve total sales from each year. Return year part of order date and total due amount. Sort result in ascending order on year part of order date.
select year(OrderDate) as 'Year', sum(TotalDue) as 'Order Amount'
from Sales.SalesOrderHeader
group by year(OrderDate)
order by year(OrderDate);

-- 18. Retrieve total sales for each year. Filter result for orders where order year is on or before 2016. Return year part of order date and total due amount. 
-- Sort result in ascending order on year of order date.
select year(OrderDate) as 'Year', sum(TotalDue) as 'Order Amount'
from Sales.SalesOrderHeader
where year(OrderDate) <= '2016'
group by year(OrderDate)
order by year(OrderDate);

-- 19. Find contacts who are designated as a manager in various departments. Return ContactTypeID and name. Sort result set in descending order.
select ContactTypeID, Name
from Person.ContactType
where name like '%Manager%'
order by ContactTypeID desc;

-- 20. Make a list of contacts who are designated as Purchasing Manager. Return BusinessEntityID, LastName, and FirstName.Sort result set in ascending order of LastName and FirstName.
select pp.BusinessEntityID, LastName, FirstName
    from Person.BusinessEntityContact  as pb 
        inner join Person.ContactType as pc
            on pc.ContactTypeID = pb.ContactTypeID
        inner join Person.Person as pp
            on pp.BusinessEntityID = pb.PersonID
    where pc.Name = 'Purchasing Manager'
    order by LastName, FirstName;

-- 21. Retrieve ehe salesperson for each PostalCode who belongs to a territory and SalesYTD is not zero. 
-- Return row numbers of each group of PostalCode, last name, salesytd, postalcode column. Sort salesytd of each postalcode group in descending order.
select row_number() over (partition by PostalCode order by SalesYTD desc) as "Row Number",
pp.LastName, sp.SalesYTD, pa.PostalCode
from Sales.SalesPerson as sp
    inner join Person.Person as pp
        on sp.BusinessEntityID = pp.BusinessEntityID
    inner join Person.Address as pa
        on pa.AddressID = pp.BusinessEntityID
where TerritoryID is not null
    and SalesYTD <> 0
order by PostalCode;

-- 25. Find sum, average, count, minimum, and maximum order quantity where order id is 43659 and 43664. 
-- Return SalesOrderId, ProductId, OrderQty, sum, average, count, max, min order quantity
select SalesOrderID, ProductID, OrderQty
    ,sum(OrderQty) over (partition by SalesOrderID) as "Total Quantity"
    ,avg(OrderQty) over (partition by SalesOrderID) as "Avg Quantity"
    ,count(OrderQty) over (partition by SalesOrderID) as "No of Orders"
    ,min(OrderQty) over (partition by SalesOrderID) as "Min Quantity"
    ,max(OrderQty) over (partition by SalesOrderID) as "Max Quantity"
from Sales.SalesOrderDetail
where SalesOrderID in (43659,43664);
