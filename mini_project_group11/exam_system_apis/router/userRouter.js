const express = require('express');
const User = require('../models/User');

let getAuth;
try {
    const adminAuth = require('firebase-admin/auth');
    getAuth = adminAuth.getAuth;
} catch (e) {
    // Auth not available
}

const router = express.Router();

// Get all users
router.get('/', async (request, response) => {
    try {
        const users = await User.find();
        response.status(200).json(users);
    } catch (error) {
        response.status(500).json({ message: error.message });
    }
});

// Get user by id
router.get('/:id', async (request, response) => {
    try {
        const user = await User.findById(request.params.id);
        if (!user) {
            return response.status(404).json({ message: "User Not Found!!!" });
        }
        response.status(200).json(user);
    } catch (error) {
        response.status(500).json({ message: error.message });
    }
});

// Login - find by email and verify password
router.post('/login', async (request, response) => {
    try {
        const { email, password } = request.body;
        let user = await User.findByEmail(email);

        // Auto-seed default users if database is fresh
        if (!user && (email === 'admin@exam.com' || email === 'faculty@exam.com' || email === 'student@exam.com')) {
            const defaultRole = email.split('@')[0];
            user = await User.create({
                name: defaultRole.charAt(0).toUpperCase() + defaultRole.slice(1) + ' User',
                email: email,
                password: password || defaultRole + '123',
                role: defaultRole
            });
        }

        if (!user) {
            return response.status(404).json({ message: "User Not Found! Please register." });
        }
        if (user.password !== password) {
            return response.status(401).json({ message: "Invalid Password!" });
        }
        response.status(200).json(user);
    } catch (error) {
        response.status(500).json({ message: error.message });
    }
});

// Create user (register) - saves to both Firebase Auth and Firestore
router.post('/', async (request, response) => {
    try {
        const { email, password, name, role } = request.body;

        // 1. Also sync to Firebase Authentication tab if Firebase Auth is active
        if (getAuth && email && password) {
            try {
                await getAuth().createUser({
                    email: email,
                    password: password,
                    displayName: name || email
                });
                console.log(` Created user in Firebase Auth: ${email}`);
            } catch (authErr) {
                // Ignore if user already exists in Firebase Auth
                if (authErr.code !== 'auth/email-already-exists') {
                    console.warn('Firebase Auth notice:', authErr.message);
                }
            }
        }

        // 2. Save user document in Firestore collection
        const user = await User.create(request.body);
        response.status(201).json({ message: "User Created Successfully!", user });
    } catch (error) {
        response.status(500).json({ message: error.message });
    }
});

// Update user
router.put('/:id', async (request, response) => {
    try {
        const user = await User.findByIdAndUpdate(request.params.id, request.body);
        if (!user) {
            return response.status(404).json({ message: "User Not Found!" });
        }
        response.status(200).json({ message: "User Updated Successfully!", user });
    } catch (error) {
        response.status(500).json({ message: error.message });
    }
});

// Delete user
router.delete('/:id', async (request, response) => {
    try {
        const user = await User.findByIdAndDelete(request.params.id);
        if (!user) {
            return response.status(404).json({ message: "User Not Found!" });
        }
        response.status(200).json({ message: "User Deleted Successfully!", user });
    } catch (error) {
        response.status(500).json({ message: error.message });
    }
});

module.exports = router;
