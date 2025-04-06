/* Diagramme de Sankey */

/*1. Mise en forme des donnees */
%macro boucle_sankey(ncpt);
	%macro sankey_S2S3_all(classe, n_cpt=&ncpt, annee_fin = 2022); /*classe: "Step II opioids" ou "Step III opioids" si analyse en sous classes
																	"opioid" si analyse en classes
																	n_cpt: nombre de delivrances prises en compte pour l analyse*/
data conso_temp;
format sous_classe $40.;
set conso;
/*Date_max = date_max + 30*/
date_30_trt = date_trt + 30;
/*On supprime les conso apres l annee fin*/
if annee_trt gt &annee_fin then delete;
/*Regroupement de la classe "dependance" dans S3*/
if classe = "dependance" then classe = "Step III opioids";
run;

/*Selection des drogues*/
data tempo;
format classe $40.;
set conso_temp;
%if &classe ne "opioid" %then %do; 
	if classe = &classe;
%end;
%if &classe = "opioid" %then %do;
	if classe ne "Psychotropic drugs";
%end;
run;
/*On verifie si plusieurs classes sont prises en meme temps*/
proc sql noprint;
/*Table avec les dates pour lesquelles il n y a qu une seule classe - On y indique la classe*/
create table no_comed_date as
select distinct(classe), date_trt, annee_trt, num_enq, count(distinct classe) as nb_classes
from tempo
group by num_enq, date_trt
having nb_classes = 1;
/*Table avec les dates pour lesquelles il y a plusieurs classes - On y indique la classe (S2+S3)*/
create table comed_date as
select count(distinct classe) as nb_classes, date_trt, annee_trt, num_enq
from tempo
group by num_enq, date_trt
having nb_classes gt 1;
quit;
data comed_date;
set comed_date;
format classe $40.;
classe = "Both steps II and III users";
run;
data raw_sankey;
set no_comed_date comed_date;
run;
%tri(raw_sankey, num_enq date_trt);
/*Si le type d'opioide est le meme que celui d avant on supprime la ligne*/
data liste_trt_diff_0;
set raw_sankey;
by num_enq date_trt annee_trt;
delai = date_trt-lag(date_trt);
if lag(classe) = classe and delai le 30 then indic_trt_diff = 0;
if lag(classe) = classe and delai gt 30 then indic_trt_diff = 1;
if lag(classe) ne classe then indic_trt_diff = 1;
if first.num_enq then indic_trt_diff = 1;
/*On ne garde que les lignes correspondant au traitement initial et aux switchs*/
if indic_trt_diff = 1;
run;
/* Pour les individus qui ont moins de delivrances que celui en ayant le plus, on ajoute artificiellement des temps de delivrance avec la meme valeur de classe que le dernier temps*/
	/*Compteur de delivrances (differentes)*/
	data liste_trt_diff;
	set liste_trt_diff_0;
	by num_enq date_trt;
	run;
	data liste_trt_diff;
	set liste_trt_diff;
	by num_enq date_trt;
	retain cpt;
	/*On reinitialise pour chaque annee*/
	if first.num_enq then cpt = 1;
	else cpt = cpt + 1;
	/*Creation d un identifiant unique : num_enq + cpt*/
	format ident_cpt $18.;
	ident_cpt = cat(num_enq,"-",cpt);
	run;
	proc sql noprint;
	select max(cpt) into: cpt1
	from liste_trt_diff;
	quit;
	%let cpt = %sysfunc(PUTn(&cpt1,8.));
	%do i = 2 %to &cpt;
		data liste_&i;
		set liste_trt_diff;
		format classe $30.;
		by num_enq date_trt;
		/*On prend la derniere valeur de classe de l annee et on la change en "no drug"*/
		if last.num_enq;
		classe = "No opioid use";
		/*On repete cette valeur en incrementant le compteur*/
		cpt = &i;
		format ident_cpt $18.;
		ident_cpt = cat(num_enq,"-",cpt);
		run;
		/*Fusion de toutes les tables */
		%if &i = &cpt %then %do;
			data liste_all;
			set liste_2-liste_&cpt;
			run;
			%supp(liste_2-liste_&cpt);
		%end;
	%end;
	/*Fusion des donnees reelles et des donnees artificielles*/
	/*A. On conserve toutes les donnees reelles --> liste_trt_diff*/
	/*B. On selectionne les donnees artificielles pour les lignes reellees manquantes*/
	proc sql noprint;
	create table artif as
	select b.classe, b.num_enq, b.cpt, b.ident_cpt
	from liste_trt_diff as a right join liste_all as b
	on a.ident_cpt = b.ident_cpt
	where a.ident_cpt is null;
	quit;
	/*C. Fusion des donnees*/
	data base_all;
	set liste_trt_diff artif;
	run;
	%tri(base_all nodupkey, num_enq cpt);
	/*On ne garde que les &n_cpt premieres delivrances*/
	data base_all_&n_cpt;
	set base_all;
	if cpt gt &n_cpt then delete;
	if classe = "Step II opioids" then classe = "Step II users";
	if classe = "Step III opioids" then classe = "Step III users";
	run;
	/*Analyse sur les 3 premieres delivrances de chaque annee*/
	/*Tout opioide*/
	title "Sankey diagram - Opioid drugs - 2006/&annee_fin";
	%sankeybarchart(data=base_all_&n_cpt
	   ,subject=num_enq
	   ,yvar=classe
	   ,xvar=cpt
	   ,yvarord=%quote(Step II users, Step III users, Both steps II and III users, No opioid use)
	   ,colorlist=VLIGB BIOY BIYG LIGGR
	   );
	/*dm "log;clear;";*/
	%mend;
/*Sortie des resultats*//*
/*Tout Opioide*/
%sankey_S2S3_all(classe="opioid");
%mend;

