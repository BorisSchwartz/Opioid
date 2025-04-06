# Opioid
SAS program created by Boris Schwartz, CESP-INSERM-U1018 Radiation Epidemiology Team (France) - 2025

Long-term opioid use in survivors of childhood cancer: Results from the French Childhood Cancer Survivor Study

Free space required on your computer : 30 Go. Note: Some warnings may appear in the log, but this has no effect on the program. 
Note: results appear as sas tables and/or rtf files (Word format). These are crude internal working documents. 
Result tables in the article have been formatted then from these documents. Run time: 1000 seconds.
Note: comments in code appears in French (sometimes in English) as this is the native language of Boris Schwartz.

Save sankey scripts (rawtosankey.sas, sankey.sas and sankeybarchart.sas in your folder before execute program).
Download and find information on Proc TRAJ at: https://www.andrew.cmu.edu/user/bjones/

Global program (OPIOID STUDY - BS.SAS) with:

1. Set up (change folders and library according to your computer to execute the following program)

2. Frequently used macros

3. Work databases: 2 files, the first with one line per delivery, the second with one line per patient

4. Description of the population

5. Annual prevalence

6. Creation of binary indicators for opioid use, per year and overall

7. Sankey diagram (/*Save sankey scripts (rawtosankey.sas, sankey.sas and sankeybarchart.sas in your folder before execute program). SAS Sankey macro created by Shane Rosanbalm of Rho, Inc. 2015 https://github.com/RhoInc/sas-sankeybarchart*/)

8. Definition of the trajectory groups (/*Not modified. To be adapted for the test dataset that is shorter than the dataset for analyze and anonymized*/)

9. Multinomial regression

10. Description of trajectory groups
