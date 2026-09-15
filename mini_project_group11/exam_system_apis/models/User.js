const db = require('../config/db');

class User {

    static async find() {
        const snapshot = await db.collection('users').get();
        if (snapshot.empty) {
            return [];
        }
        const users = [];
        snapshot.forEach((doc) => {
            users.push({
                id: doc.id,
                ...doc.data()
            });
        });
        return users;
    }

    static async findById(id) {
        const docRef = db.collection('users').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return null;
        }
        return { id: doc.id, ...doc.data() };
    }

    static async findByEmail(email) {
        const snapshot = await db.collection('users').where('email', '==', email).get();
        if (snapshot.empty) {
            return null;
        }
        const doc = snapshot.docs[0];
        return { id: doc.id, ...doc.data() };
    }

    static async create(user) {
        const docRef = await db.collection('users').add(user);
        const doc = await docRef.get();
        return { id: doc.id, ...doc.data() };
    }

    static async findByIdAndUpdate(id, user) {
        const docRef = db.collection('users').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return null;
        }
        await docRef.update(user);
        const updatedUser = await docRef.get();
        return { id: updatedUser.id, ...updatedUser.data() };
    }

    static async findByIdAndDelete(id) {
        const docRef = db.collection('users').doc(id);
        const doc = await docRef.get();
        if (!doc.exists) {
            return null;
        }
        await docRef.delete();
        return { id: doc.id, ...doc.data() };
    }
}

module.exports = User;
