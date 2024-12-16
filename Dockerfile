# Utiliser une image Python légère comme base
FROM python:3.10-slim
 
# Mettre à jour pip
RUN pip install --upgrade pip
  
# Installer les dépendances système nécessaires (par exemple pour pyodbc)
RUN apt-get update && apt-get install -y \
    unixodbc-dev gcc \
    && rm -rf /var/lib/apt/lists/*

# Définir le répertoire de travail dans le conteneur
WORKDIR /app
 
# Copier les fichiers nécessaires dans le conteneur
COPY requirements.txt /app/requirements.txt
COPY api/src /app/src

# Installer les dépendances Python et nettoyer le cache de pip
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache

# Passer les variables d'environnement
ENV SQL_CONNECTION_STRING=${SQL_CONNECTION_STRING}
ENV SECRET_KEY=${SECRET_KEY}

# Exposer le port utilisé par Flask (exemple : 5000)
EXPOSE 5000

# Définir la commande pour démarrer l'application
CMD ["python", "src/main.py"]