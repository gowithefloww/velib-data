df <- read.csv("ml/dispo/data/part-00000")
df$bikes <- as.double(df$bikes)
df$mp15 <- as.double(df$mp15)
df$mm30 <- as.double(df$mm30)
df$hm1 <- as.double(df$hm1)
df$hm24 <- as.double(df$hm24)
df$hm25 <- as.double(df$hm25)

initial_model <- lm(mp15 ~ ., data=df)
best_model <- step(initial_model, direction="both", trace=0)
summary(best_model)
plot(best_model)

