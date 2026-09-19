const db = require('../config/db');

class Question {

    static async find() {
        const snapshot = await db.collection('questions').get();
        if (snapshot.empty) {
            return [];
        }
        const questions = [];
        snapshot.forEach((doc) => {
            questions.push({
                id: doc.id,
                ...doc.data()
            });
        });
        return questions;
    }

    static async findById(id) {
        const docRef = db.collection('questions').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return null;
        }
        return { id: doc.id, ...doc.data() };
    }

    static async findByExamId(examId) {
        const snapshot = await db.collection('questions').where('examId', '==', examId).get();
        if (snapshot.empty) {
            return [];
        }
        const questions = [];
        snapshot.forEach((doc) => {
            questions.push({
                id: doc.id,
                ...doc.data()
            });
        });
        return questions;
    }

    static async create(question) {
        const docRef = await db.collection('questions').add(question);
        const doc = await docRef.get();
        return { id: doc.id, ...doc.data() };
    }

    static async findByIdAndUpdate(id, question) {
        const docRef = db.collection('questions').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return null;
        }
        await docRef.update(question);
        const updatedQuestion = await docRef.get();
        return { id: updatedQuestion.id, ...updatedQuestion.data() };
    }

    static async findByIdAndDelete(id) {
        const docRef = db.collection('questions').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return null;
        }
        await docRef.delete();
        return { id: doc.id, ...doc.data() };
    }
}

module.exports = Question;
