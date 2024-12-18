
from flask import Blueprint, request, jsonify
from ..models.users import User
from werkzeug.security import generate_password_hash, check_password_hash
import jwt
from datetime import datetime, timedelta
from ..models.db import db
from ..models.basket import Basket  # Assure-toi de définir ce modèle
from dotenv import load_dotenv
import os
from ..models.items import Item

load_dotenv()
# Initialisation du Blueprint
user_bp = Blueprint('users', __name__)

# Clé secrète pour JWT

SECRET_KEY = os.getenv("SECRET_KEY")

# Route pour récupérer tous les utilisateurs
@user_bp.route('/all', methods=['GET'])
def get_all_users():
    users = User.query.all()
    users_list = [{"id": user.id, "username": user.username, "email": user.email} for user in users]
    return jsonify(users_list), 200

# Route pour s'inscrire
@user_bp.route('/signup', methods=['POST'])
def subscribe():
    data = request.json
    if not data or not data.get('username') or not data.get('email') or not data.get('password'):
        return jsonify({"error": "Missing data"}), 400

    # Vérifie si l'utilisateur existe déjà
    existing_user = User.query.filter_by(email=data['email']).first()
    if existing_user:
        return jsonify({"error": "Email already registered"}), 400

    # Crée un nouvel utilisateur
    new_user = User(
        username=data['username'],
        email=data['email'],
        password=generate_password_hash(data['password'])  # Hashage du mot de passe
    )
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"message": "User registered successfully"}), 201

@user_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    if not data or not data.get('email') or not data.get('password'):
        return jsonify({"error": "Missing data"}), 400
    
    # Recherche l'utilisateur dans la base de données par son email
    user = User.query.filter_by(email=data['email']).first()
    
    # Vérifie si l'utilisateur existe et si le mot de passe est correct
    if not user or not check_password_hash(user.password, data['password']):
        return jsonify({"error": "Invalid email or password"}), 401

    # Génère un token JWT pour l'utilisateur
    token = jwt.encode(
        {"sub": str(user.id), "exp": datetime.utcnow() + timedelta(minutes=30)},  # Convertir user.id en string
        SECRET_KEY,
        algorithm="HS256"
    )

    

    return jsonify({"access_token": token, "token_type": "bearer"}), 200


# Route pour obtenir le panier d'un utilisateur
@user_bp.route('/basket', methods=['GET'])
def get_basket():
    

    # Récupérer l'ID de l'utilisateur à partir du JWT ou d'un paramètre
    token = request.headers.get('Authorization')
    print('token', token)
    if not token:
        return jsonify({"error": "Token is missing"}), 401

    try:
        # Décoder le token
        decoded_token = jwt.decode(token, key=SECRET_KEY, algorithms=["HS256"])
        user_id = decoded_token['sub']
  

    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 401
    except jwt.InvalidTokenError as e:
        return jsonify({"error": "Invalid token", "message": str(e)}), 401


    # Trouver l'utilisateur et son panier
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    basket = Basket.query.filter_by(user_id=user.id).first()  # Trouver le panier de l'utilisateur

    if not basket:
        return jsonify({"message": "No basket found for this user"}), 404

    # Retourner les éléments du panier
    basket_items = [{"id": item.id, "name": item.name, "price": item.price} for item in basket.items]

    return jsonify({"basket": basket_items}), 200



@user_bp.route('/basket/add', methods=['POST'])
def add_to_basket():
    data = request.json
    if not data or not data.get('item_id') or not data.get('quantity'):
        return jsonify({"error": "Missing data"}), 400

    token = request.headers.get('Authorization')
    if not token:
        return jsonify({"error": "Token is missing"}), 401

    try:
        # Décoder le token JWT pour récupérer l'ID de l'utilisateur
        decoded_token = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        user_id = decoded_token['sub']
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 401
    except jwt.InvalidTokenError as e:
        return jsonify({"error": "Invalid token", "message": str(e)}), 401

    # Récupérer l'utilisateur
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Vérifier si l'item existe
    item = Item.query.get(data['item_id'])
    if not item:
        return jsonify({"error": "Item not found"}), 404

    # Vérifier si un panier existe pour l'utilisateur
    basket = Basket.query.filter_by(user_id=user.id).first()
    if not basket:
        # Créer un panier si l'utilisateur n'en a pas
        basket = Basket(user_id=user.id)
        db.session.add(basket)
        db.session.commit()

    # Ajouter l'item au panier
    # On ajoute une relation entre le panier et l'item dans la table intermédiaire
    if item not in basket.items:
        basket.items.append(item)

    db.session.commit()

    return jsonify({"message": "Item added to basket"}), 201


@user_bp.route('/basket/remove', methods=['POST'])
def remove_from_basket():
    data = request.json
    if not data or not data.get('item_id'):
        return jsonify({"error": "Missing data"}), 400

    token = request.headers.get('Authorization')
    if not token:
        return jsonify({"error": "Token is missing"}), 401

    try:
        # Décoder le token JWT pour récupérer l'ID de l'utilisateur
        decoded_token = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        user_id = decoded_token['sub']
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 401
    except jwt.InvalidTokenError as e:
        return jsonify({"error": "Invalid token", "message": str(e)}), 401

    # Récupérer l'utilisateur
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Vérifier si un panier existe pour l'utilisateur
    basket = Basket.query.filter_by(user_id=user.id).first()
    if not basket:
        return jsonify({"error": "Basket not found"}), 404

    # Vérifier si l'item existe dans le panier
    item = Item.query.get(data['item_id'])
    if not item or item not in basket.items:
        return jsonify({"error": "Item not in basket"}), 404

    # Supprimer l'item du panier
    basket.items.remove(item)
    db.session.commit()

    return jsonify({"message": "Item removed from basket"}), 200
