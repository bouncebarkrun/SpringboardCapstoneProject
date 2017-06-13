# Import data packages
install.packages("dplyr")
install.packages("readr")
install.packages("tidyr")
install.packages("rmarkdown")

#Load data packages
library("dplyr")
library("readr")
library("tidyr")
library("rmarkdown")

#Import data sets
Master <- read_csv("C:/Users/mmcnamara/Desktop/Master.csv")
Scoring <- read_csv("C:/Users/mmcnamara/Desktop/Scoring.csv")
Draft <- read_csv("C:/Users/mmcnamara/Desktop/DraftData.csv")
Teams <- read_csv("C:/Users/mmcnamara/Desktop/Teams.csv")

#Convert datasets to a tbl class for easier viewing
tbl_df(Master)
tbl_df(Scoring)
tbl_df(Draft)
tbl_df(Teams)

#Start cleaning up column names to be more easily understood
colnames(Master) <- c("Player_ID", "Coach_ID", "HallFame_ID", "First_Name", "Last_Name", "Name_Notes", "Given_Name", "Nickname", "Height", "Weight", "Shooting_Hand", "legendsID", "ihdbID", "hrefID", "FirstNHLseason", "LastNHLseason", "FirstWHAseason", "LastWHAseason", "Position_Played", "Birth_Year", "Birth_Month", "Birth_Day", "Birth_Country", "Birth_State", "Birth_City", "Death_Year", "Death_Month", "Death_Day", "Death_Country", "Death_State", "Death_City")
colnames(Scoring) <- c("Player_ID", "Season", "Stint", "Team_ID", "League_ID", "Position", "Games_Played", "Goals", "Assists", "Points", "Penalty_Minutes", "Plus_Minus", "PP_Goals", "PP_Assists", "SH_Goals", "SH_Assists", "Gamewinning_Goals", "GameTying_Goals", "Shots", "PS_Games", "PS_Goals", "PS_Assists", "PS_Points", "PS_PenaltyMin", "PS_PlusMinus", "PS_PowerplayG", "PS_PowerplayA", "PS_ShorthandedG", "PS_ShorthandedA", "PS_GamewinningG", "PS_Shots")
colnames(Draft) <- c("Draft_Pick", "Draft_Year", "Draft_Team", "Player", "Draft_Age", "LastYearPlayed", "Amateur_Team")
colnames(Teams) <- c("Year", "League_ID", "Team_ID", "FranchiseID", "Conference_ID", "Division_ID", "SeasonEnd_Rank", "Playoff_Result", "Team_Total_Games", "Team_Wins", "Team_Losses", "Team_Ties", "Team_OT_Losses", "Team_Points", "Team_ShootoutWins", "Team_ShootoutLosses", "Team_GoalsFor", "Team_GoalsAgainst", "TeamName", "Team_PenaltyMin", "Team_BenchMinors", "Team_PPG", "Team_PPC", "Team_SHA", "Team_PKG", "Team_PKC", "Team_SHF")

#Separate player name and Player_ID from each other in Draft database
Draft <- separate(Draft, Player, into = c("Player", "Player_ID"), sep = "/")

#Join datasets
MergedData <- merge(Master, Scoring, by = "Player_ID")
AllData <- merge(MergedData, Draft, by = "Player_ID")

#Remove some unnecessary columns
PlayerFilter <- select(AllData, -Position, -Player, -ihdbID, -League_ID, -Coach_ID, -HallFame_ID, -Name_Notes, -Given_Name, -Nickname, -legendsID, -hrefID, -FirstWHAseason, -LastWHAseason, -LastYearPlayed)
TeamFilter <- select(Teams, -League_ID, -FranchiseID)

#Subset the dataset to the period of interest (the 2000-2011 seasons)
PlayerData <- subset(PlayerFilter, Season >= 2000)
TeamData <- subset(TeamFilter, Year >= 2000)

#Convert multiple fields to factors and integers
playercols <- c("Position_Played", "Team_ID", "Birth_Country", "Birth_City", "Birth_State", "Death_Country", "Death_City", "Death_State", "Shooting_Hand", "Draft_Team", "Amateur_Team")
PlayerData[playercols] <- lapply(PlayerData[playercols], factor)
teamfactor <- c("Team_ID", "Conference_ID", "Division_ID", "Playoff_Result", "TeamName")
TeamData[teamfactor] <- lapply(TeamData[teamfactor], factor)
teamnum <- c("Team_OT_Losses", "Team_ShootoutWins", "Team_ShootoutLosses")
TeamData[teamnum] <- lapply(TeamData[teamnum], as.numeric)

#Look at new datasets
summary(PlayerData)
summary(TeamData)

#Assess NA values
is.na(PlayerData)
is.na(TeamData)
#NAs in certain fields are acceptable as they aren't applicable to some players: death statistics (many players haven't died as yet)
#Scoring statistics are NA where players or teams did not contribute to these stats during a season. These will be replaced with a 0.
NAcols <- c("Games_Played", "Goals", "Assists", "Points", "Penalty_Minutes", "Plus_Minus", "PP_Goals", "PP_Assists", "SH_Goals", "SH_Assists", "Gamewinning_Goals", "GameTying_Goals", "Shots", "PS_Games", "PS_Goals", "PS_Assists", "PS_Points", "PS_PenaltyMin", "PS_PlusMinus", "PS_PowerplayG", "PS_PowerplayA", "PS_ShorthandedG", "PS_ShorthandedA", "PS_GamewinningG", "PS_Shots")
PlayerData[NAcols][is.na(PlayerData[NAcols])] <- 0
NAteam <- c("Team_Ties", "Team_ShootoutWins", "Team_ShootoutLosses")
TeamData[NAteam][is.na(TeamData[NAteam])] <- 0


#Look at the final cleaned up datasets
summary(PlayerData)
summary(TeamData)

#Save the cleaned up datasets
write.csv(PlayerData, file = "C:/Users/mmcnamara/Desktop/PlayerData_clean.csv")
write.csv(TeamData, file = "C:/Users/mmcnamara/Desktop/TeamData_clean.csv")