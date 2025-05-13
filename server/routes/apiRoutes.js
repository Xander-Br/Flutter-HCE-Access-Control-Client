// routes/apiRoutes.js
const express = require('express');
const router = express.Router();
const { User, Permission } = require('../models'); // Adjusted path
const { authenticator } = require('otplib');

// API Endpoint to verify TOTP (e.g., called by the mobile app via NFC reader)
router.post('/authenticate-totp', async (req, res) => {
  const { username, totpCode } = req.body;

  if (!username || !totpCode) {
    return res.status(400).json({ success: false, message: 'Username and TOTP code are required.' });
  }

  try {
    const user = await User.findOne({ where: { username } });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    const isValid = authenticator.check(totpCode, user.totpSecret);

    if (isValid) {
      res.json({ success: true, message: 'TOTP authentication successful.' /*, permissions: permissionNames */ });
    } else {
      res.status(401).json({ success: false, message: 'Invalid TOTP code.' });
    }
  } catch (error) {
    console.error('TOTP Authentication Error:', error);
    res.status(500).json({ success: false, message: 'An internal server error occurred.' });
  }
});


// For this PoC, it's a direct check, but in a real app, secure this endpoint.
router.post('/check-permission', async (req, res) => {
  const { username, permissionName } = req.body;

  if (!username || !permissionName) {
    return res.status(400).json({ success: false, message: 'Username and permission name are required.' });
  }

  try {
    const user = await User.findOne({
      where: { username },
      include: {
        model: Permission,
        where: { name: permissionName },
        required: true // Ensures that only users with the permission are returned
      }
    });

    if (user && user.Permissions && user.Permissions.length > 0) {
      res.json({ success: true, message: `User has permission: ${permissionName}` });
    } else {
      res.status(403).json({ success: false, message: `User does not have permission: ${permissionName}` });
    }
  } catch (error) {
    console.error('Permission Check Error:', error);
    res.status(500).json({ success: false, message: 'An internal server error occurred.' });
  }
});


module.exports = router;