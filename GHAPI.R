#install.packages("jsonlite")
require(jsonlite)
library(jsonlite)

#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)
#install.packages("rlang")
install.packages("devtools")
require(devtools)
library(devtools)

install_github('ramnathv/rCharts')

library(rCharts)




install.packages("plotly")
library(plotly)
require(plotly)




# Can be github, linkedin etc depending on application
oauth_endpoints("github")

# Change based on what you 
myapp <- oauth_app(appname = "GHAPI",
                   key = "976df76c83a3690ebbf0",
                   secret = "e48e987307c4f14f0578c470f39aeb42d23b30b5")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/jtleek/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
gitDF[gitDF$full_name == "jtleek/datasharing", "created_at"] 

#Code sourced from Michael Galarnyk's blog:
# https://towardsdatascience.com/accessing-data-from-github-api-using-r-3633fb62cb08

# -----------------------------------------------------------------------------------
# Interrogate the Github API. R will return the number of followers and public repositories
# in my GitHub account
#Basic details
myData = fromJSON("https://api.github.com/users/healys10")
myData$followers
myData$following
myData$id
myData$bio
myData$company
myData$gists_url
myData$email
myData$type
myData$site_admin
myData$public_gists
myData$public_repos



#followers
myFollowers = fromJSON("https://api.github.com/users/healys10/followers")
myFollowers$login  #user names of followers
length = length(myFollowers$login)
length #Number of followers
myFollowers$type
myFollowers$followers_url


#repos
repos <- fromJSON("https://api.github.com/users/healys10/repos")
repos$name #names your public repositories
repos$created_at # when repos were created
ass1 <- fromJSON("https://api.github.com/repos/healys10/ass1/commits")
ass1$commit$message #shows commit messages
repos$language #Languages of my repositories 
myLangs = repos$language
df_uniq = unique(myLangs)
length(df_uniq)
aggregate(data.frame(count = myLangs), list(value =myLangs), length) #Number of repositories with each language


#following
following = fromJSON("https://api.github.com/users/healys10/following") 
following$login #Details of the people I follow 
noFollowing = length(following$login)
noFollowing
following$type
following$following_url



#I can look at the info of other developers by changing the user name in
#the links above, and specifiying what it is that I want to view.

toconno5 <- fromJSON("https://api.github.com/users/toconno5/following")
toconno5$login

#Instead of viewing this information in a dataframe, i can convert it back to a
#JSon and study it this way, as it is viewed in a browser.

myDataJSon <- toJSON(myData, pretty = TRUE)
myDataJSon

#This gives me information as to the type of data available to me
#and which URLs i can make use of.

#Using functions makes it easier to get the information from another user for example
getFollowers <- function(username)
{
  URL <- paste("https://api.github.com/users/", username , "/followers", sep="")
  followers = fromJSON(URL)
  return (followers$login)
}
#We can now get the info without changing any code
getFollowers("cassidke")
#Functions like the one above can be called in the console so that changing code is not necessary to get info on different users.
#Functions for repositories and followers are below.

getFollowing <- function(username)
{
  URL <- paste("https://api.github.com/users/", username , "/following", sep="")
  followers = fromJSON(URL)
  return (followers$login)
}

getRepos <- function(username)
{
  URL <- paste("https://api.github.com/users/", username , "/repos", sep="")
  repos = fromJSON(URL) 
  return (repos$name)
}






#Using user 'phadej''s data for the following section
data = GET("https://api.github.com/users/phadej/followers?per_page=100;",gtoken)
extract = content(data)
githubDB = jsonlite::fromJSON(jsonlite::toJSON(extract))
githubDB$login
id=githubDB$login
user_ids = c(id)
#empty vector and data frame
users = c()
usersDB = data.frame(
  username = integer(),
  following = integer(),
  followers = integer(),
  repos = integer(),
  dateCreated = integer()
)


for(i in 1:length(user_ids))
{
  #Retrieve a list of individual users 
  followingURL = paste("https://api.github.com/users/", user_ids[i], "/following", sep = "")
  followingRequest = GET(followingURL, gtoken)
  followingContent = content(followingRequest)
  
  #Ignore if they have no followers
  if(length(followingContent) == 0)
  {
    next
  }
  
  followingDF = jsonlite::fromJSON(jsonlite::toJSON(followingContent))
  followingLogin = followingDF$login
  
  #Loop through 'following' users
  for (j in 1:length(followingLogin))
  {
    #Check that the user is not already in the list of users
    if (is.element(followingLogin[j], users) == FALSE)
    {
      #Add user to list of users
      users[length(users) + 1] = followingLogin[j]
      
      #Retrieve data on each user
      followingUrl2 = paste("https://api.github.com/users/", followingLogin[j], sep = "")
      following2 = GET(followingUrl2, gtoken)
      followingContent2 = content(following2)
      followingDF2 = jsonlite::fromJSON(jsonlite::toJSON(followingContent2))
      
      #Retrieve each users following
      followingNumber = followingDF2$following
      
      #Retrieve each users followers
      followersNumber = followingDF2$followers
      
      #Retrieve each users number of repositories
      reposNumber = followingDF2$public_repos
      
      #Retrieve year which each user joined Github
      yearCreated = substr(followingDF2$created_at, start = 1, stop = 4)
      
      #Add users data to a new row in dataframe
      usersDB[nrow(usersDB) + 1, ] = c(followingLogin[j], followingNumber, followersNumber, reposNumber, yearCreated)
      
    }
    next
  }
  #Stop when there are more than 400 users
  if(length(users) > 400)
  {
    break
  }
  next
}


Sys.setenv("plotly_username"="healys10")
Sys.setenv("plotly_api_key"="Vgft5JBZ088leAAcrbeE")


plot = plot_ly(data = usersDB, x = ~repos, y = ~followers, 
                text = ~paste("Followers: ", followers, "<br>Repositories: ", 
                              repos
                ))
plot
#Upload the plot to Plotly
Sys.setenv("plotly_username"="healys10")
Sys.setenv("plotly_api_key"="Vgft5JBZ088leAAcrbeE")
api_create(plot, filename = "Followers and Repos")
#PLOTLY LINK: https://plot.ly/~healys10/5



plot1 = plot_ly(data = usersDB, x = ~repos, y = ~followers, 
                text = ~paste("Followers: ", followers, "<br>Repositories: ", 
                              repos, "<br>Date Created:", dateCreated), color = ~dateCreated)
plot1

#Upload the plot to Plotly
Sys.setenv("plotly_username"="healys10")
Sys.setenv("plotly_api_key"="Vgft5JBZ088leAAcrbeE")
api_create(plot1, filename = "Followers and Repos by Date")
#PLOTLY LINK: https://plot.ly/~healys10/1


plot2 = plot_ly(data = usersDB, x = ~following, y = ~followers, 
                text = ~paste("Followers: ", followers, "<br>Following: ", 
                              following))
plot2

#Upload the plot to Plotly
Sys.setenv("plotly_username"="healys10")
Sys.setenv("plotly_api_key"="Vgft5JBZ088leAAcrbeE")
api_create(plot2, filename = "Followers vs Following")
#PLOTLY LINK: https://plot.ly/~healys10/3




#Looking at data from my own followers now


followersNames <- fromJSON("https://api.github.com/users/healys10/followers")
followersNames$login #User names of my followers as seen before




a <- "https://api.github.com/users/"
b <- followersNames$login[5]
b
c <- "/followers"

test <- sprintf("%s%s%s", a,b,c) #combines, b and c into one string 
test                              


#kennyc11's followers are now in test. 
#To get emmalouiser's followers link, change to:
# b <- followersNames$login[6] as she is number 6 on my followers list.











