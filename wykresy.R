require('ggplot2')
df <- read.csv('gr_efekt.csv')
p1 <- ggplot(df,aes(x=ryzyko,y=wynik))+geom_line()+ggtitle("Zbiór rozwi¹zañ efektywnych")+
  ylab("Zysk")+xlab("Ryzyko")
png("zbior_rozw_efekt.png")
print(p1)
dev.off()