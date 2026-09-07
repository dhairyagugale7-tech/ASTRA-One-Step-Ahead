// ===============================
// ASTRA LIVE GUARDIAN TRACKING
// ===============================


// ---------- FIREBASE CONFIG ----------

const firebaseConfig = {
    apiKey: "AIzaSyDzXCwHKSxAZGxkxuXObOIOwe7S6caUaZY",
    authDomain: "astra-one-step-ahead.firebaseapp.com",
    projectId: "astra-one-step-ahead",
    storageBucket: "astra-one-step-ahead.firebasestorage.app",
    messagingSenderId: "597022047813",
    appId: "1:597022047813:web:dbd3e7ef47104a078ead2c",
    measurementId: "G-DGS3JZXTH8"
};


// ---------- INITIALIZE FIREBASE ----------

firebase.initializeApp(firebaseConfig);

const db = firebase.firestore();


// ---------- GET TRACKING DETAILS FROM URL ----------

const urlParams = new URLSearchParams(
    window.location.search
);

const userId = urlParams.get("uid");
const journeyId = urlParams.get("journeyId");
const sosId = urlParams.get("sosId");


// ---------- HTML ELEMENTS ----------

const statusElement =
    document.getElementById("status");

const latitudeElement =
    document.getElementById("latitude");

const longitudeElement =
    document.getElementById("longitude");

const lastUpdatedElement =
    document.getElementById("lastUpdated");


// ---------- CHECK URL ----------

// JOURNEY TRACKING
if (userId && journeyId) {

    console.log(
        "Tracking Journey:",
        userId,
        journeyId
    );

    startJourneyTracking();


// SOS TRACKING
} else if (sosId) {

    console.log(
        "Tracking SOS:",
        sosId
    );

    startSOSTracking();


// INVALID
} else {

    statusElement.textContent =
        "Invalid tracking link.";

    console.error(
        "Missing Journey or SOS tracking information."
    );
}


// ---------- MAP ----------

let map;
let marker;


function initializeMap(
    latitude,
    longitude
) {

    map = L.map("map").setView(
        [latitude, longitude],
        15
    );


    L.tileLayer(
        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        {
            maxZoom: 19,
            attribution:
                "&copy; OpenStreetMap contributors"
        }
    ).addTo(map);


    marker = L.marker([
        latitude,
        longitude
    ]).addTo(map);


    marker
        .bindPopup(
            "User's Live Location"
        )
        .openPopup();
}


// ---------- UPDATE MAP ----------

function updateMap(
    latitude,
    longitude
) {

    const newPosition = [
        latitude,
        longitude
    ];


    if (!map) {

        initializeMap(
            latitude,
            longitude
        );

        return;
    }


    marker.setLatLng(
        newPosition
    );


    map.setView(
        newPosition,
        map.getZoom()
    );
}


// ============================================================
// JOURNEY LIVE TRACKING
// ============================================================

function startJourneyTracking() {

    const journeyRef = db
        .collection("users")
        .doc(userId)
        .collection("journeys")
        .doc(journeyId);


    journeyRef.onSnapshot(

        (doc) => {

            if (!doc.exists) {

                statusElement.textContent =
                    "Journey not found.";

                console.error(
                    "Journey document does not exist."
                );

                return;
            }


            const data = doc.data();


            console.log(
                "Firestore journey update:",
                data
            );


            const latitude =
                data.currentLatitude;

            const longitude =
                data.currentLongitude;


            if (
                latitude === undefined ||
                longitude === undefined
            ) {

                statusElement.textContent =
                    "Waiting for user's location...";

                return;
            }


            statusElement.textContent =
                "LIVE";


            latitudeElement.textContent =
                latitude.toFixed(6);

            longitudeElement.textContent =
                longitude.toFixed(6);


            lastUpdatedElement.textContent =
                new Date().toLocaleTimeString();


            updateMap(
                latitude,
                longitude
            );

        },


        (error) => {

            console.error(
                "Firestore Journey tracking error:",
                error
            );


            statusElement.textContent =
                "Unable to access live location.";
        }
    );
}


// ============================================================
// SOS LIVE TRACKING
// ============================================================

function startSOSTracking() {

    const sosRef = db
        .collection("sosEvents")
        .doc(sosId);


    sosRef.onSnapshot(

        (doc) => {

            if (!doc.exists) {

                statusElement.textContent =
                    "SOS event not found.";

                console.error(
                    "SOS document does not exist."
                );

                return;
            }


            const data = doc.data();


            console.log(
                "Firestore SOS update:",
                data
            );


            // --------------------------------------------------
            // USE LIVE SOS LOCATION
            // --------------------------------------------------

            const latitude =
                data.currentLatitude;

            const longitude =
                data.currentLongitude;


            // --------------------------------------------------
            // CHECK LOCATION
            // --------------------------------------------------

            if (
                latitude === undefined ||
                longitude === undefined
            ) {

                statusElement.textContent =
                    "Waiting for emergency location...";

                return;
            }


            // --------------------------------------------------
            // UPDATE STATUS
            // --------------------------------------------------

            statusElement.textContent =
                "🚨 SOS LIVE";


            latitudeElement.textContent =
                latitude.toFixed(6);

            longitudeElement.textContent =
                longitude.toFixed(6);


            // --------------------------------------------------
            // UPDATE LAST UPDATED
            // --------------------------------------------------

            if (data.lastUpdated) {

                lastUpdatedElement.textContent =
                    data.lastUpdated
                        .toDate()
                        .toLocaleTimeString();

            } else {

                lastUpdatedElement.textContent =
                    new Date()
                        .toLocaleTimeString();
            }


            // --------------------------------------------------
            // UPDATE MAP
            // --------------------------------------------------

            updateMap(
                latitude,
                longitude
            );

        },


        (error) => {

            console.error(
                "Firestore SOS tracking error:",
                error
            );


            statusElement.textContent =
                "Unable to access SOS live location.";
        }
    );
}