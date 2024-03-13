from flask import Blueprint,request,jsonify

from src.services.Authentication import AuthenticationService
from src.models.UserModel import Usuario
from src.models.ErrorModel import Error
from src.utils.Security import Security

auth = Blueprint('authentication',__name__)

@auth.route('/', methods = ['POST'])
def login():
    credentials = {
        'correo' : request.json['correo'],
        'password' : request.json['password'],
        'codigo_sucursal' : request.json['codigo_sucursal']
    }
    logeo = AuthenticationService.get_authentication(credentials)
    
    if(type(logeo) == Error):
        return jsonify(logeo.to_json()),500
    print(type(logeo) == Usuario)
    if(type(logeo) == Usuario):
        encoded_token = Security.generate_token(logeo)
        return jsonify({
            'success': True,
            'token' : encoded_token
        })
    elif(logeo != None):
        return jsonify(logeo)
    else:
        response = Error('Unauthorized',False)
        return (response.to_json()),401

@auth.route('/restore-password',methods = ['POST'])
def restore_password():
    user = {
        'correo' : request.json['correo'],
        'password' : request.json['password']
    }

    update = AuthenticationService.restore_password(user)

    if(type(update) == Error):
        return jsonify(update.to_json()),500
    if(type(update) == Usuario):
        return jsonify(
            {
                'message' : 'Password actualizado correctamente',
                'user' : update.to_json()
            }),200
    elif(update != None):
        return jsonify(update)
    else:
        response = Error('Unauthorized',False)
        return (response.to_json()),401