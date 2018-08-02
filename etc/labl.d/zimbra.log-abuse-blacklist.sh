#!/bin/bash

# 20180730, jtingiris

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# signature is what's grep'ed, e.g. email@somewhere.com, service=smtp, etc.
signature="$1"

if [ "$signature" == "" ]; then
    echo "usage: $0 <signature>"
    echo "-or"
    echo "usage: $0 <labl-reload|summary>"
    exit 1
fi

abuse_ip_file=abuse-ip-blacklist
abuse_ip_data=/etc/labl.d/${abuse_ip_file}.data
abuse_ip_data_tmp=${abuse_ip_data}.tmp
abuse_timestamp=$(date +%Y%m%d%H%M%S.%N)
abuse_signature_tmp=/tmp/${abuse_ip_file}-${signature}.tmp
abuse_signature_ip_tmp=/tmp/${abuse_ip_file}-ip-${signature}.tmp

tmp_dir=/opt/labl/tmp
if [ ! -d "$tmp_dir" ]; then
    mkdir -p "$tmp_dir"
fi

abuse_ip_save=${tmp_dir}/${abuse_ip_file}.${abuse_timestamp}
abuse_signature_save=${tmp_dir}/${abuse_ip_file}.${abuse_timestamp}.${signature}

if [ "$signature" == "labl-reload" ]; then
    if [ -s ${abuse_ip_data} ]; then
        if [ -x /opt/labl/sbin/blacklist ]; then
            /opt/labl/sbin/blacklist restart
            for abuse_ip in $(cat ${abuse_ip_data}); do
                echo "$(date) $(/opt/labl/sbin/blacklist add $abuse_ip)"
            done
        else
            echo "$(date) /opt/labl/sbin/blacklist file not executable"
        fi
    fi
    exit
fi

if [ "$signature" == "summary" ]; then
    if [ -s ${abuse_ip_data} ]; then
        # this will simply output a summary /24 route for all subnets with 10 or more abusive IPs detected
        #((for subnet in $(cat ${abuse_ip_data} | awk -F\. '{print $1"."$2"."$3}' |sort -uV); do echo -n "subnet $subnet = "; grep -c ^${subnet}\.[0-9] ${abuse_ip_data}; done) | sort -k 4n | grep \ [0-9][0-9]$) | awk '{print $2".0/24"}'
        while read subnet; do
            if [ -r /etc/blacklist.labl ]; then
                in_blacklist_labl=$(grep ^${subnet} /etc/blacklist.labl)
                if [ "$in_blacklist_labl" == "" ]; then
                    echo "[NOTICE] ${abuse_ip_data} contains abusive subnet ${subnet} but NOT in /etc/blacklist.labl"
                    # TODO add this to the blacklist file?
                else
                    echo "[  OK  ] ${abuse_ip_data} contains abusive subnet ${subnet} is in /etc/blacklist.labl"
                fi
            else
                echo "${abuse_ip_data} contains abusive subnet ${subnet}"
            fi
            #; grep -c ^${subnet}\.[0-9] ${abuse_ip_data}
        done <<< "$(cat ${abuse_ip_data} | awk -F\. '{print $1"."$2"."$3}' | sort -V | uniq -c | sort -n | grep "^[[:space:]].*[0-1][0-9][[:space:]]" | awk '{print $2".0/24"}')"
    fi
    exit
fi

if [ -r /var/log/zimbra.log ]; then

    egrep -e 'SASL.*+authentication failed:|auth failure:' /var/log/zimbra.log 2> /dev/null | egrep -e 'warning:|do_auth' | awk '{$1=$2=$3=$4=$5=""; print $0}' | awk '/warning:/ {printf "\n%s\n",$0;next} {printf "%s ",$0}' | sed '$!N;s/\n\s*do_auth//;P;D' | grep warning: > ${abuse_signature_tmp}

    # this is helpful, too, but do not use (yet) ...
    #cat /var/log/zimbra.log | grep sasl | grep smtps | grep "$signature" | grep client= | awk -Fclient= '{print $NF}'

    if [ -s ${abuse_signature_tmp} ]; then

        cat ${abuse_signature_tmp} | sort -uV | awk -F\] '{print $1}' | awk -F\[ '{print $NF}' > ${abuse_signature_ip_tmp}

        if [ -s ${abuse_signature_ip_tmp} ]; then
            #echo "$(date) $0 $@ evaluation started"

            if [ -s ${abuse_ip_data} ]; then
                cat ${abuse_ip_data} ${abuse_signature_ip_tmp} | sort -uV > ${abuse_ip_data_tmp}
            else
                echo "$(date) $0 $@ creating $abuse_ip_data from $abuse_signature_ip_tmp"
                cat ${abuse_signature_ip_tmp} | sort -uV > ${abuse_ip_data}
            fi

            if [ -s ${abuse_ip_data} ] && [ -s ${abuse_ip_data_tmp} ]; then
                #echo "$(date) $0 $@ diff $abuse_ip_data $abuse_ip_data_tmp"
                abuse_ips="$(diff ${abuse_ip_data_tmp} ${abuse_ip_data} 2> /dev/null | egrep -e '^<' | cut -c 3-)"
                if [ "$abuse_ips" != "" ]; then
                    for abuse_ip in $abuse_ips; do
                        if [ -x /opt/labl/sbin/blacklist ]; then
                            #echo "$(date) blacklisting $abuse_ip ..."
                            echo "$(date) $(/opt/labl/sbin/blacklist add $abuse_ip)"
                        else
                            echo "$(date) NOT blacklisting $abuse_ip ..."
                        fi
                    done

                    cp "${abuse_ip_data}" "${abuse_ip_save}"
                    if [ $? -ne 0 ]; then
                        echo "$(date) $0 $@ FAILED to copy '$abuse_ip_data' to '$abuse_ip_data_save'"
                    else
                        #echo "$(date) $0 $@ saved $abuse_ip_save"
                        cp "${abuse_ip_data_tmp}" "${abuse_ip_data}"
                        if [ $? -ne 0 ]; then
                            echo "$(date) $0 $@ FAILED to copy '$abuse_ip_data_tmp' to '$abuse_ip_data'"
                        fi
                    fi

                    cp "${abuse_signature_tmp}" "${abuse_signature_save}"
                    if [ $? -ne 0 ]; then
                        echo "$(date) $0 $@ FAILED to copy '$abuse_signature_tmp' to '$abuse_signature_save'"
                    fi

                else
                    echo "$(date) no new abusive ips detected"
                fi

                if [ "$abuse_ip_data_tmp" != "" ] && [ -r "${abuse_ip_data_tmp}" ]; then
                    rm -f "${abuse_ip_data_tmp}"
                fi

            fi
        fi
    fi
fi
