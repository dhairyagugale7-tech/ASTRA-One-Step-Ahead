import os

from dotenv import load_dotenv
from twilio.rest import Client

load_dotenv()


class NotificationService:

    def __init__(self):
        self.account_sid = os.getenv("TWILIO_ACCOUNT_SID")
        self.auth_token = os.getenv("TWILIO_AUTH_TOKEN")

        self.whatsapp_number = os.getenv(
            "TWILIO_WHATSAPP_NUMBER"
        )

        self.call_number = os.getenv(
            "TWILIO_CALL_NUMBER"
        )

        self.client = Client(
            self.account_sid,
            self.auth_token,
        )

    def send_whatsapp(
        self,
        phone_number: str,
        message: str,
    ):

        return self.client.messages.create(
            from_=self.whatsapp_number,
            to=f"whatsapp:{phone_number}",
            body=message,
        )

    def call_primary_guardian(
        self,
        phone_number: str,
        tracking_url: str,
    ):

        print("CALL TO:", phone_number)
        print("CALL FROM:", self.call_number)

        twiml = """
        <Response>
            <Say>
                Emergency SOS activated.
                Please check your WhatsApp for the live location.
            </Say>
        </Response>
        """

        return self.client.calls.create(
            to=phone_number,
            from_=self.call_number,
            twiml=twiml,
        )