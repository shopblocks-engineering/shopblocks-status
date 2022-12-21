#!/bin/bash

commit=true
KEYSARRAY=()
URLSARRAY=()

urlsConfig="./urls.cfg"
echo "Reading $urlsConfig"
while read -r line
do
  echo "  $line"
  IFS='=' read -ra TOKENS <<< "$line"
  KEYSARRAY+=(${TOKENS[0]})
  URLSARRAY+=(${TOKENS[1]})
done < "$urlsConfig"

echo "***********************"
echo "Starting health checks with ${#KEYSARRAY[@]} configs:"

mkdir -p logs

for (( index=0; index < ${#KEYSARRAY[@]}; index++))
do
  key="${KEYSARRAY[index]}"
  url="${URLSARRAY[index]}"
  echo "  $key=$url"

#  echo "$url"
#  status_code=$(curl --write-out "%{http_code}" --silent --output /dev/null "${url}")
#  echo "$status_code"

  for i in 1 2 3 4;
  do
    status_code=$(curl --write-out '%{http_code}' --silent --output /dev/null $url)
    if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 202 ] || [ "$status_code" -eq 301 ] || [ "$status_code" -eq 307 ]; then
      result="success"
      break
    else
      if [ "$status_code" -eq 302 ]; then
        status_code=$(curl --write-out '%{http_code}' --silent --output /dev/null "$url/login")

        if [ "$status_code" -eq 200 ] || [ "$status_code" -eq 202 ] || [ "$status_code" -eq 301 ] || [ "$status_code" -eq 307 ]; then
          result="success"
          break
        else
          result="failed"
        fi
      else
        result="failed"
      fi
    fi

    if [ "$url" == "https://api.shopblocks.com/test-client" ] && [ "$status_code" -eq 500 ]; then
      result="success"
      break
    fi

    if [ "$url" == "https://search.shopblocks.com" ] && [ "$status_code" -eq 403 ]; then
      result="success"
      break
    fi

    sleep 5
  done
  dateTime=$(date +'%Y-%m-%d %H:%M')
  if [[ $commit == true ]]
  then
    echo $dateTime, $result >> "logs/${key}_report.log"
  else
    echo "    $dateTime, $result"
  fi
done

if [[ $commit == true ]]
then
  git config --global user.name 'Shopblocks'
  git config --global user.email 'dev1@shopblocks.com'
  git add -A --force logs/
  git commit -am '[Automated] Update Health Check Logs'
  git push
fi
