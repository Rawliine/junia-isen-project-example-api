from flask import Blueprint, jsonify
from ..models.basket import db, Basket

basket_bp = Blueprint('baskets', __name__)

@basket_bp.route('/', methods=['GET'])
def get_baskets():
    # Récupérer tous les paniers de tous les utilisateurs
    baskets = Basket.query.all()

    # Formater la réponse pour retourner les informations essentielles des paniers
    baskets_data = [
        {
            "id": b.id,  # ID du panier
            "user_id": b.user_id,  # ID de l'utilisateur associé au panier
            "items": [{"id": item.id, "name": item.name, "price": item.price} for item in b.items]  # Liste des items dans le panier
        }
        for b in baskets
    ]
    
    return jsonify(baskets_data), 200
