
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

/*Probleme avec OPIO --> on le regle en sommant S2 et S3 dans l annee plutot que de modifier le programme (gain de temps)*/
%macro pb_annnee(annee_fin=&stop);
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
%pb_annnee();

