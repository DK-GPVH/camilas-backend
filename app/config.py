from decouple import config

class DevelopmentConfig():
    DEBUG = True


config = {
    'development' : DevelopmentConfig
}