# AWS S3 info and testing

library(aws.s3)
library(tidyverse)

s3covid <- s3read_using(FUN = read_csv, bucket = 'awsgoutamorg-bucket', object = 'Vaccines.gov__COVID-19_vaccinating_provider_locations.csv')
View(s3covid)

# AWS Setup with R
# https://www.gormanalysis.com/blog/connecting-to-aws-s3-with-r/

# Set this in RStudio
# Sys.setenv(
#   "AWS_ACCESS_KEY_ID" = "KEY",
#   "AWS_SECRET_ACCESS_KEY" = "SECRET",
#   "AWS_DEFAULT_REGION" = "us-west-2"
# )

# File downloadable until 2022-02-17
# https://awsgoutamorg-bucket.s3.us-west-2.amazonaws.com/Vaccines.gov__COVID-19_vaccinating_provider_locations.csv?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEDoaCXVzLXdlc3QtMiJGMEQCIFELxoN0Q7MoYNzpzgpMPiCDAPsXeN0kXaT0M7LdDQljAiArJehONd%2FtAKbsg2e31vRzzdwfiPmvSTXrmJEaJX%2Fh7SrxAgiD%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAAaDDIwNTM2MTM2NDgyNCIM%2BD%2FmBjExJ6H9BOCvKsUC7lS5%2FQ%2FdHAQbNVvtUoGCdtbPmzuTgk0%2BxxTv3Ut7b4f3upwY1CYNhbhZXEwit81lS%2BtaZ%2Fa1ojQRxOHXyRQf6DIcS%2Bgi8dguituQt9%2FaoeCt1FMc49N6gYyze81YQwCKwF9CNsmbAJcWAwxy%2BBtHDlCGWplHv5XI9Hibne8kmPeEbksAUQQv3ycpE5CtG4fBKLqqU6dcC7XKXN7P35V0LXnT0%2FACVG1sGLmdplXLkzuF9wlb6oGWAjtMip9OAnnIKoASyUMxxL5HgCP1J9QpNXbKQw0MfrMPbJFvCYQDGhzc2K5UFDLG4mFc3oevpAXPFjQQi%2F3YubPYMV89iysmUGXT8N4G4yjNygZcrdMRX5RyuwN094%2FZJDK07mX7gMY%2B6EnzkhdzKS2jzP3vs8fwosiWebiL2k82XAcvf2n9JsC%2F5%2B8i9jCi86aQBjq0AgrX1ftUScLzrmhLSUVn57g35Pg%2FhIoWqLGPYERfZhW4PR8meys%2BbRFYp%2Fr80ONGSuixHOsdHPh%2BdMvfegqzT0OLx2mGFVW4DScTEqiZLK8KqqCV8rCPNxXnRb3aQPrsvFDvtazkUQ2NuGJVvaVBRcc8%2BO3fUUxQfKL6iokT2JldgHnXYP3vmUUQnHjE15aVfri%2BUO9VOEpBOsFgepITbCo2RLuk7CAfCGA60pUT9NWh%2BUdDBHB2GV97FUsNuLH662L4%2BuJNlVZygQL3WnlLORvUVaFtakK2vAzUU4%2FOvdA%2FG0GFezJaJWW3b9p%2FHR2aSpKa9WnyezE1nC%2F2r4ei6hWUuLBWziHB4TQ%2BZFPGCSOrg%2FBsPyHf47%2BpIc7shxINX64BOJ0oIMAkI%2Fefwzhv%2BDVlIzos&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220214T020857Z&X-Amz-SignedHeaders=host&X-Amz-Expires=604800&X-Amz-Credential=ASIAS7UD5X5MFGCKCWRE%2F20220214%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=6aeb44a9c07c336137de8212aca98d4511cec0a87fc5818d6be276368c4b39d2
