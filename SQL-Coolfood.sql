-- List of the total revenue by employee
WITH revenue_by_order (OrderId, FullName, Revenue)
AS
(
SELECT DISTINCT od.OrdenID, 
		e.Nombre + ' ' + e.Apellido as FullName, 
		ROUND(SUM(od.PrecioUnitario*od.Cantidad*(1-od.Descuento)) OVER(Partition by od.OrdenID),2) AS Revenue
		
FROM Coolfood.dbo.Ordenes as o
JOIN Coolfood.dbo.DetallesOrden as od
	ON o.OrdenId = od.OrdenID
JOIN Coolfood.dbo.Empleados as e
	ON o.EmpleadoID = e.EmpleadoID
)
SELECT FullName, SUM(Revenue) AS TotalRevenue
FROM revenue_by_order
GROUP BY FullName
ORDER BY TotalRevenue DESC;


-- Total Revenue by year
WITH revenue_by_year (Year, Revenue)
AS
(
SELECT 
	YEAR(o.FechaOrden) AS Year,
	ROUND(SUM(od.PrecioUnitario*od.Cantidad*(1-od.Descuento)) OVER(Partition by od.OrdenID),2) AS Revenue
		
FROM Coolfood.dbo.Ordenes as o
JOIN Coolfood.dbo.DetallesOrden as od
	ON o.OrdenId = od.OrdenID
)
SELECT Year, SUM(Revenue) AS TotalRevenue
FROM revenue_by_year
GROUP BY Year
ORDER BY Year;


-- List of the best 10 clients 
WITH revenue_by_client 
AS
(
SELECT
	c.NombreEmpresa AS Client,
	c.ContactoNombre AS Contact,
	c.Direccion AS Address,
	c.Ciudad AS City,
	c.Region AS Region,
	c.CodigoPostal AS ZipCode,
	c.Pais AS Country,
	c.Telefono AS Phone,
	ROUND(SUM(od.PrecioUnitario*od.Cantidad*(1-od.Descuento)) OVER(Partition by od.OrdenID),2) AS Revenue
FROM  Coolfood.dbo.Ordenes as o
JOIN Coolfood.dbo.DetallesOrden as od
	ON o.OrdenId = od.OrdenID
JOIN Coolfood.dbo.Clientes AS c
	ON o.ClienteID = c.ClienteID
)
SELECT TOP 10 Client, Contact, Address, City, Region, ZipCode, Country, Phone, SUM(Revenue) AS TotalRevenue
FROM revenue_by_client
GROUP BY Client, Contact, Address, City, Region, ZipCode, Country, Phone
ORDER BY TotalRevenue DESC


-- List with the most ordered products 
SELECT p.ProductoNombre AS Product, cat.CategoriaNombre AS Category, SUM(od.Cantidad) AS Quantity 
FROM Coolfood.dbo.DetallesOrden AS od
JOIN Coolfood.dbo.Productos AS p
	ON od.ProductoID = p.ProductoID
JOIN Coolfood.dbo.Categorias AS cat 
	ON p.CategoriaID = cat.CategoriaID
GROUP BY od.ProductoID, p.ProductoNombre, cat.CategoriaNombre
ORDER BY Quantity DESC


-- Total revenue by country
WITH revenue_by_country (Country, Revenue)
AS
(
SELECT 
	o.PaisEnvio AS Country,
	ROUND(SUM(od.PrecioUnitario*od.Cantidad*(1-od.Descuento)) OVER(Partition by od.OrdenID),2) AS Revenue
		
FROM Coolfood.dbo.Ordenes as o
JOIN Coolfood.dbo.DetallesOrden as od
	ON o.OrdenId = od.OrdenID
)
SELECT Country, ROUND(CAST(SUM(Revenue) AS float),2) AS TotalRevenue
FROM revenue_by_country
GROUP BY Country
ORDER BY TotalRevenue DESC


-- List of the orders with the time to deliver over 10 days
SELECT 
o.OrdenId AS OrderID, 
c.NombreEmpresa AS Client,
o.PaisEnvio AS Shipping_Country,
DATEDIFF(DAY,o.FechaOrden,o.FechadeEnvio) AS Time_To_Deliver
FROM Coolfood.dbo.Ordenes as o
JOIN Coolfood.dbo.Clientes as c
	ON o.ClienteID = c.ClienteID
WHERE DATEDIFF(DAY,o.FechaOrden,o.FechadeEnvio) > 10
ORDER BY Time_To_Deliver DESC


-- Average time to deliver an order by country 
SELECT 
o.PaisEnvio AS Shipping_Country,
AVG(DATEDIFF(DAY,o.FechaOrden,o.FechadeEnvio)) AS [Time_To_Deliver (days)]
FROM Coolfood.dbo.Ordenes as o
GROUP BY o.PaisEnvio
ORDER BY [Time_To_Deliver (days)] DESC