from flask import Blueprint,jsonify,request,render_template

main = Blueprint("index",__name__,template_folder="../../templates")

@main.route('/')
def index():
    cursos = ['MAte','Comu','Historia']
    data={
        'titulo' : 'index',
        'bienvenida' : 'saludos',
        'cursos' : cursos,
        'numero_cursos' : len(cursos)
    }
    return render_template('index.html',nombre_variable=data)

@main.errorhandler(404)
def pagina_no_encontrada():
    return render_template('404.html')