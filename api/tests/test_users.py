# SHOP-APP-CODE/api/tests/test_users.py

import pytest
import jwt
from datetime import datetime, timedelta
from werkzeug.security import generate_password_hash
from src.app.__init__ import create_app
from src.app.models.db import db
from src.app.models.users import User
from src.app.models.items import Item
from src.app.models.basket import Basket
import os


@pytest.fixture
def app():
    """
    Fixture Pytest qui crée l'application Flask pour les tests
    et initialise la base de données *en mémoire* (SQLite).
    """
    # Ici, on indique testing=True -> la factory va utiliser "sqlite:///:memory:"
    app = create_app(testing=False)

    with app.app_context(): # Contexte de l'application
        db.create_all()

        # Insérer des items initiaux (20 items) si pas déjà présents
        if not Item.query.first():
            Item.create_initial_items()

        # Ajouter des utilisateurs de base (testuser1, testuser2)
        user1 = User(
            username="testuser1",
            email="test1@example.com",
            password=generate_password_hash("password1")
        )
        user2 = User(
            username="testuser2",
            email="test2@example.com",
            password=generate_password_hash("password2")
        )
        db.session.add_all([user1, user2])
        db.session.commit()

    yield app

    # Teardown : on détruit la DB
    with app.app_context():
        db.drop_all()


@pytest.fixture
def client(app):
    """Retourne un client de test Flask pour effectuer les requêtes HTTP."""
    
    return app.test_client()


@pytest.fixture
def auth_token(app):
    """
    Génère un token JWT valide pour 'test1@example.com'.
    """
    with app.app_context():
        user = User.query.filter_by(email="test1@example.com").first()
        if not user:
            return None

        SECRET_KEY = app.config['SECRET_KEY']
        token = jwt.encode(
            {"sub": str(user.id), "exp": datetime.utcnow() + timedelta(minutes=30)},
            SECRET_KEY,
            algorithm="HS256"
        )
        return token


def test_get_all_users(client):
    """Test la récupération de tous les utilisateurs."""
    response = client.get('/users/all')
    assert response.status_code == 200

    data = response.get_json()
    assert len(data) == 2  # On a créé 2 utilisateurs dans la fixture
    assert data[0]['username'] == "testuser1"
    assert data[1]['email'] == "test2@example.com"


def test_signup_success(client):
    """Test l'inscription d'un nouvel utilisateur avec succès."""
    payload = {
        "username": "newuser",
        "email": "new@example.com",
        "password": "newpass"
    }
    response = client.post('/users/signup', json=payload)
    assert response.status_code == 201
    data = response.get_json()
    assert data["message"] == "User registered successfully"


def test_signup_existing_email(client):
    """Test l'inscription avec un email déjà enregistré."""
    payload = {
        "username": "duplicated",
        "email": "test1@example.com",  # déjà en base via fixture
        "password": "whatever"
    }
    response = client.post('/users/signup', json=payload)
    assert response.status_code == 400
    data = response.get_json()
    assert data["error"] == "Email already registered"


def test_signup_missing_data(client):
    """Test l'inscription avec des champs manquants."""
    payload = {
        "username": "missingPassword"
        # email et password manquent
    }
    response = client.post('/users/signup', json=payload)
    assert response.status_code == 400
    data = response.get_json()
    assert data["error"] == "Missing data"


def test_login_success(client):
    """Test la connexion réussie avec des identifiants valides."""
    payload = {
        "email": "test1@example.com",
        "password": "password1"
    }
    response = client.post('/users/login', json=payload)
    assert response.status_code == 200
    data = response.get_json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_login_wrong_password(client):
    """Test la connexion avec un mot de passe incorrect."""
    payload = {
        "email": "test1@example.com",
        "password": "wrongpassword"
    }
    response = client.post('/users/login', json=payload)
    assert response.status_code == 401
    data = response.get_json()
    assert data["error"] == "Invalid email or password"


def test_login_missing_data(client):
    """Test la connexion avec des champs manquants."""
    payload = {
        "email": "test1@example.com"
        # Mot de passe manquant
    }
    response = client.post('/users/login', json=payload)
    assert response.status_code == 400
    data = response.get_json()
    assert data["error"] == "Missing data"


def test_get_basket_no_token(client):
    """Test la récupération du panier sans token."""
    response = client.get('/users/basket')
    assert response.status_code == 401
    data = response.get_json()
    assert data["error"] == "Token is missing"


def test_get_basket_valid_token(client, auth_token):
    """Test la récupération du panier avec un token valide."""
    headers = {"Authorization": auth_token}
    response = client.get('/users/basket', headers=headers)
    # S'il n'y a pas de panier, on s'attend à un code 404 (voir user_routes.py)
    # Sinon 200
    assert response.status_code in [200, 404]

    data = response.get_json()
    if response.status_code == 404:
        assert data["message"] == "No basket found for this user"
    else:
        # Panier existant
        assert "basket" in data


def test_add_to_basket(client, auth_token):
    """Test l'ajout d'un item au panier avec un token valide."""
    payload = {
        "item_id": 1,
        "quantity": 1
    }
    headers = {"Authorization": auth_token}
    response = client.post('/users/basket/add', json=payload, headers=headers)
    assert response.status_code == 201
    data = response.get_json()
    assert data["message"] == "Item added to basket"

    # Vérifier l'item dans le panier
    basket_resp = client.get('/users/basket', headers=headers)
    assert basket_resp.status_code == 200
    basket_data = basket_resp.get_json()
    assert any(item["id"] == 1 for item in basket_data["basket"])


def test_remove_from_basket(client, auth_token):
    """Test la suppression d'un item du panier."""
    headers = {"Authorization": auth_token}
    # On ajoute d'abord un item (id=2) pour pouvoir le retirer
    payload_add = {"item_id": 2, "quantity": 1}
    add_resp = client.post('/users/basket/add', json=payload_add, headers=headers)
    assert add_resp.status_code == 201

    # Maintenant, on le retire
    payload_remove = {"item_id": 2}
    remove_resp = client.post('/users/basket/remove', json=payload_remove, headers=headers)
    assert remove_resp.status_code == 200
    data = remove_resp.get_json()
    assert data["message"] == "Item removed from basket"

    # Vérifier qu'il n'est plus dans le panier
    basket_resp = client.get('/users/basket', headers=headers)
    assert basket_resp.status_code == 200
    basket_data = basket_resp.get_json()
    assert all(item["id"] != 2 for item in basket_data["basket"])
