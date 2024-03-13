from flask import Flask, render_template , request , redirect , url_for ,jsonify , json
from flask_mysqldb import MySQL

app = Flask(__name__)
#configuracion db
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'camilas'

conexion = MySQL(app)

#decoradores antes de las peticiones y despues de peticiones
@app.before_request
def before_request():
    print('Antes de la peticion ...')

@app.after_request
def after_request(response):
    print('Despues de la peticion')
    return response

@app.route('/')
def index():
    #return "HOLA MUNDO"
    cursos = ['MAte','Comu','Historia']
    data={
        'titulo' : 'index',
        'bienvenida' : 'saludos',
        'cursos' : cursos,
        'numero_cursos' : len(cursos)
    }
    return render_template('index.html',nombre_variable=data)

#rutas con parametros
@app.route('/contacto/<nombre>')
def contacto(nombre):
    data = {
        'titulo' : 'Contacto',
        'nombre' : nombre
    }
    return render_template('contacto.html',data = data)


#rutas query string
def query_string():
    print(request)
    print(request.args)
    print(request.args.get('valor1'))
    return 'OK'

@app.route('/usuarios')
def listar_usuarios():
    data ={}
    try:
        cursor = conexion.connection.cursor()
        sql = 'SELECT * FROM usuario ORDER BY nombre ASC'
        cursor.execute(sql)
        usuarios = cursor.fetchall()
        data['mensaje'] = 'Exito' 
        data['usuarios'] = []
        for user in usuarios:
            data['usuarios'].append({
                'id' : user[0],
                'nombre' : user[1],
                'correo' : user[5]
            })
    except Exception as ex:
        data['mensaje'] ='Error ..'
        print(ex)
    users = jsonify(data)
    

    #return users
    return render_template('usuarios.html', data = data ) 

#manejar errores
def pagina_no_encontrada(error):   
    # return render_template('404.html'),404
    return redirect(url_for('index')) #redirecciona las paginas a una vista indicada


if __name__ == '__main__':
    app.add_url_rule('/query_string', view_func = query_string)
    app.register_error_handler(404,pagina_no_encontrada)
    app.run(debug=True)
