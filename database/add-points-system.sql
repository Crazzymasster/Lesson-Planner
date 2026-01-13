-- Migration: Add Points System to Lessons
-- Date: 2026-01-03
-- Description: Adds points functionality to track student progress and proficiency

-- Add points column to lessonPlans table
-- Points are awarded when a student completes a lesson
-- Difficulty-based default points: Beginner=10, Intermediate=20, Advanced=30
ALTER TABLE lessonPlans
ADD points INT DEFAULT 10 NOT NULL;
GO

-- Update existing lessons with points based on difficulty
UPDATE lessonPlans
SET points = CASE 
    WHEN difficulty = 'Beginner' THEN 10
    WHEN difficulty = 'Intermediate' THEN 20
    WHEN difficulty = 'Advanced' THEN 30
    ELSE 10
END;
GO

-- Add pointsEarned to studentProgress table
-- Tracks how many points the student earned from completing this specific lesson
ALTER TABLE studentProgress
ADD pointsEarned INT DEFAULT 0;
GO

-- Update existing progress records with points earned
UPDATE sp
SET sp.pointsEarned = COALESCE(lp.points, 10)
FROM studentProgress sp
INNER JOIN lessonPlans lp ON sp.lessonId = lp.id
WHERE sp.pointsEarned IS NULL OR sp.pointsEarned = 0;
GO

-- Add totalPointsEarned as computed column in students table
-- This will automatically sum up all points from completed lessons
-- Note: For performance, you might want to denormalize this later with a trigger
-- For now, we'll calculate it in queries
GO

-- Optional: Create a view to easily see student stats with points
CREATE VIEW vw_StudentStats AS
SELECT 
    s.id,
    s.name,
    s.age,
    s.skillLevel,
    s.groupId,
    COUNT(sp.lessonId) AS totalLessonsCompleted,
    COALESCE(SUM(sp.pointsEarned), 0) AS totalPointsEarned,
    COALESCE(AVG(sp.pointsEarned), 0) AS avgPointsPerLesson
FROM students s
LEFT JOIN studentProgress sp ON s.id = sp.studentId
GROUP BY s.id, s.name, s.age, s.skillLevel, s.groupId;
GO

-- Add index for better performance on points queries
CREATE INDEX idx_lessonPlans_points ON lessonPlans(points);
CREATE INDEX idx_studentProgress_pointsEarned ON studentProgress(studentId, pointsEarned);

-- Example: Query to get top students by points
-- SELECT TOP 10 * FROM vw_StudentStats ORDER BY totalPointsEarned DESC;

-- Example: Query to get a student's proficiency level based on points
-- Proficiency levels: 0-50 = Beginner, 51-150 = Intermediate, 151+ = Advanced
/*
SELECT 
    name,
    totalPointsEarned,
    CASE 
        WHEN totalPointsEarned <= 50 THEN 'Beginner'
        WHEN totalPointsEarned <= 150 THEN 'Intermediate'
        ELSE 'Advanced'
    END AS proficiencyLevel
FROM vw_StudentStats;
*/
