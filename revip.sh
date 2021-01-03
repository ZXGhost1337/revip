#!/bin/bash
# Name     : Accurate Reverse IP
# Type     : Enumeration


echo "     ____            ________  ";
echo "    / __ \___ _   __/  _/ __ \ ";
echo "   / /_/ / _ \ | / // // /_/ / ";
echo "  / _, _/  __/ |/ // // ____/  ";
echo " /_/ |_|\___/|___/___/_/ V 2.0 ";
echo "                By ZeroXGhost1337 "
echo "----- Accurate Reverse IP -----";
echo "";

echo -ne "[?] Input Site : ";
read TARGET;

REALIP=$(dig +short ${TARGET} | grep -oE "\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" | head -1);

echo "INFO: address $REALIP"
if [[ -z ${REALIP} ]];then
	echo "ERROR: ${TARGET} invalid domain";
	exit;
fi

if [[ -f ./accurev-ip/${TARGET}_SITES.LST ]];then
	echo "INFO: ${TARGET} had scanned";
	echo "INFO: file locate (./accurev-ip/${TARGET}.done)"
	echo -ne "[?] Want to try scan again? [y/n] : ";
	read CHS;
	if [[ ${CHS} == "n" ]];then
		exit;
	fi
	rm -f ./accurev-ip/${TARGET}.done
fi

if [[ ! -d "accurev-ip" ]];then
	mkdir accurev-ip
fi

function cleanUp() {
	if [[ -f REVERSEIP.TEMP ]];then
		rm REVERSEIP.TEMP;
	fi
	if [[ -f REVERSEIP2.TEMP ]];then
		rm REVERSEIP2.TEMP;
	fi
	if [[ -f REVERSEIP3.TEMP ]];then
		rm REVERSEIP3.TEMP;
	fi
}
cleanUp;

function yougetsignal() {
	WEB="${1}"
	CURL=$(curl -s -F "remoteAddress=${WEB}" "https://domains.yougetsignal.com/domains.php");
	IP=$(echo ${CURL} | grep -Po 'remoteIpAddress":"\K.*?(?=")');
	echo "INFO: Grab sites from yougetsignal.com"
	i=0;
	for SITE in $(echo ${CURL} | grep -Po '\["\K.*?(?=",)');
	do
		((i++))
		echo "${SITE}" >> REVERSEIP.TEMP;
	done
	echo "INFO: Total ${i} sites grabbed";
}

function viewdns() {
	WEB="${1}";
	echo "INFO: Grab sites from viewdns.info"
	i=0;
	for SITE in $(curl -s "https://viewdns.info/reverseip/?host=${WEB}&t=1" | grep '</td><td' | sed 's|</td><td|\n|g' | sed 's| <td>| |g' | awk '{print $2}' | sed  '/^$/d' | sed '1d' | sed '1d');
	do
		((i++))
		echo "${SITE}" >> REVERSEIP.TEMP;
	done
	echo "INFO: Total ${i} sites grabbed";
}

function hackertarget() {
	WEB="${1}";
	echo "INFO: Grab sites from hackertarget.com"
	i=0;
	for SITE in $(curl -s -d "theinput=${WEB}&thetest=reverseiplookup&name_of_nonce_field=d210302267&_wp_http_referer=%2Freverse-ip-lookup%2F" "https://hackertarget.com/reverse-ip-lookup/" | sed -n -e '/<pre id="formResponse">/,/<\/pre>/p' | sed 's/<pre id="formResponse">/LINEPALINGATAS\n/g' | grep -v LINEPALINGATAS | grep -v '</pre>');
	do
		((i++))
		echo "${SITE}" >> REVERSEIP.TEMP;
	done
	echo "INFO: Total ${i} sites grabbed";
}

yougetsignal ${TARGET}
viewdns ${TARGET}
hackertarget ${TARGET}

cat REVERSEIP.TEMP | sort -n | uniq >> REVERSEIP2.TEMP
echo "INFO: Total unique sites $(cat REVERSEIP2.TEMP | wc -l)";

function webchk() {
	WEB="${1}";
	ADDR=$(dig +short ${WEB} | grep -oE "\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" | head -1);
	if [[ ! -z ${ADDR} ]]
	then
		echo "INFO: ${WEB} - ${ADDR}";
		echo "${ADDR} ${WEB}" >> REVERSEIP3.TEMP;
	else
		echo "ERROR: ${WEB} invalid domain";
		return 1;
	fi
}

for WEB in $(cat REVERSEIP2.TEMP);
do
	webchk "${WEB}" &
done
wait

cat REVERSEIP3.TEMP | grep "${REALIP}" | awk '{print $2}' >> ./accurev-ip/${TARGET}.done;
echo "INFO: Total $(cat ./accurev-ip/${TARGET}.done | wc -l) sites same with ${TARGET}'s server";
echo "DONE: Saved ./accurev-ip/${TARGET}.done";
cleanUp;