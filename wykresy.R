require('ggplot2')
df <- read.csv('gr_efekt.csv') # wczytaj wartosci z optymalizacji
brzegowe <- c(which(df[,1] == min(df[,1])), # znajdz indeksy dla maks. wyniku i min. ryzyka
              which(df[,2] == max(df[,2])))
# narysuj
p1 <- ggplot(df,aes(x=ryzyko,y=wynik))+
  geom_line()+
  ggtitle("Zbiór rozwi¹zañ efektywnych")+
  ylab("Zysk")+
  xlab("Ryzyko")+
  geom_point(data=df[brzegowe,], aes(x=ryzyko,y=wynik), color="red")

# zapisz w pliku
png("zbior_rozw_efekt.png")
  print(p1)
dev.off()

#podaj wartosci dla maks. wyniku i min. ryzyka
print(df[brzegowe,])

#