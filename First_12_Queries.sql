select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from return_status;
select * from members;

-- Task 1. Create a New Book Record -- '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn,	book_title, category,	rental_price,	status,	author,	publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');


--Task 2: Update an Existing Member's (C103) Address to '125 Oak St'
UPDATE members
SET	member_address = '125 Oak St'
WHERE member_id = 'C103';


--
/* Task 3: Delete a Record from the Issued Status Table 
Objective: Delete the record with issued_id = 'IS121' from the issued_status table. */

DELETE FROM issued_status
WHERE issued_id = 'IS121';

--
/* Task 4: Retrieve All Books Issued by a Specific Employee 
Objective: Select all books issued by the employee with emp_id = 'E101'. */

WHERE issued_emp_id = 'E101';

-- 
/* Task 5: List Members Who Have Issued More Than One Book 
Objective: Use GROUP BY to find members who have issued more than one book. */

SELECT COUNT(*), issued_member_id
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1


------3. CTAS (Create Table As Select)------

/* Task 6: Create Summary Tables: 
--Used CTAS to generate new tables based on query results 
Objective: To create a Summary Table consisting of count of how many times a book has been issued */

CREATE TABLE book_count AS
(SELECT b.isbn, b.book_title , COUNT(i.issued_id) AS num_issued
FROM books b
JOIN issued_status i ON i.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title);


------4. Data Analysis & Findings -----------

-- Task 7. Retrieve All Books in a Specific Category, ex: Classic 

SELECT	* FROM books 
WHERE category = 'Classic' 


-- Task 8. Task 8: Find Total Rental Price by Category:

SELECT b.category, SUM(b.rental_price), COUNT(*) FROM books b
JOIN issued_status i
ON b.isbn = i.issued_book_isbn
GROUP BY b.category

-- Task 9. List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';


-- Task 10. List Employees with Their Branch Manager's Name and their branch details:

SELECT e.emp_id, e.emp_name, e.position, b.*, e2.emp_name AS manager
FROM employees e
JOIN branch b ON e.branch_id = b.branch_id
JOIN employees e2 ON e2.emp_id = b.manager_id

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold (ex:7.00)

CREATE TABLE costly_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT i.issued_id, i.issued_book_name, r.return_id 
FROM issued_status i
LEFT JOIN return_status r ON r.issued_id = i.issued_id
WHERE r.return_id IS NULL

----- ADVANCED SQL--------

-- 
/* Task 13: identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue. */

SELECT m.member_id, m.member_name, i.issued_book_name, i.issued_date, r.return_date, (current_date - i.issued_date) as overdue
FROM issued_status i
JOIN members m ON m.member_id = i.issued_member_id
LEFT JOIN return_status r on i.issued_id = r.issued_id
WHERE r.return_date IS NULL
AND (CURRENT_DATE - i.issued_date) > 30
ORDER BY m.member_id;

/*Task 14: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals. */

SELECT b.branch_id, COUNT(i.issued_id) AS issued_total, COUNT(r.return_id) AS return_total, SUM(bk.rental_price) AS revenue FROM branch b
JOIN employees e ON b.branch_id = e.branch_id
JOIN issued_status i ON e.emp_id = i.issued_emp_id
LEFT JOIN return_status r ON i.issued_id = r.issued_id
JOIN books bk ON bk.isbn = i.issued_book_isbn
GROUP BY b.branch_id

/*Task 15: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 2 months. */

CREATE TABLE active_members AS(
SELECT m.* FROM members m
JOIN issued_status i ON m.member_id = i.issued_member_id
WHERE issued_date >= CURRENT_DATE - interval'2 month'
GROUP BY m.member_id);

SELECT * FROM active_members;

/*Task 16: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch id. */

SELECT e.emp_id, e.emp_name, COUNT(i.issued_id)AS books_processed, e.branch_id 
FROM employees e
JOIN issued_status i ON i.issued_emp_id = e.emp_id
GROUP BY e.emp_id 
ORDER BY books_processed DESC
LIMIT 3

/*Task 17: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books with the status "damaged" in the books table.
Display the member name, book title, and the number of times they've issued damaged books. */

SELECT m.member_id, m.member_name, b.book_title, COUNT(i.issued_id) AS ttl_issued_books FROM members m
JOIN issued_status i ON m.member_id = i.issued_member_id
JOIN return_status r ON i.issued_id = r.issued_id
JOIN books b ON b.isbn = i.issued_book_isbn
WHERE r.book_quality = 'Damaged'
GROUP BY m.member_id, b.book_title



