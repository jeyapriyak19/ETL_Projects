create database Project_DB;
use Project_DB;

-- Section 1 – Employee Management
-- Task 1
/* The HR team wants a report showing all employees who joined after 01-Jan-2023 and whose salary is greater than the average salary of all employees.
Display:
• Employee Name
• Department
• Joining Date
• Salary
Sort the result by Salary in descending order.*/

select Emp_Name, Department, Joining_Date, Salary from employees
where Joining_Date > 2023-01-01 and salary > (
select avg(salary) from employees) order by salary desc;

-- Taks 2
/*Management wants to identify departments where the total salary expense exceeds ₹500,000.
Display:
• Department
• Total Employees
• Total Salary
Only display departments satisfying the condition.*/

select Department, sum(salary) as Total_Salary, count(Emp_ID) as Total_Employee_Count from employees
group by Department 
having Total_Salary > 500000;

-- Task 3
/*The HR department wants to identify employees who earn more than every employee in the Sales department.
Display:
• Employee Name
• Department
• Salary*/

select Department, Emp_Name, Salary from employees where Salary > ALL (select salary from employees where Department = 'Sales');
select * from employees;

-- Task 4
/*Generate a report displaying the top 5 highest-paid employees in each department.
Display:
• Employee Name
• Department
• Salary
• Rank*/

SELECT Emp_Name,Department,Salary,Salary_Rank
FROM(SELECT Emp_Name,Department,Salary, DENSE_RANK() OVER (
PARTITION BY Department
ORDER BY Salary DESC
) AS Salary_Rank
FROM Employees
)AS RankedEmployees
WHERE Salary_Rank <= 5;

-- Task 5
/*Display employees whose salary is greater than the average salary of their own department.*/
SELECT Emp_ID,Emp_Name,Department,Salary
FROM Employees e1
WHERE Salary > (SELECT AVG(Salary)FROM Employees WHERE Department = e1.Department); 

-- Task 6 
/*Find departments where no employee earns less than ₹40,000.*/
SELECT Department
FROM Employees GROUP BY Department
HAVING MIN(Salary) >= 40000;

-- Task 7
/*Display employees whose names start with 'A' or end with 'N' and whose salary is between ₹40,000 and ₹90,000.*/
Select EMP_ID, EMP_NAME, DEpartment from employees where emp_Name like 'A%' or EMP_NAME like '%N' AND Salary between 40000 AND 90000;
-- Task 8
/* Generate a report showing the second highest salary in every department.*/
SELECT Department,Emp_ID,Emp_Name,Salary
FROM (SELECT Emp_ID,Emp_Name,Department,Salary,
DENSE_RANK() OVER (
PARTITION BY Department
ORDER BY Salary DESC
) AS Salary_Rank
FROM Employees
)AS RankedEmployees
WHERE Salary_Rank = 2;

-- Task 9
/* Display employees who never received a promotion.*/
SELECT e.Emp_ID, e.Emp_Name, e.Department, e.Salary
FROM Employees e
LEFT JOIN Promotions p
ON e.Emp_ID = p.Emp_ID
WHERE p.Emp_ID IS NULL;

-- Task 10
/*Create a reusable View that displays only active employees working in the IT department.*/
CREATE VIEW Active_IT_Employees AS
SELECT Emp_ID, Emp_Name, Department, Salary,
Status
FROM Employees
WHERE Department = 'IT'
AND Status = 'Active';
SELECT * FROM Active_IT_Employees;

-- Section 2 – Customer & Orders (Tasks 11–20)
-- Task 11
/* Find customers who placed more than five orders.*/
select c.customer_id, c.customer_name, count(o.order_id)as Total_Count 
from customers c LEFT JOIN orders o
ON c.customer_id = o.customer_id
group by customer_id, customer_name
having count(o.order_id) > 5;

-- Task 12
/*Display customers whose total purchase amount is greater than the average purchase amount of all customers.*/
SELECT c.Customer_ID, c.Customer_Name, SUM(o.Order_Amount) AS Total_Purchase
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
HAVING SUM(o.Order_Amount) >
(SELECT AVG(Customer_Total)FROM
(
	SELECT SUM(Order_Amount) AS Customer_Total
	FROM Orders
	GROUP BY Customer_ID
    ) AS T
);

-- Task 13
-- Display the top 10 customers based on total spending.
select c.customer_id,c.customer_name,sum(o.order_amount) as total_spending
from customers c 
left join orders o 
ON c.customer_id=o.customer_id 
group by customer_id, customer_name
order by total_spending DESC
limit 10;

-- Task 14
-- Find customers who have never placed an order.
select c.customer_name,c.customer_id,o.order_id 
from customers c 
left join orders o 
On c.customer_id=o.customer_id 
where order_id is null;

-- Task 15
-- Generate monthly revenue along with the previous month's revenue.
WITH MonthlyRevenue AS
(SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS Month, SUM(Order_Amount) AS Monthly_Revenue 
FROM Orders
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
)
SELECT Month, Monthly_Revenue,
LAG(Monthly_Revenue) OVER (ORDER BY Month) AS Previous_Month_Revenue
FROM MonthlyRevenue;

-- Task 16
-- Find the month having the highest sales.
SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS Month, SUM(Order_Amount) AS Total_Sales
FROM Orders
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY Total_Sales DESC
LIMIT 1;

-- Task 17
-- Display products that were ordered in every month of the current year.
Use project_db;
SELECT DATE_FORMAT(Order_Date, '%Y-%m') AS Month,
SUM(Order_Amount) AS Monthly_Revenue,
LAG(SUM(Order_Amount)) OVER (
ORDER BY DATE_FORMAT(Order_Date, '%Y-%m')
) AS Previous_Month_Revenue
FROM Orders
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m');

-- Task 18
-- Generate department-wise revenue using CTE.
WITH DepartmentRevenue AS
(SELECT e.Department, SUM(o.Order_Amount) AS Total_Revenue
FROM Employees e
INNER JOIN Orders o
ON e.Emp_ID = o.Emp_ID
GROUP BY e.Department
)
SELECT Department, Total_Revenue
FROM DepartmentRevenue
ORDER BY Total_Revenue DESC;
-- Task 19
-- Create a View that displays customer order history.

CREATE VIEW Customer_Order_History AS
SELECT c.Customer_ID, c.Customer_Name, o.Order_ID, o.Order_Date, o.Order_Amount
FROM Customers c
JOIN Orders o
ON c.Customer_ID = o.Customer_ID;

SELECT *
FROM Customer_Order_History;
-- Task 20
-- Write a Stored Procedure that returns customer orders for a given customer ID.
DELIMITER //

CREATE PROCEDURE GetCustomerOrders(IN Cust_ID INT)
BEGIN
SELECT Order_ID, Customer_ID, Order_Date, Order_Amount
FROM Orders
WHERE Customer_ID = Cust_ID;
END //

DELIMITER ;

CALL GetCustomerOrders(101);

/* Task 21 – Top 3 Best-Selling Products*/
SELECT P.Product_Name, SUM(O.Quantity) AS Total_Quantity_Sold
FROM Orders O
INNER JOIN Product P
ON O.Product_ID = P.Product_ID
GROUP BY P.Product_Name
ORDER BY Total_Quantity_Sold DESC
LIMIT 3;

/*Task 22 – Products Never Ordered*/
SELECT P.Product_ID, P.Product_Name
FROM Product P
LEFT JOIN Orders O
ON P.Product_ID = O.Product_ID
WHERE O.Product_ID IS NULL;

/*Task 23 – Monthly Sales Report */
SELECT MONTH(Order_Date) AS Month, COUNT(Order_ID) AS Total_Orders, SUM(Total_Amount) AS Total_Revenue
FROM Orders
GROUP BY MONTH(Order_Date)
ORDER BY Month;

/* Task 24 – Average Order Value by Month */
SELECT MONTH(Order_Date) AS Month, AVG(Total_Amount) AS Average_Order_Value
FROM Orders
GROUP BY MONTH(Order_Date)
ORDER BY Month;

/*Task 25 – Running Total of Monthly Revenue */
WITH MonthlySales AS
( SELECT MONTH(Order_Date) AS Month, SUM(Total_Amount) AS Revenue
    FROM Orders
    GROUP BY MONTH(Order_Date))
SELECT Month, Revenue, SUM(Revenue) OVER
( ORDER BY Month
) AS Running_Total
FROM MonthlySales;

/*Task 26 – Revenue Difference from Previous Month */
WITH MonthlySales AS
(SELECT MONTH(Order_Date) AS Month, SUM(Total_Amount) AS Revenue
FROM Orders
GROUP BY MONTH(Order_Date)
)
SELECT Month, Revenue, Revenue - LAG(Revenue)
OVER(ORDER BY Month) AS Revenue_Difference
FROM MonthlySales;

/*Task 27 – Highest Order Amount Per Customer*/
SELECT C.Customer_Name, MAX(O.Total_Amount) AS Highest_Order
FROM Customer C
INNER JOIN Orders O
ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_Name;

/*Task 28 – Customers with Orders Every Month */
SELECT C.Customer_ID, C.Customer_Name
FROM Customer C
INNER JOIN Orders O
ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_ID, C.Customer_Name
HAVING COUNT(DISTINCT MONTH(O.Order_Date)) =
( SELECT COUNT(DISTINCT MONTH(Order_Date)) FROM Orders);

/*Task 29 – Product Sales Ranking*/
SELECT P.Product_Name, SUM(O.Quantity) AS Total_Sold, 
DENSE_RANK() OVER
( ORDER BY SUM(O.Quantity) DESC
) AS Product_Rank
FROM Orders O
INNER JOIN Product P
ON O.Product_ID = P.Product_ID
GROUP BY P.Product_Name;

/*Task 30 – Product Sales Summary View*/
CREATE VIEW Product_Sales_Summary AS
SELECT P.Product_ID, P.Product_Name, SUM(O.Quantity) AS Total_Quantity, SUM(O.Total_Amount) AS Total_Revenue
FROM Product P
INNER JOIN Orders O
ON P.Product_ID = O.Product_ID
GROUP BY P.Product_ID, P.Product_Name;
    
/*Task 31 – Customers with Account Balance Greater than ₹1,00,000*/
SELECT Customer_ID, Customer_Name, Balance
FROM Customer
WHERE Balance > 100000;

/*Task 32 – Total Balance by Branch*/
SELECT Branch_Name, SUM(Balance) AS Total_Balance
FROM Account
GROUP BY Branch_Name;

/*Task 33 – Customers with More Than One Account*/
SELECT Customer_ID, COUNT(Account_ID) AS Total_Accounts
FROM Account
GROUP BY Customer_ID
HAVING COUNT(Account_ID) > 1;

/*Task 34 – Latest Transaction for Every Customer*/
WITH CTE AS
(
SELECT Customer_ID, Transaction_ID, Transaction_Date, Amount,
ROW_NUMBER() OVER
(
	PARTITION BY Customer_ID
    ORDER BY Transaction_Date DESC
) AS RN
FROM Transactions
)
SELECT Customer_ID, Transaction_ID, Transaction_Date, Amount
FROM CTE
WHERE RN = 1;

/*Task 35 – Top 5 Customers by Account Balance*/
SELECT Customer_ID, Customer_Name, Balance
FROM Customer
ORDER BY Balance DESC
LIMIT 5;

/*Task 36 – Deposit and Withdrawal Summary*/
SELECT Transaction_Type, SUM(Amount) AS Total_Amount
FROM Transactions
GROUP BY Transaction_Type;

/*Task 37 – Running Balance for Each Customer*/
SELECT Customer_ID, Transaction_Date, Amount,
SUM(Amount) OVER
(
	PARTITION BY Customer_ID
	ORDER BY Transaction_Date
) AS Running_Balance
FROM Transactions;

/*Task 38 – Previous Transaction Amount*/
SELECT Customer_ID, Transaction_Date, Amount, LAG(Amount)
OVER
(
	PARTITION BY Customer_ID
	ORDER BY Transaction_Date
)   AS Previous_Transaction
FROM Transactions;

/*Task 39 – Customer Transaction View */
CREATE VIEW Customer_Transaction_View AS
SELECT C.Customer_Name, A.Account_ID, T.Transaction_ID, T.Transaction_Date, T.Transaction_Type, T.Amount
FROM Customer C
INNER JOIN Account A
ON C.Customer_ID = A.Customer_ID
INNER JOIN Transactions T
ON A.Account_ID = T.Account_ID;

/*Task 40 – Stored Procedure to Get Customer Transactions*/
DELIMITER //
CREATE PROCEDURE GetCustomerTransactions(IN p_Customer_ID INT)
BEGIN
SELECT T.Transaction_ID, T.Transaction_Date, T.Transaction_Type, T.Amount
FROM Transactions T
INNER JOIN Account A
ON T.Account_ID = A.Account_ID
WHERE A.Customer_ID = p_Customer_ID
ORDER BY T.Transaction_Date;
END //

DELIMITER ;

/*Task 41 – Records Present in Source but Missing in Target*/
SELECT s.Customer_ID
FROM Source s
LEFT JOIN Target t
ON s.Customer_ID = t.Customer_ID
WHERE t.Customer_ID IS NULL;

/*Task 42 – Records Present in Target but Missing in Source*/
SELECT t.*
FROM target_employee t
LEFT JOIN source_employee s
ON t.emp_id = s.emp_id
WHERE s.emp_id IS NULL;


/*Task 43 – Compare Source and Target Data*/
SELECT S.Primary_Key, S.Column1 AS Source_Value, T.Column1 AS Target_Value
FROM Source_Table S
INNER JOIN Target_Table T
ON S.Primary_Key = T.Primary_Key
WHERE S.Column1 <> T.Column1;

/*Task 44 – Duplicate Records in Source*/
SELECT emp_id, COUNT(*) AS duplicate_count
FROM source_employee
GROUP BY emp_id
HAVING COUNT(*) > 1;

/*Task 45 – Remove Duplicate Records Using CTE */
WITH CTE AS
(
SELECT *, ROW_NUMBER() OVER
(
	PARTITION BY Primary_Key
	ORDER BY Primary_Key
) AS RN
FROM Source_Table
)
DELETE FROM Source_Table
WHERE Primary_Key IN
( SELECT Primary_Key
  FROM CTE
  WHERE RN > 1
);

/*Task 46 – Record Count Validation*/
SELECT
( SELECT COUNT(*)
  FROM Source_Table
) AS Source_Count,

( SELECT COUNT(*)
  FROM Target_Table
) AS Target_Count;

/*Task 47 – Null Value Validation*/
SELECT *
FROM Source_Table
WHERE Column1 IS NULL
OR Column2 IS NULL
OR Column3 IS NULL;
   
/*Task 48 – Data Quality Check*/
SELECT *
FROM Source_Table
WHERE TRIM(Column1) = ''
OR Column1 IS NULL;
   
/*Task 49 – Create ETL Validation View*/

CREATE VIEW ETL_Validation AS
SELECT S.Primary_Key, S.Column1 AS Source_Value, T.Column1 AS Target_Value
FROM Source_Table S
INNER JOIN Target_Table T
ON S.Primary_Key = T.Primary_Key;

/*Task 50 – ETL Validation Stored Procedure*/
DELIMITER //
CREATE PROCEDURE Validate_ETL()
BEGIN
SELECT S.Primary_Key, S.Column1 AS Source_Value, T.Column1 AS Target_Value
FROM Source_Table S
INNER JOIN Target_Table T
ON S.Primary_Key = T.Primary_Key
WHERE S.Column1 <> T.Column1;
END //
DELIMITER ;