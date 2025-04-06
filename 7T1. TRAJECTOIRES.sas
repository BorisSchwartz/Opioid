

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

/*1. TOUT OPIOIDE*/
/*****************/

/*Nombre de groupes : on teste toutes les trajectoires de 1 a 7 groupes, en quadratique*/
data traj.nb_groupes_annee_smn_opioid;
run;
%traj_trim(opioid,1, 2);
%traj_trim(opioid,2, 2 2);
%traj_trim(opioid,3, 2 2 2);
%traj_trim(opioid,4, 2 2 2 2);
%traj_trim(opioid,5, 2 2 2 2 2);
%traj_trim(opioid,6, 2 2 2 2 2 2);
%traj_trim(opioid,7, 2 2 2 2 2 2 2);

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
merge comp_nb_groupes2 mean_1_group mean_2_group mean_3_group mean_4_group mean_5_group mean_6_group mean_7_group;
by modele groupe;
drop alpha0-alpha5 beta3;
run;

%svg(comp_nb_groupes3, traj, selection_nb_grp_OPIOID_smn4)

/*5 GROUPES*/
/*Pas a pas descendant*//*On demarre avec 1 ordre le plus eleve et on procede en pas a pas descendant en reduisant les polynomes d un ordre a chaque etape*/
%traj_trim(opioid,4,5 5 5 5);
%traj_trim(opioid,4,5 5 5 4);
%traj_trim(opioid,4,5 5 5 3);
%traj_trim(opioid,4,5 5 5 2);
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
