--1. Display for all employees their number, name, job, monthly salary, their current annual salary
--(not including commission) and what their annual salary would be if they were given a 10% pay
--rise. Order the output by employee number.
SELECT
    empname,
    empjob,
    empmsal,
    empmsal * 12       AS "anual sal",
    empmsal * 12 * 1.1 AS "anual sal increase"
FROM
    payroll.employee
ORDER BY
    empno;

--2. Display the name of all employees, their birthdate and their age in years. Order the output by
--birthdate, within birthdate order the output by name.
SELECT
    empname,
    empbdate,
    to_char(empbdate, 'dd-mm-yyyy')               AS "birhtday",
    floor(months_between(sysdate, empbdate) / 12) AS "age"
FROM
    payroll.employee
ORDER BY
    empname;

--3. Display for all employees, their number, name, job, monthly salary, commission (which is paid
--monthly) and their current annual salary (including commission). Order the output by employee
--number.
SELECT
    *
FROM
    payroll.employee;

SELECT
    empno,
    empname,
    empjob,
    empmsal,
    empcomm,
    ( empmsal + nvl(empcomm, 0) ) * 12 AS "annual sallary"
FROM
    payroll.employee
ORDER BY
    empno;
--4. Display all employees’ details in the following format: EMPLOYEE N. Smith IS A Trainer AND
--WORKS IN THE Training DEPARTMENT. Order the output by employee number.

SELECT
    'EMPLOYEE '
    || empinit
    || '. '
    || initcap(empname)
    || 'IS A '
    || initcap(empjob)
    || ' AND WORKS IN THE '
    || initcap(deptname)
    || ' DEPARTMENT'
FROM
         payroll.employee e
    JOIN payroll.department d
    ON e.deptno = d.deptno
ORDER BY
    empno;


--5. Display the name of all employees, their birthdate and their age in months. Order the output by
--age in months (with the oldest employee first), within age in months order the output by name. The
--age in months must be shown with one decimal point and right aligned.
SELECT
    empname,
    to_char(empbdate, 'mm-dd-yyyy'),
    lpad(to_char(months_between(sysdate, empbdate),'9990.0'),100)
FROM
    payroll.employee;
--6. Display the employees who were born in February. Order the output by employee name.
select * from payroll.employee e
where extract(month from empbdate) = 2
order by 
empname;
--7. Display the employee name, salary and commission (using the GREATEST function) for those
--employees who earn more commission than their monthly salary. Order the output by employee
--name and within name by monthly take home pay (salary plus commission).
SELECT
    empname,
    empmsal,
    empcomm
FROM
    payroll.employee
WHERE
    greatest(empmsal, empcomm) = empcomm;
--8. Display the name of all employees and their birthdate in the following format: EMPLOYEE N.
--Smith was born on FRIDAY the 17 of DECEMBER , 1982. Order the output by employee name.
SELECT
    'EMPLOYEE '
    || empinit
    || '. '
    || initcap(empname)
    || ' was born on '
    || rtrim(to_char(empbdate, 'DAY'))
    || ' the '
    || EXTRACT(DAY FROM empbdate)
    || ' of '
    || rtrim(to_char(empbdate, 'MONTH'))
    || ' , '
    || EXTRACT(YEAR FROM empbdate)
FROM
    payroll.employee;
--9. Display the name of the employees who have registered for a course and the number of times
--they have registered. Order the output by employee number.
select empname, count(crscode) from payroll.employee e
join payroll.registration r on e.empno = r.empno
group by e.empname,e.empno
order by e.empno
;
--10. Who is the oldest employee? Show the employee number, name and date of birth. Order the
--output by employee number.
select empno,empname,empbdate from payroll.employee
where empbdate = ( select min(empbdate) from payroll.employee)
order by empbdate;
--11. For each department, list the department number and name, the number of employees, the
--minimum and maximum monthly salary, the total monthly salary and the average salary paid to
--their employees. Name the columns: NbrOfEmployees, MinSalary, MaxSalary, TotalSalary,
--AvgSalary. Order the output by department number.
SELECT
    d.deptname,
    MIN(e.empmsal) AS "min sal",
    MAX(e.empmsal) AS "max empsal",
    AVG(e.empmsal) AS "avg sal",
    COUNT(e.empno) AS "number of emp",
    SUM(e.empmsal) AS "total sal"
FROM
         payroll.department d
    left outer JOIN payroll.employee e
    ON d.deptno = e.deptno
GROUP BY
    d.deptname;

SELECT
    d.deptno,
    d.deptname,
    COUNT(e.empno)                           "NbrOfEmployees",
    MIN(empmsal)                             "MinSalary",
    MAX(empmsal)                             "MaxSalary",
    SUM(empmsal)                             "TotalSalary",
    to_char(AVG(empmsal), '9999.99')          "AvgSalary"
FROM
    payroll.employee      e
    RIGHT OUTER JOIN payroll.department    d
    ON ( e.deptno = d.deptno )
GROUP BY
    d.deptno,
    d.deptname
ORDER BY
    deptno;
--12. Display the department number, jobs available in that department and the total monthly salary
--paid for each job. Order the output by department number and within a department by job.

SELECT
    deptno,
    empjob,
    SUM(empmsal)
FROM
    payroll.employee
GROUP BY
    deptno,
    empjob
ORDER BY deptno,empjob;
--13. Which employee earns more than the average salary? Show the employee number, name and
--monthly salary. Order the output by employee number.
SELECT
    *
FROM
    payroll.employee
WHERE
    empmsal > (
        SELECT
            AVG(empmsal)
        FROM
            payroll.employee
    )
order by empno;
--14. Which department has the greatest average monthly salary? Show the department no, name
--and average monthly salary. Order the output by department number.

SELECT
    d.deptno,
    d.deptname,
    AVG(empmsal)
FROM
    payroll.department d
    LEFT OUTER JOIN payroll.employee   e
    ON e.deptno = d.deptno
Having
    AVG(empmsal) = (
        SELECT
            MAX(AVG(empmsal))
        FROM
            payroll.department d
            LEFT OUTER JOIN payroll.employee   e
            ON e.deptno = d.deptno
        GROUP BY
            d.deptno
    )
GROUP BY
    d.deptno,
    d.deptname
ORDER BY
    d.deptno;
--15. Which course has the most offerings? Show the course code, description and number of
--offerings. Order the output by the number of offerings in descending order and within the number of
--offerings by the course code.
SELECT
    c.crscode,
    COUNT(*)
FROM
    payroll.course   c
    LEFT OUTER JOIN payroll.offering o
    ON c.crscode = o.crscode
GROUP BY
    c.crscode
HAVING
    COUNT(*) = (
        SELECT
            MAX(COUNT(*))
        FROM
            payroll.course   c
            LEFT OUTER JOIN payroll.offering o
            ON c.crscode = o.crscode
        GROUP BY
            c.crscode
    )
ORDER BY
    COUNT(*) DESC;


--16. Display the name, job and date of birth of employees who perform the same job as SCOTT and
--were born in the same year. Do not include SCOTT in the output. Order the output by employee
--name.
SELECT
    e.empjob,
    e.empname,
        to_char(empbdate, 'dd-Mon-yyyy') as birthdate
FROM
    payroll.employee e
WHERE
        ( e.empjob,
          EXTRACT(YEAR FROM e.empbdate) ) = (
            SELECT
                e1.empjob,
                EXTRACT(YEAR FROM e1.empbdate)
            FROM
                payroll.employee e1
            WHERE
                upper(e1.empname) = 'SCOTT'
        )
    AND upper(e.empname) <> 'SCOTT';
    

SELECT
    e.empname,
    e.empjob,
    to_char(empbdate, 'dd-Mon-yyyy') as birthdate
FROM
    payroll.employee e
WHERE
        ( e.empjob,
          EXTRACT(YEAR FROM empbdate) ) = (
            SELECT
                e.empjob,
                EXTRACT(YEAR FROM empbdate)
            FROM
                payroll.employee e
            WHERE
                upper(empname) = 'SCOTT'
        )
    AND upper(e.empname) <> 'SCOTT'
ORDER BY
    empname;

--17. Using the MINUS statement, which employees have never registered in a course. Show their
--employee number and name. Order the output by employee number.
SELECT
    empno,
    empname
FROM
    payroll.employee
MINUS

select distinct e.empno,e.empname  from payroll.employee e join payroll.registration r on e.empno = r.empno


--18. Using the INTERSECT statement, which employees have both registered for and conducted
--courses. Show the employee number and name. Order the output by employee number.