#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)

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
aggregate(data.frame(count = myLanguages), list(value =myLanguages), length) #Number of repositories with each language


#following
following = fromJSON("https://api.github.com/users/healys10/following") 
following$login #Details of the people I follow 
noFollowing = length(following$login)
noFollowing
following$type
following$following_url


#I can look at the info of other developers by changing the user name in
#the links above, and specifiying what it is that I want to view.

emmalouiser <- fromJSON("https://api.github.com/users/emmalouiser/following")
emmalouiser$login

#Instead of viewing this information in a dataframe, i can convert it back to a
#JSon and study it this way, as it is viewed in a browser.

myDataJSon <- toJSON(myData, pretty = TRUE)
myDataJSon

#This gives me information as to the type of data available to me
#and which URLs i can make use of.

#This is the end of part 1 of the assignment.

#This is the beginning of part 2 of the assignment.

