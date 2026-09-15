const fs = require('fs');
const path = require('path');

let db;

const serviceAccountPath = path.join(__dirname, '../serviceAccountKey.json');

if (fs.existsSync(serviceAccountPath)) {
    try {
        const { initializeApp, cert } = require('firebase-admin/app');
        const { getFirestore } = require('firebase-admin/firestore');
        const serviceAccountKey = require(serviceAccountPath);

        initializeApp({
            credential: cert(serviceAccountKey)
        });

        db = getFirestore();
        console.log(' Connected to Firebase Firestore using serviceAccountKey.json');
    } catch (err) {
        console.warn('⚠️ Firebase initialization failed, falling back to local memory store:', err.message);
        db = createInMemoryDb();
    }
} else {
    console.log('ℹ️ serviceAccountKey.json not found — running in local memory mode.');
    db = createInMemoryDb();
}

function createInMemoryDb() {
    const store = {
        users: new Map(),
        exams: new Map(),
        questions: new Map(),
        submissions: new Map()
    };

    // Pre-populate with demo data
    store.users.set('1', { name: 'Admin User', email: 'admin@exam.com', password: 'admin123', role: 'admin' });
    store.users.set('2', { name: 'Faculty Teacher', email: 'faculty@exam.com', password: 'faculty123', role: 'faculty' });
    store.users.set('3', { name: 'Student Piyush', email: 'student@exam.com', password: 'student123', role: 'student' });

    store.exams.set('exam_1', {
        title: 'Flutter & Dart Fundamentals',
        description: 'Comprehensive test on Flutter widgets, state management, and async Dart',
        durationMinutes: 30,
        totalMarks: 20,
        passingMarks: 10,
        status: 'active',
        scheduledAt: '2026-09-20 10:00',
        createdBy: '2'
    });

    store.questions.set('q1', {
        examId: 'exam_1',
        questionText: 'What is the purpose of setState() in Flutter?',
        optionA: 'To rebuild the widget tree with updated state',
        optionB: 'To destroy the widget',
        optionC: 'To navigate to another page',
        optionD: 'To stop the app',
        correctAnswer: 'A',
        marks: 5
    });

    store.questions.set('q2', {
        examId: 'exam_1',
        questionText: 'Which widget is best suited for responsive layouts?',
        optionA: 'Container',
        optionB: 'LayoutBuilder / Flexible',
        optionC: 'Text',
        optionD: 'Icon',
        correctAnswer: 'B',
        marks: 5
    });

    store.questions.set('q3', {
        examId: 'exam_1',
        questionText: 'What is the root widget of most Flutter Material apps?',
        optionA: 'MaterialApp',
        optionB: 'Scaffold',
        optionC: 'Container',
        optionD: 'Center',
        correctAnswer: 'A',
        marks: 5
    });

    store.questions.set('q4', {
        examId: 'exam_1',
        questionText: 'Which keyword is used to handle asynchronous operations in Dart?',
        optionA: 'defer',
        optionB: 'async / await',
        optionC: 'promise',
        optionD: 'thread',
        correctAnswer: 'B',
        marks: 5
    });

    let autoIdCounter = 100;

    return {
        collection: (collectionName) => {
            if (!store[collectionName]) {
                store[collectionName] = new Map();
            }
            const map = store[collectionName];

            return {
                get: async () => {
                    const docs = [];
                    map.forEach((value, id) => {
                        docs.push({
                            id,
                            data: () => ({ ...value }),
                            exists: true
                        });
                    });
                    return {
                        empty: docs.length === 0,
                        docs,
                        forEach: (cb) => docs.forEach(cb)
                    };
                },
                doc: (id) => ({
                    get: async () => ({
                        id,
                        exists: map.has(id),
                        data: () => (map.has(id) ? { ...map.get(id) } : undefined)
                    }),
                    update: async (data) => {
                        if (map.has(id)) {
                            map.set(id, { ...map.get(id), ...data });
                        }
                    },
                    delete: async () => {
                        map.delete(id);
                    }
                }),
                add: async (data) => {
                    const id = (++autoIdCounter).toString();
                    map.set(id, { ...data });
                    return {
                        id,
                        get: async () => ({
                            id,
                            exists: true,
                            data: () => ({ ...map.get(id) })
                        })
                    };
                },
                where: (field, op, val) => ({
                    get: async () => {
                        const docs = [];
                        map.forEach((v, id) => {
                            let match = false;
                            if (op === '==' && v[field] === val) match = true;
                            if (match) {
                                docs.push({
                                    id,
                                    data: () => ({ ...v }),
                                    exists: true
                                });
                            }
                        });
                        return {
                            empty: docs.length === 0,
                            docs,
                            forEach: (cb) => docs.forEach(cb)
                        };
                    }
                })
            };
        }
    };
}

module.exports = db;
