// routes/adminRoutes.js
const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const { authenticator } = require('otplib');
const qrcode = require('qrcode');
const { Admin, User, Permission, UserPermission } = require('../models'); // Adjusted path
const { isAdminAuthenticated } = require('../middleware/authMiddleware');

const saltRounds = 10;

// --- Admin Auth ---
router.get('/login', (req, res) => {
  res.render('admin/login', { title: 'Admin Login', error: null, success: null });
});

router.post('/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const admin = await Admin.findOne({ where: { username } });
    if (admin && await bcrypt.compare(password, admin.password)) {
      req.session.adminId = admin.id;
      req.session.adminUsername = admin.username;
      const returnTo = req.session.returnTo || '/admin/dashboard';
      delete req.session.returnTo;
      res.redirect(returnTo);
    } else {
      res.render('admin/login', { title: 'Admin Login', error: 'Invalid username or password.', success: null });
    }
  } catch (error) {
    console.error('Login error:', error);
    res.render('admin/login', { title: 'Admin Login', error: 'An error occurred.', success: null });
  }
});

router.get('/logout', (req, res) => {
  req.session.destroy(err => {
    if (err) {
      return res.redirect('/admin/dashboard'); 
    }
    res.clearCookie('connect.sid'); 
    res.redirect('/admin/login');
  });
});

// --- Dashboard ---
router.get('/dashboard', isAdminAuthenticated, (req, res) => {
  res.render('admin/dashboard', { title: 'Admin Dashboard', adminUsername: req.session.adminUsername });
});

// --- User Management ---
router.get('/users', isAdminAuthenticated, async (req, res) => {
  try {
    const users = await User.findAll();
    res.render('admin/users', { title: 'Manage Users', users, adminUsername: req.session.adminUsername, message: req.session.message });
    delete req.session.message;
  } catch (error) {
    console.error(error);
    res.status(500).send('Error fetching users');
  }
});

router.get('/users/add', isAdminAuthenticated, (req, res) => {
  res.render('admin/addUser', { title: 'Add New User', adminUsername: req.session.adminUsername, error: null, success: null, qrCodeUrl: null, totpSecret: null });
});

router.post('/users/add', isAdminAuthenticated, async (req, res) => {
  const { username } = req.body;
  if (!username) {
      return res.render('admin/addUser', { title: 'Add New User', adminUsername: req.session.adminUsername, error: 'Username is required.', success: null, qrCodeUrl: null, totpSecret: null });
  }
  try {
    const existingUser = await User.findOne({ where: { username } });
    if (existingUser) {
      return res.render('admin/addUser', { title: 'Add New User', adminUsername: req.session.adminUsername, error: 'Username already exists.', success: null, qrCodeUrl: null, totpSecret: null });
    }

    const totpSecret = authenticator.generateSecret();
    const newUser = await User.create({ username, totpSecret });

    // Generate QR code for TOTP setup
    const serviceName = 'SICPA_POC_Access';
    const otpAuthUrl = authenticator.keyuri(username, serviceName, totpSecret);
    const qrCodeDataUrl = await qrcode.toDataURL(otpAuthUrl);

    // Instead of redirecting, render the same page with QR code
    req.session.message = { type: 'success', text: `User ${username} added. Please scan the QR code.`};
    res.render('admin/addUser', {
      title: 'Add New User',
      adminUsername: req.session.adminUsername,
      error: null,
      success: `User "${username}" created successfully. Scan the QR code to set up TOTP.`,
      qrCodeUrl: qrCodeDataUrl,
      totpSecret: totpSecret, // Optionally show the secret for manual entry
      addedUsername: username
    });

  } catch (error) {
    console.error('Error adding user:', error);
    res.render('admin/addUser', { title: 'Add New User', adminUsername: req.session.adminUsername, error: 'Failed to add user.', success: null, qrCodeUrl: null, totpSecret: null });
  }
});

// --- Permission Management ---
router.get('/permissions', isAdminAuthenticated, async (req, res) => {
  try {
    const permissions = await Permission.findAll();
    res.render('admin/permissions', { title: 'Manage Permissions', permissions, adminUsername: req.session.adminUsername, message: req.session.message });
    delete req.session.message;
  } catch (error) {
    console.error(error);
    res.status(500).send('Error fetching permissions');
  }
});

router.get('/permissions/add', isAdminAuthenticated, (req, res) => {
  res.render('admin/addPermission', { title: 'Add New Permission', adminUsername: req.session.adminUsername, error: null, success: null });
});

router.post('/permissions/add', isAdminAuthenticated, async (req, res) => {
  const { name, description } = req.body;
  if (!name) {
    return res.render('admin/addPermission', { title: 'Add New Permission', adminUsername: req.session.adminUsername, error: 'Permission name is required.', success: null });
  }
  try {
    const existingPermission = await Permission.findOne({ where: { name } });
    if (existingPermission) {
      return res.render('admin/addPermission', { title: 'Add New Permission', adminUsername: req.session.adminUsername, error: 'Permission name already exists.', success: null });
    }
    await Permission.create({ name, description });
    req.session.message = { type: 'success', text: `Permission "${name}" added successfully.`};
    res.redirect('/admin/permissions');
  } catch (error) {
    console.error('Error adding permission:', error);
    res.render('admin/addPermission', { title: 'Add New Permission', adminUsername: req.session.adminUsername, error: 'Failed to add permission.', success: null });
  }
});

// --- Manage User Permissions ---
router.get('/users/:userId/permissions', isAdminAuthenticated, async (req, res) => {
  try {
    const user = await User.findByPk(req.params.userId, {
      include: { model: Permission, as: 'Permissions' }
    });
    if (!user) return res.status(404).send('User not found');

    const allPermissions = await Permission.findAll();
    const userPermissionIds = user.Permissions.map(p => p.id);

    res.render('admin/userPermissions', {
      title: `Manage Permissions for ${user.username}`,
      adminUsername: req.session.adminUsername,
      user,
      allPermissions,
      userPermissionIds,
      message: req.session.message
    });
    delete req.session.message;
  } catch (error) {
    console.error(error);
    res.status(500).send('Error fetching user permissions');
  }
});

router.post('/users/:userId/permissions', isAdminAuthenticated, async (req, res) => {
  const userId = parseInt(req.params.userId, 10);
  let { permissionIds } = req.body; 

  if (!permissionIds) {
    permissionIds = [];
  } else if (!Array.isArray(permissionIds)) {
    permissionIds = [permissionIds];
  }
  permissionIds = permissionIds.map(id => parseInt(id, 10));


  try {
    const user = await User.findByPk(userId);
    if (!user) return res.status(404).send('User not found');

    const currentPermissions = await user.getPermissions();
    const currentPermissionIds = currentPermissions.map(p => p.id);

    const permissionsToAdd = permissionIds.filter(id => !currentPermissionIds.includes(id));
    const permissionsToRemove = currentPermissionIds.filter(id => !permissionIds.includes(id));

    if (permissionsToAdd.length > 0) {
      await user.addPermissions(permissionsToAdd);
    }
    if (permissionsToRemove.length > 0) {
      await user.removePermissions(permissionsToRemove);
    }

    req.session.message = { type: 'success', text: 'User permissions updated successfully.'};
    res.redirect(`/admin/users/${userId}/permissions`);
  } catch (error) {
    console.error('Error updating user permissions:', error);
    req.session.message = { type: 'danger', text: 'Error updating permissions.'};
    res.redirect(`/admin/users/${userId}/permissions`);
  }
});


module.exports = router;