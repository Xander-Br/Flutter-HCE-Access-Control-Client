// middleware/authMiddleware.js
function isAdminAuthenticated(req, res, next) {
    if (req.session && req.session.adminId) {
      return next();
    } else {
      req.session.returnTo = req.originalUrl; // Store original URL to redirect after login
      res.redirect('/admin/login');
    }
  }
  
  module.exports = { isAdminAuthenticated };