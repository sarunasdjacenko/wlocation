const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");
admin.initializeApp();

// TODO: automatic account creation and sign in when blocking is released
// https://twitter.com/puf/status/1134823420909314049

// (Temporary) Get a sign-in token if credentials are correct.
exports.getToken = functions.region("europe-west2").https.onCall(data =>
  admin
    .firestore()
    .collection("administrators")
    .doc(data.username)
    .get()
    .then((document) => {
      if (document.exists) {
        hash = crypto
          .createHash("sha512")
          .update(data.password + document.data().salt)
          .digest("hex");
        if (hash == document.data().hash) {
          return admin.auth().createCustomToken(data.username);
        }
      }
    })
);
