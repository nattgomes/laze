# from flask_wtf import FlaskForm
# from wtforms import StringField, PasswordField, BooleanField, SubmitField
# from wtforms.validators import DataRequired, InputRequired, Email
# from app.models.users import User
#
#
# class NewUserForm(FlaskForm):
#     name = StringField('Name', validators=[DataRequired()])
#     lastname = StringField('Lastname', validators=[DataRequired()])
#     username = StringField('Username', validators=[DataRequired()])
#     email = StringField('Email', validators=[DataRequired(), Email()])
#     cpf = StringField('Cpf', validators=[DataRequired()])
#     phone = StringField('Phone', validators=[DataRequired()])
#     password = PasswordField('Password', validators=[DataRequired()])
#     password2 = PasswordField(
#         'Repeat Password', validators=[DataRequired(), EqualTo('password')])
#     submit = SubmitField('Sign Up')
#
#     def validate_username(self, username):
#         user = User.query.filter_by(username=username.data).first()
#         if user is not None:
#             raise ValidationError('Please use a different username.')
#
#     def validate_email(self, email):
#         user = User.query.filter_by(email=email.data).first()
#         if user is not None:
#             raise ValidationError('Please use a different email address.')

# https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-v-user-logins
