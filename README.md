# CNASS Prototype

Site de suivi du prototype de vérification faciale CNASS × STARTAI : étapes (lues depuis Supabase), maquette 3D de la borne, matériel et présentation.

Nom du projet :
- Supabase : `CNASS Prototype` (espaces autorisés)
- Vercel : `cnass-prototype` (Vercel n'accepte que minuscules, chiffres et tirets)
- Adresse attendue : https://cnass-prototype.vercel.app (Vercel ajoute un suffixe si le nom est déjà pris)

## 1. Base Supabase
1. supabase.com > New project > Name : `CNASS Prototype`, mot de passe, région Europe > Create new project.
2. SQL Editor > New query > coller `supabase/schema.sql` > Run.
3. Nouvelle requête : `alter publication supabase_realtime add table public.etapes;` > Run.
4. Project Settings > API : copier Project URL et clé anon (publishable). Jamais la clé service_role.
5. Coller les deux valeurs dans `public/config.js`.

## 2. Test local
```
cd cnass-prototype
npx serve public
```
Ouvrir http://localhost:3000 : le point vert « Supabase connecté » doit apparaître.

## 3. Déploiement Vercel
```
npm i -g vercel
vercel login
vercel
```
Réponses : Y / votre compte / N (pas de projet existant) / nom : `cnass-prototype` / dossier : `./` / N (pas de modification).
Puis :
```
vercel --prod
```

## 4. Mise à jour de l'avancement
Supabase > Table Editor > etapes > colonne `statut` : `realise`, `en_cours` ou `a_venir`. Le site se met à jour tout seul.

## Sécurité
Site public : aucune donnée d'assuré ni donnée biométrique. La clé anon est publique par conception ; les règles RLS limitent les visiteurs à la lecture.
