child_account_ids=`aws ssm get-parameter --name "test" --query Parameter.Value`

echo "$child_account_ids" | sed -n 1'p' | tr ',' '\n' | while read account_id; do
    account_id=`echo $account_id | tr -d '"'`
    echo "the account number is $account_id"
    echo "terraform init with $account_id"
    echo "terraform plan with $account_id"
    echo "terraform apply with $account_id"
done