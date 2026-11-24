/*DROP SCHEMA public CASCADE;
CREATE SCHEMA public;*/

CREATE TABLE Students (
    idnr CHAR(10) PRIMARY KEY CHECK (idnr ~ '^[0-9]{10}$'),
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL
);

CREATE TABLE Branches (
    name TEXT,
    program TEXT,
    PRIMARY KEY (name, program)
);

CREATE TABLE Courses (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL CHECK (credits >= 0),
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses (
    code TEXT REFERENCES Courses(code) PRIMARY KEY,
    capacity INT NOT NULL CHECK (capacity >= 0)
);

CREATE TABLE StudentBranches (
    student TEXT REFERENCES Students(idnr) PRIMARY KEY,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Classifications (
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified (
    course TEXT REFERENCES Courses(code),
    classification TEXT REFERENCES Classifications(name),
    PRIMARY KEY (course, classification)
);

CREATE TABLE MandatoryProgram (
    course TEXT REFERENCES Courses(code),
    program TEXT,
    PRIMARY KEY(course, program)
);


CREATE TABLE MandatoryBranch(
    course TEXT REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program) 

);

CREATE TABLE RecommendedBranch(
    course TEXT REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY(branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Registered(
    student TEXT REFERENCES Students(idnr),
    course TEXT REFERENCES Courses(code),
    PRIMARY KEY(student, course)
);

CREATE TABLE Taken(
    student TEXT REFERENCES Students(idnr),
    course TEXT REFERENCES Courses(code),
    grade TEXT NOT NULL CHECK (grade IN ('3','4','5','U')),
    PRIMARY KEY (student, course)
);

CREATE TABLE WaitingList(
    student TEXT REFERENCES Students(idnr),
    course TEXT REFERENCES Limitedcourses(code),
    position INT NOT NULL CHECK (position >= 1),
    PRIMARY KEY(student, course)
);


-- psql -f runsetup.sql postgres