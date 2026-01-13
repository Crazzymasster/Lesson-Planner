# Proficiency System Documentation

## How It Works

The proficiency system automatically updates based on points earned from completed lessons.

### Proficiency Levels & Point Thresholds

| Level | Points Required | Progress Bar Range |
|-------|----------------|-------------------|
| **Beginner** | 0 - 50 points | 0% - 100% (within level) |
| **Intermediate** | 51 - 150 points | 0% - 100% (within level) |
| **Advanced** | 151 - 300 points | 0% - 100% (within level) |
| **Expert** | 301+ points | 100% (max level) |

### How Progress is Calculated

**Within Each Level:**
- **Beginner**: Each point = 2% progress (50 points needed)
- **Intermediate**: Each point = 1% progress (100 points needed: 51→151)
- **Advanced**: Each point = 0.67% progress (150 points needed: 151→301)
- **Expert**: Maximum level reached

### Examples

| Points Earned | Proficiency Level | Progress % | Next Milestone |
|--------------|------------------|-----------|----------------|
| 0 pts | Beginner | 0% | 51 pts → Intermediate |
| 25 pts | Beginner | 50% | 26 pts to Intermediate |
| 50 pts | Beginner | 100% | 1 pt to Intermediate |
| 51 pts | Intermediate | 0% | 100 pts to Advanced |
| 100 pts | Intermediate | 49% | 51 pts to Advanced |
| 150 pts | Intermediate | 99% | 1 pt to Advanced |
| 151 pts | Advanced | 0% | 150 pts to Expert |
| 225 pts | Advanced | 49% | 76 pts to Expert |
| 301+ pts | Expert | 100% | Max Level! |

### Automatic Updates

When a student completes a lesson:
1. **Points are awarded** based on lesson difficulty:
   - Beginner lessons: 10 points
   - Intermediate lessons: 20 points
   - Advanced lessons: 30 points

2. **Proficiency is recalculated** for that language
3. **Last Practiced date** is updated
4. **Progress bar** updates to show % within current level

### Display Features

- **Progress Bar**: Shows percentage within current proficiency level (not overall)
- **Points Display**: Shows total points earned and points needed for next level
- **Lesson History**: Shows points earned for each completed lesson (not test scores)
- **Real-time Updates**: Proficiency updates immediately when lessons are marked complete

### Database

The system automatically:
- Stores `pointsEarned` in `studentProgress` table
- Updates `proficiencyLevel` in `studentLanguages` table
- Updates `lastPracticedAt` in `studentLanguages` table

No manual intervention needed - everything updates automatically!
