from app import db
import string
from sqlalchemy.dialects import postgresql
from sqlalchemy import func, exists, desc, orm
from sqlalchemy.orm import aliased
from datatables import DataTables, ColumnDT


# https://stackoverflow.com/questions/20518521/is-possible-to-mapping-view-with-class-using-mapper-in-sqlalchemy

class VW_result_codes(db.Model):
    __tablename__ = 'vw_result_codes'
    year = db.Column(db.Integer, primary_key=True)
    month = db.Column(db.Integer, primary_key=True)
    result = db.Column(db.Text, primary_key=True)
    total = db.Column(db.BigInteger())

    def __repr__(self):
        return 'VW_result_codes: (month=%s, total=%s)' % (self.month, self.total)


    @classmethod
    def getResultsChart(cls, year, month):
        try:

            values = db.session.query(VW_result_codes.result, VW_result_codes.total).filter(VW_result_codes.year == year, VW_result_codes.month == month).limit(10)

            # print(str(values.statement.compile(dialect=postgresql.dialect())))

        except Exception as e:
            print('Error!')
            print(e)
            return None;
        return values


    @classmethod
    def refresh_mat_view(cls):
        try:
            db.session.flush()
            db.session.execute('REFRESH MATERIALIZED VIEW CONCURRENTLY vw_result_codes')
            db.session.commit()
        

        except Exception as e:
            print('Error refreshing views!')
            print(e)
            return None;
        return 1
