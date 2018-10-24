#!/usr/bin/env swipl

%%% Importation du module d'automodification
:- consult('automodif').
% entre(Mot,[Mot|Reste],Reste).  % Déjà défini dans automodif


%%% Peuplement de nos classes grammaticales
init_dico:-
    ajoutNP(pierre,masc),
    ajoutNP(marie,fem),
    ajoutNC(pomme,fem,sing,nonanimé),
    ajoutNC(copain,masc,sing,animé),
    ajoutNC(femme,fem,sing,animé),
    ajoutNC(melon,masc,sing,nonanimé),
    ajoutNC(pommes,fem,pluriel,nonanimé),
    ajoutNC(copains,masc,pluriel,animé),
    ajoutNC(femmes,fem,pluriel,animé),
    ajoutNC(melons,masc,pluriel,nonanimé),
    ajoutDET(le,masc,sing),
    ajoutDET(la,fem,sing),
    ajoutDET(un,masc,sing),
    ajoutDET(une,fem,sing),
    ajoutDET(les, _ ,pluriel),
    ajoutDET(des, _ ,pluriel),
    ajoutVI(tombe,sing,_),
    ajoutVI(dort,sing,animé),
    ajoutVI(tombent,pluriel,_),
    ajoutVI(dorment,pluriel,animé),
    ajoutVT(regarde,sing,animé),
    ajoutVT(mange,sing,animé),
    ajoutVT(regardent,pluriel,animé),
    ajoutVT(mangent,pluriel,animé).
:- init_dico.

% Note: on peut imaginer une fonction paramétrée pour faire toute ces actions. Il s'agit ici simplement d'un exemple.
main:-
  writeln('Quel est l\'arbre syntaxique de "pierre mange une pomme"?'),
  analyse([pierre,mange,une,pomme]),
  writeln('Est-ce que "pierre mange une pomme" est une phrase bien formée?'),
  (phrase([pierre,mange,une,pomme]), writeln('Oui'); writeln('Non')),
  writeln('Est-ce que "marc aime les femmes" est une phrase bien formée?'),
  (phrase([marc,aime,les,femmes]), writeln('Oui'); writeln('Non')),
  writeln('Sinon, ajoutons les mots manquants à notre base'),
  estReconnuPhrase([marc,aime,les,femmes]),
  writeln('Est-ce que "marc aime les femmes" est maintenant une phrase bien formée?'),
  (phrase([marc,aime,les,femmes]), writeln('Oui'); writeln('Non')),
  write('OK').
  % phrases.         % Liste de toutes les phrases reconnues par le prog  

%%%%%%%% GRAMMAIRE
s([phrase,GN,GV], A,B):-
    gn(GN, A, X, _, N, Anime),
    gv(GV, X, B, N, Anime).

gnSansRec([groupeNominal,Det,NC],X,Y,Genre,Nombre,Anime):-
    det(Det, X,I,Genre,Nombre),
    nc(NC, I,Y,Genre,Nombre,Anime).
gnSansRec([groupeNominal,Nom],X,Y,Genre,sing,animé):- np(Nom, X,Y,Genre).
gn(TYPE, X,Y,G,N,A):- gnSansRec(TYPE,X,Y,G,N,A).
gn([groupeNominal,REL,GN], X,Y,Genre,Nombre,Anime):-
    gnSansRec(GN,X,J,Genre,Nombre,Anime),
    relqui(REL,J,Y, Nombre).

relqui([relationQui, GV], U,V, Nombre):- entre(qui,U,X), gv(GV, X,V, Nombre, _).

gv([groupeVerbal, Verb, GN], U,V,Nombre,Anime):- vt(Verb, U,W,Nombre,Anime),gnSansRec(GN, W,V,_,_,_).
gv([groupeVerbal, Verb], U,V,Nombre,Anime):- vi(Verb, U,V,Nombre,Anime).

%% Affichage des phrases possibles avec
%% phrases.
phrase([]).                     % cas particulier
phrase(L):- s(X,L,[]).


estReconnuPhrase(L):- not(phrase(L)), parcoursVerifDico(L).
estReconnuPhrase(L):- phrase(L).

% Rédaction de toute les phrases connues par le système
phrases :-
    findall(X, (s(_,X,[])), Res),
    parcoursPhrase(Res).

% Fonction de parcours pour écriture des phrases sous forme de string
parcoursPhrase([]).
parcoursPhrase(S):-
    S=[H|T],
    listToString(H, Res),
    writeln(Res),
    % writeln(H),
    parcoursPhrase(T).

listToString([X],X).
listToString([H|T],Y):-
    listToString(T,Result),
    % atomics_to_string([H,Result],' ',Y).
    atomic_list_concat([H,Result],' ',Y).

%% Analyse Syntaxique
%% Rentrer par exemple dans la saisie
%% [pierre, mange, la, pomme].
analyse(L):-s(Arbre,L,[]), writeln(Arbre).
analyse:-
    writeln('Rentrez une phrase pour obtenir son arbre syntaxique'),
    read(L),
    analyse(L).     
