library(tidyverse)
library(rvest)
library(httr)
library(jsonlite)

# Static HTML Scraping
# read the html of the page
challenge0 <- read_html("http://localhost:4321/demo/static-scraping")

# convert HTML table to tibble
challenge0 <- challenge0 |> html_element("#standings-table") |> 
  html_table()

# calculate the total number of wins across all teams
sum(challenge0$Wins)


# Finding Hidden APIs
# call the endpoint
challenge1 <- GET("http://localhost:4321/api/t1-results")

# convert the JSON response to tibble
challenge1 <- content(challenge1, "text") |> 
  fromJSON() |> 
  as_tibble() |> 
  unnest(data)

# find the duration of T1's first match
challenge1 |> slice(1) |> select(duration)


# Query Parameters
# call the endpoint
challenge2 <- GET("http://localhost:4321/api/matches?page=1&limit=20&winner=all")
challenge2 <- content(challenge2, "text") |>
  fromJSON()

# find the number of pages
totalpages <- challenge2$total_pages

# iterate through each page and convert JSON response to tibble
challenge2 <- map_dfr(1:totalpages, function(page) {
  GET(str_c("http://localhost:4321/api/matches?page=", page)) |>
    content("text") |>
    fromJSON() |>
    as_tibble() |> 
    unnest(data)
})

# Calculate how many matches the red side won
challenge2 |> filter(red_side == winner) |> nrow()

# Request/Response Headers
# call the endpoint
challenge3 <- GET("http://localhost:4321/demo/headers", 
                  add_headers("x-team-id" = "T1"))

# convert the HTML response to tibble
challenge3 <- content(challenge3, "text") |>
  read_html() |>
  html_element("table") |>
  html_table()

# find the coach for T1
challenge3 |> filter(Position == "Coach") |> select(Player)

# Bearer Token Authentication
token <- "u5bdZovYb6txRq8hWSImOOIvhMnEg_bqBZPIM4AdyA4"

# call the endpoint
challenge4 <- GET(
  str_c("http://localhost:4321/api/premium/player/faker"),
  add_headers(Authorization = paste("Bearer", token))
)

# convert the JSON response to tibble
challenge4 <- content(challenge4, "text") |>
  fromJSON() |>
  as_tibble() 

# Find the number of smurf account matches faker has
challenge4$smurf_account_matches