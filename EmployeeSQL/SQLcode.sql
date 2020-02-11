--Create Tables, Import CSV Data, Assign Foreign Keys

CREATE TABLE "employees" (
    "emp_no" INT   NOT NULL,
    "birth_date" DATE   NOT NULL,
    "first_name" VARCHAR(100)   NOT NULL,
    "last_name" VARCHAR(100)   NOT NULL,
    "gender" VARCHAR(100)   NOT NULL,
    "hire_date" DATE   NOT NULL,
    CONSTRAINT "pk_employees" PRIMARY KEY (
        "emp_no"
     )
);

CREATE TABLE "titles" (
    "emp_no" INT   NOT NULL,
    "title" VARCHAR(200)   NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL
);

CREATE TABLE "salaries" (
    "emp_no" INT   NOT NULL,
    "salary" INT   NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL
);

CREATE TABLE "departments" (
    "dept_no" varchar(20)   NOT NULL,
    "dept_name" varchar(100)   NOT NULL,
    CONSTRAINT "pk_departments" PRIMARY KEY (
        "dept_no"
     )
);

CREATE TABLE "dept_manager" (
    "dept_no" varchar(20)   NOT NULL,
    "emp_no" INT   NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL
);

CREATE TABLE "dept_emp" (
    "emp_no" INT   NOT NULL,
    "dept_no" VARCHAR(100)   NOT NULL,
    "from_date" DATE   NOT NULL,
    "to_date" DATE   NOT NULL
);

copy employees from '/Users/adambilski/employees.csv'
with (format CSV, HEADER);

copy titles from '/Users/adambilski/titles.csv'
with (format CSV, HEADER);

copy salaries from '/Users/adambilski/salaries.csv'
with (format CSV, HEADER);

copy departments from '/Users/adambilski/departments.csv'
with (format CSV, HEADER);

copy dept_manager from '/Users/adambilski/dept_manager.csv'
with (format CSV, HEADER);

copy dept_emp from '/Users/adambilski/dept_emp.csv'
with (format CSV, HEADER);

ALTER TABLE "titles" ADD CONSTRAINT "fk_titles_emp_no" FOREIGN KEY("emp_no")
REFERENCES "employees" ("emp_no");

ALTER TABLE "salaries" ADD CONSTRAINT "fk_salaries_emp_no" FOREIGN KEY("emp_no")
REFERENCES "employees" ("emp_no");

ALTER TABLE "dept_manager" ADD CONSTRAINT "fk_dept_manager_dept_no" FOREIGN KEY("dept_no")
REFERENCES "departments" ("dept_no");

ALTER TABLE "dept_manager" ADD CONSTRAINT "fk_dept_manager_emp_no" FOREIGN KEY("emp_no")
REFERENCES "employees" ("emp_no");

ALTER TABLE "dept_emp" ADD CONSTRAINT "fk_dept_emp_emp_no" FOREIGN KEY("emp_no")
REFERENCES "employees" ("emp_no");

ALTER TABLE "dept_emp" ADD CONSTRAINT "fk_dept_emp_dept_no" FOREIGN KEY("dept_no")
REFERENCES "departments" ("dept_no");

--Queries for Assignment
--1. List the following details of each employee: employee number, last name, first name, gender, and salary.

SELECT employees.emp_no, employees.last_name, employees.first_name, employees.gender, salaries.salary
FROM employees
INNER JOIN salaries ON
salaries.emp_no=employees.emp_no
ORDER BY emp_no;

--2. List employees who were hired in 1986.

SELECT * 
FROM employees
WHERE hire_date >= '1986-01-01' 
AND hire_date <= '1986-12-31';

--3. List the manager of each department with the following information: department number, department name, the manager's employee number, last name, first name, and start and end employment dates.
CREATE View step_1 AS
SELECT dept_manager.dept_no, dept_manager.emp_no, employees.first_name, employees.last_name
FROM dept_manager
INNER JOIN employees ON
dept_manager.emp_no = employees.emp_no;

CREATE VIEW step_2 AS
SELECT departments.dept_name, step_1.dept_no, step_1.emp_no, step_1.first_name, step_1.last_name
FROM departments
INNER JOIN step_1 ON
departments.dept_no=step_1.dept_no;

CREATE VIEW manager_info AS
SELECT dept_emp.from_date, dept_emp.to_date, step_2.dept_name, step_2.dept_no, step_2.emp_no, step_2.first_name, step_2.last_name
FROM dept_emp
INNER JOIN step_2 ON
dept_emp.emp_no = step_2.emp_no;

SELECT * from manager_info;

--4. List the department of each employee with the following information: employee number, last name, first name, and department name.

CREATE VIEW step_one AS
SELECT employees.emp_no, employees.first_name, employees.last_name, dept_emp.dept_no
FROM employees
INNER JOIN dept_emp ON
employees.emp_no = dept_emp.emp_no
ORDER BY emp_no;

CREATE VIEW employee_departments_list AS
SELECT departments.dept_name, step_one.emp_no, step_one.first_name, step_one.last_name
FROM departments
INNER JOIN step_one ON
departments.dept_no = step_one.dept_no;

SELECT * FROM employee_departments_list;

--5. List all employees whose first name is "Hercules" and last names begin with "B."
SELECT first_name, last_name
FROM employees
WHERE first_name = 'Hercules'
AND last_name LIKE 'B%';

--6. List all employees in the Sales department, including their employee number, last name, first name, and department name.

Select * 
FROM employee_departments_list
WHERE dept_name = 'Sales';

--7. List all employees in the Sales and Development departments, including their employee number, last name, first name, and department name.

Select *
FROM employee_departments_list
WHERE dept_name = 'Sales'
OR dept_name = 'Development';

--8. In descending order, list the frequency count of employee last names, i.e., how many employees share each last name.
SELECT last_name, count(emp_no)
FROM employees
GROUP BY last_name
ORDER BY count DESC;

