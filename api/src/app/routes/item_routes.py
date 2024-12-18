from flask import Blueprint, jsonify
from ..models.items import Item

item_bp = Blueprint('items', __name__)

@item_bp.route('/', methods=['GET'])
def get_items():
    items = Item.query.all()
    return jsonify([{"id": i.id, "name": i.name, "price": i.price} for i in items])
