library(xlsx);
bodyfatdata<-read.xlsx('bodyfatdata.xlsx',1);

percentageFat<-bodyfatdata$percentageFat;
age<-bodyfatdata$age