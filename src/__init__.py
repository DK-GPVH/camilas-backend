from flask import Flask,render_template
from .routes import IndexRoute,UsuariosRoute,AuthenticationRoute
from flask_cors import CORS


app = Flask(__name__)
CORS(app)

def pagina_no_encontrada(error):
    print({"ESTE ES EL ERROR" : error.code})   
    return render_template('404.html'),404

def init_app (config):
    app.config.from_object(config)

    app.register_blueprint(IndexRoute.main, url_prefix='/')
    app.register_blueprint(UsuariosRoute.usuarios_page, url_prefix = '/usuarios')
    app.register_blueprint(AuthenticationRoute.auth,url_prefix='/authentication')
    app.register_error_handler(404,pagina_no_encontrada)
    return app