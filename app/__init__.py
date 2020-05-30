from flask import Flask
from config import Config
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager


app = Flask(__name__)
app.config.from_object(Config)
db = SQLAlchemy(app)
# migrate = Migrate(app, db)
login = LoginManager(app)
login.login_view = '/'

from app import routes, models


# https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-i-hello-world


# usar Flask-WTF?? em forms?


# não serve p nada aqui? não está rodando na porta correta
# if __name__ == "__main__":
#     app.run(host='localhost', port=8082, debug=True)
