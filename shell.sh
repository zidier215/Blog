#!/bin/bash 

filename=$1
echo $filename
echo "`whoami`"
if [ $# -lt 1 ];then
 echo "usage : ./scripts filename"
fi

if [ ! -f $filename ];then
	echo "$filename is not a file"
	exit 0;
fi 

user="`whoami`"
if [ "$user" != "root" ];then
 echo "use scripts with root"
 #exit 0;
fi

#ɾ������,���а�����tables + space
sed '/^[[:blank:]]*$/d' $filename > "${filename}_backup"

#ɾ�� // ���ڵ���
sed -i '/^[[:blank:]]*\/\//d' "${filename}_backup"

#/*xxxxx*/
#��ӡ/*���еĿ�ʼ��
grep -n '[[:blank:]]*/[*]' "${filename}_backup" | awk 'BEGIN{FS=":"}{print $1}' > "start.txt"
#��ӡ*/���еĽ�����
grep -n '[*]/[[:blank:]]*' "${filename}_backup" | awk 'BEGIN{FS=":"}{print $1}' > "end.txt"

#�ϲ������ļ���final.txt����ÿ�о���/*xx....\n....xx*/��������ע�͵Ŀ�ʼ�к���ʼ�к�
paste "start.txt" "end.txt" > "final.txt"

while read line
do
 #�õ���ʼ��
 START=`echo "$line" | awk 'BEGIN{FS="\t"}{print $1}'`
 #�õ�������
 END=`echo "$line" | awk 'BEGIN{FS="\t"}{print $2}'`
 #������һ��bug������/*xxxx*/�е�/*��*/��ͬһ�г���,�����д���Ҳ��ͬһ��
 # printf("hello world\n"); /*��ӡ�ַ���*/ 
 # /*��ӡ�ַ���*/
 #������������ľ�û���жϣ�ϣ������Ż�
 if [ $START -eq $END ];then
 continue
 fi
 #ɾ��/*��*/�м�������
 sed -i "${START},${END}d" "${filename}_backup"
done < "final.txt"

wc -l "${filename}_backup"
rm -f "final.txt" "start.txt" "end.txt"