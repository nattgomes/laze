from app import db
import time, datetime
import string
from sqlalchemy.dialects import postgresql
from sqlalchemy import func, exists, desc
from sqlalchemy.orm import aliased
from datatables import DataTables, ColumnDT

class Client(db.Model):
    __tablename__ = 'dim_client'
    client_dim_id = db.Column(db.Integer, db.Sequence('dim_client_id_seq'), primary_key=True, nullable=False)
    client_address = db.Column(db.String(15), nullable=False)
    facts = db.relationship('Request', backref= 'fact_client',
                        primaryjoin='Client.client_dim_id == Request.client_id')

    def __repr__(self):
        return 'Client_dim: (id=%s, address=%s)' % (self.client_dim_id, self.client_address)


class Method(db.Model):
    __tablename__ = 'dim_method'
    method_dim_id = db.Column(db.Integer, db.Sequence('dim_method_id_seq'), primary_key=True, nullable=False)
    type = db.Column(db.String(9), nullable=False)
    facts = db.relationship('Request', backref= 'fact_method',
                        primaryjoin='Method.method_dim_id == Request.method_id')

    def __repr__(self):
        return 'Method_dim: (id=%s, type=%s)' % (self.method_dim_id, self.type)


class ResultCodes(db.Model):
    __tablename__ = 'dim_result_codes'
    result_codes_dim_id  = db.Column(db.Integer,  db.Sequence('dim_result_codes_id_seq'), primary_key=True, nullable=False)
    type = db.Column(db.Text, nullable=False)
    facts = db.relationship('Request', backref= 'fact_result',
                        primaryjoin='ResultCodes.result_codes_dim_id == Request.result_codes_id')

    def __repr__(self):
        return 'ResultCodes_dim: (id=%s, type=%s)' % (self.result_codes_dim_id, self.type)


class Url(db.Model):
    __tablename__ = 'dim_url'
    url_dim_id = db.Column(db.Integer, db.Sequence('dim_url_id_seq'), primary_key=True, nullable=False)
    url_netloc = db.Column(db.String(128), nullable=False)
    facts = db.relationship('Request', backref= 'fact_url',
                        primaryjoin='Url.url_dim_id == Request.url_id')

    def __repr__(self):
        return 'Url_dim: (id=%s, netloc=%s)' % (self.url_dim_id, self.url_netloc)


class HierarchyCodes(db.Model):
    __tablename__ = 'dim_hierarchy_codes'
    hierarchy_codes_dim_id = db.Column(db.Integer, db.Sequence('dim_hierarchy_codes_id_seq'), primary_key=True, nullable=False)
    type = db.Column(db.Text)
    facts = db.relationship('Request', backref= 'fact_hierarchy',
                        primaryjoin='HierarchyCodes.hierarchy_codes_dim_id == Request.hierarchy_codes_id')

    def __repr__(self):
        return 'HierarchyCodes_dim: (id=%s, type=%s)' % (self.hierarchy_codes_dim_id, self.type)


class AuthUser(db.Model):
    __tablename__ = 'dim_user'
    user_dim_id = db.Column(db.Integer, db.Sequence('dim_user_id_seq'), primary_key=True, nullable=False)
    type = db.Column(db.String(40))
    facts = db.relationship('Request', backref= 'fact_user',
                        primaryjoin='AuthUser.user_dim_id == Request.user_id')

    def __repr__(self):
        return 'User_dim: (id=%s, type=%s)' % (self.user_dim_id, self.type)


class ContentType(db.Model):
    __tablename__ = 'dim_content_type'
    content_type_dim_id = db.Column(db.Integer, db.Sequence('dim_content_type_id_seq'), primary_key=True, nullable=False)
    type = db.Column(db.Text)
    facts = db.relationship('Request', backref= 'fact_content',
                        primaryjoin='ContentType.content_type_dim_id == Request.content_type_id')

    def __repr__(self):
        return 'ContentType_dim: (id=%s, type=%s)' % (self.content_type_dim_id, self.type)


class Time(db.Model):
    __tablename__ = 'dim_time'
    time_dim_id = db.Column(db.Integer, primary_key=True, nullable=False)
    time_type = db.Column(postgresql.TIME)
    time_value = db.Column(db.String(5), nullable=False)
    hours_24 = db.Column(db.String(2), nullable=False)
    hours_12 = db.Column(db.String(2), nullable=False)
    hour_minutes = db.Column(db.String(2), nullable=False)
    day_minutes = db.Column(db.Integer, nullable=False)
    day_time_name = db.Column(db.String(20), nullable=False)
    day_night = db.Column(db.String(20), nullable=False)
    facts = db.relationship('Request', backref= 'fact_time',
                        primaryjoin='Time.time_dim_id == Request.time_id')

    def __repr__(self):
        return 'Time_dim: (id=%s, time=%s)' % (self.time_dim_id, self.time_value)


class Date(db.Model):
    __tablename__ = 'dim_date'
    date_dim_id = db.Column(db.BigInteger(), primary_key=True, nullable=False)
    date_actual = db.Column(postgresql.DATE)
    day_suffix = db.Column(db.String(4), nullable=False)
    day_name = db.Column(db.String(9), nullable=False)
    day_of_week = db.Column(db.Integer, nullable=False)
    day_of_month = db.Column(db.Integer, nullable=False)
    day_of_quarter = db.Column(db.Integer, nullable=False)
    day_of_year = db.Column(db.Integer, nullable=False)
    week_of_month = db.Column(db.Integer, nullable=False)
    week_of_year = db.Column(db.Integer, nullable=False)
    week_of_year_iso = db.Column(db.String(10), nullable=False)
    month_actual = db.Column(db.Integer, nullable=False)
    month_name = db.Column(db.String(9), nullable=False)
    month_name_abbreviated = db.Column(db.String(3), nullable=False)
    quarter_actual = db.Column(db.Integer, nullable=False)
    quarter_name = db.Column(db.String(9), nullable=False)
    year_actual = db.Column(db.Integer, nullable=False)
    first_day_of_week = db.Column(db.DateTime(timezone=False), nullable=False)
    last_day_of_week = db.Column(db.DateTime(timezone=False), nullable=False)
    first_day_of_month = db.Column(db.DateTime(timezone=False), nullable=False)
    last_day_of_month = db.Column(db.DateTime(timezone=False), nullable=False)
    first_day_of_quarter = db.Column(db.DateTime(timezone=False), nullable=False)
    last_day_of_quarter = db.Column(db.DateTime(timezone=False), nullable=False)
    first_day_of_year = db.Column(db.DateTime(timezone=False), nullable=False)
    last_day_of_year = db.Column(db.DateTime(timezone=False), nullable=False)
    mmyyyy = db.Column(db.String(6), nullable=False)
    mmddyyyy = db.Column(db.String(10), nullable=False)
    weekend_indr = db.Column(db.Boolean, nullable=False)
    facts = db.relationship('Request', backref= 'fact_date',
                        primaryjoin='Date.date_dim_id == Request.date_id')

    def __repr__(self):
        return 'Date_dim: (id=%s, date=%s)' % (self.date_dim_id, self.mmddyyyy)


class Request(db.Model):
    __tablename__ = 'fact_request'
    fact_id = db.Column(db.Integer, primary_key=True, nullable=False)
    date_id = db.Column(db.Integer, db.ForeignKey('dim_date.date_dim_id'))
    time_id = db.Column(db.Integer, db.ForeignKey('dim_time.time_dim_id'))
    content_type_id =  db.Column(db.Integer, db.ForeignKey('dim_content_type.content_type_dim_id'))
    user_id =  db.Column(db.Integer, db.ForeignKey('dim_user.user_dim_id'))
    hierarchy_codes_id =  db.Column(db.Integer, db.ForeignKey('dim_hierarchy_codes.hierarchy_codes_dim_id'))
    url_id =  db.Column(db.Integer, db.ForeignKey('dim_url.url_dim_id'))
    result_codes_id =  db.Column(db.Integer, db.ForeignKey('dim_result_codes.result_codes_dim_id'))
    method_id =  db.Column(db.Integer, db.ForeignKey('dim_method.method_dim_id'))
    client_id =  db.Column(db.Integer, db.ForeignKey('dim_client.client_dim_id'))
    duration = db.Column(db.Integer, nullable=False)
    bytes = db.Column(db.Integer, nullable=False)
    url_scheme = db.Column(db.String(10), nullable=False)
    url_path = db.Column(db.Text, nullable=False)
    url_params = db.Column(db.Text, nullable=False)


    def __repr__(self):
        return 'FactRequest_dim: (id=%s, date=%s, time=%s, client=%s,  address=%s)' % (self.request_fact_id, self.date_id, self.time_id, self.client_id, self.url_id)


################################
#######  welcome charts  #######

    @classmethod
    def getTopDomainDoughnut(cls, initial_date, final_date):
        try:
            values = db.session.query(Url.url_netloc, func.count(Request.url_id)).join(Request, Request.url_id == Url.url_dim_id).filter(db.session.query(Date).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d")), Date.date_dim_id == Request.date_id).exists()).group_by(Url.url_netloc, Request.url_id).order_by(func.count(Request.url_id).desc()).limit(10)

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values


    @classmethod
    def getTopUsersDoughnut(cls, initial_date, final_date):
        try:
            values = db.session.query(Client.client_address, func.sum(Request.bytes)/(1024*1024)).join(Request, Request.client_id == Client.client_dim_id).filter(db.session.query(Date).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d")), Date.date_dim_id == Request.date_id).exists()).group_by(Client.client_address, Request.client_id).order_by(func.sum(Request.bytes).desc()).limit(10)

        except Exception as e:
            print('Error!')
            print(e)
            return None
        return values


    @classmethod
    def getBytesRequestsByMonth(cls, initial_date, final_date):
        try:
            values = db.session.query(Date.month_actual, func.sum(Request.bytes)/(1024*1024), func.count(Request.url_id)).filter(Request.date_id == Date.date_dim_id).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d"))).group_by(Date.month_actual).order_by(Date.month_actual)

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values


    @classmethod
    def getBytesRequestsByDay(cls, initial_date, final_date):
        print(initial_date, final_date)
        try:
            values = db.session.query(Date.day_of_month, func.sum(Request.bytes)/(1024*1024), func.count(Request.url_id)).filter(Request.date_id == Date.date_dim_id).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d"))).group_by(Date.day_of_month).order_by(Date.day_of_month)

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values


#######  END welcome charts  #######
####################################



    @classmethod
    def getTopDomains(cls, initial_date, final_date):
        try:
            values = db.session.query(Url.url_netloc, func.sum(Request.bytes)/1024, func.sum(Request.duration)/1000, func.count(Request.client_id.distinct()), func.count(Request.url_id).label("nr_clients")).join(Request, Request.url_id == Url.url_dim_id).filter(db.session.query(Date).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d")), Date.date_dim_id == Request.date_id).exists()).group_by(Url.url_netloc, Request.url_id).order_by(func.count(Request.url_id).desc())

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

            #### USO DE FUNÇÃO ####
            # values_by_function = db.session.query(func.public.top_domains(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d")))

            # print(type(values_by_function))
            # for value in values_by_function:
            #     print(value)

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values


    @classmethod
    def getClientsByDomain(cls, domain):
        try:
            values = db.session.query(Client.client_address,func.sum(Request.bytes)/1024,func.sum(Request.duration)/1000,func.count(Request.url_id), Client.client_dim_id).join(Request, Request.client_id == Client.client_dim_id).filter(db.session.query(Url).filter(Url.url_netloc == domain, Url.url_dim_id == Request.url_id).exists()).group_by(Client.client_address, Client.client_dim_id).order_by(func.count(Request.url_id).desc())

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values


## mudar jinja users by domain
    @classmethod
    def getClientAndUser(cls, domain, client):
        try:
            values = db.session.query(Date.date_actual, Time.time_type, Request.bytes, Request.duration, Method.type, ResultCodes.type, ContentType.type).filter(Request.date_id == Date.date_dim_id).filter(Request.time_id == Time.time_dim_id).filter(Request.method_id == Method.method_dim_id).filter(Request.result_codes_id == ResultCodes.result_codes_dim_id).filter(Request.content_type_id == ContentType.content_type_dim_id).filter(Request.client_id == Client.client_dim_id).filter(Request.url_id == Url.url_dim_id).filter(Client.client_address == client).filter(Url.url_netloc == domain).order_by((Date.date_actual).desc())

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values


    @classmethod
    def getTopClients(cls, initial_date, final_date):
        try:
            values = db.session.query(
            Client.client_address,
            func.sum(Request.duration)/1000,
            func.sum(Request.bytes)/1024,
            func.count(Request.client_id), func.count(Request.url_id.distinct())).join(Request, Request.client_id == Client.client_dim_id).filter(db.session.query(Date).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d")), Date.date_dim_id == Request.date_id).exists()).group_by(Client.client_address, Request.client_id).order_by(func.count(Request.client_id).desc())

            # print(str(values.statement.compile(dialect=postgresql.dialect())))


        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values


    @classmethod
    def getDomainsByClient(cls, client):
        try:
            values = db.session.query(Url.url_netloc,func.sum(Request.bytes),func.sum(Request.duration),func.count(Request.client_id)).join(Request, Request.url_id == Url.url_dim_id).filter(db.session.query(Client).filter(Client.client_address == client, Client.client_dim_id == Request.client_id).exists()).group_by(Url.url_netloc).order_by(func.count(Request.client_id).desc())

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values


    @classmethod
    def getComunicationsByMonth(cls, initial_date, final_date):
        try:
            values = db.session.query(Url.url_netloc, Client.client_address, func.sum(Request.bytes)/1024, func.sum(Request.duration)/1000, func.count(Request.fact_id)).filter(Request.client_id == Client.client_dim_id).filter(Request.url_id == Url.url_dim_id).filter(db.session.query(Date).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d")), Date.date_dim_id == Request.date_id).exists()).group_by(Client.client_address, Url.url_netloc, Request.client_id, Request.client_id, Request.url_id).order_by(func.sum(Request.bytes).desc()).limit(10)

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values

# hora cliente dominio, sem data e sem posicao
    @classmethod
    def getResultCodes(cls, resultCode, initial_date, final_date):
        try:
            #https://stackoverflow.com/questions/35690518/sqlalchemy-query-filter-returned-no-from-clauses-due-to-auto-correlation

            url = Request.url_scheme + "://" + Url.url_netloc + Request.url_path

            values = db.session.query(url.label("url"), Client.client_address, Date.date_actual, Time.time_type, ResultCodes.type, Url.url_netloc).filter(Request.result_codes_id == ResultCodes.result_codes_dim_id).filter(Request.url_id == Url.url_dim_id).filter(Request.time_id == Time.time_dim_id).filter(Request.client_id == Client.client_dim_id).filter(ResultCodes.type.like("%"+resultCode+"%")).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d"))).limit(100)

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values






#############################
#######  PDF queries  #######

    @classmethod
    def getDomainsByClientPDF(cls, client, initial_date, final_date):
        try:
            url = Request.url_scheme + "://" + Url.url_netloc + Request.url_path
            values = db.session.query(url.label("url"), Date.date_actual, Time.time_type, Request.bytes, Request.duration, ResultCodes.type, ContentType.type).filter(Request.date_id == Date.date_dim_id).filter(Request.time_id == Time.time_dim_id).filter(Request.url_id == Url.url_dim_id).filter(Request.result_codes_id == ResultCodes.result_codes_dim_id).filter(Request.content_type_id == ContentType.content_type_dim_id).filter(Request.client_id == Client.client_dim_id).filter(Request.url_id == Url.url_dim_id).filter(Client.client_address == client).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d"))).order_by((Date.date_actual).desc())

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values

    @classmethod
    def getClientsByDomainPDF(cls, domain, initial_date, final_date):
        try:
            url = Request.url_scheme + "://" + Url.url_netloc + Request.url_path
            values = db.session.query(Client.client_address, Date.date_actual, Time.time_type, Request.bytes, Request.duration, url.label("url"), ResultCodes.type, ContentType.type).filter(Request.date_id == Date.date_dim_id).filter(Request.time_id == Time.time_dim_id).filter(Request.url_id == Url.url_dim_id).filter(Request.result_codes_id == ResultCodes.result_codes_dim_id).filter(Request.content_type_id == ContentType.content_type_dim_id).filter(Request.client_id == Client.client_dim_id).filter(Request.url_id == Url.url_dim_id).filter(Url.url_netloc.ilike('%' + domain + '%')).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d"))).order_by((Date.date_actual).desc())

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values
       

    @classmethod
    def getComunicationDomainClientPDF(cls, domain, client, initial_date, final_date):
        try:
            url = Request.url_scheme + "://" + Url.url_netloc + Request.url_path
            values = db.session.query(url.label("url"), Date.date_actual, Time.time_type, Request.bytes, Request.duration, Method.type, ResultCodes.type, ContentType.type).filter(Request.date_id == Date.date_dim_id).filter(Request.time_id == Time.time_dim_id).filter(Request.method_id == Method.method_dim_id).filter(Request.url_id == Url.url_dim_id).filter(Request.result_codes_id == ResultCodes.result_codes_dim_id).filter(Request.content_type_id == ContentType.content_type_dim_id).filter(Request.client_id == Client.client_dim_id).filter(Request.url_id == Url.url_dim_id).filter(Url.url_netloc.ilike('%' + domain + '%')).filter(Client.client_address == client).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d"))).order_by((Date.date_actual).desc())

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values



    @classmethod
    def getDeniedPDF(cls, initial_date, final_date):
        try:
            url = Request.url_scheme + "://" + Url.url_netloc + Request.url_path
            resultCode = 'DENIED'

            values = db.session.query(url.label("url"), Client.client_address, Date.date_actual, Time.time_type, ResultCodes.type).filter(Request.result_codes_id == ResultCodes.result_codes_dim_id).filter(Request.url_id == Url.url_dim_id).filter(Request.time_id == Time.time_dim_id).filter(Request.client_id == Client.client_dim_id).filter(ResultCodes.type.like("%"+resultCode+"%")).filter(Date.date_actual.between(initial_date.strftime("%Y-%m-%d"), final_date.strftime("%Y-%m-%d"))).order_by(Date.date_actual)

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values


#######  end PDF queries  #######
#################################










































































# O engraçado é que a gente vive a maior quantia dos nossos dias sem nos importarmos com as oportunidades que eles nos trazem, sem pensar muito sobre o tempo que não volta. Algumas vezes até torcemos para que o dia passe logo, para que a semana termine, para que o ano acabe. Deixamos de dar valor às pessoas que amamos, talvez porque não percebemos que o tempo delas ao nosso lado não é infinito. Elas parecem estar sempre ali para que convivamos, então deixamos para depois e para depois e para depois, até que o depois seja tarde demais. Fazemos o mesmo com nossos sonhos, com aquilo que queremos experimentar ou tentar. Parecemos esquecer que o tempo nos traz algumas limitações e restrições. De repente já não podemos experimentar algo porque não nos convém ou não nos pertence. Sobram as memórias das experiências boas e as lamentações decorrentes de oportunidades perdidas. Talvez quase todos nós lembramos da época de infância com saudosismo pois crianças são mais ingênuas, menos contidas e menos influenciáveis com os dilemas e problemas do dia a dia. Elas normalmente fazem e dizem o que querem. Talvez vivenciam as coisas com mais intensidade com que nós vivenciamos. E assim o tempo vai passando: continuamos a lamentar o tempo passado sem notar que o presente, que ora recusamos aproveitar, escapa por nossas mãos e passado se torna também.
