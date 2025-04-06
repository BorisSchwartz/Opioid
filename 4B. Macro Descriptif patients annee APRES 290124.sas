/*Descriptif par annee*/

%macro desc_annee(patients, classe = ., sous_classe = ., annee = .);
/*On cree la base avec tous les patients chaines retenus pour l etude*/
proc sql;
create table opioides as
select *
from opi_2006;
quit;

	%if &classe ne . %then %do;
		/*Si la classe renseignee est differente de "Opioid" alors on utilise la classe renseignee*/
		%if &classe ne "Opioid" %then %do;
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
		/*Si la classe renseignee est "Opioid" alors on utilise toutes les lignes qui ne sont pas des pyschotropes (car la base = psychotropes + opioides)*/
		%if &classe = "Opioid" %then %do;
			proc sql;
			create table ident as
			select distinct(num_enq)
			from conso
			where (classe ne "Psychotropic drugs") 
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
	%end;
	%if &sous_classe ne . %then %do;
		proc sql;
		create table ident as
		select distinct(num_enq)
		from conso
		where (sous_classe = &sous_classe) 
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
	/*Table donnees cliniques*/
	data clin_&annee;
	set opioides_&annee;
	exit_date = mdy(12,31,&stop);
	if deces = 1 then exit_date = date_deces;
	fup = (exit_date - date_diag)/365.25;
	if fup ge 50 				then c_fup = "E 50 and more";
	if fup ge 20 and fup lt 30 	then c_fup = "B 20-29";
	if fup ge 30 and fup lt 40 	then c_fup = "C 30-39";
	if fup ge 40 and fup lt 50 	then c_fup = "D 40-49";
	if fup lt 20 				then c_fup = "A <20 ";
	att_age = (exit_date - date_nais)/365.25;
	if att_age ge 50 					then c_att_age = "E 50 and more";
	if att_age ge 20 and att_age lt 30 	then c_att_age = "A <20 ";/*On regroupe A et B*/
	if att_age ge 30 and att_age lt 40 	then c_att_age = "C 30-39";
	if att_age ge 40 and att_age lt 50 	then c_att_age = "D 40-49";
	if att_age lt 20 					then c_att_age = "A <20 ";
	run;

	/*sexe*/
	%ql(clin_&annee noprint, sexe/out=a);
	/*agediag*/
	%ql(clin_&annee noprint, c_age_diag/out=b);
	/*ttt_era*/
	%ql(clin_&annee noprint, ttt_era/out=c);
	/*fup*/
	%ql(clin_&annee noprint, c_fup/out=d);
	/*Attained age*/
	%ql(clin_&annee noprint, c_att_age/out=e);
	/*fpn*/
	%ql(clin_&annee noprint, typeg_clair/out=f);
	%ql(clin_&annee noprint, type_bs_clair/out=fa);

	/*treatment*/
	%ql(clin_&annee noprint, trt/out=g);
	%ql(clin_&annee noprint, rt/out=rt);
	%ql(clin_&annee noprint, ct/out=ct);
	/*Overall*/
	%ql(clin_&annee noprint, dummy_overall/out=h);
	/*Chirurgie*/
	%ql(clin_&annee noprint, chir/out=i);

	/*Comorbidites*/
	%ql(clin noprint, card_before_end/out=n);
	%ql(clin noprint, renal_before_end/out=o);
	%ql(clin noprint, diabete/out=p);

	/*Doses cerv*/
	%ql(clin noprint, rt_brain/out=rt_b);
	%ql(clin noprint, c_vol_5/out=q);
	%ql(clin noprint, c_vol_20/out=r);
	%ql(clin noprint, c_vol_30/out=s);
	%ql(clin noprint, c_vol_40/out=t);
	%ql(clin noprint, c_d05_cerv/out=u);
	%ql(clin noprint, c_d95_cerv/out=v);

	/*CT*/
	%ql(clin noprint, anthra/out=ct1);
	%ql(clin noprint, alkyl/out=ct2);
	%ql(clin noprint, cisp/out=ct3);
	%ql(clin noprint, doxo/out=ct4);
	%ql(clin noprint, dauno/out=ct5);	
	%ql(clin noprint, vinca/out=ct6);	


	/*FDEP*/
	%ql(clin noprint, fdep13_Q/out=fdep);

	/*tabac alcool*/
	%ql(clin noprint, tabacYN/out=hab1);
	%ql(clin noprint, alcoolYN/out=hab2);
	/**/
	/*Age diag*/
	proc univariate data = clin_&annee noprint;
	var age_diag;
	output out = kQ1 Q1=age_diag_Q1;
	output out = kQ2 median=age_diag_median;
	output out = kQ3 Q3=age_diag_Q3;
	output out = kmoy mean=age_diag_moy;
	output out = kET STD=age_diag_ET;
	run;
	data k1_mediane;
	retain level count_&patients percent_&patients;
	format percent_&patients $15.;
	merge kQ1 kQ2 kQ3;
	factor = "Median age at diagnosis, in years (IQR)";
	level = "";
	count_&patients = round(age_diag_median, 1);
	percent_&patients = cats("(",round(age_diag_Q1,1),"-",round(age_diag_Q3,1),")");
	ordre = 10;
	keep level count_&patients percent_&patients ordre factor;
	run;
	data k1_moy;
	retain level count_&patients percent_&patients;
	format percent_&patients $15.;
	merge kmoy kET;
	factor = "Mean age at diagnosis, in years (SD)";
	level = "";
	count_&patients = round(age_diag_moy, 1);
	percent_&patients = cats("(",round(age_diag_ET,1),")");
	ordre = 11;
	keep level count_&patients percent_&patients ordre factor;
	run;
	data K;
	set k1_mediane k1_moy;
	run;

	/*Suivi*/
	proc univariate data = clin_&annee noprint;
	var fup;
	output out = lQ1 Q1=fup_Q1;
	output out = lQ2 median=fup_median;
	output out = lQ3 Q3=fup_Q3;
	output out = lmoy mean=fup_moy;
	output out = lET STD=fup_ET;
	run;
	data l1_mediane;
	retain level count_&patients percent_&patients;
	format percent_&patients $15.;
	merge lQ1 lQ2 lQ3;
	factor = "Median follow-up, in years (IQR)";
	level = "";
	count_&patients = round(fup_median, 1);
	percent_&patients = cats("(",round(fup_Q1,1),"-",round(fup_Q3,1),")");
	ordre = 12;
	keep level count_&patients percent_&patients ordre factor;
	run;
	data l1_moy;
	retain level count_&patients percent_&patients;
	format percent_&patients $15.;
	merge lmoy lET;
	factor = "Mean follow-up, in years (SD)";
	level = "";
	count_&patients = round(fup_moy, 1);
	percent_&patients = cats("(",round(fup_ET,1),")");
	ordre = 13;
	keep level count_&patients percent_&patients ordre factor;
	run;
	data L;
	set l1_mediane l1_moy;
	run;
	%supp(lq1 lq2 lq3 lmoy let l1_mediane l1_moy lmoy_et);

	/*Att_Age*/
	proc univariate data = clin_&annee noprint;
	var att_age;
	output out = lQ1 Q1=fup_Q1;
	output out = lQ2 median=fup_median;
	output out = lQ3 Q3=fup_Q3;
	output out = lmoy mean=fup_moy;
	output out = lET STD=fup_ET;
	run;
	data l1_mediane;
	retain level count_&patients percent_&patients;
	format percent_&patients $15.;
	merge lQ1 lQ2 lQ3;
	factor = "Median attained age, in years (IQR)";
	level = "";
	count_&patients = round(fup_median, 1);
	percent_&patients = cats("(",round(fup_Q1,1),"-",round(fup_Q3,1),")");
	ordre = 12;
	keep level count_&patients percent_&patients ordre factor;
	run;
	data l1_moy;
	retain level count_&patients percent_&patients;
	format percent_&patients $15.;
	merge lmoy lET;
	factor = "Mean attained age, in years (SD)";
	level = "";
	count_&patients = round(fup_moy, 1);
	percent_&patients = cats("(",round(fup_ET,1),")");
	ordre = 13;
	keep level count_&patients percent_&patients ordre factor;
	run;
	data L2;
	set l1_mediane l1_moy;
	run;

	/* --> Recuperer les infos dans une table et faire tableau de sortie*/
	data &patients._&annee;
	retain level count_&patients percent_&patients;
	format percent_&patients $15.;
	set a b c d e f fa g h i n o p q r s t u v ct1 ct2 ct3 ct4 ct5 ct6 hab1 hab2 rt ct rt_b fdep;
	format sexe sexe. level $40. factor $50.;
	if dummy_overall = "Overall" then do; level = dummy_overall; ordre = 0; factor = "Overall"; end;
	if sexe = 1 then do;level = "Men";ordre = 1;factor = "Sex";end;
	if sexe = 2 then do;level = "Women";ordre = 1;factor = "Sex";end;
	if c_age_diag ne "" then do;level = c_age_diag;ordre = 2;factor = "Age at diagnosis";end;
	if ttt_era ne "" then do;level = ttt_era;ordre = 3;factor = "Treatment era";end;
	if rt ne "" then do;level = rt;ordre = 3.1;factor = "Radiotherapy";end;
	if ct ne "" then do;level = ct;ordre = 3.2;factor = "Chemotherapy";end;
	if c_fup ne "" then do;level = c_fup;ordre = 4;factor = "Follow-up";end;
	if c_att_age ne "" then do;level = c_att_age;ordre = 5;factor = "Attained age at 31/12/&stop";end;
	if typeg_clair ne "" then do;level = typeg_clair;ordre = 6;factor = "Childhood cancer type";end;
	if type_bs_clair ne "" then do;level = type_bs_clair;ordre = 6.1;factor = "Childhood cancer type 2";end;
	if trt ne "" then do;level = trt;ordre = 7;factor = "Treatment";end;
	if chir ne "" then do;level = chir;ordre = 8;factor = "Surgery";end;
	if chir_trt ne "" then do;level = chir_trt;ordre = 9;factor = "Surgery & treatment";end;

	if k2_before_end ne "" then do;level = k2_before_end;ordre = 10;factor = "SMN";end;
	if card_before_end ne "" then do;level = card_before_end;ordre = 11;factor = "Cardiac disease";end;
	if renal_before_end ne "" then do;level = renal_before_end;ordre = 12;factor = "Kidney disease";end;
	if diabete ne "" then do;level = diabete;ordre = 13;factor = "Diabetes mellitus";end;
	if rt_brain ne "" then do;level = rt_brain;ordre = 13.9;factor = "Radiation dose to brain";end;
	if c_vol_5 ne "" then do;level = c_vol_5;ordre = 14;factor = "V5 brain (Gy)";end;
	if c_vol_20 ne "" then do;level = c_vol_20;ordre = 15;factor = "V20 brain (Gy)";end;
	if c_vol_30 ne "" then do;level = c_vol_30;ordre = 16;factor = "V30 brain (Gy)";end;
	if c_vol_40 ne "" then do;level = c_vol_40;ordre = 17;factor = "V40 brain (Gy)";end;
	if c_d95_cerv ne "" then do;level = c_d95_cerv;ordre = 13.1;factor = "Min dose brain (Gy)";end;
	if c_d05_cerv ne "" then do;level = c_d05_cerv;ordre = 13.2;factor = "Max dose brain (Gy)";end;

	if anthra ne "" then do;level = anthra;ordre = 18;factor = "Anthracycline administration";end;
	if alkyl ne "" then do;level = alkyl;ordre = 19;factor = "Alkylating agents administration";end;
	if cisp ne "" then do;level = cisp;ordre = 20;factor = "Cisplatin administration";end;
	if dauno ne "" then do;level = dauno;ordre = 21;factor = "Dauno administration";end;
	if doxo ne "" then do;level = doxo;ordre = 22;factor = "Doxorubicin administration";end;
	if vinca ne "" then do;level = vinca;ordre = 22.1;factor = "Vinca alkaloid administration";end;

	if fdep13_Q ne "" then do;level = fdep13_Q;ordre = 22.5;factor = "Deprivation index";end;
	if tabacYN ne "" then do;level = tabacYN;ordre = 23;factor = "Smoking-related conditions";end;
	if alcoolYN ne "" then do;level = alcoolYN;ordre = 24;factor = "Alcohol-related conditions";end;

	count_&patients = count;
	percent = round(percent, 0.1);
	percent_&patients = input(percent, $15.); /*On met au format caractere pour pouvoir ensuite ajouter les IQR des medianes*/
	keep level count_&patients percent_&patients ordre factor;
	run;
	data &patients._&annee;
	set &patients._&annee K L L2;
	run;
	%tri(&patients._&annee, ordre level);
	%supp(a);
	%supp(b);
	%supp(c);
	%supp(d);
	%supp(e);
	%supp(f);
	%supp(g);
	%supp(h);
	%supp(i);
	%supp(j);
	%supp(m n o p q r s t u v ct1 ct2 ct3 ct4 ct5 ct6 hab1 hab2 rt ct fdep);
	%supp( K K1_mediane K1_moy Ket KQ1 KQ2 KQ3 Kmoy)
	%supp( L L1_mediane L1_moy Let LQ1 LQ2 LQ3 Lmoy L2)
	%supp(clin_&annee);
%mend;
%macro boucle_annee();
/*%clin(fccss);*/
%do annee = &start %to &stop;
	%desc_annee(opioid, classe = "Opioid", annee = &annee);
	%desc_annee(psychotropes, classe = "Psychotropic drugs", annee = &annee);
	%desc_annee(Step2, classe = "Step II opioids", annee = &annee);
	%desc_annee(Step3, classe = "Step III opioids", annee = &annee);
	%desc_annee(dependance, classe = "dependance", annee = &annee);
	/*fusion des resultats*/
	data res_clin_&annee;
	retain factor level;
	merge fccss opioid_&annee psychotropes_&annee step2_&annee step3_&annee dependance_&annee;
	by ordre level;
	drop ordre;
	run;
	%supp(opioid_&annee);
	%supp(psychotropes_&annee);
	%supp(step2_&annee);
	%supp(step3_&annee);
	%supp(dependance_&annee);
	%tri(res_clin_&annee, factor level);
	data res_clin_&annee;
	set res_clin_&annee;
	by factor;
	if first.factor = 0 then factor = "";
	run;
	/*Tableau recapitulatif*/
	options mprint mlogic;
	options orientation=landscape;
	ods rtf file="&path_out.\&date._descriptif_patients_APRES_1_&annee..rtf"
	              style=statistical fontscale=85
	              nogfootnote nogtitle;
	title "Table XX - Patients characteristics - Consumers of &annee";
	proc report data = res_clin_&annee
		style(report)=[borderrightcolor=white borderleftcolor=white background=white ]
		style(summary)=[frame=void background=white ]
		style(report column header summary)=[background=white borderrightcolor=white borderleftcolor=white];

	column 	factor
			level
			("FCCSS" (
			("N" COUNT_fccss)
	      	("%" PERCENT_fccss)))
			("Opioids" (
			("N" COUNT_opioid)
	      	("%" PERCENT_opioid)))
			("Step II"(
			("N" COUNT_step2)
	      	("%" PERCENT_step2)))
			("Step III" (
			("N" COUNT_step3)
	      	("%" PERCENT_step3)))
			("Dependance" (
			("N" COUNT_dependance)
	      	("%" PERCENT_dependance)))

	       ;
	run;
	footnote;
	ods rtf close;
%end;
%mend;


/* 2. Durees des traitements par indiv par annee*/
%macro durees(patients, classe = ., sous_classe = ., annee = .);
/*On cree la base de conso souhaitee*/
%if &classe ne . %then %do;
	/*Si la classe renseignee est differente de "Opioid" alors on utilise la classe renseignee*/
	%if &classe ne "Opioid" %then %do;
		proc sql;
		create table duree as
		select *
		from conso
		where (classe = &classe) 
			and (annee_trt = &annee) 
			and	(num_enq in(select num_enq 
								from opi_2006
								));
		/*On recupere la derniere date_trt de l annee precedente pour savoir si le patient est sous trt au debut de l annee*/
		create table duree_an_prev as
		select num_enq, max(date_trt) as date_an_prev format ddmmyy10.
		from conso
		where (classe = &classe) 
			and (annee_trt = %eval(&annee-1)) 
			and	(num_enq in(select num_enq 
								from opi_2006
								))
			group by num_enq;
		quit;
		data duree;
		merge duree duree_an_prev;
		by num_enq;
		if date_trt = . then delete;
		run;
	%end;
	/*Si la classe renseignee est "Opioid" alors on utilise toutes les lignes qui ne sont pas des pyschotropes (car la base = psychotropes + opioides)*/
	%if &classe = "Opioid" %then %do;
		proc sql;
		create table duree as
		select *
		from conso
		where (classe ne "Psychotropic drugs") 
			and (annee_trt = &annee) 
			and	(num_enq in(select num_enq 
								from opi_2006
								));
		/*On recupere la derniere date_trt de l annee precedente pour savoir si le patient est sous trt au debut de l annee*/
		create table duree_an_prev as
		select num_enq, max(date_trt) as date_an_prev format ddmmyy10.
		from conso
		where (classe ne "Psychotropic drugs") 
			and (annee_trt = %eval(&annee-1)) 
			and	(num_enq in(select num_enq 
								from opi_2006
								))
			group by num_enq;
		quit;
		data duree;
		merge duree duree_an_prev;
		by num_enq;
		if date_trt = . then delete;
		run;
	%end;
%end;
/*On cree la base de conso souhaitee*/
%if &sous_classe ne . %then %do;
	proc sql;
	create table duree as
	select *
	from conso
	where (sous_classe = &sous_classe) 
	and (annee_trt = &annee) 
	and	(num_enq in(select num_enq 
							from opi_2006
							));
	/*On recupere la derniere date_trt de l annee precedente pour savoir si le patient est sous trt au debut de l annee*/
	create table duree_an_prev as
	select num_enq, max(date_trt) as date_an_prev format ddmmyy10.
	from conso
	where (classe = &classe) 
		and (annee_trt = %eval(&annee-1)) 
		and	(num_enq in(select num_enq 
							from opi_2006
							))
		group by num_enq;
	quit;
	data duree;
	merge duree duree_an_prev;
	by num_enq;
	if date_trt = . then delete;
	run;
%end;
/*On cree une dummy base avec date de traitement = 31/12/&annee pour utilisation du lag correctement*/
data temp;
set duree;
date_trt = mdy(12,31,&annee);
if date_trt = mdy(12,31,&annee);
run;
%tri(temp nodupkey, num_enq date_trt);
/*On supprime les lignes avec un num_enq et une date_trt identiques*/
%tri(duree nodupkey, num_enq date_trt);
/*calcul des durees : date_trt + 28j // ou date_trt + 30j*/
data duree_&patients._&annee;
set duree temp;
run;
%supp(temp);
%tri(duree_&patients._&annee nodupkey, num_enq date_trt);
data duree_&patients._&annee;
set duree_&patients._&annee;
format date_prev_trt ddmmyy10.;
/*On ne cumule pas les durees sur les memes periodes*/
by num_enq date_trt;
/*Par defaut, la duree est de 28j*/
duree = 28;
/*Sinon, si la date de traitement suivante est avant 28j on raccourcit la duree*/
date_prev_trt = lag(date_trt);
if (date_trt - date_prev_trt ) lt 28 then duree = (date_trt - date_prev_trt);
/*On attribue une duree 0 pour la premiere periode par defaut (sinon le calcul est fausse)*/
if first.num_enq then do; 
	date_prev_trt = .;
	duree = 0;
	/*Si la date de trt de l annee precedente est apres le 03/12, on ajoute la duree de trt au debut de l annee (date_an_prev + 28)*/
	if date_an_prev gt mdy(12,03,%eval(&annee-1)) then do;
		duree_a_soustraire = mdy(12,31,%eval(&annee-1))-date_an_prev;
		duree = 28 - duree_a_soustraire;
	end;
end;
run;
/*Duree totale sur l annee*/
proc sql;
create table duree_&patients._&annee as
select distinct(num_enq), sum(duree) as duree_&annee
from duree_&patients._&annee
group by num_enq;
quit;
/*On cree une nouvelle table pour les stats generales sur la periode*/
data duree_&patients._&annee._tot;
set duree_&patients._&annee;
duree = duree_&annee;
keep duree;
run;
%qt(duree_&patients._&annee, duree_&annee);
/*Table avec les durees pour toutes les annees*/
%if &annee = &start %then %do;
	/*Une colonne = une annee*/
	data duree_&patients._col;
	set duree_&patients._&annee; 
	drop num_enq;										/*Enlever le drop num_enq pour calcul des durees sur l'ensemble de la periode pour chaque patient ayant au moins une prescription*/
	run;
	/*Une colonne pour toutes les annees*/
	data duree_&patients._tot;
	set duree_&patients._&annee._tot;
	run;
%end;
%if &annee gt &start %then %do;
	data duree_&patients._col;
	merge duree_&patients._col duree_&patients._&annee;
	drop num_enq;
	run;
	data duree_&patients._tot;
	set duree_&patients._tot duree_&patients._&annee._tot;
	run;
%end;
%supp(duree_&patients._&annee);
%supp(duree_&patients._&annee._tot);
%mend;
%macro duree_annee();
%do annee = &start %to &stop;
	%durees(opioid, classe = "Opioid", annee = &annee);
	%durees(psychotropes, classe = "Psychotropic drugs", annee = &annee);
	%durees(Step2, classe = "Step II opioids", annee = &annee);
	%durees(Step3, classe = "Step III opioids", annee = &annee);
	%durees(dependance, classe = "dependance", annee = &annee);
%end;
%mend;


/*Stats de durees*/
%macro stat_duree(patients);
ods rtf file="&path_out.\&date._duree_APRES_&patients..rtf";
/*Duree mediane totale (2006-2018)*/
proc univariate data = duree_&patients._tot noprint;
var duree;
output out = Q1 Q1=duree_Q1;
output out = Q2 median=duree_median;
output out = Q3 Q3=duree_Q3;
output out = moy mean=duree_moy;
output out = ET SD=duree_ET;
run;
data &patients._duree_mediane_tot;
merge Q1 Q2 Q3;
factor = "Annual median duration of treatment, in days (IQR)";
level = "";
count_&patients = duree_median;
percent_&patients = cats("(",duree_Q1,"-",duree_Q3,")");
run;
data &patients._duree_moy_tot;
merge moy ET;
factor = "Annual mean duration of treatment, in days (SD)";
level = "";
count_&patients = round(duree_moy, 1);
percent_&patients = cats("(",round(duree_ET,1),")");
run;
data &patients._duree_mediane_tot;
set &patients._duree_mediane_tot &patients._duree_moy_tot;
run;
%supp(&patients._duree_moy_tot);
/*Duree mediane par annee*/
%do annee = /*2006*/&start %to /*2018*/&stop;
	proc univariate data = duree_&patients._col noprint ;
	var duree_&annee;
	output out = N N=N;
	output out = Q1 Q1=duree_Q1;
	output out = Q2 median=duree_median;
	output out = Q3 Q3=duree_Q3;
	output out = moy mean=duree_moy;
	output out = ET SD=duree_ET;
	run;
	data &patients._median_&annee;
	merge Q1 Q2 Q3;
	annee = &annee;
	factor = "Median duration of treatment, in days (IQR)";
	level = "";
	count_&patients = duree_median;
	percent_&patients = cats("(",duree_Q1,"-",duree_Q3,")");
	run;
	data &patients._duree_moy_&annee;
	merge moy ET;
	annee = &annee;
	factor = "Mean duration of treatment, in days (SD)";
	level = "";
	count_&patients = round(duree_moy,1);
	percent_&patients = cats("(",round(duree_ET,1),")");
	run;
	data &patients._median_&annee;
	set &patients._median_&annee &patients._duree_moy_&annee;
	run;
	%supp(&patients._duree_moy_&annee);
%end;
ods rtf close;
data &patients._duree_mediane;
set &patients._median_&start-&patients._median_&stop;
run;
data duree.&patients._duree_mediane;
set &patients._duree_mediane;
if duree_Q1 ne .;
drop level count_&patients percent_&patients duree_moy duree_ET;
run;
data duree.&patients._duree_moyenne;
set &patients._duree_mediane;
if duree_Q1 = .;
drop level count_&patients percent_&patients duree_Q1 duree_median duree_Q3;
run;
%do annee = &start %to &stop;
	%supp(&patients._median_&annee);
%end;
%mend;

/* 3. --> INSERER RESULTATS DANS TABLEAUX --> RES_CLIN */ /*UTILISER CE TABLEAU*/
%macro sortie_clin_duree();
data tot;
merge opioid_duree_mediane_tot psychotropes_duree_mediane_tot step2_duree_mediane_tot step3_duree_mediane_tot dependance_duree_mediane_tot;
drop duree_Q1 duree_median duree_Q3 duree_moy duree_ET;
run;
data res_clin_tot;
set res_clin tot;
run;
/*Tableau recapitulatif*/
options mprint mlogic;
options orientation=landscape;
ods rtf file="&path_out.\&date._TABLE_1_descriptif_patients_APRES.rtf"
              style=statistical fontscale=85
              nogfootnote nogtitle;
title "Table XX - Patients characteristics - Consumers from &start. to &stop";
proc report data = res_clin_tot
	style(report)=[borderrightcolor=white borderleftcolor=white background=white ]
	style(summary)=[frame=void background=white ]
	style(report column header summary)=[background=white borderrightcolor=white borderleftcolor=white];

column 	factor
		level
		("FCCSS" (
		("N" COUNT_fccss)
      	("%" PERCENT_fccss)))
		("Non-users" (
		("N" COUNT_nonuser)
      	("%" PERCENT_nonuser)))
		("Opioids" (
		("N" COUNT_opioid)
      	("%" PERCENT_opioid)))
		("Step II"(
		("N" COUNT_step2)
      	("%" PERCENT_step2)))
		("Step III" (
		("N" COUNT_step3)
      	("%" PERCENT_step3)))
 		("Dependance" (
		("N" COUNT_dependance)
      	("%" PERCENT_dependance)))      ;
run;
footnote;
ods rtf close;
%mend;

/* 3 bis. --> INSERER RESULTATS DANS TABLEAUX --> RES_CLIN_&ANNEE*/ /*--> Meme tableau mais avec les durees medianes et moyennes en plus - Utiliser ce tableau*/
%macro insert_result();
%do annee = &start %to &stop;
	data duree_&annee;
	merge opioid_duree_mediane psychotropes_duree_mediane step2_duree_mediane step3_duree_mediane dependance_duree_mediane;
	where annee = &annee;
	drop duree_Q1 duree_median duree_Q3 duree_moy duree_ET;
	run;
	data res_clin_duree_&annee._2;
	set res_clin_&annee duree_&annee;
	drop annee;
	run;
	%supp(duree_&annee);
	/*Tableau recapitulatif*/
	options mprint mlogic;
	options orientation=landscape;
	ods rtf file="&path_out.\&date._TABLE_1_descriptif_APRES_patients_&annee..rtf"
	              style=statistical fontscale=85
	              nogfootnote nogtitle;
	title "Table XX - Patients characteristics - Consumers in &annee";
	proc report data = res_clin_duree_&annee._2
		style(report)=[borderrightcolor=white borderleftcolor=white background=white ]
		style(summary)=[frame=void background=white ]
		style(report column header summary)=[background=white borderrightcolor=white borderleftcolor=white];

	column 	factor
			level
			("FCCSS" (
			("N" COUNT_fccss)
	      	("%" PERCENT_fccss)))
			("Opioids" (
			("N" COUNT_opioid)
	      	("%" PERCENT_opioid)))
			("Step II"(
			("N" COUNT_step2)
	      	("%" PERCENT_step2)))
			("Step III" (
			("N" COUNT_step3)
	      	("%" PERCENT_step3)))
			("Dependance" (
			("N" COUNT_dependance)
	      	("%" PERCENT_dependance)))      
	       ;
	run;
	footnote;
	ods rtf close;
%end;
%mend;
