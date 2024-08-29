# SQL Project - Library Management System 

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_project`

This project showcases the development of a comprehensive Library Management System using SQL. It involves designing and managing relational databases, performing CRUD operations, and executing complex SQL queries. The project aims to highlight proficiency in database design, data manipulation, and advanced querying techniques.

![Library_project](https://github.com/arunmohla/SQL_Project_Library_Management/blob/main/library_managmenet_SQL.png)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/arunmohla/SQL_Project_Library_Management/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_project`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
```

**Task 6: Create Summary Tables** -- Used CTAS to generate new tables based on query results
--Objective: To create a Summary Table consisting of count of how many times a book has been issued

```sql
CREATE TABLE book_count AS
(SELECT b.isbn, b.book_title , COUNT(i.issued_id) AS num_issued
FROM books b
JOIN issued_status i ON i.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title);
```

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Price by Category**:

```sql
SELECT b.category, SUM(b.rental_price), COUNT(*) FROM books b
JOIN issued_status i
ON b.isbn = i.issued_book_isbn
GROUP BY b.category
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT e.emp_id, e.emp_name, e.position, b.*, e2.emp_name AS manager
FROM employees e
JOIN branch b ON e.branch_id = b.branch_id
JOIN employees e2 ON e2.emp_id = b.manager_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold (ex:7.00)**:
```sql
CREATE TABLE costly_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT i.issued_id, i.issued_book_name, r.return_id 
FROM issued_status i
LEFT JOIN return_status r ON r.issued_id = i.issued_id
WHERE r.return_id IS NULL
```

**Task 13: Identify Members with Overdue Books (assume a 30-day return period)**  
Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
	m.member_id, 
	m.member_name, 
	i.issued_book_name, 
	i.issued_date, 
	r.return_date, 
	(current_date - i.issued_date) as overdue
FROM issued_status i
JOIN members m ON m.member_id = i.issued_member_id
LEFT JOIN return_status r on i.issued_id = r.issued_id
WHERE r.return_date IS NULL
AND (CURRENT_DATE - i.issued_date) > 30
ORDER BY m.member_id;
```

**Task 14: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql

SELECT 
	b.branch_id, 
	COUNT(i.issued_id) AS issued_total, 
	COUNT(r.return_id) AS return_total, 
	SUM(bk.rental_price) AS revenue FROM branch b
JOIN employees e ON b.branch_id = e.branch_id
JOIN issued_status i ON e.emp_id = i.issued_emp_id
LEFT JOIN return_status r ON i.issued_id = r.issued_id
JOIN books bk ON bk.isbn = i.issued_book_isbn
GROUP BY b.branch_id
```

**Task 15: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 2 months.

```sql
CREATE TABLE active_members AS(
SELECT m.* FROM members m
JOIN issued_status i ON m.member_id = i.issued_member_id
WHERE issued_date >= CURRENT_DATE - interval'2 month'
GROUP BY m.member_id);

SELECT * FROM active_members;
```

**Task 16: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch id.

```sql

SELECT 
	e.emp_id, 
	e.emp_name, 
	COUNT(i.issued_id)AS books_processed, 
	e.branch_id 
FROM employees e
JOIN issued_status i ON i.issued_emp_id = e.emp_id
GROUP BY e.emp_id 
ORDER BY books_processed DESC
LIMIT 3
```

**Task 17: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.

```sql
SELECT 
	m.member_id, 
	m.member_name, 
	b.book_title, 
	COUNT(i.issued_id) AS ttl_issued_books 
FROM members m
JOIN issued_status i ON m.member_id = i.issued_member_id
JOIN return_status r ON i.issued_id = r.issued_id
JOIN books b ON b.isbn = i.issued_book_isbn
WHERE r.book_quality = 'Damaged'
GROUP BY m.member_id, b.book_title
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project highlights the effective application of SQL in developing and managing a robust library management system. It covers database setup, data manipulation, and advanced querying, demonstrating a strong foundation in data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/arunmohla/SQL_Project_Library_Management.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Arun Mohla

This project showcases SQL skills essential for database management and analysis. 
For any questions or further information about this project, feel free to contact me at:

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/arun-mohla-82792111a/)
- **Instagram**: [Follow me](https://www.instagram.com/arun_mohla/)
- **Twitter**: [Follow me](https://x.com/arun_mohla)

Thank you for your interest in this project!
