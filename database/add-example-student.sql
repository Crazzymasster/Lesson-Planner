-- Add a comprehensive example student showcasing all features

-- Insert detailed student (no group assigned)
INSERT INTO students (name, age, skillLevel, groupId, email, parentEmail, notes, isActive, createdAt, updatedAt)
VALUES (
  'Jordan Martinez', 
  13, 
  'Advanced', 
  NULL,
  'jordan.m@email.com',
  'parent.martinez@email.com',
  'Highly motivated student. Enjoys building games and web applications. Needs challenging projects to stay engaged.',
  1,
  GETDATE(),
  GETDATE()
);

-- Get the newly inserted student ID
DECLARE @studentId INT = SCOPE_IDENTITY();

-- Add multiple languages with different proficiency levels
INSERT INTO studentLanguages (studentId, language, proficiencyLevel, startedAt, lastPracticedAt, notes)
VALUES 
(@studentId, 'Python', 'Advanced', DATEADD(month, -8, GETDATE()), DATEADD(day, -2, GETDATE()), 'Mastered object-oriented programming, currently learning data structures'),
(@studentId, 'JavaScript', 'Intermediate', DATEADD(month, -4, GETDATE()), DATEADD(day, -1, GETDATE()), 'Strong with DOM manipulation, learning async/await and promises'),
(@studentId, 'Java', 'Beginner', DATEADD(month, -1, GETDATE()), DATEADD(day, -5, GETDATE()), 'Just started, familiar with basic syntax from Python background'),
(@studentId, 'HTML/CSS', 'Expert', DATEADD(month, -6, GETDATE()), GETDATE(), 'Can build responsive websites, understands flexbox and grid');

-- Add lesson progress showing variety of statuses (only for lessons that exist)
DECLARE @lesson1 INT = (SELECT TOP 1 id FROM lessonPlans ORDER BY id);
DECLARE @lesson2 INT = (SELECT TOP 1 id FROM lessonPlans WHERE id > @lesson1 ORDER BY id);
DECLARE @lesson3 INT = (SELECT TOP 1 id FROM lessonPlans WHERE id > @lesson2 ORDER BY id);

IF @lesson1 IS NOT NULL
BEGIN
  INSERT INTO studentProgress (studentId, lessonId, status, completedAt, score, timeSpentMinutes, notes)
  VALUES (@studentId, @lesson1, 'Mastered', DATEADD(day, -30, GETDATE()), 98, 65, 'Completed with excellent understanding. Created extra challenging exercises.');
  PRINT 'Added progress for lesson ' + CAST(@lesson1 AS VARCHAR);
END

IF @lesson2 IS NOT NULL
BEGIN
  INSERT INTO studentProgress (studentId, lessonId, status, completedAt, score, timeSpentMinutes, notes)
  VALUES (@studentId, @lesson2, 'Completed', DATEADD(day, -15, GETDATE()), 92, 120, 'Built an impressive text adventure game with multiple branching paths.');
  PRINT 'Added progress for lesson ' + CAST(@lesson2 AS VARCHAR);
END

IF @lesson3 IS NOT NULL
BEGIN
  INSERT INTO studentProgress (studentId, lessonId, status, completedAt, score, timeSpentMinutes, notes)
  VALUES (@studentId, @lesson3, 'In Progress', NULL, NULL, 45, 'Currently working through the advanced concepts.');
  PRINT 'Added progress for lesson ' + CAST(@lesson3 AS VARCHAR);
END
ELSE
BEGIN
  PRINT 'Note: Some lesson progress not added - only ' + CAST(CASE WHEN @lesson3 IS NOT NULL THEN 3 WHEN @lesson2 IS NOT NULL THEN 2 WHEN @lesson1 IS NOT NULL THEN 1 ELSE 0 END AS VARCHAR) + ' lessons found in database';
END

PRINT 'Added comprehensive example student: Jordan Martinez';
PRINT 'Student ID: ' + CAST(@studentId AS VARCHAR);
PRINT '- 4 languages with varying proficiency levels';
PRINT '- Lesson progress with different statuses';
