library(RMySQL)
drv = dbDriver("MySQL")
con = dbConnect(drv,host="127.0.0.1",dbname="eth_base",user="root",pass="1234")

#how many project are indentified for analysis?

print("How many projects are identified for analysis?")
query<-"select count(distinct project_name) 
from pull_request_data";
pr_count=dbGetQuery(con,statement=query)
print(sprintf("Total %s projects are identified for analysis",pr_count))

#What are the languages in which these projects are developed?

print("What are the languages in which these projects are developed?")
query<-"select distinct lang
from pull_request_data";
lang=dbGetQuery(con,statement = query)
for(i in 1:nrow(lang)){
  print(sprintf("%s ",lang[i,1]))
}

#What is the start and end date of the activities captured in the dataset? Activities include creation of pull request, merging pull request, and closeing pull request?
print("What is the start and end date of the activities captured in the dataset?")
query<-"select min(created_at) created_at_min
,max(created_at)) created_at_max
,min(nullif(merged_at,0)) merged_at_min
,max(merged_at) merged_at_max
,min(closed_at) closed_at_min
,max(closed_at) closed_at_max
from pull_request_data
"
act_st_end = dbGetQuery(con, statement = query)
print(sprintf("create start : %s end : %s // merged start : %s end : %s // closed start : %s end : %s ",
              act_st_end[,1],act_st_end[,2],act_st_end[,3],act_st_end[,4],act_st_end[,5],act_st_end[,6]))

#datetime version

print("What is the start and end date of the activities captured in the dataset?")
query<-"select from_unixtime(min(created_at)) created_at_min
,from_unixtime(max(created_at)) created_at_max
,from_unixtime(min(nullif(merged_at,0))) merged_at_min
,from_unixtime(max(merged_at)) merged_at_max
,from_unixtime(min(closed_at)) closed_at_min
,from_unixtime(max(closed_at)) closed_at_max
from pull_request_data
"
act_st_end = dbGetQuery(con, statement = query)
print(sprintf("create start : %s end : %s // merged start : %s end : %s // closed start : %s end : %s ",
              act_st_end[,1],act_st_end[,2],act_st_end[,3],act_st_end[,4],act_st_end[,5],act_st_end[,6]))


#How many pull requests are available for analysis?
query<- "select count(pull_req_id)
from pull_request_data"
pr_count = dbGetQuery(con, statement = query)
print(sprintf("we have %s of pull_requset",pr_count))

#How many pulll requsets are open?
query<-"select count(pull_req_id)
from pull_request_data
where created_at!=0 and merged_at =0 and closed_at=0"
open_count = dbGetQuery(con, statement = query)
print(sprintf("the number of opened qull request is %s",open_count))

#How many pulll requsets are mereged?
query<-"select count(pull_req_id)
from pull_request_data
where created_at!=0 and merged_at !=0 and closed_at!=0"
merged_count = dbGetQuery(con, statement = query)
print(sprintf("the number of merged qull request is %s",merged_count))

#How many pulll requsets are closed?
query<-"select count(pull_req_id)
from pull_request_data
where created_at!=0 and merged_at =0 and closed_at!=0"
closed_count = dbGetQuery(con, statement = query)
print(sprintf("the number of closed qull request is %s",closed_count))

#what is the overall pull request acceptance rate ?
query <- "select count(pull_req_id),
sum(if(merged='\"TRUE\"',1,0)) merged_cnt
from pull_request_data"
merged_cnt = dbGetQuery(con, statement = query)
print(sprintf("The pull request accptance rate is %s",merged_cnt[,2]/merged_cnt[,1]*100))

#How many people participate in any activity in the pull_requset lifecycle?
query <- "select count(*)
from(select requester as tt from pull_request_data
union select closer as tt from pull_request_data
union select merger as tt from pull_request_data)as t"
part_count = dbGetQuery(con, statement = query)
print(sprintf("%s people participate in the pull_request lifecycle",part_count))

#How many people worked in selected projects?
query <- "select project_name, count(*)
from(select project_name, requester from pull_request_data
union select project_name, closer from pull_request_data
union select project_name, merger from pull_request_data)as t
group by project_name"
pj_part_count = dbGetQuery(con, statement = query)
for(i in 1:nrow(pj_part_count)){
  print(sprintf("%s people participate in %s",pj_part_count[,2],pj_part_count[,1]))
}

#how much time does it take to merge a pull request
query <- "select mergetime_minutes
from pull_request_data
where mergetime_minutes !=0"
merged_time = dbGetQuery(con, statement = query)
print(sprintf("the average of merged time is %s // the standard deviation is %s",mean(merged_time[,1]), sd(merged_time[,1])));

#how much time does it ake to dlose a not-merged pull request
query <- "select lifetime_minutes
from pull_request_data
where mergetime_minutes =0"
not_merged_time = dbGetQuery(con, statement = query)
print(sprintf("the average of merged time is %s // the standard deviation is %s",mean(not_merged_time[,1]), sd(not_merged_time[,1])));
