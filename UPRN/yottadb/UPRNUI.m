UPRNUI ; ; 6/22/20 2:03pm
 ;set ^%W(17.6001,"B","GET","ui/login","LOGIN^UPRNUI",0)=""
 ;set ^%W(17.6001,"B","POST","check/login","CHECK^UPRNUI",8)=""
 ;set ^%W(17.6001,"B","POST","ui/calculate","CALC^UPRNUI",8)=""
 set ^%W(17.6001,"B","POST","api/fileupload","UPLOAD^UPRNUI",123)=""
 set ^%W(17.6001,123,0)="POST"
 set ^%W(17.6001,123,1)="api/fileupload"
 set ^%W(17.6001,123,2)="UPLOAD^UPRNUI"
 set ^%W(17.6001,"B","GET","api/fileresponse","RETFILE^UPRNUI",45)=""
 S ^%W(17.6001,45,0)="GET"
 S ^%W(17.6001,45,1)="api/fileresponse"
 S ^%W(17.6001,45,2)="RETFILE^UPRNUI"
 
 set ^%W(17.6001,"B","GET","api/filedownload","DOWNLOAD^UPRNUI",124)=""
 set ^%W(17.6001,124,0)="GET"
 set ^%W(17.6001,124,1)="api/filedownload"
 set ^%W(17.6001,124,2)="DOWNLOAD^UPRNUI"
 quit
 
DOWNLOAD(result,arguments) 
 K ^TMP($J)
 ;S ^TMP($J,1)="TEST DATA"
 set file=$get(arguments("filename"))
 S ^FRED=file
 ;s file="/opt/files/50000.txt"
 S file="/opt/files/"_file
 S l="",c=1
 F  S l=$order(^FILE(file,l)) q:l=""  s ^TMP($J,c)=^(l),c=c+1
 S result("mime")="text/plain, */*"
 S result=$NA(^TMP($J))
 QUIT
 
LOGIN(result,arguments) ;
 kill ^TMP($J)
 d H("<html>")
 d H("<form action=""https://apiuprn.discoverydataservice.net:8443/check/login"" method=""post"">")
 ;http://10.0.101.22:9080
 ;d H("<form action=""http://10.0.101.22:9080/check/login"" method=""post"">")
 d H("<table border=1>")
 d H("<td>UserName:</td><td><input type=""text"" name=""username"" /></td><tr>")
 d H("<td>Password:</td><td><input type=""password"" name=""pwd"" /></td><tr>")
 d H("<td><input type=""submit""></td><td></tr><tr>")
 d H("</table>")
 d H("</form>")
 d H("</html>")
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
GETFILENAM(disposition) 
 ;
 quit
 
RETFILE(result,arguments) 
 K ^TMP($J)
 ;k ^PS25
 S ^PS23="IN RETFILE"
 set file=$get(arguments("filename"))
 s file="/opt/files/"_file
 S ^PS24=file
 ;m ^TMP($J)=^FILE(file)
 S c="",line=1
 f  s c=$o(^FILE(file,c)) q:c=""  D
 .s ^TMP($J,line)=^(c)_$c(13,10)
 .;S ^PS25($J,line)=^(c)_$c(13,10)
 .s line=line+1
 .QUIT
 set result("mime")="text/plain, */*"
 set result=$na(^TMP($J))
 QUIT
 
UPLOAD(arguments,body,result) 
 new file,line
 K ^TMP($J)
 M ^FILES=body
 set result("mime")="text/html"
 ;
 ;set ^FILES=$I(^FILES)
 ;set file="file"_^FILES_".csv"
 ;
 set file=$piece(body(1),$c(10),2)
 set file=$piece(file,"""",4)
 do 6^ZOS("/opt/files")
 set file="/opt/files/"_file
 ;
 if $data(body(1)) set body(1)=$p(body(1),$c(10),5,9999999999)
 ;
 ;open file:(writeonly)
 ;
 set line=$order(body(""),-1)
 if line'="" set body(line)=$piece(body(line),"------WebKitFormBoundary",1)
 ;
 open file:newversion
 set line=""
 for  set line=$order(body(line)) q:line=""  do
 .use file write body(line)
 .quit
 close file
 ;
 s ^TMP($J,1)="{""upload"": { ""status"": ""OK""}}"
 set result=$na(^TMP($J))
 Job PROCESS(file)
 quit 1
 
PROCESS(file) ;
 K ^FILE(file)
 close file
 o file:(readonly):0
 S cnt=1
 f  u file r str q:$zeof  do
 .s adrec=$p(str,",",2,99)
 .D GETUPRN^UPRNMGR(adrec)
 .s json=^temp($j,1)
 .K B,C
 .D DECODE^VPRJSON($name(json),$name(B),$name(C))
 .S UPRN=$GET(B("UPRN"))
 .S ADDFORMAT=$GET(B("Address_format"))
 .S ALG=$GET(B("Algorithm"))
 .S CLASS=$GET(B("Classification"))
 .S MATCHB=$GET(B("Match_pattern","Building"))
 .S MATCHF=$GET(B("Match_pattern","Flat"))
 .S MATCHN=$GET(B("Match_pattern","Number"))
 .S MATCHP=$GET(B("Match_pattern","Postcode"))
 .S MATCHS=$GET(B("Match_pattern","Street"))
 .S ABPN=$GET(B("ABPAddress","Number"))
 .S ABPP=$GET(B("ABPAddress","Postcode"))
 .S ABPS=$GET(B("ABPAddress","Street"))
 .S ABPT=$GET(B("ABPAddress","Town"))
 .S QUAL=$GET(B("Qualifier"))
 .S ^FILE(file,cnt)=UPRN_","_ADDFORMAT_","_ALG_","_CLASS_","_MATCHB_","_MATCHF_","_MATCHN_","_MATCHP_","_MATCHS_","_QUAL_","_ABPN_","_ABPP_","_ABPS_","_ABPT_","_adrec
 .s cnt=cnt+1
 .quit
 close file
 QUIT
 
CALC(arguments,body,result) ;
 new data,a
 K ^TMP($J),^BODY
 M ^BODY=body
 
 S data=""
 f i=1:1:$o(body(""),-1) set ^TMP($J,i)=body(i)_"<br>",data=data_body(i)
 s i=i+1
 ;s ^TMP($J,i)="<b>ZWR ^BODY</b>"
 
 K ^TMP($J)
 ;S ^TMP($J,1)=$$REL(data)
 
 set cnt=1,data=$$REL(data)
 F i=1:1:$L(data,$c(13)) set:$p(data,$c(13),i)'=$C(10) a(cnt)=$p(data,$c(13,10),i),cnt=cnt+1
 
 s zi=""
 f  s zi=$o(a(zi)) q:zi=""  do
 .s adrec=a(zi)
 .D GETUPRN^UPRNMGR(adrec)
 .s json=^temp($j,1)
 .K B,C
 .D DECODE^VPRJSON($name(json),$name(B),$name(C))
 .set UPRN=$GET(B("UPRN"))
 .S ^TMP($J,cnt)=adrec_" = "_UPRN_"<BR>"
 .S cnt=cnt+1
 .quit
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 Q 1
 
CHECK(arguments,body,result) ;
 k ^TMP($J)
 M ^BODY=body
 f i=1:1:$o(body(""),-1) set ^TMP($J,i)=body(i)_"<br>"
 s i=i+1
 s ^TMP($J,i)="<b>end</b>"
 
 ;set result("mime")="text/html"
 ;set result=$na(^TMP($J))
 ;m ^A=^TMP($J)
 ; check the username/password
 
 kill ^TMP($J)
 
 d H("<html>")
 d H("<form action=""https://apiuprn.discoverydataservice.net:8443/ui/calculate"" method=""post"">")
 d H("<textarea rows=""4"" cols=""50"" name=""addrlines"">")
 d H("Yvonne carter Building,58 turner street,london,E1 2AB"_$C(10))
 d H("top flat,133 shepherdess walk,,london,,n17qa"_$C(10))
 d H("5 uferstrasse,,,stuebach,Germany,g1 4sg"_$C(10))
 d H("Crystal Palace football club,  SE25 6PU"_$C(10))
 d H("10 Downing St,Westminster,London,SW1A2AA"_$C(10)) 
 d H("</textarea>")
 
 d H("<input type=""submit"">")
 d H("</form>")
 d H("</html>")
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit 1
 
H(H) ;
 n c
 s c=$order(^TMP($J,""),-1)+1
 s ^TMP($J,c)=H_$c(13)_$c(10)
 quit
 
TR(ZX,ZY,ZZ) ;Extrinsix function to translate a string [ 01/19/92  5:03 PM ]
         ;ZX is the variable
         ;ZY is the string to translate
         ;ZZis the string to tranlsate to
         N ZW
         S ZW=0
         FOR  S ZW=$F(ZX,ZY,ZW) Q:ZW=0  S ZW=ZW-$L(ZY)-1 S ZX=$E(ZX,0,ZW)_ZZ_$E(ZX,ZW+$L(ZY)+1,99999),ZW=ZW+$L(ZZ)+1
         Q ZX
 
REL(data) 
         S data=$$TR(data,"+"," ")
         D HEX
         S A=""
         F  S A=$O(^TOPT($J_"HEX",A)) Q:A=""  D
         .S HEX=$P(A,"%",2)
  .;W $$FUNC^%HD("2C")
         .S data=$$TR(data,A,$C($$FUNC^%HD(HEX)))
         .Q
         Q data
 
HEX      K ^TOPT($J_"HEX")
  ; %0D%0A%0D%0A
  S ^TOPT($J_"HEX","%0D")="",^TOPT($J_"HEX","%0A")=""
         S ^TOPT($J_"HEX","%20")="",^TOPT($J_"HEX","%C2")=""
         S ^TOPT($J_"HEX","%22")="",^TOPT($J_"HEX","%A3")=""
         S ^TOPT($J_"HEX","%3D")="",^TOPT($J_"HEX","%2B")=""
         S ^TOPT($J_"HEX","%5E")="",^TOPT($J_"HEX","%7E")=""
         S ^TOPT($J_"HEX","%2F")="",^TOPT($J_"HEX","%28")=""
         S ^TOPT($J_"HEX","%29")="",^TOPT($J_"HEX","%2C")=""
         S ^TOPT($J_"HEX","%26")="",^TOPT($J_"HEX","%21")=""
         S ^TOPT($J_"HEX","%5B")="",^TOPT($J_"HEX","%5D")=""
         S ^TOPT($J_"HEX","%3F")="",^TOPT($J_"HEX","%24")=""
         S ^TOPT($J_"HEX","%25")="",^TOPT($J_"HEX","%7B")=""
         S ^TOPT($J_"HEX","%7D")="",^TOPT($J_"HEX","%5C")=""
         S ^TOPT($J_"HEX","%23")="",^TOPT($J_"HEX","%3A")=""
         S ^TOPT($J_"HEX","%3B")="",^TOPT($J_"HEX","%27")=""
         S ^TOPT($J_"HEX","%3C")="",^TOPT($J_"HEX","%3E")=""
         Q
