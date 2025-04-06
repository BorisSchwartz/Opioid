
/*Description patients selon groupe de trajectoire*/


/* 1. Donnees Cliniques*/
%macro clin_traj(group);
/*On cree la base avec tous les patients chaines retenus pour l etude (n=5582)*/

/*EDIT APRES IMPORT DOSES ET COMORBIDITES*/ /*Creation de op.multin_opioid dans le programme 8T1*/
proc sql;
create table opioides as
select *
from git.multin_opioid_smn4
where group = &group;
quit;

data opioides;
set opioides;
drop ttt_era;
run;
data clin;
set opioides;
if typeg = 8 then typeg = 0;
format c_age_diag $10.;
exit_date = mdy(12,31,&stop);
if deces = 1 and date_deces ne . then exit_date = date_deces;/**/
fup = (exit_date - date_diag)/365.25;
if fup ge 50 				then c_fup = "E 50 and more";
if fup ge 20 and fup lt 30 	then c_fup = "A <30 ";
if fup ge 30 and fup lt 40 	then c_fup = "C 30-39";
if fup ge 40 and fup lt 50 	then c_fup = "D 40-49";
if fup lt 20 				then c_fup = "A <30 ";
att_age = (exit_date - date_nais)/365.25;
if att_age ge 50 					then c_att_age = "E 50 and more";
if att_age ge 20 and att_age lt 30 	then c_att_age = "A <30 ";/*On regroupe A et B*/
if att_age ge 30 and att_age lt 40 	then c_att_age = "C 30-39";
if att_age ge 40 and att_age lt 50 	then c_att_age = "D 40-49";
if att_age lt 20 					then c_att_age = "A <30 ";
if chimiotherapie = . then chimiotherapie = 0;
if radiotherapie = . then radiotherapie = 0;
format trt $20.;
if chimiotherapie = 0 and radiotherapie = 0 then trt = "A Surgery only";
if chimiotherapie = 1 and radiotherapie = 1 then trt = "D CT and RT";
if chimiotherapie = 1 and radiotherapie = 0 then trt = "C CT no RT";
if chimiotherapie = 0 and radiotherapie = 1 then trt = "B RT no CT";
format typeg_clair $22.;
if typeg = 0 then typeg_clair = "Others";
if typeg = 1 then typeg_clair = "Nephroblastoma";
if typeg = 2 then typeg_clair = "Neuroblastoma";
if typeg = 3 then typeg_clair = "Lymphoma";
if typeg = 4 then typeg_clair = "Soft tissue sarcoma";
if typeg = 5 then typeg_clair = "Osteosarcoma";
if typeg = 6 then typeg_clair = "CNS tumor";
if typeg = 7 then typeg_clair = "Gonadal tumor";
if typeg = 8 then typeg_clair = "Thyroid tumor";
if typeg = 9 then typeg_clair = "Retinoblastoma";
format ttt_era_c $30.;
annee_diag = year(date_diag);
if annee_diag ge 2000 							then ttt_era_c = "1990 and more";/*regroupement de classes*/
if annee_diag ge 1970 and annee_diag lt 1980 	then ttt_era_c = "before 1980";
if annee_diag ge 1980 and annee_diag lt 1990 	then ttt_era_c = "1980-1989";
if annee_diag ge 1990 and annee_diag lt 2000 	then ttt_era_c = "1990 and more";
if annee_diag lt 1970 							then ttt_era_c = "before 1980";
format type_bs typeg.;
if typeg = 4 then type_bs = 4;
if typeg = 5 then type_bs = 5;
if typeg ne 5 and typeg ne 4 then type_bs = 0;
format type_bs_clair $22.;
if type_bs = 4 then type_bs_clair = "Soft tissue sarcoma";
if type_bs = 5 then type_bs_clair = "Osteosarcoma";
if type_bs = 0 then type_bs_clair = "Others";
format tabacYN $4. alcoolYN $4.;
if tabac = 0 then tabacYN = "No";
if tabac = 1 then tabacYN = "Yes";
if alcool = 0 then alcoolYN = "No";
if alcool = 1 then alcoolYN = "Yes";
if c_d05_cerv ne "B 0" then rt_brain = "Yes";
if c_d05_cerv = "B 0" then rt_brain = "No";
format ct $4. rt $4.;
if chimiotherapie = 0 then ct = "No";
if chimiotherapie = 1 then ct = "Yes";
if radiotherapie = 0 then rt = "No";
if radiotherapie = 1 then rt = "Yes";

dummy_overall = "Overall";
run;

/*Overall*/
%ql(clin noprint, dummy_overall/out=a);
/*sexe*/
%ql(clin noprint, sexe/out=b);
/*agediag*/
%ql(clin noprint, c_age_diag/out=c);
/*ttt_era*/
%ql(clin noprint, ttt_era_c/out=d);
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
/*%ql(clin noprint, k2_before_end/out=m);*/
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
retain level count_&group percent_&group;
format percent_&group $15.;
merge kQ1 kQ2 kQ3;
factor = "Median age at diagnosis, in years (IQR)";
level = "";
count_&group = round(age_diag_median, 1);
percent_&group = cats("(",round(age_diag_Q1,1),"-",round(age_diag_Q3,1),")");
ordre = 10;
keep level count_&group percent_&group ordre factor;
run;
data k1_moy;
retain level count_&group percent_&group;
format percent_&group $15.;
merge kmoy kET;
factor = "Mean age at diagnosis, in years (SD)";
level = "";
count_&group = round(age_diag_moy, 1);
percent_&group = cats("(",round(age_diag_ET,1),")");
ordre = 11;
keep level count_&group percent_&group ordre factor;
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
retain level count_&group percent_&group;
format percent_&group $15.;
merge lQ1 lQ2 lQ3;
factor = "Median follow-up, in years (IQR)";
level = "";
count_&group = round(fup_median, 1);
percent_&group = cats("(",round(fup_Q1,1),"-",round(fup_Q3,1),")");
ordre = 12;
keep level count_&group percent_&group ordre factor;
run;
data l1_moy;
retain level count_&group percent_&group;
format percent_&group $15.;
merge lmoy lET;
factor = "Mean follow-up, in years (SD)";
level = "";
count_&group = round(fup_moy, 1);
percent_&group = cats("(",round(fup_ET,1),")");
ordre = 13;
keep level count_&group percent_&group ordre factor;
run;
data L;
set l1_mediane l1_moy;
run;
%supp(lq1 lq2 lq3 lmoy let l1_mediane l1_moy lmoy_et);

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
retain level count_&group percent_&group;
format percent_&group $15.;
merge lQ1 lQ2 lQ3;
factor = "Median attained age, in years (IQR)";
level = "";
count_&group = round(fup_median, 1);
percent_&group = cats("(",round(fup_Q1,1),"-",round(fup_Q3,1),")");
ordre = 12;
keep level count_&group percent_&group ordre factor;
run;
data l1_moy;
retain level count_&group percent_&group;
format percent_&group $15.;
merge lmoy lET;
factor = "Mean attained age, in years (SD)";
level = "";
count_&group = round(fup_moy, 1);
percent_&group = cats("(",round(fup_ET,1),")");
ordre = 13;
keep level count_&group percent_&group ordre factor;
run;
data L2;
set l1_mediane l1_moy;
run;


/* --> Recuperer les infos dans une table et faire tableau de sortie*/
data G&group;
retain level count_&group percent_&group;
format percent_&group $15.;
set a b c d e f g ga h i /*m*/ n o p q r s t u v ct1 ct2 ct3 ct4 ct5 ct6 hab1 hab2 ct rt rt_b fdep;
format sexe sexe. level $40. factor $50.;
if dummy_overall = "Overall" then do; level = dummy_overall; ordre = 0; factor = "Overall"; end;
if sexe = 1 then do;level = "Men";ordre = 1;factor = "Sex";end;
if sexe = 2 then do;level = "Women";ordre = 1;factor = "Sex";end;
if c_age_diag ne "" then do;level = c_age_diag;ordre = 2;factor = "Age at diagnosis";end;
if ttt_era_c ne "" then do;level = ttt_era_c;ordre = 3;factor = "Treatment era";end;
if c_fup ne "" then do;level = c_fup;ordre = 4;factor = "Follow-up";end;
if c_att_age ne "" then do;level = c_att_age;ordre = 5;factor = "Attained age at 31/12/&stop";end;
if typeg_clair ne "" then do;level = typeg_clair;ordre = 6;factor = "Childhood cancer type";end;
if type_bs_clair ne "" then do;level = type_bs_clair;ordre = 6.1;factor = "Childhood cancer type 2";end;
if trt ne "" then do;level = trt;ordre = 7;factor = "Treatment";end;
if rt ne "" then do;level = rt;ordre = 7.1;factor = "Radiotherapy";end;
if ct ne "" then do;level = ct;ordre = 7.2;factor = "Chemotherapy";end;
if chir ne "" then do;level = chir;ordre = 8;factor = "Surgery";end;
if chir_trt ne "" then do;level = chir_trt;ordre = 9;factor = "Surgery & treatment";end;

/*if k2_before_end ne "" then do;level = k2_before_end;ordre = 10;factor = "SMN";end;*/
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

count_&group = count;
percent = round(percent, 0.1);
percent_&group = input(percent, $15.); /*On met au format caractere pour pouvoir ensuite ajouter les IQR des medianes*/
keep level count_&group percent_&group ordre factor;
run;
data G&group;
set G&group K L L2;
run;
%tri(G&group, ordre level);
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
%supp(m n o p q r s t u v ct1 ct2 ct3 ct4 ct5 ct6 hab1 hab2 ct rt rt_b fdep);
%supp(k);
%supp(l);
*%supp(clin);
%mend;


