// models/index.js
const { Sequelize } = require('sequelize'); // <--- IMPORT Sequelize CLASS HERE
const sequelizeInstance = require('../config/database'); // Renamed to avoid confusion with Sequelize class
const AdminModel = require('./Admin');
const UserModel = require('./User');
const PermissionModel = require('./Permission');
const UserPermissionModel = require('./UserPermission');

const Admin = AdminModel(sequelizeInstance, Sequelize.DataTypes);
const User = UserModel(sequelizeInstance, Sequelize.DataTypes);
const Permission = PermissionModel(sequelizeInstance, Sequelize.DataTypes);
const UserPermission = UserPermissionModel(sequelizeInstance, Sequelize.DataTypes);

// Define associations
User.belongsToMany(Permission, { through: UserPermission, foreignKey: 'userId', otherKey: 'permissionId', as: 'Permissions' }); // Added 'as' alias
Permission.belongsToMany(User, { through: UserPermission, foreignKey: 'permissionId', otherKey: 'userId', as: 'Users' }); // Added 'as' alias

const db = {
  sequelize: sequelizeInstance, // Export the instance
  Sequelize,                  // Export the Sequelize class/constructor
  Admin,
  User,
  Permission,
  UserPermission,
};

// Sync all models
db.sync = async () => {
  await sequelizeInstance.sync({ alter: true }); //TODO: Fix database intialization and restart to persist data
  console.log('All models were synchronized successfully.');

  // Seed initial admin if none exists
  const adminCount = await Admin.count();
  if (adminCount === 0) {
    const bcrypt = require('bcrypt');
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(process.env.DEFAULT_ADMIN_PASSWORD || 'admin123', saltRounds);
    await Admin.create({ username: process.env.DEFAULT_ADMIN_USER || 'admin', password: hashedPassword });
    console.log('Default admin user created.');
    console.log('Default admin user created with username "admin" and password "admin123" (or environment variables if set)');
  }

  // Optional: Seed some initial permissions
  const permCount = await Permission.count();
  if (permCount === 0) {
    await Permission.bulkCreate([
      { name: 'access_zone_a', description: 'Access to Zone A' },
      { name: 'access_zone_b', description: 'Access to Zone B' },
      { name: 'view_reports', description: 'Can view system reports' },
    ]);
    console.log('Initial permissions seeded.');
  }
};

module.exports = db;