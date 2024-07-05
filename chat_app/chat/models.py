from django.db import models
from django.contrib.auth import get_user_model
# from encrypted_model_fields.fields import EncryptedCharField
from cryptography.fernet import Fernet
import base64

#---------------------------------------------------
key = Fernet.generate_key()
cipher_suite = Fernet(key)
#---------------------------------------------------

User = get_user_model()

#----------------------ENCTYPTION CLASS--------------------------------------
class EncryptedField(models.TextField):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def get_prep_value(self, value):
        if value is not None:
            # Encrypt the value before saving it to the database
            value = value.encode()
            encrypted_value = cipher_suite.encrypt(value)
            return base64.urlsafe_b64encode(encrypted_value).decode()
        return value

    def from_db_value(self, value, expression, connection):
        if value is not None:
            # Decrypt the value when retrieving it from the database
            encrypted_value = base64.urlsafe_b64decode(value.encode())
            decrypted_value = cipher_suite.decrypt(encrypted_value)
            return decrypted_value.decode()
        return value

    def to_python(self, value):
        if value is not None and isinstance(value, str):
            # Decrypt the value when accessing it in Python
            encrypted_value = base64.urlsafe_b64decode(value.encode())
            decrypted_value = cipher_suite.decrypt(encrypted_value)
            return decrypted_value.decode()
        return value
#-------------------------------------------------------------------------------

class ChatParticipantsChannel(models.Model):
    channel = models.CharField(max_length=256)
    user = models.ForeignKey(User, on_delete=models.PROTECT)

    def __str__(self):
        return str(self.channel)


class ChatRoom(models.Model):
    name = models.CharField(max_length=256)

    # Store the last message and the user who sent it
    last_message = models.CharField(max_length=2048, null=True)
    last_sent_user = models.ForeignKey(
        User, on_delete=models.PROTECT, null=True)

    def __str__(self):
        return self.name


class Messages(models.Model):
    room = models.ForeignKey(ChatRoom, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    content = models.CharField(max_length=2048)
    #content = EncryptedField(max_length=2048)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Message by {self.user.username}: {self.content[:50]}... to  '


class ChatRoomParticipants(models.Model):
    user = models.ForeignKey(User, on_delete=models.PROTECT)
    room = models.ForeignKey(ChatRoom, on_delete=models.PROTECT)

    def __str__(self):
        return f'{self.user.username} in {self.room.name}'
