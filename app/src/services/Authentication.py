from src.database.db_mysql import get_connection
from src.models.UserModel import Usuario
from src.models.ErrorModel import Error

class AuthenticationService():

    @classmethod
    def get_authentication(cls,user):
        try:
            connection = get_connection()
            if(type(connection) == Error):
                return connection
            cursor = connection.cursor()
            sentence_sql = f"CALL verificar_identidad('{user['correo']}','{user['password']}','{user['codigo_sucursal']}')"
            usuario = None
            cursor.execute(sentence_sql)
            res = cursor.fetchone()
            if res != None:
                usuario = Usuario(res[0],res[1],res[2],res[3],res[4],res[5],res[6],res[7])
            connection.close()
            return usuario
        except Exception as ex:
            error = Error(str(ex),False)
            return error

    @classmethod
    def restore_password(cls,user):
        try:
            connection = get_connection()
            if(type(connection) == Error):
                return connection
            cursor = connection.cursor()
            sentence_sql = f"CALL restore_password('{user['correo']}','{user['password']}')"
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