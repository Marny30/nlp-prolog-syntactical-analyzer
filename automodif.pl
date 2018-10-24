#!/usr/bin/env swipl
               

% motNonReconnu(Mot):-not(motReconnu(Mot)),!,fail.
% motNonReconnu(Mot).  
entre(Mot,[Mot|Reste],Reste).


dico(Mot,np):-np(Mot,_,_,_).
dico(Mot,nc):-nc(Mot,_,_,_,_,_).
dico(Mot,vi):-vi(Mot,_,_,_,_).
dico(Mot,vt):-vt(Mot,_,_,_,_).
dico(Mot,det):-det(Mot,_,_,_,_).

dico(qui,relqui). % Debug pour relqui, car le mot vient uniquement dans un chunk, jamais indépendemment.

motReconnu(Mot):-dico(Mot,_).

%% np(pierre,U,V,masc) satisfié lorsque U est une chaîne commençant par "pierre"

:- dynamic np/4.
ajoutNP(N,G):-
    asserta(np(N,U,V,G):-entre(N,U,V)).

ajoutNP:-    
  writeln('Rentrez un nouveau nom (suivi d\'un point)'),
  read(N),
  writeln('Rentrez le genre de la personne (suivi d\'un point)'),
  read(G),
  ajoutNP(N,G).

ajoutNP(Mot):-
  writeln('Rentrez le genre de la personne (suivi d\'un point)'),
  read(G),
  ajoutNP(Mot,G).

:- dynamic nc/6.
ajoutNC(Mot):-
  writeln('Rentrez le genre (masc/fem) (suivi d\'un point)'),
  read(G),
  writeln('Rentrez le nombre sing/pluriel (suivi d\'un point)'),
  read(Nombre),
  writeln('Renseigez si l\'objet désigné est animé ou non (animé/nonanimé) (suivi d\'un point)'),
  read(Anime),
  ajoutNC(Mot,G,Nombre,Anime).

ajoutNC(NC,G,Nombre,Anime):-
    asserta(nc(NC,U,V,G,Nombre,Anime):- entre(NC,U,V)).

:- dynamic vi/5.
ajoutVI(Mot,Nombre,Anime):-
    asserta(vi(Mot,U,V,Nombre,Anime):- entre(Mot,U,V)).
ajoutVI(Mot):-
  writeln('Rentrez le nombre sing/pluriel (suivi d\'un point)'),
  read(Nombre),
  writeln('Renseigez si le verbe s applique sur des objets animes ou non (animé/nonanimé) (suivi d\'un point)'),
  read(Anime),
  ajoutVI(Mot,Nombre,Anime).

:- dynamic vt/5.
ajoutVT(Mot,Nombre,Anime):-
  asserta(vt(Mot,U,V,Nombre,Anime):- entre(Mot,U,V)).
ajoutVT(Mot):-
  writeln('Rentrez le nombre sing/pluriel (suivi d\'un point)'),
  read(Nombre),
  writeln('Renseigez si le verbe s applique sur des objets animes ou non (animé/nonanimé) (suivi d\'un point)'),
  read(Anime),
  ajoutVT(Mot,Nombre,Anime).

:- dynamic det/5.
ajoutDET(Mot,Genre,Nombre):-
  asserta(det(Mot,U,V,Genre,Nombre):- entre(Mot,U,V)).
ajoutDET(Mot):-
  writeln('Rentrez le genre (masc/fem) (suivi d\'un point)'),
  read(G),
  writeln('Rentrez le nombre sing/pluriel (suivi d\'un point)'),
  read(Nombre),
  ajoutDET(Mot,G,Nombre).

testMotNonReconnu(Mot):-
  not(motReconnu(Mot)),
  % !,
  write('Le mot "'),
  write(Mot),
  writeln('" n\'a pas été reconnu. Ajoutons le au dictionnaire.'),
  ajoutMot(Mot),
  fail.
testMotNonReconnu(_).


ajoutMot(Mot):-
  writeln('Rentrez la classe du mot : np, nc, vt, vi, det... (suivi d\'un point) (exit pour quitter)'),
  read(POS),
  (
   POS = exit -> fail;
   POS = np -> ajoutNP(Mot);
   POS = nc -> ajoutNC(Mot);
   POS = vt -> ajoutVT(Mot);
   POS = vi -> ajoutVI(Mot);
   POS = det -> ajoutDET(Mot);
   write('La classe grammaticale n\'est pas reconnue. Abandon de la procedure.')).
% parcoursVerifDico est vérifié quand tous les mots d'une phrase sont des mots reconnus
parcoursVerifDico([]).
parcoursVerifDico(S):-
  S=[H|T],
  % writeln(H),
  testMotNonReconnu(H),
  parcoursVerifDico(T).

% Fonction de main pour donner un exemple de l'automodification
main:-
  % peuplement initial
  ajoutNP(pierre,masc),
  ajoutNP(marie,fem),
  ajoutNC(orange,fem,sing, nonanimé),
  write('Contenu du dictionnaire : '),
  mots,
  writeln('phrase "Le garçon mange": tous les mots sont ils connus?'),
  parcoursVerifDico([le,garçon,mange]),
  write('Contenu actuel du dictionnaire : '),
  mots,
  writeln('Test de la même phrase'),
  parcoursVerifDico([le,garçon,mange]).

mots:-
  findall(X, (dico(X,_)), Mots),
  writeln(Mots).
