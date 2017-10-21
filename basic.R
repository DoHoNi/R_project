library(RMySQL)

drv = dbDriver("MySQL")
con = dbConnect(drv,host="127.0.0.1",dbname="eth",user="root",pass="1234")

#1
query <- "select count(*)
,round(sum(if(pr_status ='merged',1,0))/count(*),2) as merge_rate
from combined"
cnt_all_pr = dbGetQuery(con,statement=query)
print(sprintf("all_pull_requset = %s merge_rate = %s",cnt_all_pr[1,1],cnt_all_pr[1,2]))

#2 #7
query <- "select prs_country as country
,count(pr_id) as submit
from combined
group by prs_country"
cnt_each_country_pr = dbGetQuery(con, statement = query)
for(i in 1:nrow(cnt_each_country_pr)){
  print(sprintf("country : %s  cnt : %s",cnt_each_country_pr[i,1],cnt_each_country_pr[i,2]))
}

#3 #12
query <- "select repo_name
,count(pr_id)
from combined
group by repo_name"
cnt_repo_pr = dbGetQuery(con, statement = query)
for(i in 1:nrow(cnt_repo_pr)){
  print(sprintf("repo_name : %s  cnt : %s",cnt_repo_pr[i,1],cnt_repo_pr[i,2]))
}

#4
query <- "select pri_id, 
count(pr_id)
from (select prm_id as pri_id, pr_id from combined where pr_status ='merged'
union select prc_id as pri_id, pr_id from combined where pr_status != 'opened')pri
group by pri_id"
cnt_reviewed_pr = dbGetQuery(con, statement = query)


#5
print("What is the start and end date of the activities captured in the dataset?")
query<-"select from_unixtime(min(created_at)) created_at_min
,from_unixtime(max(created_at)) created_at_max
,from_unixtime(min(nullif(merged_at,0))) merged_at_min
,from_unixtime(max(merged_at)) merged_at_max
,from_unixtime(min(closed_at)) closed_at_min
,from_unixtime(max(closed_at)) closed_at_max
from combined
"
act_st_end = dbGetQuery(con, statement = query)

#8
print("How many pull requsets are evalutated per country?")
query <-"select pri_country as country
,count(pr_id) as eval
from (select prm_country as pri_country, pr_id from combined where pr_status ='merged'
union select prc_country as pri_country, pr_id from combined where pr_status != 'opened')as pri
group by pri_country"
cnt_eval_pr = dbGetQuery(con, statement = query)

#What country has the largest number of differece between submission an evaluation
m_eval_submit <- merge(cnt_eval_pr, cnt_each_country_pr, by='country')
m_eval_submit$sub <- m_eval_submit$submit - m_eval_submit$eval

#9 #10
print("What  is the pull requset acceptance rate when the pull requests are divided based on the country of submitter?")
query <- "select prs_country as country
,round(sum(if(pr_status='merged',1,0))/count(pr_id)*100,2) as merge_rate
from combined
group by prs_country"
country_merge_rate = dbGetQuery(con, statement = query)

#11
print("how many projects are analyzed?")
query <- "select repo_name
,count(pr_id)
from combined
group by repo_name"
cnt_repo = dbGetQuery(con, statement = query)

#13
print("how many developers woerk for each projects")
query <- "select repo_name
,count(distinct dev_id)
from (select repo_name, prs_id as dev_id from combined
union select repo_name, prm_id as dev_id from combined where prm_id is not null
union select repo_name, prs_id as dev_id from combined where prc_id is not null)t
group by repo_name"
cnt_dev_project = dbGetQuery(con, statement = query)

# how many people are the same person with submitter and merger and submitter and closer from each country?
query <- "select prs_country as country
,count(pr_id) as cnt_pr
,sum(if(prs_id = prm_id,1,0)) s_m_same
,sum(if(prs_id = prc_id,1,0)) s_c_same
from combined
group by prs_country
having prs_country is not null"
s_m_c_same = dbGetQuery(con, statement = query)

s_m_c_same$s_m_rate <- round(s_m_c_same$s_m_same / s_m_c_same$cnt_pr *100,2)
s_m_c_same$s_c_rate <- round(s_m_c_same$s_c_same / s_m_c_same$cnt_pr *100,2)
s_m_c_same <- merge(s_m_c_same , country_merge_rate, by ='country')
s_m_c_same$sub_rate <- s_m_c_same$s_c_rate - s_m_c_same$s_m_rate

#14
print("WHat is the pull request acceptance rate per project?")
query <- "select repo_name
,round(sum(if(pr_status='merged',1,0))/count(pr_id)*100,2) as merge_rate
from combined
group by repo_name"
repo_merge_rate = dbGetQuery(con, statement = query)

repo_merge_rate <- merge(repo_merge_rate, cnt_repo_pr, by ='repo_name')
repo_0_merge_rate <- repo_merge_rate[repo_merge_rate$merge_rate ==0,]
repo_merge_rate <- merge(repo_merge_rate, repo_cnt_prs, by = 'repo_name')
repo_merge_rate <- merge(repo_merge_rate, repo_cnt_dev, by = 'repo_name')
repo_merge_rate <- merge(repo_merge_rate, repo_s_c_same, by ='repo_name')

nrow(repo_0_merge_rate[repo_0_merge_rate$s_c_rate==100,])
nrow(repo_0_merge_rate)

# how many submitter is working per project?
query <- "select repo_name
,count(distinct prs_id) cnt_prs
from combined
group by repo_name"
repo_cnt_prs = dbGetQuery(con, statement = query)

#how many developer is working per project?
query <- "select repo_name
,count(distinct dev_id) cnt_dev
from (select repo_name, prs_id as dev_id from combined
union select repo_name, prm_id as dev_id from combined where prm_id is not null
union select repo_name, prc_id as dev_id from combined where prc_id is not null)as dev
group by repo_name"
repo_cnt_dev = dbGetQuery(con, statement = query)

#how many pull request is closed by someone who submitter and closer is same is?
query <- "select repo_name
,sum(if(prs_id = prc_id,1,0)) s_c_same
,round(sum(if(prs_id = prc_id,1,0))/count(pr_id)*100,2) s_c_rate
from combined
group by repo_name"
repo_s_c_same = dbGetQuery(con, statement = query)


#15
print("What is the average time to merge a pull request per project?")
query <- "select avg(lifetime_minutes) 
from combined
where pr_status ='merged'"
avg_merge_time = dbGetQuery(con, statement = query)

#16
print("What is the average time to close a pull request per project?")
query <- "select avg(lifetime_minutes) 
from combined
where pr_status ='closed'"
avg_close_time = dbGetQuery(con, statement = query)

#15-1 
query <- "select pr_id
,lifetime_minutes 
from combined
where pr_status ='merged'"
each_merge_time = dbGetQuery(con, statement = query)
tmp <- each_merge_time[each_merge_time$lifetime_minutes <200000,]
tmp <- each_merge_time[each_merge_time$lifetime_minutes <50000,]
tmp <- each_merge_time[each_merge_time$lifetime_minutes <30000,]
tmp <- each_merge_time[each_merge_time$lifetime_minutes <5000,]
tmp <- each_merge_time[each_merge_time$lifetime_minutes <3000,]
tmp <- each_merge_time[each_merge_time$lifetime_minutes <500,]
tmp <- each_merge_time[each_merge_time$lifetime_minutes <100,]
tmp <- each_merge_time[each_merge_time$lifetime_minutes <50,]
#15-2
query<- "select pr_id
,lifetime_minutes
from combined
where pr_status = 'merged' and prs_id = prm_id "
s_m_merge_time = dbGetQuery(con, statement=query)
nrow(s_m_merge_time)
nrow(s_m_merge_time[s_m_merge_time$lifetime_minutes==0,])
7075/31386*100

#15-2-1
query<- "select pr_id
,lifetime_minutes
from combined
where pr_status = 'merged' and prs_id != prm_id "
s_m__merge_time = dbGetQuery(con, statement=query)


#16-1
query <- "select pr_id
,lifetime_minutes 
from combined
where pr_status ='closed'"
each_close_time = dbGetQuery(con, statement = query)
tmp <- each_close_time[each_close_time$lifetime_minutes<50000,]

#16-2
query <- "select pr_id
,lifetime_minutes 
from combined
where pr_status ='closed' and prs_id =prc_id"
s_c_close_time = dbGetQuery(con, statement = query)

#16-2-1
query <- "select pr_id
,lifetime_minutes 
from combined
where pr_status ='closed' and prs_id !=prc_id"
s_c__close_time = dbGetQuery(con, statement = query)

#18 #19
print("How many pull requests are submitted by each develper?")
query <- "select prs_id 
,count(pr_id) cnt_pr
,round(sum(if(pr_status='merged',1,0))/count(pr_id)*100,2) as merge_rate
from combined 
group by prs_id"
cnt_prs_pr = dbGetQuery(con, statement = query)
nrow(cnt_prs_pr[cnt_prs_pr$cnt_pr <=5, ])
nrow(cnt_prs_pr[cnt_prs_pr$cnt_pr <=5, ]) / nrow(cnt_prs_pr) *100 
nrow(cnt_prs_pr[cnt_prs_pr$cnt_pr <=10, ]) / nrow(cnt_prs_pr) *100
nrow(cnt_prs_pr[cnt_prs_pr$cnt_pr <=20, ]) / nrow(cnt_prs_pr) *100 
nrow(cnt_prs_pr[cnt_prs_pr$cnt_pr >=100, ]) / nrow(cnt_prs_pr) *100 
nrow(cnt_prs_pr[cnt_prs_pr$cnt_pr >=100, ])
tmp <- cnt_prs_pr[cnt_prs_pr$cnt_pr >=100, ]
tmp <- cnt_prs_pr[cnt_prs_pr$cnt_pr <100,]
tmp <- cnt_prs_pr[cnt_prs_pr$cnt_pr <100 & cnt_prs_pr$cnt_pr >10,]
tmp <- cnt_prs_pr[cnt_prs_pr$cnt_pr <100 & cnt_prs_pr$cnt_pr >1,]
summary(cnt_prs_pr[cnt_prs_pr$cnt_pr>1,])
summary(cnt_prs_pr[cnt_prs_pr$cnt_pr>2,])
summary(cnt_prs_pr[cnt_prs_pr$cnt_pr>5,])
nrow(cnt_prs_pr[cnt_prs_pr$cnt_pr==1 & cnt_prs_pr$merge_rate==100,])
nrow(cnt_prs_pr[cnt_prs_pr$cnt_pr==1,])
nrow(cnt_prs_pr[cnt_prs_pr$cnt_pr==1 & cnt_prs_pr$merge_rate==100,]) / 7824 *100

#20
print("How many developers work as submitters for each country?")
query <- "select prs_country
,count(distinct prs_id)
from combined
group by prs_country
having prs_country is not null"
cnt_prs_country = dbGetQuery(con, statement = query)

#21
print("How many developers work as integrators for each country?")
query <- "select pri_country
,count(distinct pri_id)
from (select prm_id as pri_id, prm_country as pri_country from combined where prm_id is not null
union select prc_id as pri_id, prc_country as prc_country from combined where prc_id is not null)pri
group by pri_country"
cnt_pri_country = dbGetQuery(con, statement = query)

#22
print("Developers from how many countries work for each project?")
query <-"select repo_name
,count(distinct dev_country)
from (select repo_name, prs_country as dev_country from combined 
union select repo_name, prm_country as dev_country from combined where prm_country is not null
union select repo_name, prc_country as dev_country from combined where prc_country is not null)dev
group by repo_name"
cnt_repo_country = dbGetQuery(con, statement = query)

#23
print("For integrators of each country, what is the pull request acceptance rate for every other country?")
query <-"select pri_country
,round(sum(if(pr_status ='merged',1,0))/count(pr_id)*100,2) merge_rate
from( select prm_country as pri_country, pr_id, pr_status from combined where prm_country is not null
union select prc_country as pri_country, pr_id, pr_status from combined where prc_country is not null)pri_country
group by pri_country"
pri_country_merge_rate= dbGetQuery(con, statement = query)
