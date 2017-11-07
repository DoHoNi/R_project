installed.packages("RMySQL")
library(RMySQL)

drv = dbDriver("MySQL")
con = dbConnect(drv,host="127.0.0.1",dbname="eth",user="root",pass="1234")

#1 #6
query <- "select count(*)
,round(sum(if(pr_status ='merged',1,0))/count(*),2) as merge_rate
from combined"
cnt_all_pr = dbGetQuery(con,statement=query)
print(sprintf("all_pull_requset = %s merge_rate = %s",cnt_all_pr[1,1],cnt_all_pr[1,2]))

#2 #7
query <- "select prs_country as country
,count(pr_id) as submit
from combined
group by prs_country
having prs_country is not NULL"
cnt_each_country_pr = dbGetQuery(con, statement = query)
write.csv(cnt_each_country_pr,file = "/home/dohyun/Desktop/R/data/2_cnt_each_country_pr",row.names = T)
for(i in 1:nrow(cnt_each_country_pr)){
  print(sprintf("country : %s  cnt : %s",cnt_each_country_pr[i,1],cnt_each_country_pr[i,2]))
}

#3 #12
query <- "select repo_name
,count(pr_id)
from combined
group by repo_name"
cnt_repo_pr = dbGetQuery(con, statement = query)
write.csv(cnt_repo_pr,file = "/home/dohyun/Desktop/R/data/3_cnt_repo_pr",row.names = T)
for(i in 1:nrow(cnt_repo_pr)){
  print(sprintf("repo_name : %s  cnt : %s",cnt_repo_pr[i,1],cnt_repo_pr[i,2]))
}

#4
query <- "select pri_id, 
count(pr_id)
from (select prm_id as pri_id, pr_id from combined where pr_status ='merged'
union select prc_id as pri_id, pr_id from combined where pr_status != 'opened')pri
group by pri_id
having pri_id is not NULL"
cnt_reviewed_pr = dbGetQuery(con, statement = query)
write.csv(cnt_reviewed_pr,file = "/home/dohyun/Desktop/R/data/4_cnt_reviewed_pr",row.names = T)

#how many people who prs and prm are the same person and prs and prc are the same person are?
query <- "select prs_id ,prm_id ,prc_id,pr_status
from combined
where prs_id = prm_id and pr_status = 'merged'"
prs_m_same = dbGetQuery(con, statement = query)
nrow(prs_m_same)
write.csv(prs_m_same,file = "/home/dohyun/Desktop/R/data/prs_m_same",row.names = T)


query <- "select prs_id ,prm_id ,prc_id,pr_status
from combined
where prs_id = prc_id"
prs_c_same = dbGetQuery(con, statement = query)
nrow(prs_c_same)
nrow(prs_c_same[prs_c_same$pr_status =='merged',])
nrow(prs_c_same[prs_c_same$pr_status =='closed',])
write.csv(prs_c_same,file = "/home/dohyun/Desktop/R/data/prs_c_same",row.names = T)

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
write.csv(act_st_end,file = "/home/dohyun/Desktop/R/data/5_act_st_end",row.names = T)

#8
print("How many pull requsets are evalutated per country?")
query <-"select pri_country as country
,count(pr_id) as eval
from (select prm_country as pri_country, pr_id from combined where pr_status ='merged'
union select prc_country as pri_country, pr_id from combined where pr_status != 'opened')as pri
group by pri_country
having pri_country is not null"
cnt_eval_pr = dbGetQuery(con, statement = query)
write.csv(cnt_eval_pr,file = "/home/dohyun/Desktop/R/data/8_cnt_eval_pr",row.names = T)

#What country has the largest number of differece between submission an evaluation
m_eval_submit <- merge(cnt_eval_pr, cnt_each_country_pr, by='country')
m_eval_submit$sub <- m_eval_submit$submit - m_eval_submit$eval
write.csv(m_eval_submit,file = "/home/dohyun/Desktop/R/data/m_eval_submit",row.names = T)

#9 #10
print("What  is the pull requset acceptance rate when the pull requests are divided based on the country of submitter?")
query <- "select prs_country as country
,round(sum(if(pr_status='merged',1,0))/count(pr_id)*100,2) as prs_merge_rate
from combined
group by prs_country
having prs_counry is not null"
country_merge_rate = dbGetQuery(con, statement = query)
write.csv(country_merge_rate,file = "/home/dohyun/Desktop/R/data/9_country_merge_rate",row.names = T)

country_merge_rate <- merge(country_merge_rate, cnt_each_country_pr, by='country')

#11
print("how many projects are analyzed?")
query <- "select repo_name
,count(pr_id)
from combined
group by repo_name"
cnt_repo = dbGetQuery(con, statement = query)
write.csv(cnt_repo,file = "/home/dohyun/Desktop/R/data/11_cnt_repo",row.names = T)

#13
print("how many developers woerk for each projects")
query <- "select repo_name
,count(distinct dev_id)
from (select repo_name, prs_id as dev_id from combined
union select repo_name, prm_id as dev_id from combined where prm_id is not null
union select repo_name, prs_id as dev_id from combined where prc_id is not null)t
group by repo_name"
cnt_dev_project = dbGetQuery(con, statement = query)
write.csv(cnt_dev_project,file = "/home/dohyun/Desktop/R/data/13_cnt_dev_project",row.names = T)

# how many people are the same person with submitter and merger and submitter and closer from each country?
query <- "select prs_country as country
,count(pr_id) as cnt_pr
,sum(if(prs_id = prm_id,1,0)) s_m_same
,sum(if(prs_id = prc_id,1,0)) s_c_same
from combined
group by prs_country
having prs_country is not null"
s_m_c_same = dbGetQuery(con, statement = query)
write.csv(s_m_c_same,file = "/home/dohyun/Desktop/R/data/s_m_c_same",row.names = T)

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
write.csv(repo_merge_rate,file = "/home/dohyun/Desktop/R/data/14_repo_merge_rate",row.names = T)
write.csv(repo_0_merge_rate,file = "/home/dohyun/Desktop/R/data/14_repo_0_merge_rate",row.names = T)
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
write.csv(each_merge_time,file = "/home/dohyun/Desktop/R/data/15_1_each_merge_time",row.names = T)
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
write.csv(s_m_merge_time,file = "/home/dohyun/Desktop/R/data/15_2_s_m_merge_time",row.names = T)
nrow(s_m_merge_time)
nrow(s_m_merge_time[s_m_merge_time$lifetime_minutes==0,])
7075/31386*100

#15-2-1
query<- "select pr_id
,lifetime_minutes
from combined
where pr_status = 'merged' and prs_id != prm_id "
s_m__merge_time = dbGetQuery(con, statement=query)
write.csv(s_m__merge_time,file = "/home/dohyun/Desktop/R/data/15_2_s_m__merge_time",row.names = T)


#16-1
query <- "select pr_id
,lifetime_minutes 
from combined
where pr_status ='closed'"
each_close_time = dbGetQuery(con, statement = query)
write.csv(each_close_time,file = "/home/dohyun/Desktop/R/data/16_1_each_close_time",row.names = T)

tmp <- each_close_time[each_close_time$lifetime_minutes<50000,]

#16-2
query <- "select pr_id
,lifetime_minutes 
from combined
where pr_status ='closed' and prs_id =prc_id"
s_c_close_time = dbGetQuery(con, statement = query)
write.csv(s_c_close_time,file = "/home/dohyun/Desktop/R/data/16_2_s_c_close_time",row.names = T)
#16-2-1
query <- "select pr_id
,lifetime_minutes 
from combined
where pr_status ='closed' and prs_id !=prc_id"
s_c__close_time = dbGetQuery(con, statement = query)
write.csv(s_c__close_time,file = "/home/dohyun/Desktop/R/data/16_2_1_s_c__close_time",row.names = T)

#18 #19
print("How many pull requests are submitted by each develper?")
query <- "select prs_id 
,count(pr_id) cnt_pr
,round(sum(if(pr_status='merged',1,0))/count(pr_id)*100,2) as merge_rate
from combined 
group by prs_id"
cnt_prs_pr = dbGetQuery(con, statement = query)
write.csv(cnt_prs_pr,file = "/home/dohyun/Desktop/R/data/18_cnt_prs_pr",row.names = T)
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

two_prs_pr <- cnt_prs_pr[cnt_prs_pr$cnt_pr==2,]
nrow(two_prs_pr)  #2991
nrow(two_prs_pr[two_prs_pr$merge_rate ==100,]) # 1020 34.10%
nrow(two_prs_pr[two_prs_pr$merge_rate ==50,]) #1049 35.07%
nrow(two_prs_pr[two_prs_pr$merge_rate ==0,]) #922  30.82%

three_prs_pr <- cnt_prs_pr[cnt_prs_pr$cnt_pr ==3,]
nrow(three_prs_pr)  #1479
nrow(three_prs_pr[three_prs_pr$merge_rate ==100,]) # 370 25.01%
nrow(three_prs_pr[three_prs_pr$merge_rate ==66.67,]) # 430 29.07%
nrow(three_prs_pr[three_prs_pr$merge_rate ==33.33,]) #379 25.62%
nrow(three_prs_pr[three_prs_pr$merge_rate ==0,]) #300  20.28%

four_prs_pr <- cnt_prs_pr[cnt_prs_pr$cnt_pr ==4,]
nrow(four_prs_pr) #976
nrow(four_prs_pr[four_prs_pr$merge_rate ==100,]) #195 19.97%
nrow(four_prs_pr[four_prs_pr$merge_rate ==75,]) #243 24.89%
nrow(four_prs_pr[four_prs_pr$merge_rate ==50,]) #223 22.84%
nrow(four_prs_pr[four_prs_pr$merge_rate ==25,]) #149 15.26%
nrow(four_prs_pr[four_prs_pr$merge_rate ==0,]) #166 17.00%


#20
print("How many developers work as submitters for each country?")
query <- "select prs_country country
,count(distinct prs_id) cnt_prs
from combined
group by prs_country
having prs_country is not null"
cnt_prs_country = dbGetQuery(con, statement = query)
write.csv(cnt_prs_country,file = "/home/dohyun/Desktop/R/data/20_cnt_prs_country",row.names = T)

#21
print("How many developers work as integrators for each country?")
query <- "select pri_country country
,count(distinct pri_id) cnt_pri
from (select prm_id as pri_id, prm_country as pri_country from combined where prm_id is not null
union select prc_id as pri_id, prc_country as prc_country from combined where prc_id is not null)pri
group by pri_country"
cnt_pri_country = dbGetQuery(con, statement = query)
write.csv(cnt_pri_country,file = "/home/dohyun/Desktop/R/data/21_cnt_pri_country",row.names = T)

country = merge(cnt_each_country_pr ,cnt_eval_pr,  by= 'country',all= TRUE)
country = merge(country, cnt_prs_country, by='country',all= TRUE)
country = merge( country, cnt_pri_country,by ='country',all= TRUE)
country$s_m_sub <- country$cnt_prs - country$cnt_pri

write.csv(country,file = "/home/dohyun/Desktop/R/data/country",row.names = T)

#22
print("Developers from how many countries work for each project?")
query <-"select repo_name
,count(distinct dev_country)
from (select repo_name, prs_country as dev_country from combined 
union select repo_name, prm_country as dev_country from combined where prm_country is not null
union select repo_name, prc_country as dev_country from combined where prc_country is not null)dev
group by repo_name"
cnt_repo_country = dbGetQuery(con, statement = query)
write.csv(cnt_repo_country,file = "/home/dohyun/Desktop/R/data/22_cnt_repo_country",row.names = T)

repo <- merge(cnt_repo_country, repo_merge_rate, by='repo_name', all = TRUE)
repo <- merge(repo, cnt_dev_project, by = 'repo_name',all =TRUE)
cov(repo$`count(distinct dev_country)`,repo$merge_rate)
cov(repo$`count(distinct dev_id)`,repo$merge_rate)
cor(repo$`count(distinct dev_country)`,repo$merge_rate)
cor(repo$`count(distinct dev_id)`,repo$merge_rate)
write.csv(repo,file = "/home/dohyun/Desktop/R/data/repo",row.names = T)

#23
print("For integrators of each country, what is the pull request acceptance rate for every other country?")
query <-"select pri_country country
,round(sum(if(pr_status ='merged',1,0))/count(pr_id)*100,2) pri_merge_rate
from( select prm_country as pri_country, pr_id, pr_status from combined where prm_country is not null
union select prc_country as pri_country, pr_id, pr_status from combined where prc_country is not null)pri_country
group by pri_country"
pri_country_merge_rate= dbGetQuery(con, statement = query)
write.csv(pri_country_merge_rate,file = "/home/dohyun/Desktop/R/data/23_pri_country_merge_rate",row.names = T)
country <- merge(country, pri_country_merge_rate, by='country',all=TRUE)
country <- merge(country, country_merge_rate, by='country',all=TRUE)


query <-"select pri_country 
,prs_country
,round(sum(if(pr_status ='merged',1,0))/count(pr_id)*100,2) merge_rate
,count(*) all_cnt
,sum(if(pr_status='merged',1,0)) merge_cnt
from( select prs_country ,prm_country as pri_country, pr_id, pr_status from combined where prm_country is not null
union select prs_country ,prc_country as pri_country, pr_id, pr_status from combined where prc_country is not null)pri_country
group by pri_country, prs_country"
prs_pri_country_merge_rate= dbGetQuery(con, statement = query)
write.csv(prs_pri_country_merge_rate,file = "/home/dohyun/Desktop/R/data/prs_pri_country_merge_rate",row.names = T)

## prm = prs

query <- "select prm_id
,prc_id
,if(prm_id =prc_id, 1, 0) m_c_same
from combined
where pr_status = 'merged'"
m_c_same = dbGetQuery(con, statement = query)

##