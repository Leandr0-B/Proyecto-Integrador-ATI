importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: 'AIzaSyAt5aHJlNsBxnjvztAXGb5TK006_bppvDQ',
    appId: '1:73835003784:web:2b6429ed098379b281443d',
    messagingSenderId: '73835003784',
    projectId: 'fir-flutter-v5',
    authDomain: 'fir-flutter-v5.firebaseapp.com',
    storageBucket: 'fir-flutter-v5.appspot.com',
    measurementId: 'G-57JZPM2LEX',

});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:

messaging.onBackgroundMessage((payload) => {
  console.log("onBackgroundMessage", payload);
  
});