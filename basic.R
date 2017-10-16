library(RMySQL)

drv = dbDriver("MySQL")
con = dbConnect(drv,host="127.0.0.1",dbname="eth",user="root",pass="1234")


#1
query <- "select count(*) from combined"
cnt_all_pr = dbGetQuery(con,statement=query)
print(sprintf("all_pull_requset = %s",cnt_all_pr))

#2
query <- "select prs_country
,count(pr_id)
from combined
group by prs_country"
cnt_each_country_pr = dbGetQuery(con, statement = query)
for(i in 1:nrow(cnt_each_country_pr)){
  print(sprintf("country : %s  cnt : %s",cnt_each_country_pr[i,1],cnt_each_country_pr[i,2]))
}

#3 
query <- "select repo_name
,count(pr_id)
from combined
group by repo_name"
cnt_repo_pr = dbGetQuery(con, statement = query)
for(i in 1:nrow(cnt_repo_pr)){
  print(sprintf("repo_name : %s  cnt : %s",cnt_repo_pr[i,1],cnt_repo_pr[i,2]))
}

#4
query <- "select prs_id
,sum(num_comments)
from combined
group by prs_id"
cnt_reviewed_pr = dbGetQuery(con, statement = query)
for(i in 1:nrow(cnt_reviewed_pr)){
  print(sprintf("prs_id : %s  comments_cnt : %s",cnt_reviewed_pr[i,1],cnt_reviewed_pr[i,2]))
}

#5
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