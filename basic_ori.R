library(RMySQL)

drv = dbDriver("MySQL")
con = dbConnect(drv,host="127.0.0.1",dbname="eth",user="root",pass="1234")

# $1 how many pull requsets are available in data for analysis?
query <- "select count(pr_id)
from combined";
cnt_pr = dbGetQuery(con,statement=query)
print(sprintf("all_pull_requst = %s",pr_cnt))

# $2 how many pull requests are submitted from each country?
query <- "select prs_country
,count(pr_id)
from combined
group by prs_country";
cnt_country_pr= dbGetQuery(con,statement=query)
for(i in 1:nrow(cnt_country_pr)){
  print(sprintf("country = %s // cnt = %s",cnt_country_pr[i,1],cnt_country_pr[i,2]))
}

# $3 how many pull request are submitted from each project?
query <- "select repo_id
,repo_name
,count(pr_id)
from combined
group by repo_id";
cnt_repo_pr= dbGetQuery(con,statement=query)
for(i in 1:nrow(cnt_repo_pr)){
  print(sprintf("repo_id = %s // repo_name = %s // cnt= %s",cnt_repo_pr[i,1],cnt_repo_pr[i,2],cnt_repo_pr[i,3]))
}

#I don't know which is right
# $4 how many pull request are reviewed from each developer?
query <- "select pr_id
,num_comments
from combined
where num_comments != 0"
cnt_each_reviewed_pr = dbGetQuery(con,statement=query)
for(i in 1:nrow(cnt_reviewed_pr)){
  print(sprintf("pr_id = %s // cnt= %s",cnt_reviewed_pr[i,1],cnt_reviewed_pr[i,2]))
}

# $4 how many pull request are reviewed from each developer?
query <- "select count(pr_id)
from combined
where num_comments != 0"
cnt_reviewed_pr = dbGetQuery(con,statement=query)
print(sprintf("pr_reveiwed_cnt = %s",cnt_reviewed_pr))

# $5 what is the start and end dates of activities in the data set?
#It has problem
query <- "select pr_id, from_unixtime(act_time), status
from (select pr_id, created_at as act_time, 'create' as status from combined
union select pr_id, merged_at as act_time, 'merged' as status from combined
union select pr_id, closed_at as act_time, 'closed' as status from combined)as t
where t.act_time != 0 and t.act_time = min(t.act_time) or t.act_time = max(t.act_time)"
min_pr = dbGetQuery(con, statement = query)
for(i in 1:nrow(min_pr)){
  print(sprintf("%s %s %s people participate in the pull_request lifecycle",min_pr[i,1],min_pr[i,2],min_pr[i,3]))
}

# $5 what is the start and end dates of activities in the data set?
print("What is the start and end date of the activities captured in the dataset?")
query<-"select from_unixtime(min(created_at)) created_at_min
,from_unixtime(max(created_at)) created_at_max
,from_unixtime(min(nullif(merged_at,0))) merged_at_min
,from_unixtime(max(merged_at)) merged_at_max
,from_unixtime(min(closed_at)) closed_at_min
,from_unixtime(max(closed_at)) closed_at_max
from combined
"
min_max_pr = dbGetQuery(con, statement = query)
print(sprintf("create start : %s end : %s // merged start : %s end : %s // closed start : %s end : %s ",
              min_max_pr[,1],min_max_pr[,2],min_max_pr[,3],min_max_pr[,4],min_max_pr[,5],min_max_pr[,6]))

# $6  what is the overall pull request acceptance rate for the sample of data?
# $10 for all countries , what are the pull request acceptance rate? 
# I think this both of questions mean same.
query <- "select count(pr_id)
,sum(if(pr_status='merged',1,0))
,round(sum(if(pr_status='merged',1,0)) / count(pr_id)*100,2)
from combined"
merged_rate = dbGetQuery(con, statement = query)
print(sprintf("total count = %s  / merged_ pr = %s / rate = %s",merged_rate[1,1],merged_rate[1,2],merged_rate[1,3] ))

#7&9
# $7 how many pull_requsets are submitted per country?
# $9 what is the pull request acceptance rate when the pull requests are divided based on the country of submitter?
query <- "select prs_country 
,count(pr_id)
,round(sum(if(pr_status='merged',1,0))/count(pr_id)*100,2) merge_rate
from combined
group by prs_country";
cnt_prs_country_pr = dbGetQuery(con, statement = query)
for(i in 1:nrow(cnt_prs_country)){
  print(sprintf("countr =%s  cnt = %s merge_rate = %s", cnt_prs_country[i,1],cnt_prs_country[i,2],cnt_prs_country[i,3]))
}

# $8 how many pull_requsets are evaluated per country?
query <- "select prc_country 
,count(pr_id)
from combined
group by prc_country";
cnt_prc_country_pr = dbGetQuery(con, statement = query)
for(i in 1:nrow(cnt_prs_country)){
  print(sprintf("country =%s  cnt = %s", cnt_prc_country[i,1],cnt_prc_country[i,2]))
}

# $11 how many projects are analyzed?
query <- "select count(distinct repo_id)
from combined"
cnt_all_repo_pr = dbGetQuery(con, statement=query)
print(sprintf("all_project_cnt = %s",cnt_all_repo_pr))

#12&14
# $12 how many pull requsets ar analyzed per projects?
# $14 what is the pull requset acceptance rate per projects?
query <- "select repo_id
,repo_name
,count(pr_id)
,round(sum(if(pr_status='merged',1,0))/count(pr_id)*100,2) as merged_rate
from combined
group by repo_id"
cnt_merge_repo_pr = dbGetQuery(con, statement=query)
for(i in 1:nrow(cnt_merge_repo_pr)){
  print(sprintf("repo id = %s repo_name = %s cnt =%s merge_rate =%s"
                ,cnt_merge_repo_pr[i,1],cnt_merge_repo_pr[i,2],cnt_merge_repo_pr[i,3],cnt_merge_repo_pr[i,4]))
}

# $13 how many developers work for each projects?
# $17 How many developers work for each projects?
query <- "select repo_id
,repo_name
,count(distinct prd.prd_id)
from(select repo_id, repo_name, prs_id as prd_id from combined
union select repo_id, repo_name, prm_id as prd_id from combined
union select repo_id, repo_name, prc_id as prd_id from combined)as prd
group by prd.repo_id"
cnt_repo_developer = dbGetQuery(con,statement = query)
for(i in 1:nrow(cnt_repo_developer)){
  print(sprintf("repo_id  = %s repo_name = %s cnt_developer = %s",cnt_repo_developer[i,1],cnt_repo_developer[i,2],cnt_repo_developer[i,3]))
}

# $15 what is the average time to merge a pull requset per project?
query <- "select avg(mergetime_minutes)
from combined
where pr_status ='merged'"
avg_merge_time = dbGetQuery(con, statement = query)
print(sprintf("avg_merge_time = %s",avg_merge_time))

# $16 what is the average time to close a pull requset per project?
query <- "select avg(lifetime_minutes)
from combined
where pr_status ='closed'"
avg_closed_time = dbGetQuery(con, statement = query)
print(sprintf("avg_closed_time = %s",avg_closed_time ))

# $18 how many pull requset are submitted by each developer?
# $19 (Guess) how many pull request are marged by each developer?
query <- "select prs_id
,count(pr_id)
,round(sum(if(pr_status='merged',1,0))/count(pr_id)*100,2) as merge_rate
from combined
group by prs_id"
cnt_prs_merge_pr = dbGetQuery(con, statement = query)
for(i in 1:nrow(cnt_prs_merge_pr)){
print(sprintf("prs_id = %s cnt_pr = %s merged_rate = %s",cnt_prs_merge_pr[i,1],cnt_prs_merge_pr[i,2],cnt_prs_merge_pr[i,3]))
}

# $20 how many developers work as submitters for each country? 
query <- "select prs_country
,count(distinct prs_id)
from combined
group by prs_country";
cnt_country_prs = dbGetQuery(con, query)
for(i in 1:nrow(cnt_country_prs)){
  print(sprintf("country = %s , cnt_developer = %s",cnt_country_prs[i,1],cnt_country_prs[i,2]))
}

# $21 how many developers work as integrators for each country? 
query <- "select pri_country
,count(pr_id)
,count(distinct pri_id)
,round(sum(if(pr_status='merged',1,0))/count(pr_id)*100 ,2) as merge_rate
from (select pr_id, pr_status , prm_id as pri_id, prm_country as pri_country from combined where prs_country != prm_country
union select pr_id, pr_status , prc_id as pri_id, prc_country as pri_country from combined where prs_country != prc_country) as pri
group by pri_country"

query <- "select pri_country
,count(distinct pri_id)
from (select pr_id, pr_status , prm_id as pri_id, prm_country as pri_country from combined where prs_country != prm_country
union select pr_id, pr_status , prc_id as pri_id, prc_country as pri_country from combined where prs_country != prc_country) as pri
group by pri_country";
cnt_country_prm = dbGetQuery(con, query)
for(i in 1:nrow(cnt_country_prm)){
  print(sprintf("country = %s , cnt_developer = %s",cnt_country_prm[i,1],cnt_country_prm[i,2]))
}

# $22 Developers from how many countries work for each project?
query <- "select repo_id
,repo_name
,count(distinct dev_country)
from(select repo_id, repo_name, prs_country as dev_country from combined
union select repo_id, repo_name, prm_country as dev_country from combined
union select repo_id, repo_name, prc_country as dev_country from combined)as country_dev
group by repo_id"
cnt_repo_dev_country = dbGetQuery(con, query)
for(i in 1:nrow(cnt_repo_dev_country)){
  print(sprintf("repo_id = %s , repo_name = %s, cnt_country = %s",cnt_repo_dev_country[i,1],cnt_repo_dev_country[i,2],cnt_repo_dev_country[i,3]))
}

# $23 for integrator of each country, what is the pull request acceptance rate for every other country?
query <- "select pri_country
,count(pr_id)
,count(distinct pri_id)
,round(sum(if(pr_status='merged',1,0))/count(pr_id)*100 ,2) as merge_rate
from (select pr_id, pr_status , prm_id as pri_id, prm_country as pri_country from combined where prs_country != prm_country
union select pr_id, pr_status , prc_id as pri_id, prc_country as pri_country from combined where prs_country != prc_country) as pri
group by pri_country"
cnt_pri_merge = dbGetQuery(con, statement = query)
for(i in 1:nrow(cnt_prm_merge)){
  print(sprintf("country = %s cnt_pr = %s dev_cnt = %s merge_rate = %s"
                ,cnt_pri_merge[i,1],cnt_pri_merge[i,2], cnt_pri_merge[i,3], cnt_pri_merge[i,4]))
}

