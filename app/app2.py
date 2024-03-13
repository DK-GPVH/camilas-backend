from src import init_app
from config import config

preferences = config['development']
app = init_app(preferences)

if __name__ == '__main__':
    app.run()