// models/UserPermission.js
module.exports = (sequelize, DataTypes) => {
    const UserPermission = sequelize.define('UserPermission', {
      userId: {
        type: DataTypes.INTEGER,
        references: {
          model: 'Users', // Name of the table
          key: 'id',
        },
        primaryKey: true,
      },
      permissionId: {
        type: DataTypes.INTEGER,
        references: {
          model: 'Permissions', // Name of the table
          key: 'id',
        },
        primaryKey: true,
      },
    });
    return UserPermission;
  };