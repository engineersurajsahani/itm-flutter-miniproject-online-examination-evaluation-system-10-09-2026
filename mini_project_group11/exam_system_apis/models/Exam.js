const db = require('../config/db');

class Exam {

    static async find() {
        const snapshot = await db.collection('exams').get();
        if (snapshot.empty) {
            return [];
        }
        const exams = [];
        snapshot.forEach((doc) => {
            exams.push({
                id: doc.id,
                ...doc.data()
            });
        });
        return exams;
    }

    static async findById(id) {
        const docRef = db.collection('exams').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return null;
        }
        return { id: doc.id, ...doc.data() };
    }

    static async findByStatus(status) {
        const snapshot = await db.collection('exams').where('status', '==', status).get();
        if (snapshot.empty) {
            return [];
        }
        const exams = [];
        snapshot.forEach((doc) => {
            exams.push({
                id: doc.id,
                ...doc.data()
            });
        });
        return exams;
    }

    static async create(exam) {
        const docRef = await db.collection('exams').add(exam);
        const doc = await docRef.get();
        return { id: doc.id, ...doc.data() };
    }

    static async findByIdAndUpdate(id, exam) {
        const docRef = db.collection('exams').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return null;
        }
        await docRef.update(exam);
        const updatedExam = await docRef.get();
        return { id: updatedExam.id, ...updatedExam.data() };
    }

    static async findByIdAndDelete(id) {
        const docRef = db.collection('exams').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return null;
        }
        await docRef.delete();
        return { id: doc.id, ...doc.data() };
    }
}

module.exports = Exam;
