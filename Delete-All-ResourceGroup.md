# Delete All Azure Resources with its resource groups

az group list --query [].name -o tsv | xargs -otl az group delete -y --no-wait -n
