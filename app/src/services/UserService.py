from src.database.db_mysql import get_connection
from src.models.UserModel import Usuario
from src.models.ErrorModel import Error

class UserService():

    @classmethod
    def get_users(cls):
        try:
            connection = get_connection()
            cursor = connection.cursor()
            sentence_sql = 'CALL listar_usuarios()'
            usuarios = []
            cursor.execute(sentence_sql)
            res = cursor.fetchall()
            for row in res :
                usuario = Usuario(
                    row[0],
                    row[1],
                    row[2],
                    row[3],
                    row[4],
                    row[5],
                    row[6],
                    row[7]
                    )
                usuarios.append(usuario.to_json())
            connection.close()
            return usuarios
        except Exception as ex:
            error = Error(str(ex),False)
            return error


    @classmethod
    def create_user(cls,user):
        try:
            connection = get_connection()
            cursor = connection.cursor()
            sentence_sql = f"CALL agregar_usuario('{user['nombre']}','{user['documento_identidad']}',{user['numero_documento']},'{user['direccion']}',{user['telefono']},'{user['cargo']}','{user['correo']}','{user['contrasenia']}')"
            usuario = None
            cursor.execute(sentence_sql)
            connection.commit()
            res = cursor.fetchone()
            if res != None :
                usuario = Usuario(res[0],res[1],res[2],res[3],res[4],res[5],res[6],res[7])
            connection.close()
            return usuario
        except Exception as ex:
            error = Error(str(ex),False)
            return error

    @classmethod
    def update_user(cls,user):
        try:
            connection = get_connection()
            cursor = connection.cursor()
            sentence_sql = f"CALL actualizar_usuario({user['id']},'{user['nombre']}','{user['documento_identidad']}',{user['numero_documento']},'{user['direccion']}',{user['telefono']},'{user['cargo']}','{user['correo']}','{user['contrasenia']}')"
            usuario = None
            cursor.execute(sentence_sql)
            connection.commit()
            res = cursor.fetchone()
            if res != None:
                usuario = Usuario(res[0],res[1],res[2],res[3],res[4],res[5],res[6],res[7])
            connection.close()
            return usuario
        except Exception as ex:
            error = Error(str(ex),False)
            return error
    
    @classmethod
    def delete_user(cls,operation):
        try:
            connection = get_connection()
            cursor = connection.cursor()
            sentence_sql = f"CALL eliminar_usuario({operation["id_solicitante"]},{operation["id_perjudicado"]})"
            usuario = None
            cursor.execute(sentence_sql)
            connection.commit()
            res = cursor.fetchone()
            if res != None:
                usuario = Usuario(res[0],res[1],res[2],res[3],res[4],res[5],res[6],res[7])
            connection.close()
            return usuario
        except Exception as ex:
            error = Error(str(ex),False)
            return error
