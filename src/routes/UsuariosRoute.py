from flask import Blueprint,render_template,jsonify,request
from src.services.UserService import UserService
from src.utils.Security import Security
from src.models.ErrorModel import Error

usuarios_page = Blueprint('usuarios',__name__,template_folder='../../templates')

@usuarios_page.route('/')
def listar_usuarios():
    has_access = Security.verify_token_admin(request.headers)
    
    if has_access:
        try:
            usuarios = UserService.get_users()
            
            if(type(usuarios) == Error):
                return jsonify(usuarios.to_json()),500
            if(len(usuarios) > 0):
                return jsonify({
                    'usuarios' : usuarios,
                    'message' : 'Lista de usuarios',
                    'success' : True
                }),200
            else:
                return jsonify({
                    'message' : 'No se obtuvo ningun usuario',
                    'success' : True
                }),204
        except Exception as ex:
            return jsonify({
                'message' : str(ex),
                'success' : False
            }),500
    else:
        error = Error('Unauthorized',False)
        return jsonify(error.to_json()),401

@usuarios_page.route('/create', methods =['POST'])
def crear_usuario():
    has_access = Security.verify_token_admin(request.headers)

    user = {
        'nombre' : request.json['nombre'],
        'documento_identidad' : request.json['documento_identidad'],
        'numero_documento' : request.json['numero_documento'],
        'direccion' : request.json['direccion'],
        'telefono' : request.json['telefono'],
        'cargo' : request.json['cargo'],
        'correo' : request.json['correo'],
        'contrasenia': request.json['contrasenia']
    }

    if has_access:
        try:
            usuario = UserService.create_user(user)

            if(type(usuario) == Error):
                return jsonify(usuario.to_json()),500
            if(usuario != None):
                return jsonify({
                    'usuario' : usuario.to_json(),
                    'message' : 'Usuario creado correctamente',
                    'success' : True
                }),201
            else:
                return jsonify({
                    'message': 'No se puede recuperar el nuevo usuario, verifique si en la lista se agrego',
                    'success' : True
                }),204
        except Exception as ex:
            return jsonify({
                'message' : str(ex),
                'success' : False
            }),500
    else:
        error = Error('Unauthorized',False)
        return jsonify(error.to_json()),401

@usuarios_page.route('/update',methods = ['PUT'])
def actualizar_usuario():
    has_access = Security.verify_token(request.headers)

    user = {
        'id' : request.json['id'],
        'nombre' : request.json['nombre'],
        'documento_identidad' : request.json['documento_identidad'],
        'numero_documento' : request.json['numero_documento'],
        'direccion' : request.json['direccion'],
        'telefono' : request.json['telefono'],
        'cargo' : request.json['cargo'],
        'correo' : request.json['correo'],
        'contrasenia': request.json['contrasenia']
    }

    if has_access:
        try:
            usuario = UserService.update_user(user)

            if(type(usuario) == Error):
                return jsonify(usuario.to_json()),500
            if(usuario != None):
                return jsonify({
                    'usuario' : usuario.to_json(),
                    'message' : 'Usuario actualizado correctamente',
                    'success' : True
                }),200
            else:
                return jsonify({
                    'message': 'No se puede recuperar la actualizacion, verifique si los datos se actualizaron',
                    'success' : True
                }),204
        except Exception as ex:
            return jsonify({
                'message' : str(ex),
                'success' : False
            }),500
    else:
        error = Error('Unauthorized',False)
        return jsonify(error.to_json()),401

@usuarios_page.route('/delete', methods = ['DELETE'])
def eliminar_usuario():
    has_access = Security.verify_token_admin(request.headers)

    operation = {
        "id_solicitante" : request.json["id_solicitante"],
        "id_perjudicado" : request.json["id_perjudicado"]
    }

    if has_access:
        try:
            usuario = UserService.delete_user(operation)

            if(type(usuario) == Error):
                return jsonify(usuario.to_json()),500
            if(usuario != None):
                return jsonify({
                    'usuario_solicitante' : usuario.to_json(),
                    'message' : 'Usuario eliminado correctamente',
                    'success' : True
                }),200
            else:
                return jsonify({
                    'message': 'No se puede recuperar la informacion, verifique si el usuario se elimino',
                    'success' : True
                }),204
        except Exception as ex:
            return jsonify({
                'message' : str(ex),
                'success' : False
            }),500
    else:
        error = Error('Unauthorized',False)
        return jsonify(error.to_json()),401