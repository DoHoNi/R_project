library(RMySQL)

drv = dbDriver("MySQL")
con = dbConnect(drv,host="127.0.0.1",dbname="eth_base",user="root",pass="1234")

query<-"select * from pull_request_data";
combined = dbGetQuery(con,statement=query)

//how many pull request? 916065 
print("How many pull requests are identified for analysis?")
query<-"select count(pull_req_id) 
from pull_request_data";
pr_count=dbGetQuery(con,statement=query)
print(sprintf("Total %s pull requests are identified for analysis",pr_count))

//How many languages are indetified? 5
print("How many languages are identified?")
query<-"select count(distinct lang) lang_count 
from pull_request_data";
lang_count=dbGetQuery(con,statement=query)
print(sprintf("Total %s languages are identified",lang_count))

//how many projects are indetified? java:1075 javascript 1726 python 1518 ruby 1086 scala 138
print("How many projects are identified in each language?")
query<- "select lang
,count(distinct project_name) as project_count 
from pull_request_data 
group by lang";
lang_proj_count=dbGetQuery(con,statement=query)
for (i in 1:nrow(lang_proj_count))
{
  print(sprintf("Total %s projects are identified in language %s",lang_proj_count[i,2],lang_proj_count[i,1]))
}

//how many pull_requset are indetified java:124069 javascript 266294 python 315258 ruby 168534 scala 41910
print("How many pull_requests are identified in each language? ")
query<- "select lang
,count(pull_req_id) as pr_count
from pull_request_data
group by lang";
lang_pr_count = dbGetQuery(con,statement=query)
for (i in 1:nrow(lang_pr_count))
{
 print(sprintf("Total %s pull requests are identified in language %s",lang_pr_count[i,2],lang_pr_count[i,1])) 
}


//It has problem
print("How many marged project are identified for analysis?")
query<- "select count(pull_req_id) as pr_count
from pull_request_data
where merged = 'TRUE' ";
marged_count =dbGetQuery(con,statement=query)
print(sprintf("marged : %s",marged_count))

// true : 777499 false : 138566
print("How many marged pull_requests are identified for analysis?")
query<- "select merged
,count(pull_req_id) as pr_count
from pull_request_data
group by merged";
merged_count = dbGetQuery(con,statement=query)
for(i in 1:nrow(merged_count))
{
print(sprintf("%s : %s",merged_count[i,1],merged_count[i,2]))
}

print("how many marged pull_requests are merged in language? ")
query<- "select lang
,sum(if(merged='\"TRUE\"',1,0)) merged
,sum(if(merged='\"FALSE\"',1,0)) not_merged
from eth_base.pull_request_data
group by lang";
lang_merged<-dbGetQuery(con,statement = query)
print(sprintf("%s : %s %s",lang_merged[1,1],lang_merged[1,2],lang_merged[1,3]))
barplot(as.matrix(prop.table(t(lang_merged[,2:3]),2)*100),
        names.arg=c(lang_merged[,1]),
        legend=c("merged","not merged"),
        args.legend = list(x = "topright", bty = "n", inset=c(0.2, 0)),las=2)

