require('ggplot2') # biblioteka rysujaca

df <- read.csv('gr_efekt.csv') # wczytaj wartosci z przeprowadzonych optymalizacji
brzegowe <- c(which(df[,1] == min(df[,1])), # znajdz indeksy dla maks. wyniku i min. ryzyka
              which(df[,2] == max(df[,2])))
# narysuj zbior rozwiazan efektywnych
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

# zbior punktow do rysowania dystrybuant
# p. pom. to punkty pomocnicze sluzace do przedstawienia wykresu w przystepniejszej formia
df <- data.frame(
  prob=c(0,0,.3,.3,1,1,0,0,.2,.2,.3,.3,1,1,0,0,.2,.2,.3,.3,1,1),
  point = c(rep("p1",6),rep("p2",8),rep("p3",8)),
  profit = c(
    65000, # p. pom.
    79540.3,# p. pom.
    79540.3,
    80834.4, # p. pom.
    80834.4,
    97000, #p pom
    
    65000,# p. pom.
    72650,# p. pom.
    72650,
    85200, #p pom
    85200,
    91300, # p pom
    91300,
    97000, #p pom
    
    65000,# p. pom.
    67775.7,# p. pom.
    67775.7,
    89012.9, #p pom
    89012.9,
    95962.9, #p pom
    95962.9,
    97000 #p pom
    )
  )

# narysuj dystrybuanty pierwszego rzedu
p2 <- ggplot(df,aes(x=profit,y=prob)) +
  geom_line(aes(color=point))+
  xlim(65000,97001)+
  ggtitle("Dystrybuanty pierwszego rzêdu")+
  xlab("Zysk")+
  ylab("Prawdopodobieñstwo")
png("dominacja.png")
  print(p2)
dev.off()

# funkcje okreslajace dystrybuanty drugiego rzêdu
# punkt 1
fun1 <- function(x){
  if(x < 79540.3){
    0
  }
  else if (x < 80834.4){
    0.3*x - 23862.09
  }
  else{
    x - 80446.17
  }
}
# punkt 2
fun2 <- function(x){
  if(x < 72650){
    0
  }
  else if (x < 85200){
    0.2*x - 14530
  }
  else if (x < 91300){
    0.3*x -23050
  }
  else{
       x - 86960
  }
}
# punkt 3
fun3 <- function(x){
  if(x < 67775.7){
    0
  }
  else if (x < 89012.9){
    0.2*x - 13555.14
  }
  else if (x < 95962.9){
    0.3*x -21066.43
  }
  else{
    x - 88240.46
  }
}

# wektor mozliwych wynikow
x <- seq(65000,97000,by=100)
# zbior punktow z obliczonymi wartosciami dla kazdej dystrybuanty
df <- data.frame(profit=rep(x,3),
                 prob = c(sapply(x,fun1),
                          sapply(x,fun2),
                          sapply(x,fun3)),
                 point = c(rep('p1',length(x)),
                           rep('p2',length(x)),
                           rep('p3',length(x)))
)
# narysuj wykres
p3 <- ggplot(df,aes(x=profit,y=prob)) +
  geom_line(aes(color=point))+
  xlim(65000,97001)+
  ggtitle("Dystrybuanty drugiego rzêdu")+
  xlab("Zysk")+
  ylab("Prawdopodobieñstwo")

# zapis do pliku
png('dominacja2.png')
  print(p3)
dev.off()