const db = require('../config/db');

class Result {

    // Get analytics for a specific exam
    static async getExamAnalytics(examId) {
        const snapshot = await db.collection('submissions').where('examId', '==', examId).get();

        if (snapshot.empty) {
            return {
                examId,
                totalStudents: 0,
                averageScore: 0,
                averagePercentage: 0,
                highestScore: 0,
                lowestScore: 0,
                passCount: 0,
                failCount: 0,
                passPercentage: 0,
                topScorers: [],
                scoreDistribution: {}
            };
        }

        const submissions = [];
        snapshot.forEach((doc) => {
            submissions.push({ id: doc.id, ...doc.data() });
        });

        const totalStudents = submissions.length;
        const scores = submissions.map(s => s.score);
        const percentages = submissions.map(s => s.percentage);

        const totalScore = scores.reduce((a, b) => a + b, 0);
        const averageScore = (totalScore / totalStudents).toFixed(2);
        const averagePercentage = (percentages.reduce((a, b) => a + b, 0) / totalStudents).toFixed(2);
        const highestScore = Math.max(...scores);
        const lowestScore = Math.min(...scores);

        // Pass = 40% or above
        const passCount = submissions.filter(s => s.percentage >= 40).length;
        const failCount = totalStudents - passCount;
        const passPercentage = ((passCount / totalStudents) * 100).toFixed(2);

        // Top 5 scorers
        const topScorers = submissions
            .sort((a, b) => b.score - a.score)
            .slice(0, 5)
            .map(s => ({
                studentId: s.studentId,
                studentName: s.studentName,
                score: s.score,
                percentage: s.percentage
            }));

        // Score distribution (ranges: 0-20, 21-40, 41-60, 61-80, 81-100)
        const scoreDistribution = {
            '0-20': submissions.filter(s => s.percentage >= 0 && s.percentage <= 20).length,
            '21-40': submissions.filter(s => s.percentage > 20 && s.percentage <= 40).length,
            '41-60': submissions.filter(s => s.percentage > 40 && s.percentage <= 60).length,
            '61-80': submissions.filter(s => s.percentage > 60 && s.percentage <= 80).length,
            '81-100': submissions.filter(s => s.percentage > 80 && s.percentage <= 100).length
        };

        return {
            examId,
            totalStudents,
            averageScore: parseFloat(averageScore),
            averagePercentage: parseFloat(averagePercentage),
            highestScore,
            lowestScore,
            passCount,
            failCount,
            passPercentage: parseFloat(passPercentage),
            topScorers,
            scoreDistribution
        };
    }

    // Get all results for a specific student across all exams
    static async getStudentResults(studentId) {
        const snapshot = await db.collection('submissions').where('studentId', '==', studentId).get();
        if (snapshot.empty) {
            return [];
        }
        const results = [];
        snapshot.forEach((doc) => {
            results.push({ id: doc.id, ...doc.data() });
        });
        return results;
    }
}

module.exports = Result;
