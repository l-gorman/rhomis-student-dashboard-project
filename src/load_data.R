library(rhomis)
library(readr)
library(dplyr)
library(tibble)


get_file_name <- function(file_path){
    split_path <- unlist(strsplit(file_path,"/"))
    file_name <- split_path[length(split_path)]
    object_name <- gsub(".csv","",file_name, fixed=T)
    return(object_name) 
}

shorten_file_names <- function(file_paths){
    return(unlist(lapply(file_paths, function(x) get_file_name(x))))


}

files <- list.files("data", all.files=T, recursive=T)
files <- files[grep("csv",files)]


new_calorie_files <- files[grep("calorie_conversions", files )]
shorten_file_names(new_calorie_files)



