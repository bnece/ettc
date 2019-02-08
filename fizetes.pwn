
public fizetes()
{	
	new rows;
	new Cache:mentett = cache_save();
	cache_get_row_count(rows);
	for(new i=0;i<rows;i++)
	{
		
		new dbi,fiz,fizt,felf,fizsz,fizrang,fizfrak,mao,tmp_fiz,tmp_frakciopenz,tmp_fizado,tmp_hazado,tmp_rezsi,tmp_jarmuado,tmp_iparado,tmp_fizetes;
		
		cache_set_active(mentett);
		cache_get_value_name_int(i,"Id",dbi);
		cache_get_value_name_int(i,"frakcio",fizfrak);
		cache_get_value_name_int(i,"frang",fizrang);
		cache_get_value_name_int(i,"fizetes",fiz);
		cache_get_value_name_int(i,"fiztipus",fizt);
		cache_get_value_name_int(i,"felfiz",felf);
		cache_get_value_name_int(i,"fizszam",fizsz);
		cache_get_value_name_int(i,"maonline",mao);
		
		// online ellenőrzés
		new k = 0;
		new bool:online = false;
		while(k < MAX_PLAYERS && online == false)
		{
			if(PlayerInfo[k][dbid] == dbi)
			{
				online = true;
			}
			else
			{
				k++;
			}
		}
		
		if(mao > 3600)
		{
			new query[256];
			new Cache:res;
			new Cache:tmp_res;
			new rowe;
			if(fizfrak != 0)
			{
				//frakciós fizetés 
				mysql_format(mysql,query,sizeof(query),"SELECT `%df` FROM `frakcio` WHERE `Id` = '%d'",fizrang,fizfrak);
				mysql_query(mysql,query);
				cache_get_value_index_int(0,0,tmp_fiz);
				//cache_delete(res);
				
				//frakciós bankszámla
				mysql_format(mysql,query,sizeof(query),"SELECT `penz` FROM `bank` WHERE `frakcio` = '%d'",fizfrak);
				res = mysql_query(mysql,query);
				cache_get_value_name_int(0,"penz",tmp_frakciopenz);
				//cache_delete(res);
				if(tmp_frakciopenz - tmp_fiz >= 0)
				{
					mysql_format(mysql,query,sizeof(query),"UPDATE `bank` SET `penz`=`penz`-'%d' WHERE `frakcio` = '%d'",tmp_fiz,fizfrak);
					mysql_tquery(mysql,query);
					fiz += tmp_fiz;
				}
			}
			//fizetés adózása
			tmp_fizetes = fiz;
			tmp_fizado = floatround((fiz * SZJA) / 100);
			fiz -= tmp_fizado;
			allamibevetel(tmp_fizado);
			
			//házak
			new aquery[256];
			new tmp_hazertek;
			mysql_format(mysql,query,sizeof(query),"SELECT `Cost` FROM `house` WHERE `Owner` = '%d'",dbi);
			res = mysql_query(mysql,query);
			cache_get_row_count(rowe);
			for(new j=0;j < rowe;j++)
			{
				new Float:adokulcs;
				cache_get_value_name_int(j,"Cost",tmp_hazertek);
				mysql_format(mysql,aquery,sizeof(aquery),"SELECT `ado` FROM `ado` WHERE  '%d' > `mettol` AND `meddig` >= '%d' AND `fajta` = '0'",tmp_hazertek,tmp_hazertek);
				tmp_res = mysql_query(mysql,aquery);
				cache_get_value_name_float(0,"ado",adokulcs);
				//cache_delete(tmp_res);
				tmp_hazado += floatround((tmp_hazertek * adokulcs) / 100);
				tmp_rezsi += (tmp_hazertek * 2) / 100;
			}
			//cache_delete(res);
			//ház adózása
			if(fiz - tmp_hazado >= 0)
			{
				fiz -= tmp_hazado;
				allamibevetel(tmp_hazado);
			}
			else
			{
				if(online == true)
				{
					PlayerInfo[k][ado] += tmp_hazado;
				}
				else
				{
					mysql_format(mysql,query,sizeof(query),"UPDATE `user` SET `ado`= `ado` + %d WHERE `Id` = '%d'",tmp_hazado,dbi);
					mysql_tquery(mysql,query);
				}
			}
			//ház rezsi
			if(fiz - tmp_rezsi >= 0)
			{
				fiz -= tmp_rezsi;
			}
			else
			{
				if(online == true)
				{
					PlayerInfo[k][ado] += tmp_rezsi;
				}
				else
				{
					mysql_format(mysql,query,sizeof(query),"UPDATE `user` SET `ado`= `ado` + %d WHERE `Id` = '%d'",tmp_rezsi,dbi);
					mysql_tquery(mysql,query);
				}
			}
			//járművek
			new tmp_modelid;
			mysql_format(mysql,query,sizeof(query),"SELECT `Model` FROM `vehicle` WHERE `Owner` = '%d'",dbi);
			res = mysql_query(mysql,query);
			cache_get_row_count(rowe);
			for(new j=0;j<rowe;j++)
			{
				new Float:adokulcs;
				cache_get_value_name_int(j,"Model",tmp_modelid);
				mysql_format(mysql,aquery,sizeof(aquery),"SELECT `ado` FROM `ado` WHERE  '%d' > `mettol` AND `meddig` >= '%d' AND `fajta` = '1'",vehdata[tmp_modelid-400][2],vehdata[tmp_modelid-400][2]);
				tmp_res = mysql_query(mysql,aquery);
				cache_get_value_name_float(0,"ado",adokulcs);
				//cache_delete(tmp_res);
				tmp_jarmuado += floatround((vehdata[tmp_modelid-400][2] * adokulcs) / 100);
			}
			//cache_delete(res);
			
			//jármű adózása
			if(fiz - tmp_jarmuado >= 0)
			{
				fiz -= tmp_jarmuado;
				allamibevetel(tmp_jarmuado);
			}
			else
			{
				if(online == true)
				{
					PlayerInfo[k][ado] += tmp_jarmuado;
				}
				else
				{
					mysql_format(mysql,query,sizeof(query),"UPDATE `user` SET `ado`= `ado` + %d WHERE `Id` = '%d'",tmp_jarmuado,dbi);
					mysql_tquery(mysql,query);
				}
			}
			
			//bizniszek
			new tmp_bizertek;
			mysql_format(mysql,query,sizeof(query),"SELECT `cost` FROM `biznisz` WHERE `owner` = '%d'",dbi);
			res = mysql_query(mysql,query);
			cache_get_row_count(rowe);
			for(new j=0;j<rowe;j++)
			{
				new Float:adokulcs;
				cache_get_value_name_int(j,"cost",tmp_bizertek);
				mysql_format(mysql,aquery,sizeof(aquery),"SELECT `ado` FROM `ado` WHERE  '%d' > `mettol` AND `meddig` >= '%d' AND `fajta` = '2'",tmp_bizertek,tmp_bizertek);
				tmp_res = mysql_query(mysql,aquery);
				cache_get_value_name_float(0,"ado",adokulcs);
				tmp_iparado += floatround((tmp_bizertek * adokulcs) / 100);
				//cache_delete(tmp_res);
			}
			//cache_delete(res);
			//biz adozas
			if(online == true)
			{
				PlayerInfo[k][ado] += tmp_iparado;
			}
			else
			{
				mysql_format(mysql,query,sizeof(query),"UPDATE `user` SET `ado`= `ado` + %d WHERE `Id` = '%d'",tmp_iparado,dbi);
				mysql_tquery(mysql,query);
			}
			
			//fizetés utalás
			if(fizt == 0)
			{
				mysql_format(mysql,query,sizeof(query),"UPDATE `user` SET `fizetes` = '0', `felfiz` = `felfiz` + '%d' WHERE `Id`='%d'",fiz,dbi);
				mysql_tquery(mysql,query);
			}
			else
			{
				mysql_format(mysql,query,sizeof(query),"UPDATE `bank` SET `penz`='%d' + `penz` WHERE `azonosito` = '%d'",fiz,fizsz);
				mysql_tquery(mysql,query);
				mysql_format(mysql,query,sizeof(query),"UPDATE `user` SET `fizetes` = '0' WHERE `Id`='%d'",dbi);
				mysql_tquery(mysql,query);
			}
			//online gondok
			if(online == true)
			{
				new string[128];
				format(string,sizeof(string),"((Fizetés folyamatban!))");
				SendClientMessage(k,-1,string);
				format(string,sizeof(string),"((Bruttó Fizetésed:%s SZJA:%s))",cformat(tmp_fizetes),cformat(tmp_fizado));
				SendClientMessage(k,-1,string);
				format(string,sizeof(string),"((Ingatlan adó:%s Rezsi:%s))",cformat(tmp_hazado),cformat(tmp_rezsi));
				SendClientMessage(k,-1,string);
				format(string,sizeof(string),"((Jármű adó:%s))",cformat(tmp_jarmuado));
				SendClientMessage(k,-1,string);
				format(string,sizeof(string),"((Iparűzési adó:%s))",cformat(tmp_iparado));
				SendClientMessage(k,-1,string);
				format(string,sizeof(string),"((Nettó fizetésed:%s ))",cformat(fiz));
				SendClientMessage(k,-1,string);
				PlayerInfo[k][pfizetes] = 0;
			}
			cache_delete(res);
			cache_delete(tmp_res);
		}
		else
		{
			if(online == true)
			{
				SendClientMessage(k,-1,"(( Nem dolgoztál eleget! ))");
			}
		}
		
		//biznisz fizetés
		for(new j;j<MAX_BIZZ;j++)
		{
			BizzInfo[j][kassza] += floatround((BizzInfo[j][Cost] * 0.8) / 100);
		}
	}
}
