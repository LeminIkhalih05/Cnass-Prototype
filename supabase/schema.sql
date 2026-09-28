-- CNASS Prototype : schéma et données initiales
-- À exécuter dans Supabase > SQL Editor (ou via le connecteur Supabase)

create table if not exists public.etapes (
  id          bigint generated always as identity primary key,
  code        text not null unique,
  titre       text not null,
  description text,
  phase       text not null default 'logiciel',   -- logiciel | borne
  statut      text not null default 'a_venir' check (statut in ('realise','en_cours','a_venir')),
  ordre       int  not null default 0,
  maj_le      timestamptz not null default now()
);

create table if not exists public.composants (
  id          bigint generated always as identity primary key,
  nom         text not null,
  role        text,
  emplacement text,
  hauteur     text,
  alimentation text,
  prix        text,
  lien        text,
  ordre       int not null default 0
);

-- Lecture publique, écriture réservée aux utilisateurs authentifiés
alter table public.etapes     enable row level security;
alter table public.composants enable row level security;

drop policy if exists "lecture publique etapes" on public.etapes;
create policy "lecture publique etapes" on public.etapes for select using (true);
drop policy if exists "ecriture equipe etapes" on public.etapes;
create policy "ecriture equipe etapes" on public.etapes for all to authenticated using (true) with check (true);

drop policy if exists "lecture publique composants" on public.composants;
create policy "lecture publique composants" on public.composants for select using (true);
drop policy if exists "ecriture equipe composants" on public.composants;
create policy "ecriture equipe composants" on public.composants for all to authenticated using (true) with check (true);

insert into public.etapes (code, titre, description, phase, statut, ordre) values
 ('T1','Base d''empreintes','PostgreSQL déployé : vecteurs 512D indexés par matricule.','logiciel','realise',1),
 ('T2','Calcul des empreintes','Microservice InsightFace et enrôlement automatique par tâche planifiée.','logiciel','realise',2),
 ('T3','Intégration API CNASS','getAssureByMatricule et createFeuilleSoins branchés.','logiciel','realise',3),
 ('T4','Moteur sur terminal Jetson','Vérification exécutée sur le Jetson Orin NX.','logiciel','en_cours',4),
 ('T5','Interface kiosque','Parcours Numéro, Caméra, Terminé ; arabe et français ; audio.','logiciel','en_cours',5),
 ('T6','Feuille de soins au terminal','Impression A4 via Canon MF3010 et CUPS.','logiciel','a_venir',6),
 ('T7','Sécurité du terminal','Mode kiosque verrouillé, journal d''audit, détection du vivant.','logiciel','a_venir',7),
 ('B1','Relevé des cotes','Mesurer la borne existante (largeur intérieure, profondeur, découpes).','borne','a_venir',8),
 ('B2','Plans 3D FreeCAD','Assemblage avec les modèles STEP des composants, export DXF.','borne','a_venir',9),
 ('B3','Découpes et aménagement','Découpe écran 310 × 235 mm, fente A4, ouïes, étagères.','borne','a_venir',10),
 ('B4','Intégration électrique','Onduleur, multiprise, prise directe parafoudre pour l''imprimante.','borne','a_venir',11),
 ('B5','Tests sur site pilote','Essais en conditions réelles avec des assurés.','borne','a_venir',12)
on conflict (code) do nothing;

insert into public.composants (nom, role, emplacement, hauteur, alimentation, prix, lien, ordre)
select * from (values
 ('Écran tactile iiyama TF1534MC-B7X','Interface utilisateur 15" 4:3','Tête inclinée à 24°','1,28 m','12 V, 10 W','≈ 500 € (Europe)','https://www.amazon.ae/iiyama-ProLite-TF1534MC-B7X-touchscreen-DisplayPort/dp/B08Y5XBGFT?th=1',1),
 ('Caméra USB 1080p WDR','Capture du visage','Sommet de la tête, centrée','1,45 m','USB, 2 W','40 à 70 $',null,2),
 ('Jetson Orin NX (Yahboom)','Calcul et décision','Étagère derrière le bandeau','0,98 m','19 V, jusqu''à 40 W','à partir de 909 $','https://category.yahboom.net/fr/products/jetson-orin-nx',3),
 ('Canon i-SENSYS MF3010','Impression A4 de la feuille de soins','Étagère à mi-hauteur, fente A4','0,55 à 0,80 m','Prise directe, pointe 960 W','prix local à vérifier',null,4),
 ('Onduleur APC Back-UPS BX500MI','Secours Jetson, écran, caméra','Au sol, en travers du fût','0,15 m','300 W','60 à 90 €',null,5),
 ('Ventilation 2 × 80 mm','Refroidissement','Arrière : entrée basse, sortie haute','0,30 m / 0,95 m','12 V, 2 W','≈ 15 $',null,6),
 ('Multiprise interne','Distribution sortie onduleur','Paroi arrière','0,26 m','—','≈ 10 $',null,7)
) as v(nom, role, emplacement, hauteur, alimentation, prix, lien, ordre)
where not exists (select 1 from public.composants);
