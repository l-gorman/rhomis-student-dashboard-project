
if ("renv" %in% installed.packages()==F){
    installed.packages("renv")
}

library(renv)
renv::restore()