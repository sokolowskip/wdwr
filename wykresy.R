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

# zad 4
df <- data.frame(
  prob=c(0,0,.3,.3,1,1,0,0,.2,.2,.3,.3,1,1,0,0,.2,.2,.3,.3,1,1),
  point = c(rep("p1",6),rep("p2",8),rep("p3",8)),
  profit = c(
    65000,
    79540.3,
    79540.3,
    80834.4, # p. pom.
    80834.4,
    97000, #p pom
    
    65000,
    72650,
    72650,
    85200, #p pom
    85200,
    91300, # p pom
    91300,
    97000, #p pom
    
    65000,
    67775.7,
    67775.7,
    89012.9, #p pom
    89012.9,
    95962.9, #p pom
    95962.9,
    97000 #p pom
    )
  )

p2 <- ggplot(df,aes(x=profit,y=prob)) +
  geom_line(aes(color=point))+
  xlim(65000,97001)+
  ggtitle("Dystrybuanty pierwszego rzêdu")+
  xlab("Zysk")+
  ylab("Prawdopodobieñstwo")
png("dominacja.png")
  print(p2)
dev.off()

# dystrybuanty drugiego rzêdu
fun1 <- function(x){
  if(x < 79540.3){
    0
  }
  else if (x < 80834.4){
    0.3*x - 79540.3*0.3
  }
  else{
    x - 80446.17
  }
}
fun2 <- function(x){
  if(x < 72650){
    0
  }
  else if (x < 85200){
    0.2*x - 72650*0.2
  }
  else if (x < 91300){
    0.3*x -23050
  }
  else{
       x - 86960
  }
}
fun3 <- function(x){
  if(x < 67775.7){
    0
  }
  else if (x < 89012.9){
    0.2*x - 67775.7*0.2
  }
  else if (x < 95962.9){
    0.3*x -21066.43
  }
  else{
    x - 88240.46
  }
}
x <- seq(65000,97000,by=100)
df <- data.frame(profit=rep(x,3),
                 prob = c(sapply(x,fun1),
                          sapply(x,fun2),
                          sapply(x,fun3)),
                 point = c(rep('p1',length(x)),
                           rep('p2',length(x)),
                           rep('p3',length(x)))
)
p3 <- ggplot(df,aes(x=profit,y=prob)) +
  geom_line(aes(color=point))+
  xlim(65000,97001)+
  ggtitle("Dystrybuanty drugiego rzêdu")+
  xlab("Zysk")+
  ylab("Prawdopodobieñstwo")
png('dominacja2.png')
  print(p3)
dev.off()