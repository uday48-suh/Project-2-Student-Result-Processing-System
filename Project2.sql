CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department VARCHAR(50),
    admission_year INT
);
CREATE TABLE Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100),
    credits INT
);
CREATE TABLE Semesters (
    semester_id INT PRIMARY KEY AUTO_INCREMENT,
    semester_name VARCHAR(50), -- e.g. "Fall 2024"
    year INT
);
CREATE TABLE Grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    semester_id INT,
    marks_obtained DECIMAL(5,2),
    grade CHAR(2),
    gpa DECIMAL(4,2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (semester_id) REFERENCES Semesters(semester_id)
);

-- Students
INSERT INTO Students (name, department, admission_year) VALUES
('Alice', 'CSE', 2022),
('Bob', 'ECE', 2022);

-- Courses
INSERT INTO Courses (course_name, credits) VALUES
('Data Structures', 3),
('DBMS', 4),
('Circuits', 3);

-- Semesters
INSERT INTO Semesters (semester_name, year) VALUES
('Fall 2024', 2024),
('Spring 2025', 2025);

-- Grades (sample)
INSERT INTO Grades (student_id, course_id, semester_id, marks_obtained)
VALUES
(1, 1, 1, 85),
(1, 2, 1, 90),
(2, 1, 1, 75),
(2, 3, 1, 55);

UPDATE Grades
SET grade = CASE
    WHEN marks_obtained >= 90 THEN 'A+'
    WHEN marks_obtained >= 80 THEN 'A'
    WHEN marks_obtained >= 70 THEN 'B'
    WHEN marks_obtained >= 60 THEN 'C'
    WHEN marks_obtained >= 50 THEN 'D'
    ELSE 'F'
END,
gpa = CASE
    WHEN marks_obtained >= 90 THEN 10
    WHEN marks_obtained >= 80 THEN 9
    WHEN marks_obtained >= 70 THEN 8
    WHEN marks_obtained >= 60 THEN 7
    WHEN marks_obtained >= 50 THEN 6
    ELSE 0
END;

SELECT s.student_id, s.name, sem.semester_name,
       ROUND(SUM(g.gpa * c.credits) / SUM(c.credits), 2) AS semester_gpa
FROM Grades g
JOIN Students s ON s.student_id = g.student_id
JOIN Courses c ON c.course_id = g.course_id
JOIN Semesters sem ON sem.semester_id = g.semester_id
WHERE s.student_id = 1 AND sem.semester_id = 1
GROUP BY s.student_id, sem.semester_id;

SELECT
    s.name,
    COUNT(CASE WHEN g.grade <> 'F' THEN 1 END) AS passed,
    COUNT(CASE WHEN g.grade = 'F' THEN 1 END) AS failed
FROM Grades g
JOIN Students s ON s.student_id = g.student_id
GROUP BY s.student_id;

WITH SemesterGPA AS (
    SELECT
        g.student_id,
        g.semester_id,
        ROUND(SUM(g.gpa * c.credits) / SUM(c.credits), 2) AS gpa
    FROM Grades g
    JOIN Courses c ON c.course_id = g.course_id
    GROUP BY g.student_id, g.semester_id
)

SELECT
    s.name,
    sem.semester_name,
    sg.gpa,
    RANK() OVER (PARTITION BY sg.semester_id ORDER BY sg.gpa DESC) AS ranks
FROM SemesterGPA sg
JOIN Students s ON s.student_id = sg.student_id
JOIN Semesters sem ON sem.semester_id = sg.semester_id;

DELIMITER $$

CREATE TRIGGER calculate_grade_gpa
BEFORE INSERT ON Grades
FOR EACH ROW
BEGIN
    IF NEW.marks_obtained >= 90 THEN
        SET NEW.grade = 'A+', NEW.gpa = 10;
    ELSEIF NEW.marks_obtained >= 80 THEN
        SET NEW.grade = 'A', NEW.gpa = 9;
    ELSEIF NEW.marks_obtained >= 70 THEN
        SET NEW.grade = 'B', NEW.gpa = 8;
    ELSEIF NEW.marks_obtained >= 60 THEN
        SET NEW.grade = 'C', NEW.gpa = 7;
    ELSEIF NEW.marks_obtained >= 50 THEN
        SET NEW.grade = 'D', NEW.gpa = 6;
    ELSE
        SET NEW.grade = 'F', NEW.gpa = 0;
    END IF;
END$$

DELIMITER ;

CREATE VIEW Semester_Result AS
SELECT
    s.student_id,
    s.name,
    sem.semester_name,
    c.course_name,
    g.marks_obtained,
    g.grade,
    g.gpa
FROM Grades g
JOIN Students s ON s.student_id = g.student_id
JOIN Courses c ON c.course_id = g.course_id
JOIN Semesters sem ON sem.semester_id = g.semester_id;



