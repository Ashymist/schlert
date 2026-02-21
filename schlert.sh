#! /usr/bin/sh

if [ ! -r ./log.txt ]
    then touch ./log.txt;
fi

date=$(date);

token=$1;
bot_url="https://api.telegram.org/bot$token/sendMessage?chat_id=@schlert&text=Расписание%20было%20обновлено!";

printf "LOG START - $date\n" >> ./log.txt;
printf "Getting url...\n" >> ./log.txt;

url=$(curl -s https://kpfu.ru/computing-technology/raspisanie | iconv -f WINDOWS-1251 -t UTF-8//TRANSLIT | grep -a -o 'https.*Raspisanie_[1-2]_.*\.xlsx');
if [ ! -z $url ]
    then
        filename=$(basename "$url");
        printf "Download url: $url\n" >> ./log.txt;
        printf "Filename: $filename\n" >> ./log.txt;
    else
        printf "Failed getting the url\n" >> ./log.txt;
fi

curl -O -s $url;
new_md5=$(md5sum "./$filename" | awk '{print $1}');

if [ -r ./current_md5.txt ]
    then 
        
        printf 'MD5 checksum file is present, checking the sum...\n' >> ./log.txt;
        md5=$(<./current_md5.txt);
        printf "Old MD5: $md5\n" >> ./log.txt;
        printf "New MD5: $new_md5\n" >> ./log.txt;
        if [ "$new_md5" = "$md5" ]
            then
                printf 'MD5 sum hasn`t changed\n' >> ./log.txt;
            else
                printf 'MD5 sum has changed! Changing the MD5 checksum file...\n' >> ./log.txt;
                echo "$new_md5" > './current_md5.txt' ;
                printf 'Sending notification...\n' >> ./log.txt;
                curl $bot_url;
                
        fi
    else
        printf 'MD5 checksum file does not exist, creating new MD5 checksum file...\n' >> ./log.txt;
        touch ./current_md5.txt;
        echo $new_md5 > ./current_md5.txt;
fi


printf "LOG END\n\n" >> ./log.txt;