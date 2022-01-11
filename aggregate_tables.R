# Install dependencies
pkgs <- c("dplyr", "lubridate", "data.table")
deps <- lapply(pkgs, library, character.only = T)


# Read raw data
raw_files <- list.files(pattern = "*.csv")
var_names <- gsub(pattern = "*.csv", replacement = "", x = raw_files)
var_names <- gsub(pattern = "\\_.*", replacement = "", x = var_names)

for (i in 1:length(raw_files)){
  var_name <- var_names[i]
  raw_name <- raw_files[i]
  assign(x     = var_name,
         value = fread(file = raw_name))
}

rm(deps, i, pkgs, raw_files, raw_name, var_name, var_names)


# Group production reports by days in order to make all tables into one format
production <- production[, .(qty = sum(prod_h)), by = day]
holidays   <- holidays[, .SD, .SDcols = c('day', 'holiday')]


# Merge all data tables into resulting table
dt_list   <- list(production, inventory, holidays, repair)
merge_f   <- function(...){merge(..., all = T, by = 'day')}
result_dt <- Reduce(merge_f, dt_list)
rm(merge_f, dt_list)

# Save results
write.csv(result_dt, file = "aggregated_data.csv", row.names = F)
