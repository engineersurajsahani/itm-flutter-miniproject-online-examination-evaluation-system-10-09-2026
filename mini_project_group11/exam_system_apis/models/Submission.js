const db = require('../config/db');
const Question = require('./Question');

class Submission {

    static async find() {
        const snapshot = await db.collection('submissions').get();
        if (snapshot.empty) {
            return [];
        }
        const submissions = [];
        snapshot.forEach((doc) => {
            submissions.push({
                id: doc.id,
                ...doc.data()
            });
        });
        return submissions;
    }

    static async findById(id) {
        const docRef = db.collection('submissions').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return null;
        }
        return { id: doc.id, ...doc.data() };
    }

    static async findByExamId(examId) {
        const snapshot = await db.collection('submissions').where('examId', '==', examId).get();
        if (snapshot.empty) {
            return [];
        }
        const submissions = [];
        snapshot.forEach((doc) => {
            submissions.push({
                id: doc.id,
                ...doc.data()
            });
        });
        return submissions;
    }

    static async findByStudentId(studentId) {
        const snapshot = await db.collection('submissions').where('studentId', '==', studentId).get();
        if (snapshot.empty) {
            return [];
        }
        const submissions = [];
        snapshot.forEach((doc) => {
            submissions.push({
                id: doc.id,
                ...doc.data()
            });
        });
        return submissions;
    }

    // Auto-evaluate: compare student answers with correct answers and compute score
    static async createAndEvaluate(submissionData) {
        const { examId, studentId, studentName, answers } = submissionData;

        // Fetch all questions for this exam
        const questions = await Question.findByExamId(examId);

        let score = 0;
        let totalMarks = 0;
        const evaluatedAnswers = {};

        for (const question of questions) {
            const questionId = question.id;
            const correctAnswer = question.correctAnswer;
            const marks = parseInt(question.marks) || 1;
            totalMarks += marks;

            const studentAnswer = answers[questionId] || '';
            const isCorrect = studentAnswer === correctAnswer;

            if (isCorrect) {
                score += marks;
            }

            evaluatedAnswers[questionId] = {
                selectedAnswer: studentAnswer,
                correctAnswer: correctAnswer,
                isCorrect: isCorrect,
                marks: isCorrect ? marks : 0
            };
        }

        const percentage = totalMarks > 0 ? ((score / totalMarks) * 100).toFixed(2) : 0;

        const submission = {
            examId,
            studentId,
            studentName,
            answers: evaluatedAnswers,
            score,
            totalMarks,
            percentage: parseFloat(percentage),
            submittedAt: new Date().toISOString()
        };

        const docRef = await db.collection('submissions').add(submission);
        const doc = await docRef.get();
        return { id: doc.id, ...doc.data() };
    }

    static async findByIdAndDelete(id) {
        const docRef = db.collection('submissions').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return null;
        }
        await docRef.delete();
        return { id: doc.id, ...doc.data() };
    }
}

module.exports = Submission;
