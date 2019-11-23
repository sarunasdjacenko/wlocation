const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// delete new users after they are created
exports.deleteNewUser = functions
  .region('europe-west2')
  .auth
  .user()
  .onCreate(user => admin.auth().deleteUser(user.uid));
