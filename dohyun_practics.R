# using combine table
# 1. compleate data

install.packages("scales")

install.packages("RMySQL")
library(scales)
library(RMySQL)

drv = dbDriver("MySQL")
con = dbConnect(drv,host="127.0.0.1",dbname="eth",user="root",pass="1234")

query<-"select count(*) all_cnt from combined";
all_cnt = dbGetQuery(con,statement=query)

#Marging rate by language

print("Which languages are the most merged?")
query<-"select repo_language
,count(pr_id) pr_count
,sum(if(merged_at !=0,1,0)) marged_num
from combined
group by repo_language";
lang_pr=dbGetQuery(con,statement=query)
for(i in 1:nrow(lang_pr)){
  print(sprintf("Pull requset of %s is %s and merged number is %s  // marge_rate = %s",lang_pr[i,1],lang_pr[i,2],lang_pr[i,3]
                ,lang_pr[i,3]/lang_pr[i,2]*100))
}

#Marging rate by domain

print("Which domain are the most merged?")
query<-"select repo_domain
,count(pr_id) pr_count
,sum(if(merged_at !=0,1,0)) marged_num
from combined
group by repo_domain";
domain_pr=dbGetQuery(con,statement=query)
for(i in 1:nrow(domain_pr)){
  print(sprintf("Pull requset of %s is %s and merged number is %s  // marge_rate = %s",domain_pr[i,1],domain_pr[i,2],domain_pr[i,3]
                ,domain_pr[i,3]/domain_pr[i,2]*100))
}

#Margeing rate by intra_branch

print("If a pull_request is intra_branch, is the merging rate high?")
query<-"select intra_branch
,count(pr_id) pr_count
,sum(if(merged_at !=0,1,0)) marged_num
from combined
group by intra_branch";
intra_branch_pr=dbGetQuery(con,statement=query)
for(i in 1:nrow(intra_branch_pr)){
  print(sprintf("intra_branch of %s is %s and merged number is %s  // marge_rate = %s",intra_branch_pr[i,1],intra_branch_pr[i,2],
                intra_branch_pr[i,3],intra_branch_pr[i,3]/(intra_branch_pr[1,2]+intra_branch_pr[2,2])*100))
}

#Margeing rate by intra_branch

print("If the repo tenure of pull_request is long, is the merging rate high?")
query<-"select repo_pr_tenure_mnth
,count(pr_id) pr_count
,sum(if(merged_at !=0,1,0)) marged_num
from combined
group by repo_pr_tenure_mnth";
ten_pr=dbGetQuery(con,statement=query)
for(i in 1:nrow(ten_pr)){
  print(sprintf(" the number of %s repo tenure is %s and merged number is %s  // marge_rate = %s",ten_pr[i,1],ten_pr[i,2],
                ten_pr[i,3],(ten_pr[i,3]/ten_pr[i,2])*100))
}
barplot(ten_pr[,3]/ten_pr[,2],
        names.arg=c(ten_pr[,1]),width =2)

#Margeing rate by core team size /10

print("If the core team size of repo of pull_request is big, is the merging rate high?")
query<-"select round(repo_pr_core_team_size/10) as core_team_div_10
,count(pr_id) pr_count
,sum(if(merged_at !=0,1,0)) marged_num
from combined
group by core_team_div_10";
core_team_pr=dbGetQuery(con,statement=query)
for(i in 1:nrow(core_team_pr)){
  print(sprintf(" the number of %s repo tenure is %s and merged number is %s  // marge_rate = %s",core_team_pr[i,1],core_team_pr[i,2],
                core_team_pr[i,3],(core_team_pr[i,3]/core_team_pr[i,2])*100))
}
barplot(core_team_pr[,3]/core_team_pr[,2],
        names.arg=c(core_team_pr[,1]))

#how much time does it take to merge a pull request
ex
print("how much time does it take to merge a pull request?")
query<-"select pr_status
,count(pr_id) pr_count
,avg(lifetime_minutes) avg_lifetime
from combined
group by pr_status";
status_lifetime=dbGetQuery(con,statement=query)
for(i in 1:nrow(status_lifetime)){
  print(sprintf(" the number of %s status is %s // avg_lifetime = %s",
                status_lifetime[i,1],status_lifetime[i,2], status_lifetime[i,3]))
}


#Margeing rate by the number of commit having 1 percent of total pull_requst

print("If there is many the commit of pull_request, is the merging rate high?")
query<-"select num_commits
,count(pr_id) pr_count
,sum(if(pr_status ='merged',1,0)) marged_num
from combined
group by num_commits
having pr_count > 131";
commit_num_pr=dbGetQuery(con,statement=query)
for(i in 1:nrow(commit_num_pr)){
  print(sprintf(" the number of %s num_commit is %s and merged number is %s  // marge_rate = %s",commit_num_pr[i,1],commit_num_pr[i,2],
                commit_num_pr[i,3],(commit_num_pr[i,3]/commit_num_pr[i,2])*100))
}
barplot((commit_num_pr[,3]/commit_num_pr[,2])*100,
        names.arg=c(commit_num_pr[,1]))


#Comparing closed, marged pull_request about commits, commit_comments, issue_comments, participants

print("If there is many the commit of pull_request, is the merging rate high?")
query<-"select pr_status
,count(pr_id) pr_cnt
,avg(num_commits) commits_avg
,avg(num_commit_comments) c_c_avg
,avg(num_issue_comments) i_c_avg
,avg(num_participants) part_avg
from combined
group by pr_status 
having pr_status = 'merged' or pr_status = 'closed'";
c_i_p_pr=dbGetQuery(con,statement=query)
for(i in 1:nrow(c_i_p_pr)){
  print(sprintf(" the number of %s status is %s and avg_commits is %s  // avg_commits_comments = %s //
                agv_issue_comments = %s // avg_participants = %s ",c_i_p_pr[i,1],c_i_p_pr[i,2],
                c_i_p_pr[i,3],c_i_p_pr[i,4],c_i_p_pr[i,5],c_i_p_pr[i,6]))
}

#Comparing closed, marged pull_request about added, deleted, modified, changed files

print("If there is many the changing of file, is the merging rate high?")  #no
query<-"select pr_status
,count(pr_id) pr_cnt
,avg(file_added) add_avg
,avg(file_deleted) delete_avg
,avg(file_modified) modified_avg
,avg(file_changed) changed_avg
from combined
group by pr_status 
having pr_status = 'merged' or pr_status = 'closed'";
changed_file_pr=dbGetQuery(con,statement=query)
for(i in 1:nrow(changed_file_pr)){
  print(sprintf(" the number of %s status is %s and avg_add is %s  // avg_delete = %s //
                agv_modified = %s // avg_changed = %s ",changed_file_pr[i,1],changed_file_pr[i,2],
                changed_file_pr[i,3],changed_file_pr[i,4],changed_file_pr[i,5],changed_file_pr[i,6]))
}

barplot(matrix(c(changed_file_pr[,3],changed_file_pr[,4],changed_file_pr[,5],changed_file_pr[,6]),2,4),beside = T ,
        names=c("add","delete","modified","changed"), col= c("green","yellow"))
legend(2,13,c("closed","marged"), fill = c("green","yellow"))


#print("If there is many the changing of file, is the merging rate high?")  #no
query<-"select pr_status
,count(pr_id) pr_cnt
,avg(src_file) src_avg
,avg(doc_file) doc_avg
,avg(other_files) other_avg
,avg(sloc) sloc_avg
,avg(src_churn) s_ch_avg
,avg(test_churn) t_ch_avg
from combined
group by pr_status 
having pr_status = 'merged' or pr_status = 'closed'";
ch_file_char_pr=dbGetQuery(con,statement=query)
for(i in 1:nrow(ch_file_char_pr)){
  print(sprintf(" the number of %s status is %s and avg_src is %s  // doc_avg = %s //
                other_avg = %s // sloc_avg = %s // s_ch_avg = %s // t_ch_avg = %s",ch_file_char_pr[i,1],ch_file_char_pr[i,2],
                ch_file_char_pr[i,3],ch_file_char_pr[i,4],ch_file_char_pr[i,5],ch_file_char_pr[i,6],ch_file_char_pr[i,7],ch_file_char_pr[i,8]))
}

barplot(matrix(c(ch_file_char_pr[,3],ch_file_char_pr[,4],ch_file_char_pr[,5]),2,3),beside = T ,
        names=c("avg_src","doc_avg","other_avg"), col= c("green","yellow"))
legend(6,7,c("closed","merged"), fill = c("green","yellow"))

barplot(matrix(c(ch_file_char_pr[,7],ch_file_char_pr[,8]),2,2),beside = T ,
        names=c("s_ch_avg","t_ch_avg"), col= c("green","yellow"))
legend(5,300,c("closed","merged"), fill = c("green","yellow"))

barplot(matrix(c(ch_file_char_pr[,6]),2,1),beside = T ,
        names=c("sloc_avg"), col= c("green","yellow"))
legend(2.2,45000,c("closed","merged"), fill = c("green","yellow"))

print("rate of same submitter and marger among all merged pr")
query <-"select pr_status
,count(pr_id) status_cnt
,sum(if (prs_pri_same_nationality=1 and (prs_id=prm_id or prs_id=prc_id),1,0)) same_developer
,sum(if (prs_pri_same_nationality=1 and not (prs_id=prm_id or prs_id=prc_id),1,0)) same_country
,sum(if (prs_pri_same_nationality=0,1,0)) different_country
from combined
group by pr_status 
having pr_status = 'merged' or pr_status = 'closed'";
same_nat_country_summary=dbGetQuery(con,statement=query)
for(i in 1:nrow(same_nat_country_summary)){
  print(sprintf("status = %s,status_cnt = %s, same_developer = %s, same_country = %s, different_country = %s",
                same_nat_country_summary[i,1],same_nat_country_summary[i,2],same_nat_country_summary[i,3],
                same_nat_country_summary[i,4],same_nat_country_summary[i,5]))
}
pie(c(same_nat_country_summary[1,3],same_nat_country_summary[1,4],same_nat_country_summary[1,5]),
    labels=c("same_developer","same_country", "different_country"),main ="closed_status_prs_prc")

vals <- c(same_nat_country_summary[1,3],same_nat_country_summary[1,4],same_nat_country_summary[1,5])
val_names <- sprintf("%s (%s)",c("same_developer","same_country", "different_country"),scales::percent(round(vals/sum(vals),2)))
names(vals) <- val_names

#for waffle charts
install.packages("scales")
library(scales)
install.packages("waffle")
library(waffle)
install.packages("ggthemes")
library(ggthemes)

waffle::waffle(vals,row=5, size = 0.5, colors=c("#c7d4b6","#a3aabd","#a0d0de"))  # doen't appear
ggthemes::scale_fill_tableau(name=NULL)

pie(c(same_nat_country_summary[2,3],same_nat_country_summary[2,4],same_nat_country_summary[2,5]),
    labels=c("same_developer","same_country", "different_country"),main ="marged_status_prs_prm")

tt <-matrix(c(round(same_nat_country_summary[,3]/same_nat_country_summary[,2]*100,2),
              round(same_nat_country_summary[,4]/same_nat_country_summary[,2]*100,2),
              round(same_nat_country_summary[,5]/same_nat_country_summary[,2]*100,2)),2,3)
bb <- barplot(tt,beside = T ,
              names=c("same_developer","same_country", "different_country"), col= c("green","yellow"))
text(bb,tt-5,tt)
legend(5,40,c("closed","merged"), fill = c("green","yellow"))

print("rate of mergeing via Country that having pull request over 1%")
query <-"select prs_country
,count(pr_id) as country_cnt
,round( sum(if (pr_status = 'merged',1,0))/count(pr_id) * 100,2) merged_rate
from combined
where pr_status = 'merged' or pr_status = 'closed'
group by prs_country
having count(pr_id)> 131191*0.01";
country_merged=dbGetQuery(con,statement=query)
for(i in 1:nrow(country_merged)){
  print(sprintf("country = %s,country_num = %s, merged_rate = %s",
                country_merged[i,1],country_merged[i,2],country_merged[i,3]))
}

print("rate of mergeing via Country name")
query <-"select prs_country
,pr_status
,count(pr_id) as country_cnt
,round(sum(if (prs_pri_same_nationality=1 and (prs_id=prm_id or prs_id=prc_id),1,0))/count(pr_id)*100 ,2) same_developer
,round(sum(if (prs_pri_same_nationality=1 and not (prs_id=prm_id or prs_id=prc_id),1,0))/count(pr_id)*100 ,2) same_country
,round(sum(if (prs_pri_same_nationality=0,1,0))/count(pr_id)*100 ,2) differnt_country
from combined
where pr_status = 'merged' or pr_status = 'closed'
group by prs_country, pr_status
having prs_country in ('\"united kingdom\"',
'\"united states\"',
'germany',
'france',
'canada',
'japan',
'brazil',
'india',
'australia',
'switzerland')";
country_summery=dbGetQuery(con,statement=query)
for(i in 1:nrow(country_summery)){
  print(sprintf("country = %s,status = %s, country_num = %s,same_developer = %s, same_country = %s, different_country = %s",
                country_summery[i,1],country_summery[i,2],country_summery[i,3],
                country_summery[i,4],country_summery[i,5],country_summery[i,6]))
}

print("rate of mergeing via Country name")
query <-"select prm_country
,count(pr_id) as country_cnt
from combined
where pr_status = 'merged' and prs_country = 'india'
group by prm_country";
indea_merge_summery=dbGetQuery(con,statement=query)
for(i in 1:nrow(indea_merge_summery)){
  print(sprintf("prm_country = %s,country_num = %s",
                indea_merge_summery[i,1],indea_merge_summery[i,2]))
}

print("rate of mergeing via Country name")
query <-"select prm_country
,round(count(pr_id)/91949*100,3) as country_rate
,count(pr_id) as count_num
,count(distinct prm_id)
from combined
where pr_status = 'merged' 
group by prm_country";
merge_summery=dbGetQuery(con,statement=query)
for(i in 1:nrow(merge_summery)){
  print(sprintf("prm_country = %s,country_num = %s",
                merge_summery[i,1],merge_summery[i,2]))
}

print("rate of submiit via Country name")
query <-"select prs_country
,round(count(pr_id)/131191*100,3) as country_cnt
,count(pr_id) as count_num
,count(distinct prs_id)
from combined
where pr_status = 'merged' 
group by prs_country";
submit_summery=dbGetQuery(con,statement=query)
for(i in 1:nrow(merge_summery)){
  print(sprintf("prm_country = %s,country_num = %s",
                merge_summery[i,1],merge_summery[i,2]))
}

query <- "select prs_country
,count(pr_id)
,count(distinct prm_id)
from combined
where prm_country = 'india'
group by prs_country"
indea_merger_prs = dbGetQuery(con, statement = query)

