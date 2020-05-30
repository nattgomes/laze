from app import db
import string
from sqlalchemy.dialects import postgresql
from sqlalchemy import func, exists, desc, orm
from sqlalchemy.orm import aliased
from datatables import DataTables, ColumnDT


# https://stackoverflow.com/questions/20518521/is-possible-to-mapping-view-with-class-using-mapper-in-sqlalchemy

class VW_content_types(db.Model):
    __tablename__ = 'vw_content_types'
    year = db.Column(db.Integer, primary_key=True)
    month = db.Column(db.Integer, primary_key=True)
    mime = db.Column(db.Text, primary_key=True)
    total = db.Column(db.BigInteger())

    def __repr__(self):
        return 'VW_result_codes: (month=%s, total=%s)' % (self.month, self.total)


    @classmethod
    def getTypesChart(cls, year, month):
        try:
            values = db.session.query(VW_content_types.mime, VW_content_types.total).filter(VW_content_types.year == year, VW_content_types.month == month).limit(10)

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
            db.session.execute('REFRESH MATERIALIZED VIEW CONCURRENTLY public.vw_content_types')
            db.session.commit()

        except Exception as e:
            print('Error refreshing views!')
            print(e)
            return None;
        return 1
