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

# Loading the full RHoMIS dataset to identify the individual
# projects and the individual forms (to split the whole dataset)
# into "Chunks" (as is the case in the main database)
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


# Actually writing the files to the database
for (file in files){
    # Read in the file

    print(file)
    print(paste(which(files==file), "out of", length(files)))



     data <- suppressMessages(readr::read_csv(file, col_types = cols()))


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
            # Sticking on 5
            data_chunk <- data[data$id_rhomis_dataset==chunk$id_rhomis_dataset,]    
            
            # Splitting into smaller chunks
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
                # Split by project and form

    for (chunk in data_chunks){
            
            data_chunk <- data[chunk$rows,]
            proj_id <- chunk$proj_id
            form_id <- chunk$form_id

             df_memory <- as.numeric(object.size(data_chunk))
            df_memory_limit <- 1250000
            if (df_memory>df_memory_limit)
            {
                divisions <- ceiling(df_memory/df_memory_limit)
                sub_chunk_size <- floor(nrow(data_chunk)/divisions)
                n <- nrow(data_chunk)
                r  <- rep(1:ceiling(n/sub_chunk_size),each=sub_chunk_size)[1:n]
                chunked_data <- split(data_chunk,r)
                
                data_chunk <- chunked_data[[1]] 
            }


            save_data_set_to_db(
            data = data_chunk,
            data_type = data_type,
            database = "rhomis-data-test",
            url = "mongodb://localhost",
            projectID = proj_id,
            formID = form_id
        )         
        }

    }


    # print(paste(is_data_set,is_unit_conversion, is_original_conversion,sep="    "))
    # print("")
}

data_string <- jsonlite::toJSON(data, pretty = T, na = "null")
    connection <- connect_to_db(collection, database, url)
    if (overwrite == F) {
        data_string <- paste0("{\"projectID\":\"", projectID, 
            "\",\"formID\":", formID, "\"dataType\":", data_type, 
            ", \"data\"", ":", data_string, "}")
        data_string <- gsub("\n", "", data_string, fixed = T)
        data_string <- gsub("\\\"", "\"", data_string, fixed = T)
        data_string <- gsub("\"\\", "\"", data_string, fixed = T)
        connection$insert(data_string)
    }
    if (overwrite == T) {
        connection$update(paste0("{\"projectID\":\"", projectID, 
            "\",\"formID\":\"", formID, "\"}"), paste0("{\"$set\":{\"data\": ", 
            data_string, "}}"), upsert = TRUE)
    }
    connection$disconnect()


#save_set_of_conversions
#add_data_to_db



 for (chunk in data_chunks){
     print(chunk$rows)
 }
