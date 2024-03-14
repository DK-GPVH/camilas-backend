from decouple import config
import pymysql
from src.models.ErrorModel import Error

def get_connection():
    try:
        return pymysql.connect(
            host = config('APP_MYSQL_HOST'),
            user = config('APP_MYSQL_USER'),
            password = config('APP_MYSQL_PASSWORD'),
            db = config('APP_MYSQL_DB'),
            port = int(config('APP_MYSQL_PORT'))
        )
    except Exception as ex:
        print(ex)
        error = Error(str(ex),False)
        return error

