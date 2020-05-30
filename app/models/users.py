from app import db, login
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import UserMixin
from flask import flash

class User(UserMixin, db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True, nullable=False)
    username = db.Column(db.String(64), index=True, unique=True)
    name = db.Column(db.String(32), nullable=False)
    lastname = db.Column(db.String(32), nullable=False)
    cpf = db.Column(db.String(11), unique=True, nullable=False)
    email = db.Column(db.String(120), nullable=False, unique=True)
    phone = db.Column(db.String(11))
    password = db.Column(db.String(128), nullable=False)

    def __repr__(self):
        return "<User(name='%s', lastname='%s', username='%s', cpf='%s', email='%s', phone='%s')" % (self.name, self.lastname, self.username, self.cpf, self.email, self.phone)


    def set_password(self, password):
        self.password = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password, password)

    @login.user_loader
    def load_user(id):
        return User.query.get(int(id))

    @classmethod
    def sign_in(cls, username, password):
        userToReturn = None
        try:
            userToReturn = cls.query.filter(cls.username == username).one()
        except:
            print ("Error trying find user")

        if userToReturn is None:
            print ("No user in DB")
            return None
        else:
            result = userToReturn.check_password(password)
            if result == True:
                return userToReturn
            else:
                print ("Incorrect password!")
                return False

    @classmethod
    def add_user(cls, name, lastname, cpf, phone, username, password, email):
        user = User(username=username, email=email, name=name, lastname=lastname, cpf=cpf, phone=phone)
        user.set_password(password)

        try:
            db.session.add(user)
            db.session.commit()
        except:
            return False
        return True

    @classmethod
    def test_username(cls, username):
        if cls.query.filter_by(username=username).first():
            return 1
        else:
            return 0

    @classmethod
    def test_actual_pw(cls, username, password):
            userToReturn = cls.query.filter(cls.username == username).one()
            result = userToReturn.check_password(password)
            if result == True:
                return 0
            else:
                return 1

    @classmethod
    def get_user(cls, id):
        userToReturn = None
        try:
            userToReturn = cls.query.filter_by(id=id).first()
        except:
            print ("Error trying find user")
            return False

        return userToReturn

    
    @classmethod
    def update_user(cls, id, name, lastname, email, cpf, phone):

        try:
            update_usr = cls.query.filter_by(id=id).first()
            update_usr.name = name
            update_usr.lastname = lastname
            update_usr.email = email
            update_usr.cpf = cpf
            update_usr.phone = phone

            db.session.commit()
            
        except:
            return False
        return True

    @classmethod
    def update_pw_user(cls, id, password):

        try:
            update_usr = cls.query.filter_by(id=id).first()
            update_usr.set_password(password)

            db.session.commit()
            
        except:
            return False
        return True
        



#  INSERT INTO users (id, username, name, lastname, cpf, phone, password, email)
# VALUES (1, 'natt', 'Natalia', 'Knob', '01330694007', '54999596950',
#         'pbkdf2:sha256:50000$zBq5wX3a$99b902e33a14eb5df228f1abd1d8211b6727bcf5312dd8da02d4256c8f0248aa', 'nattgomesadv@gmail.com');

#
# >>> from werkzeug.security import generate_password_hash
# >>> hash = generate_password_hash('natt')
# >>> hash
# 'pbkdf2:sha256:50000$zBq5wX3a$99b902e33a14eb5df228f1abd1d8211b6727bcf5312dd8da02d4256c8f0248aa'
