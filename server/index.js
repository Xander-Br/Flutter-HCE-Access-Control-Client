// app.js
const express = require('express');
const session = require('express-session');
const path = require('path');
const bodyParser = require('body-parser');
const db = require('./models'); // Sequelize instance and models

const adminRoutes = require('./routes/adminRoutes');
const apiRoutes = require('./routes/apiRoutes');

const app = express();
const PORT = process.env.PORT || 8080;

// View engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

// Middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

// Session setup
app.use(session({
  secret: process.env.SESSION_SECRET || 'secret-key', 
  resave: false,
  saveUninitialized: true, 
  cookie: {
    secure: false, 
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000 // 1 day
  }
}));

app.use((req, res, next) => {
  res.locals.session = req.session;
  next();
});

// Routes
app.use('/admin', adminRoutes);
app.use('/api', apiRoutes);

app.get('/', (req, res) => {
  res.redirect('/admin/login');
});

// 404 Handler
app.use((req, res, next) => {
  res.status(404).render('partials/404', { title: 'Page Not Found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).render('partials/500', { title: 'Server Error', error: err.message });
});


// Initialize database and start server
db.sync()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Server is running on http://localhost:${PORT}`);
      console.log(`Admin panel: http://localhost:${PORT}/admin/login`);
    });
  })
  .catch(err => {
    console.error('Unable to connect to the database or sync models:', err);
  });