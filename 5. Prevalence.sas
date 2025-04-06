/*Prevalences annuelles*/

/*Prevalence = sum(nb_patients avec une prescription ou + ans l annee)/sum(py de l annee) ; On garde tous les patients de la cohorte pour effectuer ce calcul, obv*/

/*Calcul des PY :
					si patient toujours vivant a la fin de l annee = 1
					si patient decede durant l annee = prorata du temps effectue dans l annee*/

data conso_temp;
set conso;
/*Date_max = date_max + 30*/
date_30_trt = date_trt + 30;
/*On supprime les conso apres l annee fin*/
if annee_trt gt &stop then delete;
run;
/*On ajoute l info sur les dates de deces dans la base*/
proc sql;
create table temp2 as
select num_enq, date_deces, deces, date_nais, sexe, typeg
from opi_2006;
quit;
data temp;
merge conso_temp temp2;
by num_enq;
format sexe sex.;
format type_bs type_bs.;
if typeg = 4 then type_bs = 4;
if typeg = 5 then type_bs = 5;
if typeg ne 5 and typeg ne 4 then type_bs = 0;
run;
proc sql;
create table temp as
select *
from temp 
where num_enq in(select num_enq
				 from opi_2006);
quit;

%macro py(classe = ., nom = ., debut = 0, groupe = ., annee_fin=&stop); /*&debut --> pour reinitialiser la table de resultats totaux
																			&groupe = pour avoir les prevalences par strate (sexe...)*/
/*On ne garde que les prescriptions qui nous interessent*/
%if &groupe = . %then %do;
	%do annee = &start %to &annee_fin;
		data conso_temp;
		set temp;
		annee = year(date_trt);
		conso_&annee = 1;
		/*Calcul de l age dans l annee et definition des classes*/
		age_&annee = floor(((mdy(06,30,&annee)-date_nais)/365.25));
		if age_&annee lt 20 						then c_age = 0;
		if age_&annee ge 20 and age_&annee lt 40 	then c_age = 1;
		if age_&annee ge 40 and age_&annee lt 60 	then c_age = 2;
		if age_&annee ge 60 						then c_age = 3;
		%if &classe ne . %then %do;
			%if &classe ne "opioid" %then %do;
				if classe ne &classe then conso_&annee = 0;
			%end;
			%if &classe = "opioid" %then %do;
				if classe = "Psychotropic drugs" then conso_&annee = 0;
			%end;
		%end;
		/*On ne garde que les dates de traitement de l annee qui nous interesse*/
		if annee ne &annee then date_trt_&annee = .;
		else date_trt_&annee = date_trt;
		/*Pour les patients sans prescriptions dans l annee (i.e. date_trt = .), on attribue l annee etudiee*/
		if date_trt = . then annee = &annee;
		/*Calcul des PY*/
		py = 1;
		annee_deces = year(date_deces);
		if deces = 1 and annee_deces = &annee then do;
			py = (date_deces-mdy(01,01,&annee))/365.25;
		end;
		if deces = 1 and annee_deces lt &annee then py = 0;

		/*Si pas de date_trt alors pas de conso dans l annee*/
		if date_trt_&annee = . then do;
			conso_&annee = 0;
			annee = &annee;
		end;
		run;
		/*Une table par individu (au lieu d une table par prescription)*/
		proc sql;
		create table tab_indiv_&annee as
		select num_enq, annee, max(conso_&annee) as conso_annee, max(py) as py_annee
		from conso_temp
		group by num_enq, annee;
		quit;
		/*Table avec les donnees de prevalence sur l annee*/
		proc sql;
		create table prev_&annee as
		select distinct(annee), sum(conso_annee) as nb_conso_&nom, sum(py_annee) as nb_py, sum(conso_annee)/sum(py_annee) as prevalence_&nom
		from tab_indiv_&annee
		where annee = &annee;
		quit;
	%end;
	/*Fusion des resultats dans une table*/
	data prev.prev_&nom; /*On enregistre les tables individuelles pour faciliter les calculs selon les types S2/S3*/
	set prev_2006-prev_&annee_fin;
	cat = "&nom";
	prev = prevalence_&nom;
	run;
	%do annee = &start %to &annee_fin;
		%supp(prev_&annee);
		%supp(tab_indiv_&annee);
	%end;
	/*On fusionne tous les resultats dans une seule table*/
	%if &debut = 1 %then %do;
		data prev.prev_totales;
		set prev.prev_&nom;
		drop cat prev;
		run;
	%end;
	%if &debut = 0 %then %do;
		data prev.prev_totales;
		merge prev.prev_totales prev.prev_&nom;
		by annee;
		drop cat prev;
		run;
	%end;
	/*%supp(prev_&nom);*/
%end;
%if &groupe ne . %then %do;
	%do annee = &start %to &annee_fin;
		data conso_temp;
		set temp;
		annee = year(date_trt);
		conso_&annee = 1;
		/*Calcul de l age dans l annee et definition des classes*/
		age_&annee = floor(((mdy(06,30,&annee)-date_nais)/365.25));
		if age_&annee lt 20 						then c_age = 0;
		if age_&annee ge 20 and age_&annee lt 40 	then c_age = 1;
		if age_&annee ge 40 and age_&annee lt 60 	then c_age = 2;
		if age_&annee ge 60 						then c_age = 3;
		%if &classe ne . %then %do;
			%if &classe ne "opioid" %then %do;
				if classe ne &classe then conso_&annee = 0;
			%end;
			%if &classe = "opioid" %then %do;
				if classe = "Psychotropic drugs" then conso_&annee = 0;
			%end;
		%end;
		/*On ne garde que les dates de traitement de l annee qui nous interesse*/
		if annee ne &annee then date_trt_&annee = .;
		else date_trt_&annee = date_trt;
		/*Pour les patients sans prescriptions dans l annee (i.e. date_trt = .), on attribue l annee etudiee*/
		if date_trt = . then annee = &annee;
		/*Calcul des PY*/
		py = 1;
		annee_deces = year(date_deces);
		if deces = 1 and annee_deces = &annee then do;
			py = (date_deces-mdy(01,01,&annee))/365.25;
		end;
		if deces = 1 and annee_deces lt &annee then py = 0;

		/*Si pas de date_trt alors pas de conso dans l annee*/
		if date_trt_&annee = . then do;
			conso_&annee = 0;
			annee = &annee;
		end;
		run;
		/*Une table par individu (au lieu d une table par prescription)*/
		proc sql;
		create table tab_indiv_&annee as
		select num_enq, annee, max(conso_&annee) as conso_annee, max(py) as py_annee, &groupe
		from conso_temp
		group by num_enq, annee, &groupe;
		quit;
		/*Table avec les donnees de prevalence sur l annee*/
		proc sql;
		create table prev_&annee as
		select annee,&groupe, sum(conso_annee) as nb_conso_&nom, sum(py_annee) as nb_py, sum(conso_annee)/sum(py_annee) as prevalence_&nom
		from tab_indiv_&annee
		where annee = &annee
		group by &groupe;
		quit;
		%tri(prev_&annee nodupkey, annee &groupe);
	%end;
	/*Fusion des resultats dans une table*/
	data prev_&nom._&groupe;
	set prev_2006-prev_&annee_fin;
	run;
	%do annee = &start %to &annee_fin;
		%supp(prev_&annee);
		%supp(tab_indiv_&annee);
	%end;
	/*On fusionne tous les resultats dans une seule table*/
	%if &debut = 1 %then %do; /* Initialisation*/
		data prev.prev_totales_&groupe;
		format &groupe &groupe..;
		set prev_&nom._&groupe;
		run;
	%end;
	%if &debut = 0 %then %do;
		data prev.prev_totales_&groupe;
		merge prev.prev_totales_&groupe prev_&nom._&groupe;
		by annee &groupe;
		run;
	%end;
	%supp(prev_&nom._&groupe);
%end;
%mend;


/*GRAPHIQUE TOTAL ET PAR categorie*/
%macro graph_prev(nom = ., total = 0, groupe = ., annee_fin=&stop); /*&total = pour mettre l incidence totale avec 
													 &groupe = pour avoir les prevalences par strate (sexe...)*/
%if &groupe = . %then %do;
	data graph;
	set prev.prev_totales ;
	prev = prevalence_&nom*100;
	prev_ceil = ceil(prev);
	run;
	proc sql;
	select max(prev_ceil) into:max_prev
	from graph;
	quit;
	options orientation=landscape;
	ods rtf file = "&path_out.\&date._prevalence_&nom..rtf"
	              style=statistical fontscale=85  
	              nogfootnote;
	*ods graphics on /LINEPATTERNOBSMAX=55600;
	proc sgplot data = graph noautolegend;
	title "Annual prevalence of &nom. use from 2006 to &annee_fin";
	series x = annee y = prev / name="p" lineattrs=(thickness=2) LINEATTRS=(pattern=solid) legendlabel="&nom";
	/*scatter x = annee y = prev / MARKERATTRS=(SYMBOL=-);*/
	XAXIS 	DISPLAY=(NOTICKS)
			VALUES = (2006 to &annee_fin by 1)
			label="Year"
			valueattrs=(color=Black size=9pt);
	YAXIS 	label="Prevalence (%)"
			VALUES = (0 to &max_prev by 1)
	        Max=0
			Min=20
			valueattrs=(color=Black size=9pt);
	KEYLEGEND "p" / NOBORDER; 
	run;
	ods rtf close;
%end;
%if &groupe ne . %then %do;
	data graph;
	format &groupe &groupe..;
	format sexe sex.;
	set prev.prev_totales_&groupe ;
	prev = prevalence_&nom*100;
	prev_ceil = ceil(prev);
	run;
	proc sql;
	select max(prev_ceil) into:max_prev
	from graph;
	quit;
	%if &total = 1 %then %do;
		data graph2;
		format &groupe &groupe..;
		format sexe sex.;
		set prev.prev_totales ;
		prev = prevalence_&nom*100;
		&groupe = 99;
		run;
		data graph;
		set graph graph2;
		run;
		%supp(graph2);
	%end;	
	options orientation=landscape;
	ods rtf file = "&path_out.\&date._prevalence_&nom._&groupe._&total..rtf"
	              style=statistical fontscale=85  
	              nogfootnote;
	*ods graphics on /LINEPATTERNOBSMAX=55600;
	proc sgplot data = graph noautolegend;
	title "Annual prevalence of &nom. use from 2006 to &annee_fin";
	series x = annee y = prev / group=&groupe name="p" lineattrs=(thickness=2) LINEATTRS=(pattern=solid) legendlabel="&nom";
	/*scatter x = annee y = prev / group=&groupe MARKERATTRS=(SYMBOL=none);*/
	XAXIS 	DISPLAY=(NOTICKS)
			VALUES = (2006 to &annee_fin by 1)
			label="Year"
			valueattrs=(color=Black size=9pt);
	YAXIS 	label="Prevalence (%)"
			VALUES = (0 to %eval(&max_prev+1) by 1)
	        Max=0
			Min=20
			valueattrs=(color=Black size=9pt);
	KEYLEGEND "p" / NOBORDER; 
	run;
	ods rtf close;
%end;
%mend;



/*S2 + S3 + Tout Opioide*/
%macro graph_prev_OP(annee_fin=&stop);
data graph;
format cat $16.;
set prev.prev_opioid prev.prev_S2 prev.prev_S3;
prev = prev*100;
prev_ceil = ceil(prev);
if cat = "opioid" then cat = "All opioid users";
if cat = "S2" then cat = "Step II users";
if cat = "S3" then cat = "Step III users";
keep cat annee prev prev_ceil;
run;
proc sql;
select max(prev_ceil) into:max_prev
from graph;
quit;

options orientation=landscape;
ods rtf file = "&path_out.\&date._prevalence_Opioid_drugs.rtf"
              style=statistical fontscale=85  
              nogfootnote;
*ods graphics on /LINEPATTERNOBSMAX=55600;
proc sgplot data = graph noautolegend;
title "Annual prevalence of opioid drugs use from &start. to &annee_fin";
series x = annee y = prev / group=cat name="p" lineattrs=(thickness=2) LINEATTRS=(pattern=solid) legendlabel="Drugs";
/*scatter x = annee y = prev / group=cat MARKERATTRS=(SYMBOL=diamondfilled);*/
XAXIS 	DISPLAY=(NOTICKS)
		VALUES = (2006 to &annee_fin by 1)
		label="Year"
		valueattrs=(color=Black size=9pt);
YAXIS 	label="Prevalence (%)"
		VALUES = (0 to %eval(&max_prev+2) by 2)
        Max=0
		Min=20
		valueattrs=(color=Black size=9pt);
KEYLEGEND "p" / NOBORDER; 
run;
ods rtf close;
%mend;


