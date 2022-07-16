# backup docker containers 

# write container ids to text file
echo docker ps -aq > container_ids.txt

i = 0
while read id; do
    docker commit -p "$id" "docker-backup$i"
    name = "container$i"
    docker save -o ~/$name.tar "docker-backup$i"
    # save tar file to termbin 
    ((i=i+1))
done < container_ids.txt