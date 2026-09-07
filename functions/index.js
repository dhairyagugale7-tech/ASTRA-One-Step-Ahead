const {setGlobalOptions} = require("firebase-functions");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

setGlobalOptions({
  maxInstances: 10,
});

exports.sendSOSNotification = onDocumentCreated(
  "sosEvents/{sosId}",
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      console.log("SOS event data is missing.");
      return;
    }

    const sosData = snapshot.data();

    const sosId = event.params.sosId;
    const userId = sosData.userId;
    const latitude = sosData.latitude;
    const longitude = sosData.longitude;
    // Never notify the person who triggered the SOS.
    const guardianIds = (sosData.guardianIds || [])
        .filter((guardianId) => guardianId !== userId);

    console.log("======================================");
    console.log("ASTRA SOS FUNCTION TRIGGERED");
    console.log("SOS ID:", sosId);
    console.log("User ID:", userId);
    console.log("Guardians:", guardianIds);
    console.log("Location:", latitude, longitude);
    console.log("======================================");

    if (!userId) {
      console.log("No userId found in SOS event.");
      return;
    }

    if (guardianIds.length === 0) {
      console.log("No guardians found in SOS event.");
      return;
    }

    // ============================================================
    // GET USER NAME
    // ============================================================

    let userName = "ASTRA User";

    try {
      const userDoc = await db
          .collection("users")
          .doc(userId)
          .get();

      if (userDoc.exists) {
        const userData = userDoc.data();

        if (userData.name) {
          userName = userData.name;
        }
      }
    } catch (error) {
      console.error(
          "Unable to get user details:",
          error,
      );
    }

    // ============================================================
    // LOCATION URL
    // ============================================================

    const locationUrl =
      "https://www.google.com/maps/search/?api=1" +
      `&query=${latitude},${longitude}`;

    // ============================================================
    // CREATE PERSISTENT NOTIFICATIONS
    // ============================================================

    for (const guardianId of guardianIds) {
      try {
        await db.collection("notifications").add({
          receiverId: guardianId,
          senderId: userId,
          type: "SOS",
          sosId: sosId,

          title: "🚨 Emergency SOS",

          body:
            `${userName} activated an emergency SOS. ` +
            "Their current location is available.",

          latitude: latitude,
          longitude: longitude,
          locationUrl: locationUrl,

          createdAt: admin.firestore.FieldValue.serverTimestamp(),

          read: false,
        });

        console.log(
          "SOS notification created for guardian:",
          guardianId,
        );
      } catch (error) {
        console.error(
          "Error creating notification for guardian:",
          guardianId,
          error,
        );
      }
    }

    // ============================================================
    // CREATE SOS CHAT MESSAGES
    // ============================================================

    const currentLocationUrl =
        "https://www.google.com/maps/search/?api=1" +
        `&query=${latitude},${longitude}`;

    const liveLocationUrl =
        "https://astra-one-step-ahead.web.app/" +
        `?sosId=${sosId}`;

    for (const guardianId of guardianIds) {
      try {
        const sosMessage =
            "🚨 EMERGENCY SOS\n\n" +
            `${userName} activated an emergency SOS.\n\n` +
            "📍 Current Location:\n" +
            `${currentLocationUrl}\n\n` +
            "🔴 Live Location:\n" +
            `${liveLocationUrl}`;

        await db.collection("messages").add({
          senderId: userId,
          receiverId: guardianId,
          message: sosMessage,
          messageType: "sos",
          createdAt:
              admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(
          "SOS chat message created for guardian:",
          guardianId,
        );
      } catch (error) {
        console.error(
          "Error creating SOS chat message for guardian:",
          guardianId,
          error,
        );
      }
    }
    // ============================================================
    // GET GUARDIAN FCM TOKENS
    // ============================================================

    const tokens = [];

    for (const guardianId of guardianIds) {
      try {
        const guardianDoc = await db
            .collection("users")
            .doc(guardianId)
            .get();

        if (!guardianDoc.exists) {
          console.log(
            "Guardian user not found:",
            guardianId,
          );
          continue;
        }

        const guardianData = guardianDoc.data();

        const token = guardianData.fcmToken;

        if (token && typeof token === "string") {
          tokens.push(token);

          console.log(
            "FCM token found for guardian:",
            guardianId,
          );
        } else {
          console.log(
            "No FCM token found for guardian:",
            guardianId,
          );
        }
      } catch (error) {
        console.error(
          "Error loading guardian:",
          guardianId,
          error,
        );
      }
    }

    // ============================================================
    // NO TOKENS
    // ============================================================

    if (tokens.length === 0) {
      console.log(
        "No guardian FCM tokens available.",
      );

      // Persistent notifications were already created.
      return;
    }

    // ============================================================
    // FCM MESSAGE
    // ============================================================

    const message = {
      tokens: tokens,

      notification: {
        title: "🚨 ASTRA EMERGENCY SOS",
        body:
          `${userName} has activated an emergency SOS. ` +
          "Tap to view their location.",
      },

      data: {
        type: "SOS",
        sosId: sosId,
        userId: userId,
        latitude: String(latitude),
        longitude: String(longitude),
        locationUrl: locationUrl,
      },

      android: {
        priority: "high",

        notification: {
          channelId: "sos_alerts",
          sound: "sos_alarm",
          priority: "max",
        },
      },
    };

    // ============================================================
    // SEND FCM
    // ============================================================

    try {
      const response =
        await messaging.sendEachForMulticast(message);

      console.log(
        "SOS notifications sent.",
      );

      console.log(
        "Successful:",
        response.successCount,
      );

      console.log(
        "Failed:",
        response.failureCount,
      );

      response.responses.forEach(
        (result, index) => {
          if (!result.success) {
            console.error(
              "FCM failed for token:",
              tokens[index],
              result.error,
            );
          }
        },
      );
    } catch (error) {
      console.error(
        "Error sending SOS:",
        error,
      );
    }
  },
);