from flask import Flask, render_template as template, request, make_response, jsonify, session, redirect, url_for, escape, Response
from app import app
from app.models.users import User
from app.models.logs import Request
from app.models.result_codes import VW_result_codes
from app.models.content_types import VW_content_types
from flask_login import current_user, login_user, logout_user, login_required
import os, time, datetime, calendar
import json, cgi
from threading import Thread
import pdfkit



@app.route('/')
def indexPage():
    if current_user.is_authenticated:
        return redirect("/welcome")
    else:
        return template('login.jinja2')


@app.route('/login', methods=['POST'])
def login():
    if current_user.is_authenticated:
        return redirect("/welcome")
    username = request.form['username']
    password = request.form['password']
    print("user", username, "password", password)
    user_login = User.sign_in(username, password)

    if user_login:
        login_user(user_login)
        return redirect('/welcome')
    elif user_login == False:
        params = {"username":username,"password":"","login_error":u"Senha incorreta. Tente novamente."}
        return template('login.jinja2', **params)
    else:
        params = {"username":username,"password":"","login_error":u"Usuário não cadastrado em sistema."}
        return template('login.jinja2', **params)



@app.route('/updatePassword')
@login_required
def updatePassword():
    active_user = current_user.name
    params = {'active_user': active_user, "last_pw":"", "new_pw":"", "verify_pw":""} 
    return template('updatePassword.jinja2', **params)


@app.route('/validateActualPW', methods=['POST'])
def validateNewPW():
    username = current_user.username
    pw = request.form.get('password')
    return template ('void.jinja2', variable=User.test_actual_pw(username, pw))



@app.route('/updatingPassword', methods=['POST'])
@login_required
def updatingPassword():
    active_user = current_user.name
    password = request.form['senha_nova']
    user_id = current_user.id

    if not User.update_pw_user(user_id, password):
        params['db_error'] = (u"Erro em banco de dados. Contate o administrador do sistema!")
    else:
        print("Senha atualizada")
        return redirect("/updated_user")

    params = {'active_user': active_user, "last_pw":"", "new_pw":"", "verify_pw":""} 
    return template('updatePassword.jinja2', **params)




@app.route('/updateUser')
@login_required
def update_user():
    active_user = current_user.name
    user_id = current_user.id

    user_data = User.get_user(user_id)

    name = user_data.name
    lastname = user_data.lastname
    cpf = user_data.cpf
    email = user_data.email
    phone = user_data.phone
    usr_name = user_data.username

    params = {'active_user': active_user, 'usr_name': usr_name, "name": name, "lastname": lastname, "cpf": cpf, "phone": phone, "email": email}

    return template('updateUser.jinja2', **params)


@app.route('/updatingUser', methods=['POST'])
@login_required
def updating_user():
    active_user = current_user.name

    name = request.form['name']
    lastname = request.form['lastname']
    email = request.form['email']
    cpf = request.form['cpf']
    phone = request.form['phone']
    username = request.form['username']

    user_id = current_user.id

    params = {'active_user': active_user, 'name': (name), 'lastname': (lastname), 'email': (email), 'cpf': (cpf), 'phone': (phone), 'usr_name': (username)}

    if not User.update_user(user_id, name, lastname, email, cpf, phone):
        params['db_error'] = (u"Erro em banco de dados. Contate o administrador do sistema!")
    else:
        print("Usuário atualizado")
        return redirect("/updated_user")

    return template('updateUser.jinja2', **params)


@app.route('/updated_user')
def updated_user():
    active_user = current_user.name
    return template('updated_user.jinja2', active_user=active_user)


@app.route('/newUser')
@login_required
def present_signup():

    active_user = current_user.name
    params = {'active_user': active_user, 'username': "username", "name": "","lastname": "", "cpf": "", "phone": "", "password":"", "usr_name": "","email": "", "verify": ""}
    return template('newUser.jinja2', **params)



@app.route('/newUser', methods=['POST'])
@login_required
def process_signup():

    name = request.form['name']
    lastname = request.form['lastname']
    email = request.form['email']
    cpf = request.form['cpf']
    phone = request.form['phone']
    username = request.form['username']
    password = request.form['password']

    active_user = current_user.name
    params = {'active_user': active_user, 'name': (name), 'lastname': (lastname), 'email': (email), 'cpf': (cpf), 'phone': (phone), 'username': (username)}

    if not User.add_user(name, lastname, cpf, phone, username, password, email):
        params['db_error'] = (u"Erro em banco de dados. Contate o administrador do sistema!")
    else:
        print("Usuário adicionado")
        return redirect("/profiles")

    return template('newUser.jinja2', **params)



@app.route('/validateNewUser', methods=['POST'])
def validateNewUser():
    username = request.form.get('username')
    return template ('void.jinja2', variable=User.test_username(username))


@app.route('/profiles')
def profiles():
    active_user = current_user.name
    return template('profiles.jinja2', active_user=active_user)


@app.route('/logout')
def logout():
    logout_user()
    return redirect("/")



@app.route('/welcome', methods=['GET', 'POST'])
@login_required
def dashboard():
    active_user = current_user.name
    start_time = time.time()

    if 'monthVisit' in request.form.keys():
        monthYear = request.form['monthVisit']
    else:
        monthYear = None

    now = datetime.datetime.now()
    currentYear = now.year
    currentMonth = now.month

    if monthYear is not None:
        pieces = monthYear.split("-")
        month = int(pieces[1])
        year = int(pieces[0])
    else:
        month = currentMonth
        year = currentYear

    initial_year = datetime.datetime(year,1,1)
    final_year = datetime.datetime(year+1,1,1)

    initial_date = datetime.datetime(year,month,1)
    print(initial_date)
    if month < 12:
        final_date = datetime.datetime(year,month+1,1)
    else:
        final_date = datetime.datetime(year+1,1,1)


    domainDoughnutChart = Request.getTopDomainDoughnut(initial_date, final_date)
    print("pós graph1: " + str(time.time() - start_time))

    userDoughnutChart = Request.getTopUsersDoughnut(initial_date, final_date)
    print ("pós graph2: " + str(time.time() - start_time))

    monthChart = Request.getBytesRequestsByMonth(initial_year, final_year)
    print ("pós graph3: " + str(time.time() - start_time))

    dailyChart = Request.getBytesRequestsByDay(initial_date, final_date)
    print("pós graph4: " + str(time.time() - start_time))

    pieChart = VW_content_types.getTypesChart(year, month)
    print ("pós graph5: " + str(time.time() - start_time))

    resultRequestChart = VW_result_codes.getResultsChart(year, month)
    print ("pós graph6: " + str(time.time() - start_time))


    colors = ["rgba(39, 44, 51,1)","rgba(39, 44, 51,0.9)","rgba(39, 44, 51,0.8)","rgba(39, 44, 51,0.7)","rgba(39, 44, 51,0.6)","rgba(39, 44, 51,0.5)","rgba(39, 44, 51,0.4)","rgba(39, 44, 51,0.3)","rgba(39, 44, 51,0.2)","rgba(39, 44, 51,0.1)"]

    colors2 = ["rgba(238, 108, 77,1)","rgba(238, 108, 77,0.9)","rgba(238, 108, 77,0.8)","rgba(238, 108, 77,0.7)","rgba(238, 108, 77,0.6)","rgba(238, 108, 77,0.5)","rgba(238, 108, 77,0.4)","rgba(238, 108, 77,0.3)","rgba(238, 108, 77,0.2)","rgba(238, 108, 77,0.1)"]

    colors3 = ["#E5FFDE", "#634B66", "#BBCBCB", "#9590A8", "#FFB997", "#7C898B", "#D6DBB2", "#759FBC", "#FFBA49", "#EF5B5B"]

    params = {'active_user': active_user, 'domaindatadoughnut': domainDoughnutChart, 'userDoughnutChart': userDoughnutChart, 'datapie': pieChart, 'dailyChart':dailyChart, 'monthChart':monthChart, 'resultRequestChart':resultRequestChart, 'colors': colors, 'colors2': colors2,  'colors3': colors3, 'valuesToQuery':monthYear, 'month': month, 'year': year}

    return template ('welcome.jinja2', **params)



@app.route('/new_upload')
@login_required
def new_upload():
    active_user = current_user.name
    return template ('new_upload.jinja2', active_user=active_user)



@app.route('/parse', methods=['POST'])
@login_required
def do_upload():
    active_user = current_user.name
    upload = request.files['upload']
    _, ext = os.path.splitext(upload.filename)
    if ext not in ('.log', '.json'):
        retorno = u"Extensão de arquivo não permitida."
        alerta = 2
    else:
        os_service = { "Linux": "laze_linux",
                      "Darwin": "laze_mac",
                      "Windows": "laze_windows.exe"}[os.uname()[0]]
        
        #print(os.getcwd())
        upload.save("app/files/"+upload.filename)
        os.system("service/"+os_service+" app/files/"+upload.filename)
        
        retorno = "Inclusão ocorrendo em background"
        alerta = 3
        

    return template ('result.jinja2', active_user=active_user, retorno=retorno, alerta=alerta)



@app.route('/domains', methods=['GET', 'POST'])
@login_required
def ranking_domains():
    active_user = current_user.name

    if 'monthVisit' in request.form.keys():
        monthYear = request.form['monthVisit']
    else:
        monthYear = None
    result = monthyear(monthYear)
    initial_date = result['initial_date']
    final_date = result['final_date']

    values = Request.getTopDomains(initial_date, final_date)
    title = u"Ranking de domínios mais acessados no mês"
    fields = (u"Posição", u"Domínio", "KBytes", u"Duração (s)", u"Usuários", u"Acessos")

    return template ('domains.jinja2', active_user=active_user, values=values, title=title, fields=fields, valuesToQuery=monthYear)


@app.route('/domainsByDay', methods=['GET', 'POST'])
def ranking_domainsByDay():
    active_user = current_user.name

    if 'dayVisit' in request.form.keys():
        dayMonthYear = request.form['dayVisit']
    else:
        dayMonthYear = None
    result = daymonthyear(dayMonthYear)
    initial_date = result['initial_date']
    final_date = result['final_date']

    values = Request.getTopDomains(initial_date, final_date)
    title = u"Ranking de domínios mais acessados no dia"
    fields = (u"Posição", u"Domínio", "KBytes", u"Duração (s)", u"Usuários", u"Acessos")

    return template('domainsByDay.jinja2', active_user=active_user, values=values, title=title, fields=fields, valuesToQuery=dayMonthYear)



# https://stackoverflow.com/questions/33108685/advanced-how-to-use-href-in-jinja2
@app.route('/query_domain/<domain>')
def domain_user(domain):
    active_user = current_user.name

    domain = cgi.escape(domain)
    values = Request.getClientsByDomain(domain)
    title = u"Usuários que acessaram o domínio " + str(domain)
    fields = (u"Posição", u"Cliente", "KBytes", u"Duração (s)", u"Requisições")

    return template ('clientsByDomain.jinja2', active_user=active_user, values=values, title=title, fields=fields, domain=domain)


#https://stackoverflow.com/questions/33108685/advanced-how-to-use-href-in-jinja2
# usando format: http://jinja.pocoo.org/docs/2.10/templates/ cmd+f format
@app.route('/query_domain_user/<domain>&<client>')
def user_domains(domain,client):
    active_user = current_user.name

    domain = cgi.escape(domain)
    client = cgi.escape(client)
    values = Request.getClientAndUser(domain, client)

    title = u"Requisições ao domínio "  + str(domain)  + u" pelo cliente " + str(client) + "."
    fields = (u"Posição", u"Data", u"Hora", "Bytes", u"Duração", u"Método", u"Resultado", u"MIME")

    return template('queryDomainClient.jinja2', active_user=active_user,  values = values,  title = title,  fields = fields)



@app.route('/clients', methods=['GET', 'POST'])
def ranking_clients():
    active_user = current_user.name

    if 'monthVisit' in request.form.keys():
        monthYear = request.form['monthVisit']
    else:
        monthYear = None
    result = monthyear(monthYear)
    initial_date = result['initial_date']
    final_date = result['final_date']

    values = Request.getTopClients(initial_date, final_date)
    title = u"Ranking de clientes por quantidade de requisições - por mês"
    fields = (u"Posição", u"Cliente", u"Duração (s)", "KBytes", u"Total de requisições", u"Total de domínios acessados")

    return template('clients.jinja2', active_user=active_user, values=values, title=title, fields=fields, valuesToQuery=monthYear)


@app.route('/clientsByDay', methods=['GET', 'POST'])
def ranking_users_by_day():
    active_user = current_user.name

    if 'dayVisit' in request.form.keys():
        dayMonthYear = request.form['dayVisit']
    else:
        dayMonthYear = None
    result = daymonthyear(dayMonthYear)
    initial_date = result['initial_date']
    final_date = result['final_date']

    values = Request.getTopClients(initial_date, final_date)
    title = u"Ranking de clientes por quantidade de requisições  - por dia"
    fields = (u"Posição", u"Cliente", u"Duração (s)", "KBytes", u"Total de requisições", u"Total de domínios acessados")

    return template ('clientsByDay.jinja2', active_user=active_user, values=values, title=title, fields=fields, valuesToQuery=dayMonthYear)


@app.route('/query_clients/<client>')
def user_domain(client):
    active_user = current_user.name

    client = cgi.escape(client)
    values = Request.getDomainsByClient(client)
    title = u"Domínios acessados pelo usuário " + str(client)
    fields = (u"Posição", u"Domínio", "Bytes", u"Duração", u"Requisições")

    return template ('domainsByClient.jinja2', active_user=active_user, values=values, title=title, fields=fields, client=client)



@app.route('/comunications', methods=['GET', 'POST'])
def ranking_comunications():
    active_user = current_user.name

    if 'monthVisit' in request.form.keys():
        monthYear = request.form['monthVisit']
    else:
        monthYear = None
    result = monthyear(monthYear)
    initial_date = result['initial_date']
    final_date = result['final_date']

    values = Request.getComunicationsByMonth(initial_date, final_date)
    title = u"Ranking comunicações Cliente-Domínio"
    fields = (u"Posição", u"Domínio", u"Cliente", "KBytes", u"Duração (s)", u"Quantidade de Requisições")

    return template ('comunications.jinja2',  active_user=active_user,  values = values,  title = title,  fields = fields,  valuesToQuery = monthYear)



@app.route('/result_codes', methods=['GET', 'POST'])
def requests_results():
    active_user = current_user.name

    if 'dayVisit' in request.form.keys():
        dayMonthYear = request.form['dayVisit']
    else:
        dayMonthYear = None
    result = daymonthyear(dayMonthYear)
    initial_date = result['initial_date']
    final_date = result['final_date']

    if 'requestResult' in request.form.keys():
        resultCode = request.form['requestResult']
    else:
        resultCode = "TCP"

    print(initial_date)
    print(final_date)

    values = Request.getResultCodes(resultCode, initial_date, final_date)
    title = u"Requisições com resultado " + str(resultCode)
    fields = (u"Posição", u"Domínio", u"Usuário", u"Data", u"Hora", u"Resultado")

    return template('requestByDay.jinja2', active_user=active_user, values = values, title=title, fields=fields, valuesToQuery=dayMonthYear)


@app.route('/updateDashboard')
def update_dashboard():
    active_user = current_user.name
    return template('update.jinja2', active_user=active_user)


@app.route('/updateDashboard', methods=['POST'])
def updating_dashboard():

    active_user = current_user.name
    retorno_r = ""
    retorno_t = ""
    alerta_r = 0
    alerta_t = 0
    results = VW_result_codes.refresh_mat_view()
    types = VW_content_types.refresh_mat_view()

    if results == 1:
        alerta_r = 1
        retorno_r = u"Resultados de requisições atualizados."
    else:
        retorno_r = u"Erro na atualização dos resultados de requisições."

    if types == 1:
        alerta_t = 1
        retorno_t = u"Tipos de conteúdo de requisições atualizados."
    else:
        retorno_t = u"Erro na atualização de conteúdo de tipos de requisições."


    return template('updated.jinja2', active_user=active_user, retorno_r=retorno_r, retorno_t=retorno_t, alerta_r=alerta_r, alerta_t=alerta_t)




@app.route('/createPdf')
def getPDFOptions():
    active_user = current_user.name
    return template('generatePDF2.jinja2', username = active_user)



@app.route('/pdfReport')
def pdf():
    option = request.args.get('option')
    initial_date = datetime.datetime.strptime(request.args.get('initial_date'), "%Y-%m-%d")
    final_date = datetime.datetime.strptime(request.args.get('final_date'), "%Y-%m-%d")
    final_date = final_date + datetime.timedelta(days=1)
    initialDate = initial_date.strftime("%d/%m/%Y")
    finalDate = final_date.strftime("%d/%m/%Y")

    if option == "user":
        user = request.args.get('user')
        title = u"Lista de domínios acessados pelo cliente " + user
        title2 = u"Período: " + initialDate + " - " + finalDate
        fields = (u"URL", u"Data", u"Hora", u"Bytes", u"Duração", u"Resultado", u"MIME")
        values = Request.getDomainsByClientPDF(user, initial_date, final_date)
        tmplt = template("PDF.jinja2", values=values, title=title, title2=title2, fields=fields)

    elif option == "domain":
        domain = request.args.get('domain')
        title = u"Lista de usuários que acessaram o domínio " + domain
        title2 = u"Período: " + initialDate + " - " + finalDate
        fields = (u"Cliente", u"Data", u"Hora", u"Bytes", u"Duração", u"URL", u"Resultado", u"MIME")
        values = Request.getClientsByDomainPDF(domain, initial_date, final_date)
        tmplt = template("PDF.jinja2", values=values, title=title, title2=title2, fields=fields)

    elif option == "comunication":
        user = request.args.get('user')
        domain = request.args.get('domain')
        title = u"Comunicação entre o cliente " + user +  u" e o domínio " + domain
        title2 = u"Período: " + initialDate + " - " + finalDate
        fields = (u"URL", u"Data", u"Hora", u"Bytes", u"Duração", u"Método", u"Resultado", u"MIME")
        values = Request.getComunicationDomainClientPDF(domain, user, initial_date, final_date)
        tmplt = template("PDF.jinja2", values=values, title=title, title2=title2, fields=fields)

    else:
        title = u"Requisições negadas"
        title2 = u"Período: " + initialDate + " - " + finalDate
        fields = (u"Domínio", u"Cliente", u"Data", u"Hora", u"Resultado")
        values = Request.getDeniedPDF(initial_date, final_date)
        print(values)
        tmplt = template("PDF.jinja2", values=values, title=title, title2=title2, fields=fields)


    pdf = pdfkit.from_string(tmplt, False)
    
    response = Response(response=pdf, status=200, mimetype="application/pdf")

    # write to PDF
    return response









############################
##### OTHERS FUNCTIONS #####

def monthyear(monthYear):
    now = datetime.datetime.now()
    currentYear = now.year
    currentMonth = now.month

    if monthYear is not None:
        pieces = monthYear.split("-")
        month = int(pieces[1])
        year = int(pieces[0])
    else:
        month = currentMonth
        year = currentYear

    # month = 4

    initial_date = datetime.datetime(year,month,1)
    if month < 12:
        final_date = datetime.datetime(year,month+1,1)
    else:
        final_date = datetime.datetime(year+1,1,1)

    return {"initial_date":initial_date, "final_date":final_date}


def daymonthyear(dayMonthYear):
    now = datetime.datetime.now()
    currentYear = now.year
    currentMonth = now.month
    currentDay = now.day

    if dayMonthYear is not None:
        pieces = dayMonthYear.split("-")
        day = int(pieces[2])
        month = int(pieces[1])
        year = int(pieces[0])
    else:
        day = currentDay
        month = currentMonth
        year = currentYear

    numberOfDays = calendar.monthrange(now.year, month)[1]

    initial_date = datetime.datetime(year,month,day)
    if month < 12:
        if day < numberOfDays:
            final_date = datetime.datetime(year,month,day+1)
        else:
            final_date = datetime.datetime(year,month+1,1)
    else:
        if day < numberOfDays:
            final_date = datetime.datetime(year,month,day+1)
        else:
            final_date = datetime.datetime(year+1,1,1)

    return {"initial_date":initial_date, "final_date":final_date}
