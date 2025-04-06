
/************************************************************************************************/
/*																							   	*/
/* SAS program created by Boris Schwartz, CESP-INSERM-U1018 Radiation Epidemiology Team - 2025 	*/
/*																							   	*/
/************************************************************************************************/
/*																							   	*/
/*					Long-term opioid use in survivors of childhood cancer: 						*/
/*					Results from the French Childhood Cancer Survivor Study 					*/
/*																								*/
/************************************************************************************************/

/*1.Set up*/
/*Options to speed up processing time*/ 
OPTIONS nofmterr nonotes nosource error=0;
/*Processing time*/
%put Starting compilation of DATA step: %QSYSFUNC(DATETIME(), DATETIME20.3);
%let startTime=%QSYSFUNC(DATETIME());

/*date*/
%let year=%sysfunc(year(%sysfunc(date())));
%let month=%sysfunc(putn(%sysfunc(month(%sysfunc(date()))), Z2.0));
%let day=%sysfunc(putn(%sysfunc(day(%sysfunc(date()))), Z2.0));
%let date=&year.&month.&day;

/*path*/	/*CHANGE PATHS*/
/*databases*/
%let path=C:\Users\b_schwartz\Desktop\Opioides\Bases\GitHub;
/*outputs*/
%let path_out=C:\Users\b_schwartz\Desktop\Opioides\Sorties\GitHub;
/*scripts*/
%let path_script=C:\Users\b_schwartz\Desktop\Opioides\Programmes\GitHub;

/*Libraries*/ 	/*CHANGE LIBRARIES*/
/*Main lib.*/
libname git "&path";
libname op "C:\Users\b_schwartz\Desktop\Opioides\Bases";
libname duree "&path.\duree";
libname prev "&path.\prevalences";
libname indicbin "&path.\indicateurs binaires";
libname traj "&path.\trajectoires";

/*Load script for Sankey plot*/
%include "&path_script.\rawtosankey.sas";
%include "&path_script.\sankey.sas";
%include "&path_script.\sankeybarchart.sas";

/*The TRAJ procedure must be implemented before running this program. More information at: 
https://www.andrew.cmu.edu/user/bjones/
*/

/*Time of study*/
%global start;
%global stop;
%let start = 2006; 
%let stop = 2022;

/*Format*/
proc format;
value TYPEG     1='Nephroblastome  '
                2='Neuroblastome'
                3='Lymphome'
                30='Hodgkin'
                31='LMNH'
                4='Tissus mous'
                5='Os '
                6='Cerveau'
                7='Gonades'
                8='Thyroïde'
                9='Retinoblastome'
                0='Autres' 
				99='Overall';
value sex 	2 = "Women"
			1 = "Men"
			99='Overall';
value sexe 	2 = "Women"
			1 = "Men"
			99='Overall';
value TYPE_BS   1='Nephroblastoma       '
                2='Neuroblastoma'
                3='Lymphoma'
                30='Hodgkin'
                31='LMNH'
                4='Soft tissue sarcoma'
                5='Bone sarcoma'
                6='CNS'
                7='Gonades'
                8='Thyroid'
                9='Retinoblastoma'
                0='Other' 
				99='Overall';
run;
/*2.frequently used macros*/
/*deleting table*/
%macro supp(tab);
proc delete data=&tab;
run;
%mend;
/*saving table*/
%macro svg(tab,repe,nom);
data &repe..&nom;
set &tab;
run;
%mend;
/*sort table*/
%macro tri(tab,var);
proc sort data=&tab;
by &var;
run;
%mend;
/*descriptive statistics for QUALITATIVE variable*/
%macro QL(tab,var,nom,g);
proc freq data=&tab;
table &var;
run;
%if &g=1 %then %do;
	axis3 label=("Effectif");
	axis4 label=(&nom);
	proc gchart data=&tab;
	vbar &var / discrete percent raxis=axis3 maxis=axis4;
	run;
	quit;
%end;
%mend;
/*descriptive statistics for QUANTITATIVE variable*/
%macro QT(tab,var,nom,g);
proc univariate data=&tab;
var &var;
%if &g=1 %then %do;
	axis1 label=("Pourcentage");
	axis2 label=(&nom);
	hist &var / normal vaxis=axis1 haxis=axis2;
%end;
run;
%mend;

/*3.Work databases*/

/*One line per delivery*/
data conso;
set git.conso;
run;
/*One line per patient*/
data opi_2006;
set git.opi_2006;
run;


/*4.Description*/
%include "&path_script.\4A. Macro Descriptif patients non users APRES 290124.sas"; 
%include "&path_script.\4B. Macro Descriptif patients annee APRES 290124.sas"; 

/* A. Donnees Cliniques (ne changent pas au cours du temps)*/
%clin(fccss);
%clin(patients=NonUser);
%clin(opioid, classe = "Opioid"); 			/*Tous les patients ayant pris des opioides au moins une fois dans la periode 2006-2018*/
%clin(psychotropes, classe = "Psychotropic drugs"); /*Tous les patients ayant pris des psychotropes au moins une fois dans la periode 2006-2018*/
%clin(Step2, classe = "Step II opioids"); 			/*Idem*/
%clin(Step3, classe = "Step III opioids"); 			/*Idem*/
%clin(dependance, classe = "dependance"); 			/*Idem*/
/*fusion des resultats*/
data res_clin;
retain factor level;
merge fccss NonUser opioid psychotropes step2 step3 dependance;
by ordre level;
drop ordre;
run;
%tri(res_clin, factor level);
data res_clin;
set res_clin;
by factor;
if first.factor = 0 then factor = "";
run;
/* A bis. Donnees Cliniques des patients ayant pris des psychotropes PAR ANNEE : seuls les patients consommants de l annee N sont inclus*/
%boucle_annee();
/* B. Durees des traitements par indiv par annee*/
%duree_annee();
/* Tables avec les resultats concernant les durees medianes et moyennes*/
%stat_duree(Opioid);
%stat_duree(psychotropes);
%stat_duree(step2);
%stat_duree(step3);
%stat_duree(dependance);
/* C. Tableau recapitulatif : donnees cliniques + durees (sur l'ensemble de la periode) : Tous les patients ayant consomme au moins une fois dans la periode 2006-2018*/
%sortie_clin_duree();
/* C bis. Tableau recapitulatif : donnees cliniques + durees (PAR ANNEE) : seuls les patients consommants de l annee N sont inclus*/
%insert_result();
/*Suppression des bases temporaires*/
proc datasets nolist lib=duree kill;
quit;


/*5. Annual prevalence*/
%include "&path_script.\5. Prevalence.sas";
/* A. Calcul des PY*/
/*Tout analgesique*/
%py(nom = analgesique,debut = 1);
%py(nom = analgesique,debut = 1, groupe = sexe);
/*Par classe et groupe*/
%py(classe = "opioid", nom = opioid);
%py(classe = "Step II opioids", nom = S2);
%py(classe = "Step III opioids", nom = S3);
%py(classe = "opioid", nom = opioid, groupe = sexe);
%py(classe = "Step II opioids", nom = S2, groupe = sexe);
%py(classe = "Step III opioids", nom = S3, groupe = sexe);
/* B. Graphiques*/
/*Total*/
%graph_prev(nom = opioid);
%graph_prev(nom = S2);
%graph_prev(nom = S3);
%graph_prev_OP();
/*Selon le sexe*/
%graph_prev(nom = opioid, groupe = sexe, total = 0);
%graph_prev(nom = S2, groupe = sexe, total = 0);
%graph_prev(nom = S3, groupe = sexe, total = 0);
%graph_prev(nom = opioid, groupe = sexe, total = 1);
%graph_prev(nom = S2, groupe = sexe, total = 1);
%graph_prev(nom = S3, groupe = sexe, total = 1);


/*6. Binary indicators per year*/

/* Par annee */
%macro indic_annee(classe = ., nom = ., annee_fin=&stop);
/*On cree la base avec tous les patients chaines retenus pour l etude (n=5582)*/
proc sql;
create table opioides as
select *
from opi_2006;
quit;
%do annee = &start %to &annee_fin;
	/*Base avec les consommants de la periode*/
	%if &classe ne . %then %do;
		proc sql;
		create table ident as
		select distinct(num_enq)
		from conso
		where (classe = &classe) 
		and (annee_trt = &annee) 
		and	(num_enq in(select num_enq 
							from opi_2006
							));
		create table opioides_&annee as
		select *
		from opioides
		where num_enq in(select num_enq
						from ident
						);
		quit;	
	%end;
	%if &classe = "opio" %then %do;
		proc sql;
		create table ident as
		select distinct(num_enq)
		from conso
		where (classe = "Step II opioids") or (classe = "Step III opioids") 
		and (annee_trt = &annee) 
		and	(num_enq in(select num_enq 
							from opi_2006
							));
		create table opioides_&annee as
		select *
		from opioides
		where num_enq in(select num_enq
						from ident
						);
		quit;	
	%end;
	/*On ajoute l indicateur de consommation sur l annee*/
	data indicbin.&nom._&annee;
	set opioides_&annee;
	&nom._&annee = 1;
	keep num_enq &nom._&annee;
	run;
	/*On fusionne avec le reste de patients de la cohorte*/
	proc sql;
	create table autres as
	select distinct(num_enq)
	from opioides
	where num_enq not in(select num_enq
						from indicbin.&nom._&annee
						);
	quit;
	data indicbin.&nom._&annee;
	set indicbin.&nom._&annee autres;
	/*On ajoute l indicateur pour les non consommants de l annee*/
	if &nom._&annee ne 1 then &nom._&annee = 0;
	run;
	%tri(indicbin.&nom._&annee, num_enq);
%end;
dm "log;clear;";
%mend;
%indic_annee(classe = "Step II opioids", nom = S2);
%indic_annee(classe = "Step III opioids", nom = S3);
%indic_annee(classe = "opioid", nom = opioid);

/*Fusion des tables*/
%macro fusion_indic_annee(nom, annee_fin=&stop);
%do annee = &start %to &annee_fin;
	%tri(indicbin.&nom._&annee, num_enq);
%end;
data &nom;
merge indicbin.&nom._&start.-indicbin.&nom._&annee_fin;
by num_enq;
run;
%mend;
%fusion_indic_annee(nom = S2);
%fusion_indic_annee(nom = S3);
%fusion_indic_annee(nom = opioid);

data indicbin.indic_annee;
merge S2 S3 opioid ;
by num_enq; 
base = "ok";
run;
/*On recupere la date de deces*/
data deces;
set opi_2006;
keep num_enq date_deces deces;
run;
%tri(indicbin.indic_annee, num_enq);
%tri(deces, num_enq);
data indicbin.indic_annee;
merge indicbin.indic_annee deces;
by num_enq;
if base = "ok";
drop base;
run;

/*OPIO --> en sommant S2 et S3 dans l annee plutot que de modifier le programme (gain de temps)*/
%macro opio_annnee(annee_fin=&stop);
data indicbin.indic_annee;
set indicbin.indic_annee;
/*Variable de temps pour les analyses de trajectoires*/
%let nb_annees = %eval(%eval(&annee_fin-&start)+1);
%do i = 1 %to &nb_annees;/*car 17 annees*/
	t&i = &i;
%end;
%do j = &start %to &annee_fin;
	if (S2_&j + S3_&j) = 0 then opioid_&j = 0;
	if (S2_&j + S3_&j) gt 0 then opioid_&j = 1;
	/*On met en valeur manquante quand le patient est decede a partir du mois/annee de deces*/
	if &j ge year(date_deces) and date_deces ne . and deces = 1 then do;
		S2_&j = .;
		S3_&j = .;
		opioid_&j = .;
	end;
%end;
run;
dm "log;clear;";
%mend;
%opio_annnee();

/*7.Sankey diagram*/
/*Per year and overall. 10 deliveries max. per period considered. Only in users.*/
%include "&path_script.\7A. Sankey N delivrances.sas";
ods rtf file ="&path_out.\&date._Sankey_10_delivrances_year.rtf";
%sankey_S2S3(classe="opioid",n_cpt=10);
ods rtf close;
%include "&path_script.\7B. Sankey N delivrances overall.sas";
ods rtf file ="&path_out.\&date._Sankey_10_delivrances_overall.rtf";
%boucle_sankey(10);
ods rtf close;
%include "&path_script.\7C. Sankey periodes.sas";
ods rtf file ="&path_out.\&date._Sankey_periods.rtf";
%boucle_sankey_S2S3();
ods rtf close;

/*8. Definition of trajectories*/

/*Not modified. To be adapted for the test dataset that is shorter than the dataset for analyze and anonymized*/
data temp_an;
set indicbin.indic_annee;
run;

/* 	1. On teste le nombre de groupes de trajectoires : 2 methodes :
			a. on fixe les polynomes en puissance 2 et on teste le meilleur modele avec le critere de Bayes et/ou le delta BIC
			b. on choisit le meilleur modele (combinaison de polynomes) pour chaque nombre de groupes. Puis on compare le meilleur des modeles avec les criteres (cf. a)
	2. On calcule l AVEPP et l OCC
*/
/*Macro pour lancer la proc traj et recuperer les resultats + indicateurs (avepp, OCC)*/
%macro traj_trim(classe, ngroups, order);
/*Creation du nom de fichier*/
%let order2 = %sysfunc(compress(&order));
proc traj data = temp_an OUT=OFduree_&order2  OUTPLOT=OPduree_&order2  OUTSTAT=OSduree_&order2  OUTEST=OEduree_&order2  ITDETAIL;
id num_enq;
var 	&classe._2006 &classe._2007 &classe._2008 &classe._2009 &classe._2010 &classe._2011 &classe._2012 &classe._2013 &classe._2014 &classe._2015 &classe._2016 &classe._2017 &classe._2018
		&classe._2019 &classe._2020 &classe._2021 &classe._2022;
indep 	t1-t17;
model 	logit;
ORDER 	&order;
Ngroups &ngroups;
run;
goptions reset = all;
/*On compile les resultats permettant de comparer les modeles dans une seule table*/
data comp1;
retain modele;
set oeduree_&order2;
format modele $20.;
modele = "&order";
if _TYPE_ = "PARMS";
keep  _LOGLIK_ _BIC1_ _BIC2_ _AIC_ _CONVERGE_ modele;
run;
data comp2;
retain modele;
set osduree_&order2;
format modele $20.;
modele = "&order";
if _N_ = 1 then groupe = "G1";
if _N_ = 2 then groupe = "G2";
if _N_ = 3 then groupe = "G3";
if _N_ = 4 then groupe = "G4";
if _N_ = 5 then groupe = "G5";
if _N_ = 6 then groupe = "G6";
if _N_ = 7 then groupe = "G7"; /* On ne teste pas plus de 7 groupes*/
drop beta4 beta5;
run;
%tri(comp1, modele);
%tri(comp2, modele);
data comp;
merge comp1 comp2;
by modele;
if first.modele ne 1 then do;
	_LOGLIK_ = .;
	_BIC1_ = .;
	_BIC2_ = .;
	_AIC_ = .;
	_CONVERGE_ = .;
end;
run;
/*Calcul de l AVEPP*/
%do i = 1 %to &ngroups;
	proc means data = OFduree_&order2;
	var GRP&i.PRB ;
	where group = &i;
	output out = mean_&i;
	run;
%end;
data mean_&ngroups._group;
set mean_1-mean_&ngroups;
if _stat_ = "MEAN";
%do i = 1 %to &ngroups;
	if GRP&i.PRB ne . then do;
		groupe = "G&i";
		avepp = GRP&i.PRB;
	end;
	drop GRP&i.PRB;
%end;
modele = "&order";
drop _type_ _freq_ _stat_ ;
run;
/*Calcul de l OCC*/
data comp3;
set comp2;
keep modele groupe PI;
run;
%tri(comp3, modele groupe);
data mean_&ngroups._group;
merge mean_&ngroups._group comp3;
by modele groupe;
OCC = (avepp/(1-avepp))/(PI/100/(1-PI/100));
run;
%tri(mean_&ngroups._group, modele groupe);
%supp(mean_1-mean_&ngroups);
data traj.nb_groupes_annee_smn_&classe;/*On compile les resultats permettant de comparer les modeles dans une seule table*/
set traj.nb_groupes_annee_smn_&classe comp;
run;
%supp(comp);
%mend;


/*Nombre de groupes : on teste toutes les trajectoires de 1 a 7 groupes, en quadratique*/
data traj.nb_groupes_annee_smn_opioid;
run;
/*Long running time so only the best model will run. Uncomment for run other models*/
/*%traj_trim(opioid,1, 2);
%traj_trim(opioid,2, 2 2);
%traj_trim(opioid,3, 2 2 2);*/
%traj_trim(opioid,4, 2 2 2 2);
/*%traj_trim(opioid,5, 2 2 2 2 2);
%traj_trim(opioid,6, 2 2 2 2 2 2);
%traj_trim(opioid,7, 2 2 2 2 2 2 2);*/

/*La base est triee dans l ordre des modeles les plus simples vers les plus complexes donc le lag correspond au modele null*/
data comp_nb_groupes;
set traj.nb_groupes_annee_smn_opioid;
/*On ne garde qu une ligne par modele*/
if _LOGLIK_ = . then delete;
run;
data comp_nb_groupes2;
set comp_nb_groupes;
format choix_bic choix_jeffrey $9.;
/*by modele;*/
bic_complex = _bic1_;
bic_null = lag(_bic1_);
/*1.*/
deux_delta = 2*(bic_complex - bic_null);
if deux_delta lt 2 						then choix_bic = "non";
if deux_delta ge 2 and deux_delta lt 6 	then choix_bic = "oui";
if deux_delta ge 6 and deux_delta lt 10 then choix_bic = "oui +";
if deux_delta ge 10 					then choix_bic = "oui ++";
if deux_delta = . then choix_bic = "";
/*2.*/
Jeffrey = exp(bic_complex - bic_null);
if jeffrey lt 1/10 						then choix_jeffrey = "non ++";
if jeffrey ge 1/10 and jeffrey lt 1/3 	then choix_jeffrey = "non +";
if jeffrey ge 1/3 and jeffrey lt 1 		then choix_jeffrey = "non";
if jeffrey ge 1 and jeffrey lt 3 		then choix_jeffrey = "oui";
if jeffrey ge 3 and jeffrey lt 10 		then choix_jeffrey = "oui +";
if jeffrey ge 10 						then choix_jeffrey = "oui ++";
/*On attribue la valeur nulle quand ce n est pas la premiere ligne du modele (2 lignes par modele)*/
if jeffrey = . 		then choix_jeffrey = "";
if deux_delta = . 	then choix_bic = lag(choix_bic);
if jeffrey = . 		then choix_jeffrey = lag(choix_jeffrey);
run;

%tri(comp_nb_groupes2, modele groupe);
data comp_nb_groupes3;
merge comp_nb_groupes2 /*mean_1_group mean_2_group mean_3_group */mean_4_group /*mean_5_group mean_6_group mean_7_group*/;
by modele groupe;
drop alpha0-alpha5 beta3;
run;

%svg(comp_nb_groupes3, traj, selection_nb_grp_OPIOID_smn4)

/*4 GROUPES*/
/*Pas a pas descendant*//*On demarre avec 1 ordre le plus eleve et on procede en pas a pas descendant en reduisant les polynomes d un ordre a chaque etape*/
/*%traj_trim(opioid,4,5 5 5 5);
%traj_trim(opioid,4,5 5 5 4);
%traj_trim(opioid,4,5 5 5 3);
%traj_trim(opioid,4,5 5 5 2);*/
%traj_trim(opioid,4,5 5 4 2);

/*Calcul Prob avepp Pj : posterior probability of group membership*/
%macro prob_avepp();
proc sql;
select count(*) into: tot
from ofduree_5542;
create table p_avepp1 as
select sum(grp1prb) as p_avepp
from ofduree_5542;
create table p_avepp2 as
select sum(grp2prb) as p_avepp
from ofduree_5542;
create table p_avepp3 as
select sum(grp3prb) as p_avepp
from ofduree_5542;
create table p_avepp4 as
select sum(grp4prb) as p_avepp
from ofduree_5542;
quit;
data p_avepp1;
set p_avepp1;
groupe = "G1";
run;
data p_avepp2;
set p_avepp2;
groupe = "G3";/*On a inverse 2 et 3*/
run;
data p_avepp3;
set p_avepp3;
groupe = "G2";
run;
data p_avepp4;
set p_avepp4;
groupe = "G4";
run;
data p_avepp;
set p_avepp1-p_avepp4;
%let total = %sysfunc(PUTn(&tot,8.));
format total 8.;
total = &total;
prop_avepp = (p_avepp/total)*100;
keep groupe prop_avepp;
run;
%mend;
%prob_avepp();

/*Frequence des groupes determines (pi)j : actual proportion of subjects assigned to each trajectory group using the maximum probability rule*/
proc freq data = ofduree_5542;
table group / out= test;
run;
data test;
set test;
/*On switche G2 et G3 en utilisante le G9 inutilise*/
if group = 2 then group = 9;
if group = 3 then group = 2;
if group = 9 then group = 3;
if group = 1 then groupe = "G1";
if group = 2 then groupe = "G2";
if group = 3 then groupe = "G3";
if group = 4 then groupe = "G4";
rename count = effectif;
keep groupe percent count;
run;

/*Fusion avec la table de statistiques*/
%tri(mean_4_group, groupe);
%tri(p_avepp, groupe);
%tri(test, groupe);
data mean_4_group;
merge mean_4_group p_avepp test;
by groupe;
OCC = round(occ,0.1);
prop_avepp = round(prop_avepp,0.1);
avepp = round(avepp,0.01);
percent = round(percent,0.1);
drop PI;
run;

/*On fait tourner la macro pour avoir les resultats compiles et l avepp + OCC et on les enregistre dans le repertoire TRAJ*/
%svg(mean_4_group,traj,best_annee_bin_opioid_smn4)

/*On recupere la variable correspondant au groupe attribue a chaque patient d apres le modele de trajectoires*/
data traj.group_annee_bin_opioid_smn4;
set OFduree_5542; /*Indiquer l ordre du meilleur modele*/
keep num_enq group;
run;

ods rtf file = "&path_out.\&date._Annee_Bin_opioid_smn4.rtf";
options orientation=landscape;
/*Mise en forme de l axe des abscisses avec les annees*/
data OPduree_5542_b;
set OPduree_5542;
t = t + 2005;
format t 5.;
run;
/*On rearrange l ordre des groupes*/
data test_graph;
set OPduree_5542_b;
/*On switche le 2 et le 3 en utilisant un groupe intermediaire inutilise (9)*/
avga = AVG2;
preda = PRED2;
L95Ma = L95M2;
U95Ma = U95M2;
avgb = AVG3;
predb = PRED3;
L95Mb = L95M3;
U95Mb = U95M3;
avg3 = AVG1;
pred3 = PRED1;
L95M3 = L95M1;
U95M3 = U95M1;
avg2 = AVGb;
pred2 = PREDb;
L95M2 = L95Mb;
U95M2 = U95Mb;
avg1 = AVGa;
pred1 = PREDa;
L95M1 = L95Ma;
U95M1 = U95Ma;
drop avga preda l95ma u95ma avgb predb l95mb u95mb;
run;
data test_graph2;
set OSduree_5542;
n = _n_;
run;
proc sql;
create table temp_but_3 as 
select *
from test_graph2 
where n ne 1;
create table temp_3 as
select *
from test_graph2
where n = 1;
quit;
data temp_but_3;
set temp_but_3;
if n = 2 then n = 1;
if n = 3 then n = 2;
run;
data temp_3;
set temp_3;
n = 3;
run;
data temp_graph3;
set temp_but_3 temp_3;
run;
%tri(temp_graph3, n);
data temp_graph3;
set temp_graph3;
drop n;
run;
/*On met sur la figure les % de patients au lieu des mixtures % (proba)*/
data temp_graph3;
set temp_graph3;
drop pi;
run;
data temp_graph3;
merge temp_graph3 mean_4_group;
keep beta0-beta5 percent;
rename percent = pi;
run;
%tri(temp_graph3,descending pi);
%trajplotnew(test_graph,temp_graph3,,,"Dispensation","Year");
data mean_4_report;
set mean_4_group;
if groupe = "G1" then groupe = "Z";
if groupe = "G3" then groupe = "G1";
if groupe = "Z" then groupe = "G3";
run;
%tri(mean_4_report, groupe);

proc report data = mean_4_report
	style(report)=[borderrightcolor=white borderleftcolor=white background=white ]
	style(summary)=[frame=void background=white ]
	style(report column header summary)=[background=white borderrightcolor=white borderleftcolor=white];

column 	groupe effectif avepp modele OCC prop_avepp percent
       ;
run;
ods rtf close;

/*9. Regression multinomiale*/
%include "&path_script.\9. Macro sortie multinomiale.sas";

%macro donnees_multin(classe, G1=, G2=, G3="", G4="");
/*On ajoute les groupes dans la base avec les autres donnees*/
%tri(traj.group_annee_bin_&classe, num_enq);
%tri(opi_2006, num_enq);
data multin_&classe; /*NOTE: an error appears in log but seems to be a false error*/
merge traj.group_annee_bin_&classe opi_2006;
by num_enq;
format group_multin $15. ttt_era ttt_era_b. sexe sex.;
if group = 1 then group_multin = &G2;
if group = 2 then group_multin = &G1;
if group = 3 then group_multin = &G3;
if group = 4 then group_multin = &G4;
age_start = (mdy(01,01,&start)-date_nais)/365.25;
drop c_age_diag;
run;
data multin_&classe;
set multin_&classe;
format c_age_diag c_age_start $20.;
age_diag = floor((date_diag - date_nais)/365.25);
if age_diag lt 0 then age_diag = 0;
age_start = floor(age_start);
/*classes d age au diagnostic*/
if age_diag gt 14 						then c_age_diag = "E 15 and more"; 
if age_diag le 3 						then c_age_diag = "A 0-3";
if age_diag gt 3 and age_diag le 8 		then c_age_diag = "B 4-8";
if age_diag gt 8 and age_diag le 11 	then c_age_diag = "C 9-11";
if age_diag gt 11 and age_diag le 14 	then c_age_diag = "D 12-14";
/*classes d age au 01/01/2006*/
if age_start gt 40 						then c_age_start = "E More than 40";
if age_start le 10						then c_age_start = "A 0-10";
if age_start gt 10 and age_start le 20 	then c_age_start = "B 11-20";
if age_start gt 20 and age_start le 30 	then c_age_start = "C 21-30";
if age_start gt 30 and age_start le 40 	then c_age_start = "D 31-40";
if diabete = . then diabete = 0;
run;
proc sql;
create table multin_&classe as
select *
from multin_&classe
where num_enq in(select num_enq 
				 from opi_2006);
quit;
%mend;
%donnees_multin(opioid_smn4, G1="No/few delivery", G2="Increase", G3="Decrease", G4="High delivery");
%svg(multin_opioid_smn4,git,multin_opioid_smn4);
/*Regression multinomiale*/
data analyse;
set git.multin_opioid_smn4;
if ttt_era = "E 1990 and more" then ttt_era = "1990 and more";
if ttt_era = "C 1980-1989" then ttt_era = "1980-1989";
if ttt_era = "A before 1980" then ttt_era = "before 1980";
exit_date = mdy(12,31,&stop);
if deces = 1 and date_deces ne . then exit_date = date_deces;/**/
fup = (exit_date - date_diag)/365.25;if fup ge 50 				then c_fup = "E 50 and more";
if fup ge 20 and fup lt 30 	then c_fup = "B 20-29";
if fup ge 30 and fup lt 40 	then c_fup = "C 30-39";
if fup ge 40 and fup lt 50 	then c_fup = "D 40-49";
if fup lt 20 				then c_fup = "A <20 ";
format type_bs typeg.;
if typeg = 4 then type_bs = 4;
if typeg = 5 then type_bs = 5;
if typeg ne 5 and typeg ne 4 then type_bs = 0;
format ct $4. rt $4.;
if chimiotherapie = 0 then ct = "No";
if chimiotherapie = 1 then ct = "Yes";
if radiotherapie = 0 then rt = "No";
if radiotherapie = 1 then rt = "Yes";
k2_before_end = 0;
drop ttt_era;
run;
%tri(analyse nodupkey, num_enq ctr);
/*Recuperation ttt_era*/
data analyse;
set analyse;
format ttt_era $30.;
annee_diag = year(date_diag);
if annee_diag ge 2000 							then ttt_era = "1990 and more";/*regroupement de classes*/
if annee_diag ge 1970 and annee_diag lt 1980 	then ttt_era = "before 1980";
if annee_diag ge 1980 and annee_diag lt 1990 	then ttt_era = "1980-1989";
if annee_diag ge 1990 and annee_diag lt 2000 	then ttt_era = "1990 and more";
if annee_diag lt 1970 							then ttt_era = "before 1980";
/*format*/
format trt $20.;
if trt = "A Surgery on" then trt = "Surgery only";
if trt = "B RT no CT" 	then trt = "RT no CT";
if trt = "C CT no RT" 	then trt = "CT no RT";
if trt = "D CT and RT" 	then trt = "CT and RT";
run;

/*MODELE RETENU*/
ods output ParameterEstimates=aa OddsRatios=ab ModelANOVA=ac modelanova=global ResponseProfile=eff;
proc logistic data = analyse;
class 	group_multin(ref="No/few delivery") sexe(ref="Men") ttt_era(ref="1990 and more") chir(ref="Other") trt(ref="Surgery only")
		/*c_dose_moy(ref="A None")*/
		card_before_end(ref="0") diabete(ref="0") renal_before_end(ref="0") k2_before_end(ref="0") c_age_start(ref="E More than 40")
		type_bs(ref="Autres") tabac(ref="0") alcool(ref="0") fdep13_Q(ref="0")
		/ param = ref;
model group_multin = sexe type_bs ttt_era trt chir card_before_end diabete renal_before_end k2_before_end age_diag c_age_start tabac alcool fdep13_Q/link = glogit;
run;
%sortie_multin(multinomiale_annee_OPIOID_age_cont_FINAL_FDEP);

/*10. Description des groupesde trajectoires*/
%include "&path_script.\10. Descriptif groupes trajectoires.sas";
%clin_traj(1);
%clin_traj(2);
%clin_traj(3);
%clin_traj(4);

/*fusion des resultats*/
data res_clin;
retain factor level;
merge G1 G2 G3 G4;
by ordre level;
drop ordre;
run;
%tri(res_clin,factor level );
data res_clin;
set res_clin;
by factor;
if first.factor = 0 then factor = "";
run;


/*Tableau recapitulatif*/
options mprint mlogic;
options orientation=landscape;
ods rtf file="&path_out.\&date._descriptif_groupe_trajectoire.rtf"
              style=statistical fontscale=85
              nogfootnote nogtitle;
title "Table XX - Patients characteristics - Consumers from &start. to &stop";
proc report data = res_clin
	style(report)=[borderrightcolor=white borderleftcolor=white background=white ]
	style(summary)=[frame=void background=white ]
	style(report column header summary)=[background=white borderrightcolor=white borderleftcolor=white];

column 	factor
		level
		("G1" (
		("N" COUNT_1)
      	("%" PERCENT_1)))
		("G2" (
		("N" COUNT_2)
      	("%" PERCENT_2)))
		("G3"(
		("N" COUNT_3)
      	("%" PERCENT_3)))
		("G4" (
		("N" COUNT_4)
      	("%" PERCENT_4)))
       ;
run;
footnote;
ods rtf close;

/*Processing time*/ /*380 sec*/
%let endTime=%QSYSFUNC(DATETIME());
%put endTime %QSYSFUNC(DATETIME(), DATETIME20.3);
%let timeDiff=%sysevalf(&endTime-&startTime);
%put 'The Compile time for this program is approximately ' &timeDiff. 'seconds';  
