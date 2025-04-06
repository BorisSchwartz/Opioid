
/*Description patients FCCSS / psychotropes / Step II / Step III*/

/* 1. Donnees Cliniques*/
%macro clin(patients, classe = ., sous_classe = .);
/*On cree la base avec tous les patients chaines retenus pour l etude */
proc sql;
create table opioides as
select *
from opi_2006;
quit;

/*Si patients = NonUser, on ne garde que ceux qui n'ont jamais consomme d opioides*/
%if &patients = NonUser %then %do;
	proc sql;
	create table ident as
	select distinct(num_enq)
	from conso
	where classe ne "Psychotropic drugs" 
	and	num_enq in(select num_enq 
						from opi_2006
						);
	create table opioides as
	select *
	from opioides
	where num_enq not in(select num_enq
					from ident
					);
	quit;	
%end;
%if &classe ne . %then %do;
	/*Si la classe renseignee est differente de "Opioid" alors on utilise la classe renseignee*/
	%if &classe ne "Opioid" %then %do;
		proc sql;
		create table ident as
		select distinct(num_enq)
		from conso
		where classe = &classe 
		and	num_enq in(select num_enq 
							from opi_2006
							);
		create table opioides as
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
		where classe ne "Psychotropic drugs" 
		and	num_enq in(select num_enq 
							from opi_2006
							);
		create table opioides as
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
	where sous_classe = &sous_classe 
	and	num_enq in(select num_enq 
						from opi_2006
						);
	create table opioides as
	select *
	from opioides
	where num_enq in(select num_enq
					from ident
					);
	quit;
%end;
data clin;
set opioides;
exit_date = mdy(12,31,&stop);
if deces = 1 and date_deces ne . then exit_date = date_deces;/**/
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

/*Overall*/
%ql(clin noprint, dummy_overall/out=a);
/*sexe*/
%ql(clin noprint, sexe/out=b);
/*agediag*/
%ql(clin noprint, c_age_diag/out=c);
/*ttt_era*/
%ql(clin noprint, ttt_era/out=d);
/*fup*/
%ql(clin noprint, c_fup/out=e);
/*Attained age*/
%ql(clin noprint, c_att_age/out=f);
/*fpn*/
%ql(clin noprint, typeg_clair/out=g);
%ql(clin noprint, type_bs_clair/out=ga);
/*treatment*/
%ql(clin noprint, trt/out=h);
%ql(clin noprint, rt/out=rt);
%ql(clin noprint, ct/out=ct);
/*Chirurgie*/
%ql(clin noprint, chir/out=i);

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
proc univariate data = clin noprint;
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
proc univariate data = clin noprint;
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

%supp(lq1 lq2 lq3 lmoy let l1_mediane l1_moy);

/*Att_Age*/
proc univariate data = clin noprint;
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
data &patients;
retain level count_&patients percent_&patients;
format percent_&patients $15.;
set a b c d e f g ga h i n o p q r s t u v ct1 ct2 ct3 ct4 ct5 ct6 hab1 hab2 rt ct rt_b fdep;
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
data &patients;
set &patients K L L2;
run;
%tri(&patients, ordre level);
%supp(a);
%supp(b);
%supp(c);
%supp(d);
%supp(e);
%supp(f);
%supp(g ga);
%supp(h);
%supp(i);
%supp(j);
%supp(m n o p q r s t u v ct1 ct2 ct3 ct4 ct5 ct6 hab1 hab2 rt ct rt_b fdep);
%supp(k);
%supp(l);
%mend;
