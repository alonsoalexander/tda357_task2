CREATE VIEW BasicInformation AS 
    SELECT s.idnr, s.name, s.login, s.program, sb.branch From Students s
    LEFT JOIN StudentBranches AS sb ON s.idnr = sb.student AND sb.program = s.program;


CREATE VIEW FinishedCourses AS 
    SELECT t.student, t.course, c.name AS courseName , t.grade, c.credits FROM Taken t
    INNER JOIN Students s ON s.idnr = t.student 
    INNER JOIN Courses c ON c.code = t.course;

CREATE VIEW Registrations AS 
    SELECT student, course, 'waiting' AS status FROM WaitingList
    UNION ALL
    SELECT student, course, 'registered' AS status FROM Registered;

CREATE VIEW PassedCourses AS
    SELECT student, course, credits FROM FinishedCourses
    WHERE grade <> 'U';
    

CREATE VIEW UnreadMandatory (student, course) AS
    SELECT s.idnr, mp.course
    FROM Students s
    JOIN MandatoryProgram mp ON mp.program = s.program

    UNION

    SELECT sb.student, mb.course
    FROM StudentBranches sb
    JOIN MandatoryBranch mb ON mb.branch = sb.branch AND mb.program = sb.program

    EXCEPT

    SELECT student, course
    FROM PassedCourses;

CREATE VIEW TotalCredits AS 
    SELECT student, COALESCE(SUM(credits),0) AS credits
    FROM PassedCourses
    GROUP BY student;

CREATE VIEW mandatoryLeft AS
    SELECT student, COALESCE(COUNT(course), 0) AS courseleft
    FROM UnreadMandatory
    GROUP BY student;

CREATE VIEW mathCredits AS
    SELECT pc.student, SUM(pc.credits) AS mathCredits 
    FROM PassedCourses pc
    JOIN Classified c ON c.course = pc.course 
    WHERE c.classification = 'math'
    GROUP BY pc.student;
    

CREATE VIEW seminarCourses AS
    SELECT pc.student, COUNT(pc.course) AS seminarCourses
    FROM PassedCourses pc
    JOIN Classified c ON c.course = pc.course 
    WHERE c.classification = 'seminar'
    GROUP BY pc.student;

CREATE VIEW RecommendedCourses AS
    SELECT pc.student, pc.course, pc.credits
    FROM PassedCourses pc
    JOIN BasicInformation bi ON bi.idnr = pc.student
    JOIN RecommendedBranch rb
        ON rb.course = pc.course
        AND rb.branch = bi.branch
        AND rb.program = bi.program;


CREATE VIEW PathToGraduation AS 
    SELECT  s.idnr AS student,
            COALESCE(tc.credits, 0) AS totalCredits,
            COALESCE(ml.courseleft, 0) AS mandatoryLeft,
            COALESCE(mc.mathCredits, 0) AS mathCredits,
            COALESCE(sc.seminarCourses, 0) AS seminarCourses,
            
            (   COALESCE(ml.courseleft, 0)          = 0
            AND COALESCE(rc.recommendedCredits, 0) >= 10
            AND COALESCE(mc.mathCredits, 0)        >= 20
            AND COALESCE(sc.seminarCourses, 0)     >= 1
           )                                   AS qualified
    FROM Students s
        LEFT JOIN TotalCredits   tc ON tc.student = s.idnr
        LEFT JOIN mandatoryLeft  ml ON ml.student = s.idnr
        LEFT JOIN mathCredits    mc ON mc.student = s.idnr
        LEFT JOIN seminarCourses sc ON sc.student = s.idnr
        LEFT JOIN (
            SELECT student, SUM(credits) AS recommendedCredits
            FROM RecommendedCourses
            GROUP BY student
        ) rc ON rc.student = s.idnr;

CREATE VIEW warnRecMand AS
    SELECT rb.course, rb.branch, rb.program
    FROM RecommendedBranch rb
    JOIN MandatoryProgram mp ON mp.course  = rb.course AND mp.program = rb.program;

CREATE VIEW warnOverfull AS
    SELECT lc.code AS course
    FROM LimitedCourses lc
    JOIN Registered r ON r.course = lc.code
    GROUP BY lc.code, lc.capacity
    HAVING COUNT(*) > lc.capacity;