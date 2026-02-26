
````markdown
# 🧠 Guide Git — Équipe *Cap Projet App*

> 📘 Ce document résume les commandes Git les plus utiles pour l’équipe.  
> Il sert à garder un workflow propre, éviter les conflits et faciliter la collaboration.

---

## 🚀 1. Démarrage

Cloner le projet :
```bash
git clone git@github.com:Pirodax/cap_projet_app.git
cd cap_projet_app
````

Créer une nouvelle branche :

```bash
git checkout -b feature/nom-de-ta-feature
```

---

## 💾 2. Cycle de travail standard

1️⃣ Vérifier l’état actuel :

```bash
git status
```

2️⃣ Ajouter tes changements :

```bash
git add .
```

3️⃣ Créer un commit :

```bash
git commit -m "feat: description claire du changement"
```

4️⃣ Mettre à jour ta branche avec `dev` :

```bash
git pull origin dev
```

5️⃣ Envoyer ta branche sur le dépôt distant :

```bash
git push origin feature/nom-de-ta-feature
```

---

## 🔀 3. Fusionner avec la branche `dev`

Quand ta feature est prête :

```bash
git checkout dev
git pull origin dev
git merge feature/nom-de-ta-feature
git push origin dev
```

> 💡 *Astuce : toujours faire un `git pull` avant de merger pour éviter les conflits.*

---

## ⚠️ 4. En cas de conflit

Lister les fichiers en conflit :

```bash
git status
```

Après les avoir corrigés manuellement :

```bash
git add .
git commit
git push
```

---

## 🧹 5. Gérer ses changements locaux

Mettre de côté temporairement (stash) :

```bash
git stash
```

Récupérer ensuite :

```bash
git stash pop
```

Annuler toutes les modifications locales (⚠️ supprime les changements non commités) :

```bash
git reset --hard
```

Restaurer un fichier spécifique :

```bash
git restore chemin/du/fichier
```

---

## 🔁 6. Revenir à un commit précédent

Afficher la liste des commits :

```bash
git log --oneline
```

Créer un **commit inverse** (conserve l’historique) :

```bash
git revert <id_commit>
```

Revenir complètement à un commit donné (⚠️ supprime les suivants) :

```bash
git reset --hard <id_commit>
```

---

## 🧱 7. Bonnes pratiques d’équipe

✅ Toujours **pull avant de push**
✅ Ne jamais commiter les fichiers IDE (`.idea/`, `.vscode/`, etc.)
✅ Utiliser des noms de branches clairs :

```
feature/...    → nouvelle fonctionnalité  
fix/...        → correction de bug  
refactor/...   → amélioration de code existant
```

✅ Utiliser des messages de commit cohérents :

```
feat: ajout du formulaire de simulation
fix: correction du bug de connexion
refactor: simplification du composant header
```

---

## 🚫 8. Ignorer les fichiers inutiles

Ajouter à ton `.gitignore` :

```
.idea/
node_modules/
.env
```

Supprimer les fichiers déjà suivis :

```bash
git rm -r --cached .idea
git commit -m "remove .idea from repo"
git push
```

---

## 🤝 9. Résumé rapide

| Action                     | Commande                      |
| -------------------------- | ----------------------------- |
| Créer une branche          | `git checkout -b feature/...` |
| Voir l’état local          | `git status`                  |
| Ajouter les fichiers       | `git add .`                   |
| Commit                     | `git commit -m "..."`         |
| Mettre à jour avec dev     | `git pull origin dev`         |
| Pousser la branche         | `git push origin feature/...` |
| Revenir à un commit        | `git reset --hard <id>`       |
| Sauvegarder temporairement | `git stash / git stash pop`   |

---

> 🧩 **Rappel :**
> Le dossier `.idea` doit être ignoré (il est propre à ton IDE).
> Si un conflit survient à cause de ce dossier :
>
> ```bash
> git restore .idea/*
> git pull origin dev
> ```

---

👨‍💻 *Dernière mise à jour : octobre 2025 — Mainteneur : [@Pirodax](https://github.com/Pirodax)*

```

---

Souhaites-tu que je te fasse aussi une **version simplifiée** (1 page, format “cheat sheet” à coller dans VS Code / Notion de l’équipe) ?
```
