const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Listens for new documents added to the /notifications collection
exports.onJobInserted = functions.firestore
  .document("notifications/{id}")
  .onCreate(async (snap, context) => {
    
    // Get the newly inserted document values
    const newJob = snap.data();
    const psuName = newJob.psuName || "A PSU";
    const jobRole = newJob.role || "A new job";

    console.log(`New Job Detected! Broadcasting: ${psuName} - ${jobRole}`);

    // Create the push notification payload
    const payload = {
      notification: {
        title: `New Recruitment Alert: ${psuName}`,
        body: `Role: ${jobRole}. Tap to view deadline and details.`,
        sound: "default"
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        notificationId: snap.id, // we can optionally pass the ID to navigate locally later!
        link: newJob.notificationLink || ""
      }
    };

    try {
      // Send the message to anyone subscribed to the "all_users" topic
      const response = await admin.messaging().sendToTopic("all_users", payload);
      console.log(`Successfully sent FCM to 'all_users' topic. Success count: ${response.successCount}`);
      return null;
    } catch (error) {
      console.error("Error sending FCM notification payload:", error);
      return null;
    }
  });
