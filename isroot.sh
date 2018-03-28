echo "Please enter your username: "
read name

if [ "$name" = root ]
then
    echo "You are the superuser."
else
    echo "You are a regular user."
fi
