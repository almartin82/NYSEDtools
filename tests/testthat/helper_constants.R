#everything here gets run before tests
root <- rprojroot::find_root(rprojroot::is_rstudio_project)
path_to_raw_data = file.path(root, 'inst', 'raw-data')

#sirs301 objects
raw_301 <- NYSEDtools::sirs301_import_csvs(path = path_to_raw_data)
demo_301 <- NYSEDtools::sirs301(csvs = raw_301)

#studentids for reports
gr6 <- demo_301$ela_math %>%
  dplyr::filter(location_name == 'DEMO SCHOOL' & test_grade == 6 & test_year == 2017) %>%
  dplyr::select(student_id) %>%
  unlist() %>% unname() %>% unique()
