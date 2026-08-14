from app.services.notification_service import NotificationService


class SOSService:

    def __init__(self):
        self.notification_service = NotificationService()

    async def activate_sos(
        self,
        latitude: float,
        longitude: float,
        guardians: list,
    ):

        if not guardians:
            raise Exception("No guardians found.")

        # Find primary guardian
        primary_guardian = next(
            (
                guardian
                for guardian in guardians
                if guardian.get("is_primary") is True
            ),
            None,
        )

        if primary_guardian is None:
            raise Exception("Primary guardian not found.")

        tracking_url = (
            f"https://your-tracking-page-url"
            f"?lat={latitude}&lng={longitude}"
        )

        message = (
            "🚨 ASTRA EMERGENCY SOS 🚨\n\n"
            "Your guardian has activated an SOS.\n\n"
            f"📍 Live Location:\n{tracking_url}\n\n"
            f"Latitude: {latitude}\n"
            f"Longitude: {longitude}\n\n"
            "Please respond immediately."
        )

        # Send WhatsApp to every guardian
        for guardian in guardians:

            phone = guardian.get("phone")

            if phone:
                self.notification_service.send_whatsapp(
                    phone,
                    message,
                )

        # Call primary guardian
        primary_phone = primary_guardian.get("phone")

        # Calling will be added after Twilio Voice is configured.
        print("Primary Guardian:", primary_guardian.get("name"))
        print("Primary Guardian Phone:", primary_guardian.get("phone"))

        return {
            "success": True,
            "primaryGuardian": primary_guardian.get("name"),
            "latitude": latitude,
            "longitude": longitude,
            "trackingUrl": tracking_url,
            "guardians": guardians,
        }