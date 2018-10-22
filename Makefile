pooledData.csv: Governors.csv Crime.csv Politics.sav
	Rscript A_Generic_Rscript_Name.R

project_2.html: pooledData.csv A_Generic_Rscript_Name.R Project_3_3.Rmd
	Rscript Another_Generic_RScript_Name.R
