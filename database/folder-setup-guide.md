# Folder System Setup

This guide will help you set up the folder organization system for lesson plans.

## Database Setup

1. Open SQL Server Management Studio or your preferred SQL client
2. Connect to your database
3. Run the script `database/folders-schema.sql`

This will:
- Create the `lessonFolders` table
- Add a `folderId` column to the `lessonPlans` table
- Set up foreign key relationships
- Create a default "Uncategorized" folder

## Features

### For Teachers

- **Create Folders**: Click the "+ New Folder" button on the Lesson Plans page
- **Organize Lessons**: Use the dropdown on each lesson card to move it to a folder
- **Collapsible Folders**: Click the arrow icon to expand/collapse folder contents
- **Color Coding**: Choose from 8 colors when creating folders for visual organization
- **Folder Management**: Edit or delete folders as needed (deleting moves lessons to "Uncategorized")

### In the Lesson Creator

- When creating or editing a lesson, you can select which folder it belongs to
- The folder dropdown appears in the Basic Information section

## Folder Properties

Each folder has:
- **Name**: Required identifier (e.g., "Python Basics", "Web Development")
- **Description**: Optional details about what lessons belong here
- **Color**: Visual indicator (8 preset colors available)
- **Lesson Count**: Automatically tracked

## How It Works

1. **Organization**: Lessons can belong to one folder or none (Uncategorized)
2. **Flexible**: Move lessons between folders at any time
3. **Safe Deletion**: Deleting a folder won't delete lessons - they become uncategorized
4. **Visual**: Folders use colored left borders for easy identification
5. **Persistent**: Folder assignments are saved to the database

## Usage Tips

- Create folders for different topics (e.g., "Python", "JavaScript", "HTML/CSS")
- Or organize by difficulty level (e.g., "Beginner", "Advanced")
- Or by course/class (e.g., "Fall 2024", "Spring 2025")
- Use descriptions to clarify what belongs in each folder
- Choose distinct colors for quick visual scanning
