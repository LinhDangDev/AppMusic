
const jwt = require('jsonwebtoken');
const User = require('../models/user');

const auth = async (req, res, next) => {
    try {
        const token = req.header('Authorization').replace('Bearer ', '');
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findOne({ _id: decoded._id, 'tokens.token': token });

        if (!user) {
            throw new Error();
        }

        req.token = token;
        req.user = user;
        next();
    } catch (e) {
        res.status(401).send({ error: 'Please authenticate.' });
    }
};

module.exports = auth;


const admin = require('../config/firebase');
const db = require('../config/database');
const jwt = require('jsonwebtoken');

exports.login = async (req, res) => {
  try {
    const { idToken } = req.body;

    // Verify Firebase token
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const { email, uid } = decodedToken;

    // Check if user exists in database
    const [users] = await db.execute(
      'SELECT * FROM Users WHERE email = ?',
      [email]
    );

    let userId;
    if (users.length === 0) {
      // Create new user if not exists
      const [result] = await db.execute(
        'INSERT INTO Users (email) VALUES (?)',
        [email]
      );
      userId = result.insertId;
    } else {
      userId = users[0].id;
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId, email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({ token, userId });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Authentication failed' });
  }
};
