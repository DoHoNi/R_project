install.packages("dplyr")
library(dplyr)
until =10

range_until <-function(range, until){
  num =1
  ran = c(0,10,20,30,40,50,60,70,80,90,100)
  filere =paste("/home/dohyun/Desktop/R/range_until/range",toString(range),"_until",toString(until),sep="")
  while(num <until){
    cat(c("# What about case where developers submitted from ",num,"to",num+range," pull requests?\n"),file=filere, append=TRUE, sep=" ")
    #cat(st,fileConn,append=TRUE)
    
    tmp <-cnt_prs_pr[cnt_prs_pr$cnt_pr>= num & cnt_prs_pr$cnt_pr < num+range,]
    total = nrow(tmp)
    abc <- hist(tmp$merge_rate)
    cat(c("total : ", total,"\n"),file=filere, append=TRUE, sep=" ")
    #write(st,fileConn,append=TRUE)
    tmp2 <- transform(tmp,under = 
                        cut(tmp$merge_rate,breaks=c(0,10,20,30,40,50,60,70,80,90,100),
                            include.lowest =TRUE,
                            right = FALSE,
                            labels = c("0:10","10:20","20:30","30:40","40:50",
                                       "50:60","60:70","70:80","80:90","90:100")))
    
    tmp2 <-tmp2 %>% count(tmp2$under)
    names(tmp2) <- c('merge','count')
    tmp2$perc <- round(tmp2$count / total*100,2)
    write.table(tmp2,filere,append =TRUE,sep='  ',row.names = F)
    cat("\n",file=filere, append=TRUE, sep=" ")
    num =num +range
  }
}

range_until(2,100)
range_until(2,200)
range_until(20,100)

num =0
ran = c(0,10,20,30,40,50,60,70,80,90,100)
filere ="/home/dohyun/Desktop/R/range1_until10"
while(num <10){
  cat(c("# What about case where developers submitted from ",num,"to",num+1," pull requests?\n"),file=filere, append=TRUE, sep=" ")
  #cat(st,fileConn,append=TRUE)
  
  tmp <-cnt_prs_pr[cnt_prs_pr$cnt_pr>= num & cnt_prs_pr$cnt_pr < num+1,]
  total = nrow(tmp)
  
  cat(c("total : ", total,"\n"),file=filere, append=TRUE, sep=" ")
  #write(st,fileConn,append=TRUE)
  tmp2 <- transform(tmp,under = 
                      cut(tmp$merge_rate,breaks=c(0,10,20,30,40,50,60,70,80,90,100),
                          include.lowest =TRUE,
                          right = FALSE,
                          labels = c("0:10","10:20","20:30","30:40","40:50",
                                      "50:60","60:70","70:80","80:90","90:100")))
  
  tmp2 <-tmp2 %>% count(tmp2$under)
  names(tmp2) <- c('merge','count')
  tmp2$perc <- round(tmp2$count / total*100,2)
  write.table(tmp2,filere,append =TRUE,sep='  ',row.names = F)
  cat("\n",file=filere, append=TRUE, sep=" ")
  num =num +1
}

num =0
ran = c(0,10,20,30,40,50,60,70,80,90,100)
filere ="/home/dohyun/Desktop/R/range1_until50"
while(num <50){
  cat(c("# What about case where developers submitted from ",num,"to",num+1," pull requests?\n"),file=filere, append=TRUE, sep=" ")
  #cat(st,fileConn,append=TRUE)
  
  tmp <-cnt_prs_pr[cnt_prs_pr$cnt_pr>= num & cnt_prs_pr$cnt_pr < num+1,]
  total = nrow(tmp)
  
  cat(c("total : ", total,"\n"),file=filere, append=TRUE, sep=" ")
  #write(st,fileConn,append=TRUE)
  tmp2 <- transform(tmp,under = 
                      cut(tmp$merge_rate,breaks=c(0,10,20,30,40,50,60,70,80,90,100),
                          include.lowest =TRUE,
                          right = FALSE,
                          labels = c("0:10","10:20","20:30","30:40","40:50",
                                     "50:60","60:70","70:80","80:90","90:100")))
  
  tmp2 <-tmp2 %>% count(tmp2$under)
  names(tmp2) <- c('merge','count')
  tmp2$perc <- round(tmp2$count / total*100,2)
  write.table(tmp2,filere,append =TRUE,sep='  ',row.names = F)
  cat("\n",file=filere, append=TRUE, sep=" ")
  num =num +1
}

num =0
ran = c(0,10,20,30,40,50,60,70,80,90,100)
filere ="/home/dohyun/Desktop/R/range2_until100"
while(num <100){
  cat(c("# What about case where developers submitted from ",num,"to",num+2," pull requests?\n"),file=filere, append=TRUE, sep=" ")
  #cat(st,fileConn,append=TRUE)
  
  tmp <-cnt_prs_pr[cnt_prs_pr$cnt_pr>= num & cnt_prs_pr$cnt_pr < num+1,]
  total = nrow(tmp)
  
  cat(c("total : ", total,"\n"),file=filere, append=TRUE, sep=" ")
  #write(st,fileConn,append=TRUE)
  tmp2 <- transform(tmp,under = 
                      cut(tmp$merge_rate,breaks=c(0,10,20,30,40,50,60,70,80,90,100),
                          include.lowest =TRUE,
                          right = FALSE,
                          labels = c("0:10","10:20","20:30","30:40","40:50",
                                     "50:60","60:70","70:80","80:90","90:100")))
  
  tmp2 <-tmp2 %>% count(tmp2$under)
  names(tmp2) <- c('merge','count')
  tmp2$perc <- round(tmp2$count / total*100,2)
  write.table(tmp2,filere,append =TRUE,sep='  ',row.names = F)
  cat("\n",file=filere, append=TRUE, sep=" ")
  num =num +2
}

num =0
ran = c(0,10,20,30,40,50,60,70,80,90,100)
filere ="/home/dohyun/Desktop/R/range3_until50"

while(num <50){
  cat(c("# What about case where developers submitted from ",num,"to",num+3," pull requests?\n"),file=filere, append=TRUE, sep=" ")
  #cat(st,fileConn,append=TRUE)
  
  tmp <-cnt_prs_pr[cnt_prs_pr$cnt_pr>= num & cnt_prs_pr$cnt_pr < num+3,]
  total = nrow(tmp)
  
  cat(c("total : ", total,"\n"),file=filere, append=TRUE, sep=" ")
  #write(st,fileConn,append=TRUE)
  tmp2 <- transform(tmp,under = 
                      cut(tmp$merge_rate,breaks=c(0,10,20,30,40,50,60,70,80,90,100),
                          include.lowest =TRUE,
                          right = FALSE,
                          labels = c("0:10","10:20","20:30","30:40","40:50",
                                     "50:60","60:70","70:80","80:90","90:100")))
  
  tmp2 <-tmp2 %>% count(tmp2$under)
  names(tmp2) <- c('merge','count')
  tmp2$perc <- round(tmp2$count / total*100,2)
  write.table(tmp2,filere,append =TRUE,sep='  ',row.names = F)
  cat("\n",file=filere, append=TRUE, sep=" ")
  num =num +3
}


num =0
ran = c(0,10,20,30,40,50,60,70,80,90,100)
filere ="/home/dohyun/Desktop/R/range5_until100"

while(num <100){
  cat(c("# What about case where developers submitted from ",num,"to",num+5," pull requests?\n"),file=filere, append=TRUE, sep=" ")
  #cat(st,fileConn,append=TRUE)
  
  tmp <-cnt_prs_pr[cnt_prs_pr$cnt_pr>= num & cnt_prs_pr$cnt_pr < num+3,]
  total = nrow(tmp)
  
  cat(c("total : ", total,"\n"),file=filere, append=TRUE, sep=" ")
  #write(st,fileConn,append=TRUE)
  tmp2 <- transform(tmp,under = 
                      cut(tmp$merge_rate,breaks=c(0,10,20,30,40,50,60,70,80,90,100),
                          include.lowest =TRUE,
                          right = FALSE,
                          labels = c("0:10","10:20","20:30","30:40","40:50",
                                     "50:60","60:70","70:80","80:90","90:100")))
  
  tmp2 <-tmp2 %>% count(tmp2$under)
  names(tmp2) <- c('merge','count')
  tmp2$perc <- round(tmp2$count / total*100,2)
  write.table(tmp2,filere,append =TRUE,sep='  ',row.names = F)
  cat("\n",file=filere, append=TRUE, sep=" ")
  num =num +5
}



n=0
filere ="/home/dohyun/Desktop/R/pr_cnt_merge_rate/until1000_pr100"
cnt_pr <- cnt_prs_pr[cnt_prs_pr$cnt_pr>2,]
sort_cnt_pr <- cnt_pr[order(cnt_pr$cnt_pr),]
while(n<1000){
  nn=n+100
  cat(c("# index ",n,"to",nn," pull requests?\n"),file=filere, append=TRUE, sep=" ")
  tmp <- sort_cnt_pr[n:nn,]
  total = nrow(tmp)
  tmp2 <- transform(tmp,under = 
                      cut(tmp$merge_rate,breaks=c(0,10,20,30,40,50,60,70,80,90,100),
                          include.lowest =TRUE,
                          right = FALSE,
                          labels = c("0:10","10:20","20:30","30:40","40:50",
                                     "50:60","60:70","70:80","80:90","90:100")))
  
  tmp2 <-tmp2 %>% count(tmp2$under)
  names(tmp2) <- c('merge','count')
  tmp2$perc <- round(tmp2$count / total*100,2)
  write.table(tmp2,filere,append =TRUE,sep='  ',row.names = F)
  cat("\n",file=filere, append=TRUE, sep=" ")
  n =n +100
}

n=0
filere ="/home/dohyun/Desktop/R/pr_cnt_merge_rate/until2000_pr200"
cnt_pr <- cnt_prs_pr[cnt_prs_pr$cnt_pr>2,]
sort_cnt_pr <- cnt_pr[order(cnt_pr$cnt_pr),]
while(n<2000){
  nn=n+200
  cat(c("# index ",n,"to",nn," pull requests?\n"),file=filere, append=TRUE, sep=" ")
  tmp <- sort_cnt_pr[n:nn,]
  total = nrow(tmp)
  tmp2 <- transform(tmp,under = 
                      cut(tmp$merge_rate,breaks=c(0,10,20,30,40,50,60,70,80,90,100),
                          include.lowest =TRUE,
                          right = FALSE,
                          labels = c("0:10","10:20","20:30","30:40","40:50",
                                     "50:60","60:70","70:80","80:90","90:100")))
  
  tmp2 <-tmp2 %>% count(tmp2$under)
  names(tmp2) <- c('merge','count')
  tmp2$perc <- round(tmp2$count / total*100,2)
  write.table(tmp2,filere,append =TRUE,sep='  ',row.names = F)
  cat("\n",file=filere, append=TRUE, sep=" ")
  n =n +200
}


n=0
filere ="/home/dohyun/Desktop/R/pr_cnt_merge_rate/until2000_pr100"
cnt_pr <- cnt_prs_pr[cnt_prs_pr$cnt_pr>2,]
sort_cnt_pr <- cnt_pr[order(cnt_pr$cnt_pr),]
while(n<2000){
  nn=n+100
  cat(c("# index ",n,"to",nn," pull requests?\n"),file=filere, append=TRUE, sep=" ")
  tmp <- sort_cnt_pr[n:nn,]
  total = nrow(tmp)
  tmp2 <- transform(tmp,under = 
                      cut(tmp$merge_rate,breaks=c(0,10,20,30,40,50,60,70,80,90,100),
                          include.lowest =TRUE,
                          right = FALSE,
                          labels = c("0:10","10:20","20:30","30:40","40:50",
                                     "50:60","60:70","70:80","80:90","90:100")))
  
  tmp2 <-tmp2 %>% count(tmp2$under)
  names(tmp2) <- c('merge','count')
  tmp2$perc <- round(tmp2$count / total*100,2)
  write.table(tmp2,filere,append =TRUE,sep='  ',row.names = F)
  cat("\n",file=filere, append=TRUE, sep=" ")
  n =n +100
}

n=0
filere ="/home/dohyun/Desktop/R/pr_cnt_merge_rate/until6540_pr100"
cnt_pr <- cnt_prs_pr[cnt_prs_pr$cnt_pr>2,]
sort_cnt_pr <- cnt_pr[order(cnt_pr$cnt_pr),]
while(n<6940){
  nn=n+100
  cat(c("# index ",n,"to",nn," pull requests?\n"),file=filere, append=TRUE, sep=" ")
  tmp <- sort_cnt_pr[n:nn,]
  total = nrow(tmp)
  tmp2 <- transform(tmp,under = 
                      cut(tmp$merge_rate,breaks=c(0,10,20,30,40,50,60,70,80,90,100),
                          include.lowest =TRUE,
                          right = FALSE,
                          labels = c("0:10","10:20","20:30","30:40","40:50",
                                     "50:60","60:70","70:80","80:90","90:100")))
  
  tmp2 <-tmp2 %>% count(tmp2$under)
  names(tmp2) <- c('merge','count')
  tmp2$perc <- round(tmp2$count / total*100,2)
  write.table(tmp2,filere,append =TRUE,sep='  ',row.names = F)
  cat("\n",file=filere, append=TRUE, sep=" ")
  n =n +100
}

n=0
filere ="/home/dohyun/Desktop/R/pr_cnt_merge_rate/until6540_pr500"
cnt_pr <- cnt_prs_pr[cnt_prs_pr$cnt_pr>2,]
nrow(cnt_pr)
sort_cnt_pr <- cnt_pr[order(cnt_pr$cnt_pr),]
while(n<6540){
  nn=n+500
  cat(c("# index ",n,"to",nn," pull requests?\n"),file=filere, append=TRUE, sep=" ")
  tmp <- sort_cnt_pr[n:nn,]
  total = nrow(tmp)
  tmp2 <- transform(tmp,under = 
                      cut(tmp$merge_rate,breaks=c(0,10,20,30,40,50,60,70,80,90,100),
                          include.lowest =TRUE,
                          right = FALSE,
                          labels = c("0:10","10:20","20:30","30:40","40:50",
                                     "50:60","60:70","70:80","80:90","90:100")))
  
  tmp2 <-tmp2 %>% count(tmp2$under)
  names(tmp2) <- c('merge','count')
  tmp2$perc <- round(tmp2$count / total*100,2)
  write.table(tmp2,filere,append =TRUE,sep='  ',row.names = F)
  cat("\n",file=filere, append=TRUE, sep=" ")
  n =n +1000
}



