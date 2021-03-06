# libraries ---------------------------------------------------------------
library(taxize)
library(foreach)
library(BIEN)

# data --------------------------------------------------------------------
Biome_Di_Ri<-read.csv("./outputs/Biome_Di_Ri_phylo.csv", row.names = 1)


sp_tmp<-unique(Biome_Di_Ri$species)
sp_tmp<-gsub("_"," ",sp_tmp)


df<-data.frame(species=NULL, family=NULL)

# I first use the tax_name function from the taxize package to extract the family information
# This function is much faster than the one from the BIEN R package
foreach(i=1:length(sp_tmp))%do% {
  print(paste("Extract",sp_tmp[i]))
  tmp<-tax_name(query = sp_tmp[i], get = "family", db = "ncbi")$family
  df_tmp<-data.frame(species=as.character(sp_tmp[i]), family=tmp)
  df<-rbind(df,df_tmp)
  write.csv(df, "./data/base/family.csv",append = T)
}

data_family<-read.csv("./data/base/family.csv", row.names = 1)

# Use BIEN database to extract the remaining information
sp_remain<-as.character(data_family$species[is.na(data_family$family)])

data_remain<-
  foreach(i=1:length(sp_remain),.combine = rbind)%do% {
    print(paste("Extract",sp_remain[i]))
    tmp<-unique(BIEN_taxonomy_species(sp_remain[i])$scrubbed_family)
    df_tmp<-data.frame(species=as.character(sp_remain[i]), family=tmp)
    df_tmp
  }

indx<-which(data_family$species%in%data_remain$species)

data_family$family<-as.character(data_family$family)
data_family$family[indx]<-as.character(data_remain$family)

write.csv(data_family,"./data/base/family_completed.csv")

unique(BIEN_taxonomy_species("Tragus australianus")$scrubbed_family)
