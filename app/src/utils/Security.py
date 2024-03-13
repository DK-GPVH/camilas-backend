import datetime
import pytz
import jwt
from decouple import config


class Security():

    secret_key = config('JWT_SECRET_KEY')
    tz = pytz.timezone('America/Lima')

    @classmethod
    def generate_token(cls,authenticated_user):
        payload = {
            'iat': datetime.datetime.now(tz = cls.tz),
            'exp': datetime.datetime.now(tz = cls.tz) + datetime.timedelta(minutes = 10),
            'usuario_id': authenticated_user.id,
            'usuario_nombre' : authenticated_user.nombre,
            'usuario_correo' : authenticated_user.correo,
            'usuario_cargo' : authenticated_user.cargo
        }

        return jwt.encode(payload,cls.secret_key,algorithm = 'HS256')

    @classmethod
    def verify_token(cls,headers):
        if 'Authorization' in headers.keys():
            authorization = headers['Authorization']
            encoded_token = authorization.split(" ")[1]

            try:
                payload = jwt.decode(encoded_token, cls.secret_key, algorithms = ['HS256'])
                return True
            except(jwt.ExpiredSignatureError,jwt.InvalidSignatureError):
                return False
        return False
    
    @classmethod
    def verify_token_admin(cls,headers):
        if 'Authorization' in headers:
            authorization = headers['Authorization']
            encoded_token = authorization.split(" ")[1]
            try:
                payload = jwt.decode(encoded_token, cls.secret_key,algorithms = ['HS256'])
                rol = payload['usuario_cargo']
                if rol == 'administrador':
                    return True
                return False
            except(jwt.ExpiredSignatureError, jwt.InvalidSignatureError):
                return False
        return False