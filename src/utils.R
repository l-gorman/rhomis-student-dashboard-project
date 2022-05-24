get_file_name <- function(file_path){
    split_path <- unlist(strsplit(file_path,"/"))
    file_name <- split_path[length(split_path)]
    object_name <- gsub(".csv","",file_name, fixed=T)
    return(object_name) 
}

shorten_file_names <- function(file_paths){
    return(unlist(lapply(file_paths, function(x) get_file_name(x))))
}

split_by_project <- function(dataset){

}