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

#删除空行,空行包括：tables + space
sed '/^[[:blank:]]*$/d' $filename > "${filename}_backup"

#删除 // 所在的行
sed -i '/^[[:blank:]]*\/\//d' "${filename}_backup"

#/*xxxxx*/
#打印/*所有的开始行
grep -n '[[:blank:]]*/[*]' "${filename}_backup" | awk 'BEGIN{FS=":"}{print $1}' > "start.txt"
#打印*/所有的结束行
grep -n '[*]/[[:blank:]]*' "${filename}_backup" | awk 'BEGIN{FS=":"}{print $1}' > "end.txt"

#合并两个文件，final.txt里面每行就是/*xx....\n....xx*/这种类型注释的开始行和起始行号
paste "start.txt" "end.txt" > "final.txt"

while read line
do
 #得到起始行
 START=`echo "$line" | awk 'BEGIN{FS="\t"}{print $1}'`
 #得到结束行
 END=`echo "$line" | awk 'BEGIN{FS="\t"}{print $2}'`
 #这里有一个bug，如是/*xxxx*/中的/*和*/在同一行出现,并且有代码也在同一行
 # printf("hello world\n"); /*打印字符串*/ 
 # /*打印字符串*/
 #上面两种情况的就没法判断，希望大家优化
 if [ $START -eq $END ];then
 continue
 fi
 #删除/*到*/中间所有行
 sed -i "${START},${END}d" "${filename}_backup"
done < "final.txt"

wc -l "${filename}_backup"
rm -f "final.txt" "start.txt" "end.txt"