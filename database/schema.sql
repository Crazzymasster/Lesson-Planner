-- Coding Lesson Planner Database Schema
-- Works with SQL Server, MySQL needs minor syntax tweaks

-- This is where we store all the lesson plans
CREATE TABLE lessonPlans (
    id INT PRIMARY KEY IDENTITY(1,1),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    language VARCHAR(50) NOT NULL, -- Which programming language this lesson teaches
    targetAge VARCHAR(50),
    duration INT, -- How long the lesson takes in minutes
    difficulty VARCHAR(20) CHECK (difficulty IN ('Beginner', 'Intermediate', 'Advanced')),
    category VARCHAR(100), -- Things like Variables, Loops, Functions, OOP
    prerequisites TEXT, -- What students need to know first
    learningOutcomes TEXT, -- What they'll be able to do after
    notes TEXT,
    createdAt DATETIME DEFAULT GETDATE(),
    updatedAt DATETIME DEFAULT GETDATE()
);

-- Topics covered in each lesson
CREATE TABLE lessonTopics (
    id INT PRIMARY KEY IDENTITY(1,1),
    lessonId INT NOT NULL,
    topic VARCHAR(100) NOT NULL,
    FOREIGN KEY (lessonId) REFERENCES lessonPlans(id) ON DELETE CASCADE
);

-- What students should learn from the lesson
CREATE TABLE lessonObjectives (
    id INT PRIMARY KEY IDENTITY(1,1),
    lessonId INT NOT NULL,
    objective TEXT NOT NULL,
    orderIndex INT DEFAULT 0,
    FOREIGN KEY (lessonId) REFERENCES lessonPlans(id) ON DELETE CASCADE
);

-- What materials you need to teach the lesson
CREATE TABLE lessonMaterials (
    id INT PRIMARY KEY IDENTITY(1,1),
    lessonId INT NOT NULL,
    material VARCHAR(255) NOT NULL,
    FOREIGN KEY (lessonId) REFERENCES lessonPlans(id) ON DELETE CASCADE
);

-- Different activities that make up the lesson
CREATE TABLE lessonActivities (
    id INT PRIMARY KEY IDENTITY(1,1),
    lessonId INT NOT NULL,
    orderIndex INT DEFAULT 0,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    duration INT, -- Minutes for this activity
    type VARCHAR(50) CHECK (type IN ('lecture', 'hands-on', 'discussion', 'game', 'project')),
    FOREIGN KEY (lessonId) REFERENCES lessonPlans(id) ON DELETE CASCADE
);

-- Step by step instructions for teaching the lesson
CREATE TABLE lessonSteps (
    id INT PRIMARY KEY IDENTITY(1,1),
    lessonId INT NOT NULL,
    stepNumber INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    instruction TEXT NOT NULL,
    codeExample TEXT, -- Example code to show
    expectedOutput TEXT, -- What the code should print
    explanation TEXT, -- Why this works the way it does
    hints TEXT, -- Help for when students get stuck
    FOREIGN KEY (lessonId) REFERENCES lessonPlans(id) ON DELETE CASCADE
);

-- Practice challenges for students
CREATE TABLE lessonChallenges (
    id INT PRIMARY KEY IDENTITY(1,1),
    lessonId INT NOT NULL,
    orderIndex INT DEFAULT 0,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    starterCode TEXT, -- Code they start with
    solution TEXT, -- The answer
    difficulty VARCHAR(20) CHECK (difficulty IN ('Easy', 'Medium', 'Hard')),
    points INT DEFAULT 0, -- For gamification stuff if you want
    FOREIGN KEY (lessonId) REFERENCES lessonPlans(id) ON DELETE CASCADE
);

-- Bigger projects students can build with what they learned
CREATE TABLE lessonProjects (
    id INT PRIMARY KEY IDENTITY(1,1),
    lessonId INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    requirements TEXT, -- Things the project needs to have
    starterCode TEXT,
    solutionCode TEXT,
    extensionIdeas TEXT, -- Cool ways to make it better
    FOREIGN KEY (lessonId) REFERENCES lessonPlans(id) ON DELETE CASCADE
);

-- Reusable code snippets you can use across lessons
CREATE TABLE codeSnippets (
    id INT PRIMARY KEY IDENTITY(1,1),
    title VARCHAR(255) NOT NULL,
    language VARCHAR(50) NOT NULL,
    code TEXT NOT NULL,
    explanation TEXT,
    difficulty VARCHAR(20) CHECK (difficulty IN ('Beginner', 'Intermediate', 'Advanced')),
    createdAt DATETIME DEFAULT GETDATE()
);

-- Connects snippets to the lessons that use them
CREATE TABLE lessonSnippets (
    lessonId INT NOT NULL,
    snippetId INT NOT NULL,
    PRIMARY KEY (lessonId, snippetId),
    FOREIGN KEY (lessonId) REFERENCES lessonPlans(id) ON DELETE CASCADE,
    FOREIGN KEY (snippetId) REFERENCES codeSnippets(id) ON DELETE CASCADE
);

-- Groups of students you teach
CREATE TABLE studentGroups (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    averageAge INT,
    skillLevel VARCHAR(20) CHECK (skillLevel IN ('Beginner', 'Intermediate', 'Advanced')),
    createdAt DATETIME DEFAULT GETDATE()
);

-- Individual student records
CREATE TABLE students (
    id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(255) NOT NULL,
    age INT,
    skillLevel VARCHAR(20) CHECK (skillLevel IN ('Beginner', 'Intermediate', 'Advanced')),
    groupId INT,
    FOREIGN KEY (groupId) REFERENCES studentGroups(id) ON DELETE SET NULL
);

-- Keep track of what lessons each student has done
CREATE TABLE studentProgress (
    studentId INT NOT NULL,
    lessonId INT NOT NULL,
    completedAt DATETIME DEFAULT GETDATE(),
    notes TEXT,
    PRIMARY KEY (studentId, lessonId),
    FOREIGN KEY (studentId) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (lessonId) REFERENCES lessonPlans(id) ON DELETE CASCADE
);

-- Some starter data to get you going
INSERT INTO lessonPlans (title, description, language, category, targetAge, duration, difficulty, prerequisites, learningOutcomes, notes)
VALUES 
('Introduction to Python Variables', 'Learn the basics of variables and data types in Python', 'python', 'Variables & Data Types', '8-10', 60, 'Beginner', 'None - this is a first lesson', 'Students will be able to create and use variables, understand different data types, and use variables in simple programs', 'Great first lesson for beginners'),
('Building a Simple Game', 'Create a text-based adventure game using Python', 'python', 'Game Development', '10-12', 90, 'Intermediate', 'Variables, conditionals (if/else), loops, functions', 'Students will be able to create a text-based adventure game with multiple choices and outcomes', 'Requires knowledge of variables, loops, and conditionals'),
('Java Hello World', 'Your first Java program', 'java', 'Getting Started', '10-12', 45, 'Beginner', 'None', 'Students will understand basic Java syntax and can write a simple program', 'Introduction to Java'),
('C++ Variables and Types', 'Learn about variables and data types in C++', 'cpp', 'Variables & Data Types', '12-14', 60, 'Beginner', 'None - first C++ lesson', 'Students will understand C++ variables, data types, and basic input/output', 'First lesson in C++');

INSERT INTO lessonTopics (lessonId, topic)
VALUES 
(1, 'Variables'),
(1, 'Data Types'),
(2, 'Game Development'),
(2, 'User Input');

INSERT INTO lessonObjectives (lessonId, objective, orderIndex)
VALUES 
(1, 'Understand what variables are and how to create them', 1),
(1, 'Identify different data types (strings, integers, floats)', 2),
(1, 'Use variables in simple programs', 3);

INSERT INTO codeSnippets (title, language, code, explanation, difficulty)
VALUES 
('Hello World', 'python', 'print("Hello, World!")', 'The classic first program in any language', 'Beginner'),
('Variable Assignment', 'python', 'name = "Andres"\nage = 10\nprint(f"My name is {name} and I am {age} years old")', 'Shows how to create variables and use them in formatted strings', 'Beginner'),
('Simple Loop', 'python', 'for i in range(5):\n    print(f"Count: {i}")', 'Demonstrates a basic for loop that counts from 0 to 4', 'Beginner');

INSERT INTO studentGroups (name, description, averageAge, skillLevel)
VALUES 
('Monday Beginners', 'Monday afternoon beginner group', 9, 'Beginner'),
('Advanced Coders', 'Thursday advanced Python group', 12, 'Advanced');
