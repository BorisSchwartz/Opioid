
%macro sortie_multin(nom);
/*Creation d une table pour chaque groupe de reponse (sauf le groupe de ref.)*/
data OR_G1;
retain varname effect OR_G1;
format varname $42. OR_G1 $20.;
set ab;
if response = "Decrease";
/*On recupere la variable*/
varname = substr(effect, 1,16); /*Longueur de la variable la plus longue*/
varname = compress(varname);
/*On recupere la modalite*/
effect = compress(effect);
if effect = "SexeFemmevsHomme" 					then effect = "Women";
if effect = "SexeWomenvsMen" 					then effect = "Women";

if effect = "age_diag" 							then effect = "";
if effect = "typegAutresvsCerveau" 				then effect = "Others";
if effect = "typegGonadesvsCerveau" 			then effect = "Gonadal tumor";
if effect = "typegLymphomevsCerveau" 			then effect = "Lymphoma";
if effect = "typegNephroblastomevsCerveau" 		then effect = "Nephroblastoma";
if effect = "typegNeuroblastomevsCerveau" 		then effect = "Neuroblastoma";
if effect = "typegOsvsCerveau" 					then effect = "Bone sarcoma";
if effect = "typegRetinoblastomevsCerveau" 		then effect = "Retinoblastoma";
if effect = "typegThyroïdevsCerveau" 			then effect = "Thyroid tumor";
if effect = "typegTissusmousvsCerveau" 			then effect = "Soft tissues sarcoma";

if effect = "typegAutresvsNephroblastome" 				then effect = "Others";
if effect = "typegGonadesvsNephroblastome" 				then effect = "Gonadal tumor";
if effect = "typegLymphomevsNephroblastome" 			then effect = "Lymphoma";
if effect = "typegCerveauvsNephroblastome" 				then effect = "CNS tumor";
if effect = "typegNeuroblastomevsNephroblastome" 		then effect = "Neuroblastoma";
if effect = "typegOsvsNephroblastome" 					then effect = "Bone sarcoma";
if effect = "typegRetinoblastomevsNephroblastome" 		then effect = "Retinoblastoma";
if effect = "typegThyroïdevsNephroblastome" 			then effect = "Thyroid tumor";
if effect = "typegTissusmousvsNephroblastome" 			then effect = "Soft tissues sarcoma";

if effect = "type_bsOsvsAutres" 					then effect = "Bone sarcoma";
if effect = "type_bsTissusmousvsAutres" 			then effect = "Soft tissues sarcoma";

if effect = "ttt_era1980-1989vs1990andmore" 	then effect = "1980-1989";
if effect = "ttt_erabefore1980vs1990andmore" 	then effect = "before 1980";
if effect = "trtCTandRTvsSurgeryonly" 			then effect = "CT and RT";
if effect = "trtCTnoRTvsSurgeryonly"			then effect = "CT no RT";
if effect = "trtRTnoCTvsSurgeryonly"			then effect = "RT no CT";
if effect = "age_start" 						then effect = "";
if effect = "chirMajorvsOther" 					then effect = "Major surgery";
if effect = "chirMinorvsOther" 					then effect = "Minor surgery";
if effect = "c_age_diagA0-3vsE15andmore" 		then effect = "A 0-3";
if effect = "c_age_diagB4-8vsE15andmore" 		then effect = "B 4-8";
if effect = "c_age_diagC9-11vsE15andmore"		then effect = "C 9-11";
if effect = "c_age_diagD12-14vsE15andmore" 		then effect = "D 12-14";
if effect = "c_age_startA0-10vsEMorethan40" 	then effect = "A 0-10";
if effect = "c_age_startB11-20vsEMorethan40" 	then effect = "B 11-20";
if effect = "c_age_startC21-30vsEMorethan40"	then effect = "C 21-30";
if effect = "c_age_startD31-40vsEMorethan40" 	then effect = "D 31-40";

if effect = "c_fupA<20vsE50andmore" 	then effect = "A 0-20";
if effect = "c_fupB20-29vsE50andmore" 	then effect = "B 20-29";
if effect = "c_fupC30-39vsE50andmore"	then effect = "C 30-39";
if effect = "c_fupD40-49vsE50andmore" 	then effect = "D 40-49";

if effect = "c_dose_moyB]0;5]vsANone" 	then effect = "B ]0;5]";
if effect = "c_dose_moyC]5;10]vsANone" 	then effect = "C ]5;10]";
if effect = "c_dose_moyD]10;20]vsANone" then effect = "D ]10;20]";
if effect = "c_dose_moyE]20;40]vsANone" then effect = "E ]20;40]";
if effect = "c_dose_moyF>40vsANone" 	then effect = "F >40";
if effect = "rtYesvsNo" 	then effect = "Yes";
if effect = "ctYesvsNo" 	then effect = "Yes";

if effect = "card_before_end1vs0" 	then effect = "Yes";
if effect = "diabete1vs0" 			then effect = "Yes";
if effect = "renal_before_end1vs0" 	then effect = "Yes";
if effect = "K2_before_end1vs0" 	then effect = "Yes";

if effect = "c_vol_5C]0;50%]vsB0%" 		then effect = "C ]0;50%]";
if effect = "c_vol_5D]50%;100%]vsB0%" 	then effect = "D ]50%;100%]";
if effect = "c_vol_20C]0;10%]vsB0%" 	then effect = "C ]0;10%]";
if effect = "c_vol_20D]10;50%]vsB0%" 	then effect = "D ]10;50%]";
if effect = "c_vol_20E]50%;100%]vsB0%" 	then effect = "E ]50%;100%]";
if effect = "c_vol_30C]0;10%]vsB0%" 	then effect = "C ]0;10%]";
if effect = "c_vol_30D]10;50%]vsB0%" 	then effect = "D ]10;50%]";
if effect = "c_vol_30E]50%;100%]vsB0%" 	then effect = "E ]50%;100%]";
if effect = "c_vol_40C]0;10%]vsB0%" 	then effect = "C ]0;10%]";
if effect = "c_vol_40D]10%;100%]vsB0%" 	then effect = "D ]10%;100%]";

if effect = "c_d95_cervC]0;5]vsB0" 	then effect = "C ]0;5]";
if effect = "c_d95_cervD>5vsB0" 	then effect = "D >5";
if effect = "c_d05_cervC]0;15]vsB0" then effect = "C ]0;15]";
if effect = "c_d05_cervD>15vsB0" 	then effect = "D >15";

if effect = "anthra1vs0" 	then effect = "Yes";
if effect = "doxo1vs0" 		then effect = "Yes";
if effect = "dauno1vs0" 	then effect = "Yes";
if effect = "alkyl1vs0" 	then effect = "Yes";
if effect = "cisp1vs0" 		then effect = "Yes";
if effect = "vinca1vs0"		then effect = "Yes";

if effect = "deces1vs0" 	then effect = "Yes";

if effect = "tabac1vs0" 	then effect = "Yes";
if effect = "alcool1vs0" 	then effect = "Yes";

if effect = "tabac_before_end1vs0" 	then effect = "Yes";
if effect = "alcool_before_end1vs0" then effect = "Yes";

if effect = "fdep13_Q1vs0" 	then effect = "1";
if effect = "fdep13_Q2vs0" 	then effect = "2";
if effect = "fdep13_Q3vs0" 	then effect = "3";
if effect = "fdep13_Q4vs0" 	then effect = "4";


/*On compile les OR + IC95% ensemble. Si < 1 on garde 2 chiffres apres la virgule, sinon un seul*/
if OddsRatioEst gt 1 	then OR_G1_fmt = put(round(OddsRatioEst, 0.1),4.1);
if LowerCL gt 1 		then L_G1_fmt = put(round(LowerCL, 0.1),4.1);
if UpperCL gt 1 		then U_G1_fmt = put(round(UpperCL, 0.1),4.1);
if OddsRatioEst le 1 	then OR_G1_fmt = put(round(OddsRatioEst, 0.01),4.2);
if LowerCL le 1 		then L_G1_fmt = put(round(LowerCL, 0.01),4.2);
if UpperCL le 1 		then U_G1_fmt = put(round(UpperCL, 0.01),4.2);
OR_G1 = cat(OR_G1_fmt," ","(",L_G1_fmt," -",U_G1_fmt,")");
keep varname effect OR_G1;
run;

data OR_G2;
retain varname effect OR_G2;
format varname $42. OR_G2 $20.;
set ab;
if response = "Increase";
/*On recupere la variable*/
varname = substr(effect, 1,16); /*Longueur de la variable la plus longue*/
varname = compress(varname);
/*On recupere la modalite*/
effect = compress(effect);
if effect = "SexeFemmevsHomme" 					then effect = "Women";
if effect = "SexeWomenvsMen" 					then effect = "Women";
if effect = "age_diag" 							then effect = "";
if effect = "typegAutresvsCerveau" 				then effect = "Others";
if effect = "typegGonadesvsCerveau" 			then effect = "Gonadal tumor";
if effect = "typegLymphomevsCerveau" 			then effect = "Lymphoma";
if effect = "typegNephroblastomevsCerveau" 		then effect = "Nephroblastoma";
if effect = "typegNeuroblastomevsCerveau" 		then effect = "Neuroblastoma";
if effect = "typegOsvsCerveau" 					then effect = "Bone sarcoma";
if effect = "typegRetinoblastomevsCerveau" 		then effect = "Retinoblastoma";
if effect = "typegThyroïdevsCerveau" 			then effect = "Thyroid tumor";
if effect = "typegTissusmousvsCerveau" 			then effect = "Soft tissues sarcoma";

if effect = "typegAutresvsNephroblastome" 				then effect = "Others";
if effect = "typegGonadesvsNephroblastome" 				then effect = "Gonadal tumor";
if effect = "typegLymphomevsNephroblastome" 			then effect = "Lymphoma";
if effect = "typegCerveauvsNephroblastome" 				then effect = "CNS tumor";
if effect = "typegNeuroblastomevsNephroblastome" 		then effect = "Neuroblastoma";
if effect = "typegOsvsNephroblastome" 					then effect = "Bone sarcoma";
if effect = "typegRetinoblastomevsNephroblastome" 		then effect = "Retinoblastoma";
if effect = "typegThyroïdevsNephroblastome" 			then effect = "Thyroid tumor";
if effect = "typegTissusmousvsNephroblastome" 			then effect = "Soft tissues sarcoma";

if effect = "type_bsOsvsAutres" 					then effect = "Bone sarcoma";
if effect = "type_bsTissusmousvsAutres" 			then effect = "Soft tissues sarcoma";

if effect = "ttt_era1980-1989vs1990andmore" 	then effect = "1980-1989";
if effect = "ttt_erabefore1980vs1990andmore" 	then effect = "before 1980";
if effect = "trtCTandRTvsSurgeryonly" 			then effect = "CT and RT";
if effect = "trtCTnoRTvsSurgeryonly"			then effect = "CT no RT";
if effect = "trtRTnoCTvsSurgeryonly"			then effect = "RT no CT";
if effect = "age_start" 						then effect = "";
if effect = "chirMajorvsOther" 					then effect = "Major surgery";
if effect = "chirMinorvsOther" 					then effect = "Minor surgery";
if effect = "c_age_diagA0-3vsE15andmore" 		then effect = "A 0-3";
if effect = "c_age_diagB4-8vsE15andmore" 		then effect = "B 4-8";
if effect = "c_age_diagC9-11vsE15andmore"		then effect = "C 9-11";
if effect = "c_age_diagD12-14vsE15andmore" 		then effect = "D 12-14";
if effect = "c_age_startA0-10vsEMorethan40" 	then effect = "A 0-10";
if effect = "c_age_startB11-20vsEMorethan40" 	then effect = "B 11-20";
if effect = "c_age_startC21-30vsEMorethan40"	then effect = "C 21-30";
if effect = "c_age_startD31-40vsEMorethan40" 	then effect = "D 31-40";

if effect = "c_fupA<20vsE50andmore" 	then effect = "A 0-20";
if effect = "c_fupB20-29vsE50andmore" 	then effect = "B 20-29";
if effect = "c_fupC30-39vsE50andmore"	then effect = "C 30-39";
if effect = "c_fupD40-49vsE50andmore" 	then effect = "D 40-49";

if effect = "c_dose_moyB]0;5]vsANone" 	then effect = "B ]0;5]";
if effect = "c_dose_moyC]5;10]vsANone" 	then effect = "C ]5;10]";
if effect = "c_dose_moyD]10;20]vsANone" then effect = "D ]10;20]";
if effect = "c_dose_moyE]20;40]vsANone" then effect = "E ]20;40]";
if effect = "c_dose_moyF>40vsANone" 	then effect = "F >40";
if effect = "rtYesvsNo" 	then effect = "Yes";
if effect = "ctYesvsNo" 	then effect = "Yes";

if effect = "card_before_end1vs0" 	then effect = "Yes";
if effect = "diabete1vs0" 			then effect = "Yes";
if effect = "renal_before_end1vs0" 	then effect = "Yes";
if effect = "K2_before_end1vs0" 	then effect = "Yes";

if effect = "c_vol_5C]0;50%]vsB0%" 		then effect = "C ]0;50%]";
if effect = "c_vol_5D]50%;100%]vsB0%" 	then effect = "D ]50%;100%]";
if effect = "c_vol_20C]0;10%]vsB0%" 	then effect = "C ]0;10%]";
if effect = "c_vol_20D]10;50%]vsB0%" 	then effect = "D ]10;50%]";
if effect = "c_vol_20E]50%;100%]vsB0%" 	then effect = "E ]50%;100%]";
if effect = "c_vol_30C]0;10%]vsB0%" 	then effect = "C ]0;10%]";
if effect = "c_vol_30D]10;50%]vsB0%" 	then effect = "D ]10;50%]";
if effect = "c_vol_30E]50%;100%]vsB0%" 	then effect = "E ]50%;100%]";
if effect = "c_vol_40C]0;10%]vsB0%" 	then effect = "C ]0;10%]";
if effect = "c_vol_40D]10%;100%]vsB0%" 	then effect = "D ]10%;100%]";
if effect = "c_d95_cervC]0;5]vsB0" 	then effect = "C ]0;5]";
if effect = "c_d95_cervD>5vsB0" 	then effect = "D >5";
if effect = "c_d05_cervC]0;15]vsB0" then effect = "C ]0;15]";
if effect = "c_d05_cervD>15vsB0" 	then effect = "D >15";

if effect = "anthra1vs0" 	then effect = "Yes";
if effect = "doxo1vs0" 		then effect = "Yes";
if effect = "dauno1vs0" 	then effect = "Yes";
if effect = "alkyl1vs0" 	then effect = "Yes";
if effect = "cisp1vs0" 		then effect = "Yes";
if effect = "vinca1vs0"		then effect = "Yes";

if effect = "deces1vs0" 	then effect = "Yes";
if effect = "tabac1vs0" 	then effect = "Yes";
if effect = "alcool1vs0" 	then effect = "Yes";
if effect = "tabac_before_end1vs0" 	then effect = "Yes";
if effect = "alcool_before_end1vs0" 	then effect = "Yes";
if effect = "fdep13_Q1vs0" 	then effect = "1";
if effect = "fdep13_Q2vs0" 	then effect = "2";
if effect = "fdep13_Q3vs0" 	then effect = "3";
if effect = "fdep13_Q4vs0" 	then effect = "4";

/*On compile les OR + IC95% ensemble. Si < 1 on garde 2 chiffres apres la virgule, sinon un seul*/
if OddsRatioEst gt 1 	then OR_G2_fmt = put(round(OddsRatioEst, 0.1),4.1);
if LowerCL gt 1 		then L_G2_fmt = put(round(LowerCL, 0.1),4.1);
if UpperCL gt 1 		then U_G2_fmt = put(round(UpperCL, 0.1),4.1);
if OddsRatioEst le 1 	then OR_G2_fmt = put(round(OddsRatioEst, 0.01),4.2);
if LowerCL le 1 		then L_G2_fmt = put(round(LowerCL, 0.01),4.2);
if UpperCL le 1 		then U_G2_fmt = put(round(UpperCL, 0.01),4.2);
OR_G2 = cat(OR_G2_fmt," ","(",L_G2_fmt," -",U_G2_fmt,")");
keep varname effect OR_G2;
run;

data OR_G3;
retain varname effect OR_G3;
format varname $42. OR_G3 $20.;
set ab;
if response = "High delivery";
/*On recupere la variable*/
varname = substr(effect, 1,16); /*Longueur de la variable la plus longue*/
varname = compress(varname);
/*On recupere la modalite*/
effect = compress(effect);
if effect = "SexeFemmevsHomme" 					then effect = "Women";
if effect = "SexeWomenvsMen" 					then effect = "Women";
if effect = "age_diag" 							then effect = "";
if effect = "typegAutresvsCerveau" 				then effect = "Others";
if effect = "typegGonadesvsCerveau" 			then effect = "Gonadal tumor";
if effect = "typegLymphomevsCerveau" 			then effect = "Lymphoma";
if effect = "typegNephroblastomevsCerveau" 		then effect = "Nephroblastoma";
if effect = "typegNeuroblastomevsCerveau" 		then effect = "Neuroblastoma";
if effect = "typegOsvsCerveau" 					then effect = "Bone sarcoma";
if effect = "typegRetinoblastomevsCerveau" 		then effect = "Retinoblastoma";
if effect = "typegThyroïdevsCerveau" 			then effect = "Thyroid tumor";
if effect = "typegTissusmousvsCerveau" 			then effect = "Soft tissues sarcoma";

if effect = "typegAutresvsNephroblastome" 				then effect = "Others";
if effect = "typegGonadesvsNephroblastome" 				then effect = "Gonadal tumor";
if effect = "typegLymphomevsNephroblastome" 			then effect = "Lymphoma";
if effect = "typegCerveauvsNephroblastome" 				then effect = "CNS tumor";
if effect = "typegNeuroblastomevsNephroblastome" 		then effect = "Neuroblastoma";
if effect = "typegOsvsNephroblastome" 					then effect = "Bone sarcoma";
if effect = "typegRetinoblastomevsNephroblastome" 		then effect = "Retinoblastoma";
if effect = "typegThyroïdevsNephroblastome" 			then effect = "Thyroid tumor";
if effect = "typegTissusmousvsNephroblastome" 			then effect = "Soft tissues sarcoma";

if effect = "type_bsOsvsAutres" 					then effect = "Bone sarcoma";
if effect = "type_bsTissusmousvsAutres" 			then effect = "Soft tissues sarcoma";


if effect = "ttt_era1980-1989vs1990andmore" 	then effect = "1980-1989";
if effect = "ttt_erabefore1980vs1990andmore" 	then effect = "before 1980";
if effect = "trtCTandRTvsSurgeryonly" 			then effect = "CT and RT";
if effect = "trtCTnoRTvsSurgeryonly"			then effect = "CT no RT";
if effect = "trtRTnoCTvsSurgeryonly"			then effect = "RT no CT";
if effect = "age_start" 						then effect = "";
if effect = "chirMajorvsOther" 					then effect = "Major surgery";
if effect = "chirMinorvsOther" 					then effect = "Minor surgery";
if effect = "c_age_diagA0-3vsE15andmore" 		then effect = "A 0-3";
if effect = "c_age_diagB4-8vsE15andmore" 		then effect = "B 4-8";
if effect = "c_age_diagC9-11vsE15andmore"		then effect = "C 9-11";
if effect = "c_age_diagD12-14vsE15andmore" 		then effect = "D 12-14";
if effect = "c_age_startA0-10vsEMorethan40" 	then effect = "A 0-10";
if effect = "c_age_startB11-20vsEMorethan40" 	then effect = "B 11-20";
if effect = "c_age_startC21-30vsEMorethan40"	then effect = "C 21-30";
if effect = "c_age_startD31-40vsEMorethan40" 	then effect = "D 31-40";

if effect = "c_fupA<20vsE50andmore" 	then effect = "A 0-20";
if effect = "c_fupB20-29vsE50andmore" 	then effect = "B 20-29";
if effect = "c_fupC30-39vsE50andmore"	then effect = "C 30-39";
if effect = "c_fupD40-49vsE50andmore" 	then effect = "D 40-49";

if effect = "c_dose_moyB]0;5]vsANone" 	then effect = "B ]0;5]";
if effect = "c_dose_moyC]5;10]vsANone" 	then effect = "C ]5;10]";
if effect = "c_dose_moyD]10;20]vsANone" then effect = "D ]10;20]";
if effect = "c_dose_moyE]20;40]vsANone" then effect = "E ]20;40]";
if effect = "c_dose_moyF>40vsANone" 	then effect = "F >40";
if effect = "rtYesvsNo" 	then effect = "Yes";
if effect = "ctYesvsNo" 	then effect = "Yes";

if effect = "card_before_end1vs0" 	then effect = "Yes";
if effect = "diabete1vs0" 			then effect = "Yes";
if effect = "renal_before_end1vs0" 	then effect = "Yes";
if effect = "K2_before_end1vs0" 	then effect = "Yes";

if effect = "c_vol_5C]0;50%]vsB0%" 		then effect = "C ]0;50%]";
if effect = "c_vol_5D]50%;100%]vsB0%" 	then effect = "D ]50%;100%]";
if effect = "c_vol_20C]0;10%]vsB0%" 	then effect = "C ]0;10%]";
if effect = "c_vol_20D]10;50%]vsB0%" 	then effect = "D ]10;50%]";
if effect = "c_vol_20E]50%;100%]vsB0%" 	then effect = "E ]50%;100%]";
if effect = "c_vol_30C]0;10%]vsB0%" 	then effect = "C ]0;10%]";
if effect = "c_vol_30D]10;50%]vsB0%" 	then effect = "D ]10;50%]";
if effect = "c_vol_30E]50%;100%]vsB0%" 	then effect = "E ]50%;100%]";
if effect = "c_vol_40C]0;10%]vsB0%" 	then effect = "C ]0;10%]";
if effect = "c_vol_40D]10%;100%]vsB0%" 	then effect = "D ]10%;100%]";
if effect = "c_d95_cervC]0;5]vsB0" 	then effect = "C ]0;5]";
if effect = "c_d95_cervD>5vsB0" 	then effect = "D >5";
if effect = "c_d05_cervC]0;15]vsB0" then effect = "C ]0;15]";
if effect = "c_d05_cervD>15vsB0" 	then effect = "D >15";

if effect = "anthra1vs0" 	then effect = "Yes";
if effect = "doxo1vs0" 		then effect = "Yes";
if effect = "dauno1vs0" 	then effect = "Yes";
if effect = "alkyl1vs0" 	then effect = "Yes";
if effect = "cisp1vs0" 		then effect = "Yes";
if effect = "vinca1vs0"		then effect = "Yes";

if effect = "deces1vs0" 	then effect = "Yes";

if effect = "tabac1vs0" 	then effect = "Yes";
if effect = "alcool1vs0" 	then effect = "Yes";
if effect = "tabac_before_end1vs0" 	then effect = "Yes";
if effect = "alcool_before_end1vs0" 	then effect = "Yes";
if effect = "fdep13_Q1vs0" 	then effect = "1";
if effect = "fdep13_Q2vs0" 	then effect = "2";
if effect = "fdep13_Q3vs0" 	then effect = "3";
if effect = "fdep13_Q4vs0" 	then effect = "4";

/*On compile les OR + IC95% ensemble. Si < 1 on garde 2 chiffres apres la virgule, sinon un seul*/
if OddsRatioEst gt 1 	then OR_G3_fmt = put(round(OddsRatioEst, 0.1),4.1);
if LowerCL gt 1 		then L_G3_fmt = put(round(LowerCL, 0.1),4.1);
if UpperCL gt 1 		then U_G3_fmt = put(round(UpperCL, 0.1),4.1);
if OddsRatioEst le 1 	then OR_G3_fmt = put(round(OddsRatioEst, 0.01),4.2);
if LowerCL le 1 		then L_G3_fmt = put(round(LowerCL, 0.01),4.2);
if UpperCL le 1 		then U_G3_fmt = put(round(UpperCL, 0.01),4.2);
OR_G3 = cat(OR_G3_fmt," ","(",L_G3_fmt," -",U_G3_fmt,")");
keep varname effect OR_G3;
run;



/*On cree une table avec les references (on procede en 2 etapes car sinon probleme de format pour la variable "effect")*/
data ref;
set ac;
varname = effect;
keep varname;
run;
data ref;
set ref;
format effect $42.;
/*On met un espace au debut du libelle pour que la reference soit situee en premiere position*/
if varname = "Sexe" 		then effect = " Men";
/*if varname = "typeg" 		then effect = " CNS tumor";*/
if varname = "typeg" 		then effect = " Nephroblastoma";
if varname = "type_bs" 		then effect = " Other";
if varname = "ttt_era" 		then effect = " 1990 and more";
if varname = "trt" 			then effect = " Surgery only";
if varname = "chir" 		then effect = " Other";
if varname = "c_age_diag" 	then effect = " E 15 and more";
if varname = "c_fup" 		then effect = " E 50 and more";
if varname = "c_age_start" 	then effect = " E More than 40";
if varname = "c_dose_moy" 	then effect = " A None";
if varname = "diabete" 			then effect = " No";
if varname = "K2_before_end" 	then effect = " No";
if varname = "renal_before_end" then effect = " No";
if varname = "card_before_end" 	then effect = " No";
if varname = "c_vol_5" 			then effect = " A 0%";
if varname = "c_vol_10" 	then effect = " A 0%";
if varname = "c_vol_20" 	then effect = " A 0%";
if varname = "c_vol_30"		then effect = " A 0%";
if varname = "c_vol_40" 	then effect = " A 0%";
if varname = "anthra" 	then effect = " No";
if varname = "doxo" 	then effect = " No";
if varname = "dauno" 	then effect = " No";
if varname = "alkyl" 	then effect = " No";
if varname = "cisp" 	then effect = " No";
if varname = "deces" 	then effect = " No";
if varname = "alcool" 	then effect = " No";
if varname = "tabac" 	then effect = " No";
if varname = "alcool_before_end" 	then effect = " No";
if varname = "tabac_before_end" 	then effect = " No";
if varname = "fdep13_Q" 	then effect = " 0";
if varname = "c_d95_cerv" 	then effect = " 0";
if varname = "c_d05_cerv" then effect = " 0";
if varname = "rt" 	then effect = " No";
if varname = "ct" 	then effect = " No";

OR_G1 = "ref.";
OR_G2 = "ref.";
OR_G3 = "ref.";

keep varname effect OR_G1 OR_G2 OR_G3 ;
/*Pas de references quand donnees continues*/
if varname = "age_diag" or varname = "age_start" then delete;
run;

/**/
/*On ajoute les pvalues*/
data pv;
set global;
rename effect = varname;
keep effect ProbChiSq;
run;
data pv;
set pv;
format effect $42.;
if varname = "Sexe" 		then effect = " Men";
/*if varname = "typeg" 		then effect = " CNS tumor";*/
if varname = "typeg" 		then effect = " Nephroblastoma";
if varname = "type_bs" 		then effect = " Other";
if varname = "ttt_era" 		then effect = " 1990 and more";
if varname = "trt" 			then effect = " Surgery only";
if varname = "chir" 		then effect = " Other";
if varname = "c_age_diag" 	then effect = " E 15 and more";
if varname = "c_age_start" 	then effect = " E More than 40";
if varname = "c_fup" 		then effect = " E 50 and more";
if varname = "c_dose_moy" 	then effect = " A None";
if varname = "c_vol_5" 		then effect = " A 0%";
if varname = "c_vol_20" 	then effect = " A 0%";
if varname = "c_vol_30" 	then effect = " A 0%";
if varname = "c_vol_40" 	then effect = " A 0%";

if varname = "diabete" 			then effect = " No";
if varname = "K2_before_end" 	then effect = " No";
if varname = "renal_before_end" then effect = " No";
if varname = "card_before_end" 	then effect = " No";

if varname = "anthra" 	then effect = " No";
if varname = "doxo" 	then effect = " No";
if varname = "dauno" 	then effect = " No";
if varname = "alkyl" 	then effect = " No";
if varname = "cisp" 	then effect = " No";
if varname = "vinca" 	then effect = " No";
if varname = "deces" 	then effect = " No";
if varname = "alcool" 	then effect = " No";
if varname = "tabac" 	then effect = " No";
if varname = "alcool_before_end" 	then effect = " No";
if varname = "tabac_before_end" 	then effect = " No";
if varname = "fdep13_Q" 	then effect = " 0";
if varname = "c_d95_cerv" 	then effect = " 0";
if varname = "c_d05_cerv" then effect = " 0";
if varname = "rt" 	then effect = " No";
if varname = "ct" 	then effect = " No";

run;


/**/


/*On compile les tables ensemble*/
%tri(OR_G1, varname effect);
%tri(OR_G2, varname effect);
%tri(OR_G3, varname effect);
data sortie_OR;
merge OR_G1 OR_G2 OR_G3 ;
by varname effect;
run;
data sortie_OR2;
set sortie_OR ref;
run;
%tri(sortie_OR2, varname effect);
%tri(pv, varname effect);
data sortie_OR;
merge sortie_OR2 pv;
by varname effect;
run;
data sortie_OR;
retain factor;
set sortie_OR;
format factor $42.;
if varname = "Sexe" 		then factor = "Sex";
if varname = "typeg" 		then factor = "Primary neoplasm";
if varname = "type_bs" 		then factor = "Primary neoplasm";
if varname = "ttt_era" 		then factor = "Treatment era (year)";
if varname = "trt" 			then factor = "Primary neoplasm treatment";
if varname = "chir" 		then factor = "Surgery";
if varname = "age_diag" 	then factor = "Age at primary neoplasm (year)";
if varname = "age_start" 	then factor = "Age at 01/01/2006 (year)";
if varname = "c_fup" 		then factor = "Follow-up (year)";
if varname = "c_age_diag" 	then factor = "Age at primary neoplasm (year)";
if varname = "c_age_start" 	then factor = "Age at 01/01/2006 (year)";
if varname = "c_dose_moy" 	then factor = "Mean radiation dose to brain (Gy)";
if varname = "c_vol_5" 		then factor = " V5 Brain";
if varname = "c_vol_10" 	then factor = " V10 Brain";
if varname = "c_vol_20" 	then factor = " V20 Brain";
if varname = "c_vol_30" 	then factor = " V30 Brain";
if varname = "c_vol_40" 	then factor = " V40 Brain";

if varname = "diabete" 			then factor = "Diabetes mellitus";
if varname = "K2_before_end" 	then factor = "Secondary malignant neoplasm*";
if varname = "renal_before_end" then factor = "Kidney disease*";
if varname = "card_before_end" 	then factor = "Cardiac pathology*";
if varname = "card_before_end" 	then factor = "Cardiac pathology*";

if varname = "anthra" 	then factor = "Anthracyclines administration";
if varname = "doxo" 	then factor = "Doxorubicin administration";
if varname = "dauno" 	then factor = "Daunorubicin administration";
if varname = "alkyl" 	then factor = "Alkylating agents administration";
if varname = "cisp" 	then factor = "Cisplatin administration";
if varname = "vinca" 	then factor = "Vinca alkaloid administration";
if varname = "deces" 	then factor = "Death";
if varname = "alcool" 	then factor = "Alcohol-related conditions";
if varname = "tabac" 	then factor = "Smoking-related conditions";
if varname = "alcool_before_end" 	then factor = "Alcohol-related conditions";
if varname = "tabac_before_end" 	then factor = "Smoking-related conditions";
if varname = "fdep13_Q" 	then factor = " FDEP";
if varname = "c_d95_cerv" 	then factor = " D95(min) brain (Gy)";
if varname = "c_d05_cerv" then factor = " D05(max) brain (Gy)";
if varname = "rt" 	then factor = "Radiotherapy";
if varname = "ct" 	then factor = "Chemotherapy";

drop varname;
run;
%tri(sortie_OR, factor effect);
data sortie_OR;
set sortie_OR;
by factor;
if first.factor ne 1 then factor = "";
/*On enleve l espace au debut du libelle pour les ref*/
effect = cats(effect);
run;

/*On recupere les effectifs*/
data eff;
set eff;
rename count=nb;
if Outcome = "No/few delivery" then OrderedValue = 1;
if Outcome = "Decrease" then OrderedValue = 2;
if Outcome = "Increase" then OrderedValue = 3;
if Outcome = "High delivery" then OrderedValue = 4;
run;
proc sql;
select max(OrderedValue) into:max_eff1
from eff;
quit;
%let max_eff = %sysfunc(PUTn(&max_eff1,8.));
%do i = 1 %to &max_eff;
	%global n_G&i;
	proc sql;
	select nb into:G&i
	from eff
	where OrderedValue = &i;
	quit;
	%let n_G&i = %sysfunc(PUTn(&&G&i,8.));
%end;

/*Tableau recapitulatif*/
options mprint mlogic;
ods rtf file="&path_out.\&date. &nom..rtf"
style=statistical fontscale=75 ;

proc report data=sortie_OR

split='#' headline headskip

   style(report)=[rules       = groups
                  background  = white
                  bordercolor = white
				   borderwidth = .2cm
				  frame = hsides]
				 

   style(header)=[background  = white
                  font_size   = 7pt
                  font_face   = 'Arial'
                  borderbottomcolor=black
				  bordertopcolor=black
				  bordertopwidth=.5pt
                  foreground=black
                  bordertopwidth=.5pt
                  just = c]

   style(column)=[font_size   = 7pt
                  font_face   = 'Arial'
                  cellwidth   = 2 cm
                  just        = l];

define Factor / 'Factor'   center;
define effect / 'Level'   center;
define OR_G1 / "Decrease group n=&n_G2" center;
define OR_G2 / "Increase group n=&n_G3" center;
define OR_G3 / "High delivery group n=&n_G4" center;
define ProbChiSq / 'Pvalues' center;
title1 "Table-XX - Multinomial Logistic Regression of Factors Associated With Opioid Delivery Trajectory-Group Membership (v No/few delivery group, n=&n_G1), from the FCCSS cohort from 2006 to 2022";
run;

options orientation=portrait;
ods rtf close;
/*suppression des tables temporaires et des macrovariables*/
/*%supp(OR_G1 OR_G2 OR_G3  global PV sortie_OR sortie_OR2);*/
%do i = 1 %to 4;
	%SYMDEL n_G&i G&i;
%end;
%mend;
