from flask_sqlalchemy import SQLAlchemy
from ..models.db import db

# Modèle Basket
class Basket(db.Model):
    __tablename__ = 'baskets'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)

    # Relation plusieurs-à-plusieurs avec la table Item
    items = db.relationship('Item', secondary='basket_items', backref='baskets')

    def __repr__(self):
        return f'<Basket {self.id}>'

# Table intermédiaire pour la relation plusieurs-à-plusieurs entre Basket et Item
basket_items = db.Table('basket_items',
    db.Column('basket_id', db.Integer, db.ForeignKey('baskets.id'), primary_key=True),
    db.Column('item_id', db.Integer, db.ForeignKey('items.id'), primary_key=True)
)

