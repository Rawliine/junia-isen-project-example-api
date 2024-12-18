import os
from flask import Flask
from dotenv import load_dotenv
from app.routes.init_routes import init_routes
from app.models.db import db  # Importer l'instance de db
from app.models.items import Item

# Charger les variables d'environnement depuis le fichier .env
load_dotenv()

# Créer l'application Flask
app = Flask(__name__)


sql_connection_string = os.getenv("SQL_CONNECTION_STRING")
print("SQL Connection String:", sql_connection_string)
raw_connection_string = (
    f"mssql+pyodbc:///?odbc_connect="
    f"Driver={{ODBC Driver 18 for SQL Server}};"
    f"Server=tcp:{sql_connection_string},1433;"
    f"Database=baceugeu-market-db;"
    f"Uid=adminuser;"
    f"Pwd={{P@ssword123}};"
    f"Encrypt=yes;"
    f"TrustServerCertificate=no;"
    f"Connection Timeout=30;"
)
 
# Afficher la chaîne brute
print("Raw Connection String:", raw_connection_string)

app.config['SQLALCHEMY_DATABASE_URI'] = raw_connection_string
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


# Initialiser la base de données
db.init_app(app)
with app.app_context():
    # Créer toutes les tables
    db.create_all()

    # Insérer les items initiaux
    if not Item.query.first():  # Vérifier s'il y a déjà des items dans la base
        Item.create_initial_items()

# Initialiser les routes
init_routes(app)

if __name__ == "__main__":
    # app.run(debug=os.getenv("FLASK_DEBUG", False))
    app.run(host="0.0.0.0", port=80)  # Écoute sur toutes les interfaces, port 80

