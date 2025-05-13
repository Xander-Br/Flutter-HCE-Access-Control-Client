// models/User.js
module.exports = (sequelize, DataTypes) => {
    const User = sequelize.define('User', {
      id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      username: { // Or email, or any unique identifier for the user
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
      },
      totpSecret: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      // You can add other user-specific fields here if needed
      // e.g., fullName, employeeId, etc.
    });
    return User;
  };