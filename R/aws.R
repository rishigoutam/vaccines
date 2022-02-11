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
# https://awsgoutamorg-bucket.s3.us-west-2.amazonaws.com/Vaccines.gov__COVID-19_vaccinating_provider_locations.csv?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEAcaCXVzLXdlc3QtMiJHMEUCIQDm5HR5zBrGHMJlOZAHwd817xuSCo%2FtmQ7%2BeH2bSFKGhgIgSWIVkMBQ%2B808NhDvYVpBqhbPLXXtbuf2jmE7aritLtsq5AIIUBAAGgwyMDUzNjEzNjQ4MjQiDJ2RXCa4MRpZxkiqQyrBAjuYQ3N0yoC4iPEdO3ZNLM9HvvXOwA1se2%2BsucDn9jEEpJfDjC29f%2FheNEZiCuOwvYMCgrB0GvI2eX%2FzFzMlHN%2BqoqqsLeEtHL9C9i5ocXplkviXbqb8JRnx%2Bk%2Bt%2Bgz0rIvLJ9q7C2tf8uGCvXVSKkA6M93qdSjlTZc4p6NUnx9TPdQhHqMSVx1uljne5qo3rRQE5RunBrYDx5jqIF%2FIxawDGbCsK78QKjjJOKVonb%2B%2FXrGIzuVn%2Fs0KqwbVuJzXbfZfPJr2Pz8ffkEUweZJgyy4Uu77%2FGvpc4rulV6SeQowilnY6Nr%2B%2B20q9BXGJ2EBEjbKjyFfdBbJ%2F%2F1Itpz5Z3mgM6benezT%2FH8OxKLR3jV3A6skirwQWBkcmIQfXGOo4kklNVfibNOXaJTTvpjJ1IqhiZOkVoLjH3VyocP8gs43MTCbyZuQBjqzApBnUFTsn8JVvMIOFe45CRt42VkDm4kNjy3bMSQbaauOfjIbCuu1FbM883xiAVnSNHBfhZqI5y0QgFBPRfegwVWUwPM1I5MdgVovy%2Fq4sDwLyzds2IOuHvHPLueo%2BYiDeNHssBZFco%2BYT1A%2Fn1OV5mSY%2BxiWORBPyYuyKnrvFaITgVdlMmmlk8H%2F%2B2kcFvRAMziUpFuNWnZ0fbkXvtpEALR%2F0Tk7s0RHm2dQZIlPabHuPWkyVSZ1GuevNL4nHsial5%2Bjdg07bVpz3ww45ktEs0VG4B%2FQqlC53grGrTuDAioJ08cEV7ZTXdjbewj5zC9JKffjuGO%2FAkUvXgtwp%2BrZdgAERuyk%2F8FgvBO17invkyBntrF8IUS8cdQd5R0hxlgtmW14PS%2FjRIAqrvOBxTw%2BPVYNaf8%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220211T230508Z&X-Amz-SignedHeaders=host&X-Amz-Expires=604800&X-Amz-Credential=ASIAS7UD5X5MEYKPVGGL%2F20220211%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=a95436411e4e956dde863009301e54adb5b0ee12ad08890d5f2171bc0a0ae2d8
