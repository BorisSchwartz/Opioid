/* Diagramme de Sankey */

/*1. Mise en forme des donnees */
%macro boucle_sankey_S2S3();
	%macro sankey_S2S3_drugs(); /*	classe: "Step II opioids" ou "Step III opioids" si analyse en sous classes
																	"opioid" si analyse en classes
															n_cpt: nombre de delivrances prises en compte pour l analyse*/
	/*On recupere les indicateurs de prise de drogue par annee*/
	data temp0;
	set indicbin.indic_annee;
	keep num_enq s2_2006-s2_2021 s3_2006-s3_2021;
	run;
	/*On ne garde que les individus de notre base*/
	proc sql;
	create table temp as
	select *
	from temp0
	where num_enq in(select num_enq
					 from opi_2006
					 );
	quit;
	data temp2;
	set temp;
	/*4 periodes : 2006-2008 / 2009-2011 / 2012-2014 / 2015-2018*/
	/*On regarde si les patients ont pris des step II*/
	S2_p1 = max(of S2_2007-S2_2009);
	S2_p2 = max(of S2_2010-S2_2012);
	S2_p3 = max(of S2_2013-S2_2015);
	S2_p4 = max(of S2_2016-S2_2018);
	S2_p5 = max(of S2_2019-S2_2021);
	/*On regarde si les patients ont pris des step III*/
	S3_p1 = max(of S3_2007-S3_2009);
	S3_p2 = max(of S3_2010-S3_2012);
	S3_p3 = max(of S3_2013-S3_2015);
	S3_p4 = max(of S3_2016-S3_2018);
	S3_p5 = max(of S3_2019-S3_2021);
	drop s2_2006-s2_2021 s3_2006-s3_2021;
	%do i = 1 %to 5;
		format drug_p&i $30.;
		/*S2 seul ou polymedication*/
		if S2_p&i = 1 then do;
			drug_p&i = "Step II users";
			if S3_p&i = 1 				then drug_p&i = "Both steps II and III users";
		end;
		else
		/*Si aucun Step II on regarde si Step III seul*/
		if drug_p&i = "" and S3_p&i = 1 then drug_p&i = "Step III users";
	%end;
	run;
	/*On cree une base pour chaque periode pour fusionner ensuite les bases (set)*/
	%do i = 1 %to 5;
		data t&i;
		set temp2;
		period = "Period &i";
		rename drug_p&i = drug;
		keep num_enq drug_p&i period;
		run;
	%end;
	/*Fusion des differentes periodes*/
	data raw_sankey_s2s3;
	set t1-t5;
	if drug = "" then drug = "No opioid use";
	run;

	/*Analyse sur les 5 periodes*/
	/*Par drogue*/
	title "Sankey diagram - Opioid drugs - 2007/2021";
	%sankeybarchart(data=raw_sankey_s2s3
	   ,subject=num_enq
	   ,yvar=drug
	   ,xvar=period
	   ,yvarord=%quote(No opioid use, Step II users, Step III users, Both steps II and III users)
	   ,colorlist=LIGGR BIGB VIPK VPAPB
	   );
	%mend;
%sankey_S2S3_drugs();
%mend;

