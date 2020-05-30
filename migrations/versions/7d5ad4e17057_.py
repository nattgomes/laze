"""empty message

Revision ID: 7d5ad4e17057
Revises: 7789f83f1b8b
Create Date: 2019-03-10 11:27:59.193584

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '7d5ad4e17057'
down_revision = '7789f83f1b8b'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('logs',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('timestamp', sa.TIMESTAMP(), nullable=True),
    sa.Column('duration', sa.Integer(), nullable=True),
    sa.Column('client_adr', sa.String(length=64), nullable=False),
    sa.Column('request', sa.String(length=30), nullable=True),
    sa.Column('bytes', sa.Integer(), nullable=True),
    sa.Column('method', sa.String(length=10), nullable=True),
    sa.Column('url', sa.String(length=512), nullable=False),
    sa.Column('type', sa.String(length=20), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('logs')
    # ### end Alembic commands ###
