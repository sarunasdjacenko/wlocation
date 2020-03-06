const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// TODO: replace signUp with beforeCreate when available
// https://twitter.com/puf/status/1134823420909314049

const createUser = async (email, password) => {
  try {
    return await admin.auth().createUser({
      email: email,
      password: password
    });
  } catch (error) {
    return null;
  }
};

const getUserByEmail = async email => {
  try {
    return await admin.auth().getUserByEmail(email);
  } catch (error) {
    return null;
  }
};

const getAdminDocumentByEmail = async email => {
  const document = await admin
    .firestore()
    .collection('administrators')
    .doc(email)
    .get();
  return document;
};

exports.signUp = functions.region('europe-west2').https.onCall(async data => {
  const email = data.email;
  const password = data.password;
  // Throw error if the user is not authorized to be an administrator.
  const document = await getAdminDocumentByEmail(email);
  if (!document.exists) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'You are not authorized to create an account.'
    );
  }
  // Throw error if the email address is already taken.
  const user = await getUserByEmail(email);
  if (user !== null) {
    throw new functions.https.HttpsError(
      'already-exists',
      'The email address is already in use by another account.'
    );
  }
  // Create an administrator account.
  const newUser = await createUser(email, password);
  if (newUser === null) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'The password you entered is invalid.'
    );
  }
  return admin.auth().setCustomUserClaims(newUser.uid, { admin: true });
});
