

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

# To see the changees are made if we exclude cases where the total number of pull request is small
hist(prs_pri_country_merge_rate$merge_rate)
s_i_country_over_1 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=2,]
hist(s_i_country_over_1$merge_rate)
s_i_country_over_2 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=3,]
hist(s_i_country_over_2$merge_rate)
s_i_country_over_3 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=4,]
hist(s_i_country_over_3$merge_rate)
s_i_country_over_4 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=5,]
hist(s_i_country_over_4$merge_rate)
s_i_country_over_5 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=6,]
hist(s_i_country_over_5$merge_rate)
s_i_country_over_6 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=7,]
hist(s_i_country_over_6$merge_rate)
s_i_country_over_7 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=8,]
hist(s_i_country_over_7$merge_rate)
s_i_country_over_8 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=9,]
hist(s_i_country_over_8$merge_rate)
s_i_country_over_10 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=10,]
hist(s_i_country_over_10$merge_rate)
s_i_country_over_20 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=20,]
hist(s_i_country_over_20$merge_rate)
s_i_country_over_50 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=50,]
hist(s_i_country_over_50$merge_rate)
s_i_country_over_100 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=100,]
hist(s_i_country_over_100$merge_rate)
s_i_country_over_200 <- prs_pri_country_merge_rate[prs_pri_country_merge_rate$all_cnt >=200,]
hist(s_i_country_over_200$merge_rate)

#It can be seen that,except for cases where there are small number of pull requests,
#there is a high merging rate in the entire data

#It seems that the more interchanges for pull requests between countries, the higher the merging rate.

s_i_country_over_100_s_india <- s_i_country_over_100[s_i_country_over_100$prs_country == 'india',]
s_i_country_over_100_s_us <- s_i_country_over_100[s_i_country_over_100$prs_country == 'united states',]

# To compare how much each country has mergeing rate into each other.
prs_pri_country_merge_rate_rev <- prs_pri_country_merge_rate
combine_s_i <- merge(prs_pri_country_merge_rate,prs_pri_country_merge_rate_rev,
                     by.x=c("pri_country","prs_country"),by.y=c("prs_country","pri_country"))
combine_s_i$sub = combine_s_i$merge_rate.x - combine_s_i$merge_rate.y
combine_s_i <- combine_s_i[combine_s_i$sub >= 0,]

combine_s_i_notsame <- combine_s_i[combine_s_i$pri_country != combine_s_i$prs_country ,]

combine_s_i_notsame_over20 <- combine_s_i_notsame[combine_s_i_notsame$all_cnt.x >20 & combine_s_i_notsame$all_cnt.y >20 ,] 
combine_s_i_notsame_over50 <- combine_s_i_notsame[combine_s_i_notsame$all_cnt.x >50 & combine_s_i_notsame$all_cnt.y >50 ,] 
hist(combine_s_i_notsame_over50$sub,breaks = 40)
combine_s_i_notsame_over100 <- combine_s_i_notsame[combine_s_i_notsame$all_cnt.x >100 & combine_s_i_notsame$all_cnt.y >100 ,]
