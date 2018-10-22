pooledData.csv: 
	Rscript A_Generic_Rscript_Name.R

project_2.html: pooledData.csv A_Generic_Rscript_Name.R Project_3_3.Rmd
	Rscript Another_Generic_RScript_Name.R

assumptions.html: pooledData.csv A_Generic_Rscript_Name.R Project_3_Assumptions.Rmd
	Rscript A_Third_Rscript_Name.R

project_2_workflow.png: makefile2graph/make2graph
	make project_2_workflow.png -Bnd | ./makefile2graph/make2graph | dot -Tpng -o project_2_workflow