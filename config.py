import os
basedir = os.path.abspath(os.path.dirname(__file__)) 

class Config(object):
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'laze-super-secret-password'
    SQLALCHEMY_DATABASE_URI = 'postgresql+psycopg2://laze:laze@localhost/laze'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
