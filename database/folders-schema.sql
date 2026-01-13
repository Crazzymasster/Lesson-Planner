-- Create lessonFolders table for organizing lesson plans
CREATE TABLE lessonFolders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    color NVARCHAR(50) DEFAULT '#1A237E',
    orderIndex INT DEFAULT 0,
    createdAt DATETIME2 DEFAULT GETDATE(),
    updatedAt DATETIME2 DEFAULT GETDATE()
);

-- Add folderId column to lessonPlans table
ALTER TABLE lessonPlans
ADD folderId INT NULL;

-- Add foreign key constraint
ALTER TABLE lessonPlans
ADD CONSTRAINT FK_lessonPlans_folders
FOREIGN KEY (folderId) REFERENCES lessonFolders(id)
ON DELETE SET NULL;

-- Create index on folderId for better query performance
CREATE INDEX IX_lessonPlans_folderId ON lessonPlans(folderId);

-- Insert a default "Uncategorized" folder
INSERT INTO lessonFolders (name, description, color, orderIndex)
VALUES ('Uncategorized', 'Lessons without a folder', '#757575', 0);
