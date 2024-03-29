(* ::Package:: *)

(* ::Input:: *)
(*(*small values*)*)
(*(*p=11;*)
(*a=1;*)
(*b=6;*)
(*pts=13;*)
(*alpha = {2,7};*)*)
(*p=115792089237316195423570985008687907853269984665640564039457584007908834671663;*)
(*a=0;*)
(*b=7;*)
(*pts=115792089237316195423570985008687907852837564279074904382605163141518161494337;*)
(*alpha = {55066263022277343669578718895168534326250603453777594175500187360389116729240,32670510020758816978083085130507043184471273380659243275938904335757337482424};*)
(**)
(**)
(*n=pts;*)
(**)
(*privKey1 =7;*)
(*privKey2=5;*)
(*privKey = privKey1+privKey2;*)
(**)
(*beta1 =Multiply[privKey1,alpha];*)
(*beta2=Multiply[privKey2,alpha];*)
(*beta=Add[beta1,beta2];*)
(**)
(*Add[P_,Q_]:= Module[{xp,yp,xq,yq,xr,yr,\[Lambda],done},*)
(*{xp,yp} = P;*)
(*{xq,yq} = Q;*)
(*done=0;*)
(**)
(*If[P=={0,0}, {xr,yr}={xq,yq};done=1];*)
(*If[Q=={0,0}, {xr,yr}={xp,yp};done=1];*)
(**)
(*If[P==Q&&done==0,*)
(*\[Lambda]=(3*(xp^2)+a)*PowerMod[(2*yp),-1,p];*)
(*xr=(\[Lambda]^2-xp-xq);*)
(*yr=(\[Lambda]*(xp-xr)-yp);*)
(*done=1];*)
(**)
(*If[xq-xp==0&&done==0,*)
(*{xr,yr}={0,0};*)
(*done=1];*)
(**)
(*If[P!=Q&&done==0,*)
(*\[Lambda]=(yq-yp)*PowerMod[(xq-xp),-1,p];*)
(*xr=(\[Lambda]^2-xp-xq);*)
(*yr=(\[Lambda]*(xp-xr)-yp)];*)
(**)
(*{Mod[xr,p],Mod[yr,p]}*)
(**)
(*]*)
(**)
(*Multiply[n_,P_]:= Module[{M},*)
(*M={0,0};*)
(*If[Mod[n,pts]>0,Do[M=Add[P,M],n]];*)
(*M*)
(*]*)
(**)
(*Double[P_] := Module[{xp,yp,xr,yr,\[Lambda]},*)
(*{xp,yp} = P;*)
(**)
(*If[P=={0,0}, {xr,yr}={xp,yp};];*)
(*If[P!= {0,0}, *)
(*\[Lambda]=(3*(xp^2)+a)*PowerMod[(2*yp),-1,p];*)
(*xr=(\[Lambda]^2-xp-xp);*)
(*yr=(\[Lambda]*(xp-xr)-yp);*)
(*];*)
(*{Mod[xr,p],Mod[yr,p]}*)
(*]*)
(**)
(*DoubleAndAdd[k_,P_] := Module[{N,Q,i,binary},*)
(*N=P;*)
(*Q={0,0};*)
(*binary=IntegerString[k,2];*)
(*For[i=1,i<StringLength[binary]+1,i++,*)
(*If[StringTake[binary,{StringLength[binary]+1-i}]=="1",Q=Add[Q,N]];*)
(*N=Double[N];*)
(*];*)
(*Q*)
(*]*)
(*EncElgamal[x_] := Module[{k,kAlpha, kBeta,xkBeta, encVal},*)
(*k =RandomInteger[{1,pts}];*)
(*kAlpha= DoubleAndAdd[k,alpha];*)
(*kBeta= DoubleAndAdd[k,beta];*)
(*xkBeta =Add[x,kBeta];*)
(*encVal ={kAlpha, xkBeta};*)
(*encVal*)
(*]*)
(**)
(*DecElgamal[y_] := Module[{pair1,pair2,privkeyPair1,negVal,dec},*)
(*pair1=y[[1]];*)
(*pair2=y[[2]];*)
(*negVal= DoubleAndAdd[pts-privKey,pair1];*)
(*dec=Add[pair2,negVal];*)
(*dec*)
(*]*)
(**)
(*EncExpElgamal[x_] :=Module[{},*)
(*EncElgamal[DoubleAndAdd[x,alpha]]*)
(*]*)
(**)
(*DecExpElgamal[y_]:=Module[{gm},*)
(*gm=DecElgamal[y];*)
(*gm*)
(*]*)
(**)
(*DecPartialExpElgamal[y_,privk_] := Module[{privkeyPair1},*)
(*privkeyPair1= DoubleAndAdd[privk,y[[1]]];*)
(*privkeyPair1*)
(*]*)
(**)
(*DecFullExpElgamal[y_,b_] := Module[{negVal,dec},*)
(*negVal=  DoubleAndAdd[pts-1,b];*)
(*dec=Add[y[[2]],negVal];*)
(*dec*)
(*]*)
(**)
(*AddElgamal[x1_,x2_]:=Module[{new},*)
(*new = {Add[x1[[1]],x2[[1]]],Add[x1[[2]],x2[[2]]]};*)
(*new*)
(*]*)
(**)
(*SubElgamal[x1_,x2_]:=Module[{new,val1,val2},*)
(*val1=  DoubleAndAdd[pts-1,x2[[1]]];*)
(*val2=  DoubleAndAdd[pts-1,x2[[2]]];*)
(*Print["c1[0] = ",val1[[1]],";"];*)
(*Print["c1[1] = ",val1[[2]],";"];*)
(*Print["c2[0] = ",val2[[1]],";"];*)
(*Print["c2[1] = ",val2[[2]],";"];*)
(*new = {Add[x1[[1]],val1],Add[x1[[2]],val2]};*)
(*new*)
(*]*)
(**)
(*MultiplyElgamal[k_, x_] :=Module[{res1,res2},*)
(*res1= DoubleAndAdd[k,x[[1]]];*)
(*res2= DoubleAndAdd[k,x[[2]]];*)
(*{res1,res2}*)
(*]*)
(*(*A=aG*)*)
(*SchnorrGenPf[A_,a_, G_] := Module[{v,r,c,val2},*)
(*v= RandomInteger[{1, n-1}];*)
(*val2 =DoubleAndAdd[v,G];*)
(*c=Hash[IntegerString[G[[1]]]<>IntegerString[G[[2]]]<>IntegerString[val2]<>IntegerString[A[[1]]]<>IntegerString[A[[2]]], "SHA256"];*)
(*r=Mod[v-a*c,n];*)
(*{val2,r,c}*)
(*]*)
(**)
(*SchnorrVerifyPf[ val2_,r_,c_,A_, G_] :=Module[{z1,z2,res,res1, res2, res3, val1},*)
(*z1=DoubleAndAdd[r,G];*)
(*z2=DoubleAndAdd[c,A];*)
(*val1=Add[z1,z2];*)
(*(*res1=(Mod[A[[2]]^2,p])\[Equal](Mod[A[[1]]^3+7,p]); *)(*Check if A is on the curve*)*)
(*res2=c==(Hash[IntegerString[G[[1]]]<>IntegerString[G[[2]]]<>IntegerString[val2]<>IntegerString[A[[1]]]<>IntegerString[A[[2]]], "SHA256"]); (*check hashes match*)*)
(*res3=(val1==val2);*)
(*res=  res2  && res3;*)
(*(*Print["A[0] = ", A[[1]],";"];*)
(*Print["A[1] = ", A[[2]],";"];*)
(*Print["G[0] = ", G[[1]],";"];*)
(*Print["G[1] = ", G[[2]],";"];*)
(*Print["v = ", v,";"];*)
(*Print["r = ", r,";"];*)
(*Print["c = ", c,";"];*)
(*Print["z1[0] = ", z1[[1]],";"];*)
(*Print["z1[1] = ", z1[[2]],";"];*)
(*Print["z2[0] = ", z2[[1]],";"];*)
(*Print["z2[1] = ", z2[[2]],";"];*)
(*Print["val2[0] = ", val2[[1]],";"];*)
(*Print["val2[1] = ", val2[[2]],";"];*)*)
(*res*)
(*]*)
(**)
(*DHTupleGenPf[c1_, c2_,c1k_, c2k_ , k_] := Module[{t, T1, T2, c,s},*)
(*t = RandomInteger[{1, n-1}];*)
(*T1 =DoubleAndAdd[t,c1];*)
(*T2 =DoubleAndAdd[t,c2];*)
(*c =Hash[ IntegerString[T1[[1]]] <>IntegerString[T1[[2]]] <> IntegerString[T2[[1]]] <>IntegerString[T2[[2]]],"SHA256"];*)
(*s= Mod[k*c+t,n];*)
(*{T1,T2, c,s}*)
(*]*)
(**)
(*(*DHTupleVerifyPf[c1_,c2_, c1k_, c2k_, pf_] := Module[{res1, res2, res3,res},*)
(*res1 = (DoubleAndAdd[pf[[4]],c1]==Add[ DoubleAndAdd[pf[[3]],c1k],pf[[1]]]);*)
(*res2 =(DoubleAndAdd[pf[[4]],c2]==Add[ DoubleAndAdd[pf[[3]],c2k],pf[[2]]]);*)
(*res3= (pf[[3]]==Hash[ IntegerString[pf[[1]]] <> IntegerString[pf[[2]]],"SHA256"]);*)
(*res=res1 && res2 && res3 ;*)
(*res*)
(*]*)*)
(**)
(*DHTupleVerifyPf[c1_,c2_, c1k_, c2k_, pf1_, pf2_, pf3_, pf4_] := Module[{res1, res2, res3,res,res11, res12,res21,res22},*)
(*res11=DoubleAndAdd[pf4,c1];*)
(*res12=DoubleAndAdd[pf3,c1k];*)
(*res21=DoubleAndAdd[pf4,c2];*)
(*res22=DoubleAndAdd[pf3,c2k];*)
(*res1 = (DoubleAndAdd[pf4,c1]==Add[ DoubleAndAdd[pf3,c1k],pf1]);*)
(*res2 =(DoubleAndAdd[pf4,c2]==Add[ DoubleAndAdd[pf3,c2k],pf2]);*)
(*res3= (pf3==Hash[ IntegerString[pf1[[1]]] <>IntegerString[pf1[[2]]] <> IntegerString[pf2[[1]]] <>IntegerString[pf2[[2]]],"SHA256"]);*)
(*res=res1 &&res2&& res3 ;*)
(*Print["\"", c1k[[1]],"\","];*)
(*Print["\"", c1k[[2]],"\","];*)
(*Print["\"", c2k[[1]],"\","];*)
(*Print["\"", c2k[[2]],"\","];*)
(*Print["\"", pf1[[1]],"\","];*)
(*Print["\"", pf1[[2]],"\","];*)
(*Print["\"", pf2[[1]],"\","];*)
(*Print["\"", pf2[[2]],"\","];*)
(*Print["\"", pf3,"\","];*)
(*Print["\"", pf4,"\","];*)
(**)
(*(*Print["dh.c1[0] = ", c1[[1]],";"];*)
(*Print["dh.c1[1] = ", c1[[2]],";"];*)
(*Print["dh.c2[0] = ", c2[[1]],";"];*)
(*Print["dh.c2[1] = ", c2[[2]],";"];*)*)
(**)
(*Print["\" ", res11[[1]],"\","];*)
(*Print["\"", res11[[2]],"\","];*)
(**)
(*Print["\" ", res12[[1]],"\","];*)
(*Print["\" ", res12[[2]],"\","];*)
(**)
(*Print["\" ", res21[[1]],"\","];*)
(*Print["\"", res21[[2]],"\","];*)
(**)
(*Print["\"", res22[[1]],"\","];*)
(*Print["\"", res22[[2]],"\","];*)
(*res*)
(*]*)
(**)
(*RandomizeAndReturn[c_] := Module[{res,res1,res2,a},*)
(*a=RandomInteger[{2,n-1}];*)
(*res1=DoubleAndAdd[a,c[[1]]];*)
(*res2=DoubleAndAdd[a,c[[2]]];*)
(*res={res1,res2};*)
(*{res,a}*)
(*]*)
(*(*Print["dh.c1k[0] = ", c1k[[1]],";"];*)
(*Print["dh.c1k[1] = ", c1k[[2]],";"];*)
(*Print["dh.c2k[0] = ", c2k[[1]],";"];*)
(*Print["dh.c2k[1] = ", c2k[[2]],";"];*)
(*Print["dh.pf1[0] = ", pf1[[1]],";"];*)
(*Print["dh.pf1[1] = ", pf1[[2]],";"];*)
(*Print["dh.pf2[0] = ", pf2[[1]],";"];*)
(*Print["dh.pf2[1] = ", pf2[[2]],";"];*)
(*Print["dh.pf3 = ", pf3,";"];*)
(*Print["dh.pf4 = ", pf4,";"];*)
(**)
(*Print["dh.c1[0] = ", c1[[1]],";"];*)
(*Print["dh.c1[1] = ", c1[[2]],";"];*)
(*Print["dh.c2[0] = ", c2[[1]],";"];*)
(*Print["dh.c2[1] = ", c2[[2]],";"];*)
(**)
(*Print["dh.res11[0] = ", res11[[1]],";"];*)
(*Print["dh.res11[1] = ", res11[[2]],";"];*)
(**)
(*Print["dh.res12[0] = ", res12[[1]],";"];*)
(*Print["dh.res12[1] = ", res12[[2]],";"];*)
(**)
(*Print["dh.res21[0] = ", res21[[1]],";"];*)
(*Print["dh.res21[1] = ", res21[[2]],";"];*)
(**)
(*Print["dh.res22[0] = ", res22[[1]],";"];*)
(*Print["dh.res22[1] = ", res22[[2]],";"];*)*)
(**)
