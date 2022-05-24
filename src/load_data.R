library(rhomis)
library(readr)
library(dplyr)
library(tibble)

# Loading functions
source("src/utils.R")


# Identifying all of the relevant files in the "data" 
# folder
files <- list.files("data", all.files=T, recursive=T)
files <- files[grep("csv",files)]
files <- paste0("./data/", files)

# All of the folders containing confirmed unit conversions
conversions <- c("mean_prices/","calorie_conversions/","units_and_conversions/")

# All of the folders containing the original unit conversions
# before they were verified by users
original_conversions <- c(".original_calorie_conversions/",".original_mean_prices_conversions/",".original_units/")

new_calorie_files <- files[grep("calorie_conversions", files )]
shorten_file_names(new_calorie_files)


processed_data <- readr::read_csv("data/processed_data/processed_data.csv")

rhomis_ids <- unique(processed_data$id_rhomis_dataset)

data_chunks <- sapply(rhomis_ids, function(rhomis_id){
    rows <- which(processed_data$id_rhomis_dataset==rhomis_id)
    proj_id <- unique(processed_data$id_proj[rows])
        form_id <- unique(processed_data$id_form[rows])

    if (length(proj_id)>1){
        print(proj_id)
        stop("More than one proj ID")
    }

     if (length(form_id)>1){
        stop("More than one form ID")
    }

    return(list(
        id_rhomis_dataset=rhomis_id,
        rows=rows,
        proj_id=proj_id,
        form_id=form_id
    ))

}, simplify=F)



for (file in files){
    # Read in the file
     data <- readr::read_csv(file)


    #' Check whether it is a unit
    #' conversion, an original 
    #' conversion or a dataset
    is_original_conversion <- any(unlist(lapply(original_conversions, function(x) grepl(x, file))))

    is_unit_conversion <- any(unlist(lapply(conversions, function(x) grepl(x, file))))
    is_unit_conversion <- (is_unit_conversion & !is_original_conversion) 

    is_data_set <- (!is_unit_conversion & !is_original_conversion) 
    


    # Write units
    if (is_unit_conversion){
        conversion_type <- get_file_name(file)

        # Split by project and form
        for (chunk in data_chunks){
            
            data_chunk <- data[data$id_rhomis_dataset==chunk$id_rhomis_dataset,]
            proj_id <- chunk$proj_id
            form_id <- chunk$form_id

            save_set_of_conversions(
                database="rhomis-data-test",
                url = "mongodb://localhost",
                projectID = proj_id,
                formID = form_id,
                conversions=data_chunk,
                conversion_type=conversion_type,
                collection="units_and_conversions",
                converted_values = T   
            )
        }
    }

        if (is_original_conversion){
         conversion_type<- get_file_name(file)
        # Split by project and form
        for (chunk in data_chunks){
            
            data_chunk <- data[data$id_rhomis_dataset==chunk$id_rhomis_dataset,]            
            proj_id <- chunk$proj_id
            form_id <- chunk$form_id

            save_set_of_conversions(
                database="rhomis-data-test",
                url = "mongodb://localhost",
                projectID = proj_id,
                formID = form_id,
                conversions=data_chunk,
                conversion_type=conversion_type,
                collection="unmodified_units",
                converted_values = T   
            )
        }
    }

    # Write Dataset
    if (is_data_set){
        data_type<- get_file_name(file)
    for (chunk in data_chunks){
            
            data_chunk <- data[chunk$rows,]
            proj_id <- chunk$proj_id
            form_id <- chunk$form_id

        # Split by project and form
            add_data_to_db(
                data=data_chunk,
                collection = "data",
                data_type=data_type,
                database = "rhomis-data-test",
                url = "mongodb://localhost",
                projectID=proj_id,
                formID=form_id,
                overwrite = F
            )
        }

    }


    print(file)
    # print(paste(is_data_set,is_unit_conversion, is_original_conversion,sep="    "))
    # print("")
}


#save_set_of_conversions
#add_data_to_db



 for (chunk in data_chunks){
     print(chunk$form_id)
 }
