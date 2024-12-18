from ..models.db import db  # Importer l'instance de db

# Modèle User
class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), nullable=False, unique=True)
    email = db.Column(db.String(100), nullable=False, unique=True)
    password = db.Column(db.String(200), nullable=False)

    baskets = db.relationship('Basket', backref='user', lazy=True)

    def __repr__(self):
        return f'<User {self.username}>'