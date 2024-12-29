# Shop Service 

Ce projet propose une API sécurisée permettant de gérer des utilisateurs et d'interagir avec une base de données SQL via une infrastructure déployée sur Azure.

---

## 📄 **Documentation**

---

### 🔧 **Protocole d'utilisation du projet**

#### **1ère étape : Création d'un dépôt GitHub**
1. Créez un dépôt public dans votre propre compte GitHub.

#### **2ème étape : Cloner le dépôt**
1. Clonez ce dépôt dans votre environnement local avec :
   ```bash
   git clone https://github.com/<votre-username>/<nom-du-repo>.git
   ```

#### 3ème étape : Configuration des accès Azure
   1. Obtenez les informations nécessaires  à la configuration Azure en éxecutant la commande suivante:
      ```bash
    az ad sp create-for-rbac --name "shop-service-plan" --role Contributor --scopes /subscriptions/<subscriptionId>
     ```
   Remplacez ```<subscriptionId>``` par l'ID de votre abonnement Azure, que vous pouvez récupérer sur le portail Azure.

   2. Cette commande générera un JSON semblable à ceci :
  ```json
   {
    "appId": "votre-appId",
    "displayName": "shop-service-plan",
    "password": "votre-password",
    "tenant": "votre-tenant"
    }
   ```

   3. AJoutez ces informations comme secret dans votre dépôt GitHub sous la clé ```AZURE_CREDENTIALS```:
   ```json
    {
      "clientSecret": "votre-password",
      "subscriptionId": "votre-subscriptionId",
      "tenantId": "votre-tenant",
      "clientId": "votre-appId"
    }
   ```

#### 4ème étape : Ajout de la clé secrète.
   1. Générez une clé secrète pour signer les tokens en utilisant un générateur de token.
   2. Ajoutez cette clé comme secret dans votre dépôt Github sous la clé ```SECRET_KEY```.

      
#### 5ème étape : Push and Deploy
  1. Poussez ce projet dans votre dépôt en suivant ces étapes:
   ```bash
    git remote remove origin
    git remote add origin https://github.com/<votre-username>/<nom-du-repo>.git
    git push -u origin main
   ```
  En poussant le projet sur votre branche main, la ci-cd de déploiement se lancera et votre projet sera prêt à être utilisé !

---

### 🔧 **Utilisation de l'API**

#### Endpoints

   #### **1. Utilisateurs (```/users```)**
   ##### ```GET /users/all```
   Récupére la liste de tous les utilisateurs.
   
   **Réponse:**
   ```json
  [
  {
    "id": 1,
    "username": "JohnDoe",
    "email": "john@example.com"
  }
]

   ```

   ##### ```POST /users/signup```
   Inscription d'un nouvel utilisateur.

   *   **Body (JSON) :**
   ```json
{
  "username": "JohnDoe",
  "email": "john@example.com",
  "password": "securepassword"
}

   ```
   *   **Réponse (succès) :**
   ```json
{
  "message": "User registered successfully"
}
   ```
   *   **Réponse (échec) :**
   ```json
{
  "error": "Email already registered"
}
   ```
   
   ##### ```POST /users/login```
   Authentification de l'utilisateur.

   *   **Body (JSON) :**
   ```json
{
  "email": "john@example.com",
  "password": "securepassword"
}
   ```
   *   **Réponse (succès) :**
   ```json
{
  "access_token": "JWT_TOKEN",
  "token_type": "bearer"
}
   ```
   *   **Réponse (échec) :**
   ```json
{
  "error": "Invalid email or password"
}
   ```

   ##### ```GET /users/basket**```
   Récupère le panier de l'utilisateur authentifié.

   *   **Headers :**
   Authorization: ```Bearer JWT_TOKEN```
   
   *   **Réponse (succès) :**
   ```json
{
  "basket": [
    {
      "id": 1,
      "name": "Item1",
      "price": 10.99
    }
  ]
}
   ```
   *   **Réponse (échec) :**
   ```json
{
  "error": "Token expired"
}
   ```
   ##### ```POST /users/basket/add```
   Ajoute un article au panier de l'utilisateur authentifié.

   *   **Headers :**
   Authorization: ```Bearer JWT_TOKEN```
   
   *   **Body (JSON) :**
   ```json
{
  "item_id": 1,
  "quantity": 1
}
```
   *   **Réponse (succès) :**
   ```json
{
  "message": "Item added to basket"
}
   ```
   *   **Réponse (échec) :**
   ```json
{
  "error": "Item not found"
}
   ```

   ##### ```POST /users/basket/remove```
   Supprime un article du panier de l'utilisateur authentifié.

   *   **Headers :**
   Authorization: ```Bearer JWT_TOKEN```
   
   *   **Body (JSON) :**
   ```json
{
  "item_id": 1,
}
```
   *   **Réponse (succès) :**
   ```json
{
  "message": "Item removed from basket"
}
   ```
   *   **Réponse (échec) :**
   ```json
{
  "error": "Item not in basket"
}
   ```


 #### **2. Paniers (```/baskets```)**
   ##### ```GET /baskets```
   Récupére la liste de tous les paniers de chaque utilisateur.
   
   *   **Réponse:**
   ```json
[
  {
    "id": 1,
    "user_id": 1,
    "items": [
      {
        "id": 1,
        "name": "Item1",
        "price": 10.99
      }
    ]
  }
]
   ```

 #### **2. Articles (```/items```)**
   ##### ```GET /items```
   Récupére la liste de tous les articles disponibles.
   
   *   **Réponse:**
   ```json
[
  {
    "id": 1,
    "name": "Item1",
    "price": 10.99
  }
]
   ```
---

### 🌐 **Infrastructure du projet**

![diagram-export-23-12-2024-11_16_12](https://github.com/user-attachments/assets/bc1f2e12-e9ef-449a-9f63-5d2968f02bf2)




### ⚖️ **Licence**
Ce projet est sous licence MIT.
Cela couvre les étapes d'installation, du'tilisation, l'infrastructure et les tests.
Vous pouvez l'adapter selon vos besoins spécifiques.

   
