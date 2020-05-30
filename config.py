import os
basedir = os.path.abspath(os.path.dirname(__file__)) ## para que serve???

class Config(object):
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-never-guess'
    # SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://postgres:postgres@192.168.56.10/laze'
    SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://laze:laze@localhost/laze'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
