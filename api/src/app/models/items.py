from ..models.db import db  # Assurez-vous que db est importé

# Modèle Item
class Item(db.Model):
    __tablename__ = 'items'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
    price = db.Column(db.Float, nullable=False)

    def __repr__(self):
        return f'<Item {self.name}>'

    @staticmethod
    def create_initial_items():
        # Créer une liste d'items à insérer
        initial_items = [
            {"name": f"Item {i}", "price": 10.99 + i} for i in range(1, 21)
        ]

        # Insérer les items dans la base de données
        for item_data in initial_items:
            item = Item(name=item_data["name"], price=item_data["price"])
            db.session.add(item)

        # Commit les ajouts dans la base de données
        db.session.commit()
