<?php
//echo "DATA: ".date('H:i:s')."<br />";
/*pagina indirizzata dal sw java per inviare i campioni ricevuti dal sensore al server e inserirli così nel db*/

echo "PARAMETRO: ".$_GET['v']."<br />";

//echo "hello";

include './functions.php';
include './conversion.php';

$conn=db_connect();

$values=$_GET['v'];

$sample=explode("|", $values);

//$num_values = sizeof($array_values);

/*
0 - ID
1 - Battery level
2 - Temp_value
3 - CO_value
4 - CO2_value
5 - NO2_value
6 - O3_value
7 - VOC_value
8 - PREX_value
9 - date
10 - time 
*/
//$sample[3]=conversion('CO',$sample[3]);
//$sample[4]=conversion('CO2',$sample[4]);
//$sample[5]=conversion('NO2',$sample[5]);
//$sample[6]=conversion('O3',$sample[6]);
//$sample[7]=conversion('VOC',$sample[7]);

//echo $sample[1] . " " . $sample[2] . " " . $sample[3] . " " . $sample[4] . " " . $sample[5] . " " . $sample[6] . " " . $sample[7] . " "
//. $sample[8] . " " . $sample[9] . " " . $sample[10] . " " . $sample[11] . " " . $sample[12] . " " . $sample[13] . " " . $sample[14] . "<br />";

$dates=$sample[9] . "-" . $sample[10] . "-" . $sample[11];
echo $dates . "<br />";

$hour=$sample[12] . ":" . $sample[13] . ":" . $sample[14];
echo $hour . "<br />";

$timestamp=mktime($sample[12],$sample[13],$sample[14],$sample[11],$sample[10],$sample[9]);
echo $timestamp . "<br />";


//$query="INSERT INTO samples_table(sensor_id,battery_level,temp_value,CO_value,CO2_value,NO2_value,O3_value,VOC_value,PREX_value,date,time) VALUES('".$sample[0]."','".$sample[1]."','".$sample[2]."','".$sample[3]."','".$sample[4]."','".$sample[5]."','".$sample[6]."','".$sample[7]."','".$sample[8]."','".date('Y-m-d')."','".date('H:i:s')."')";
$query="INSERT INTO nesproject(\"sensor_id\",\"battery_level\",\"TEMP_value\",\"CO_value\",\"CO2_value\",\"NO2_value\",\"O3_value\",\"VOC_value\",\"HUM_value\",\"date\",\"time\",\"timestamp\") VALUES('".$sample[0]."','".$sample[1]."','".$sample[2]."','".$sample[3]."','".$sample[4]."','".$sample[5]."','".$sample[6]."','".$sample[7]."','".$sample[8]."','".$dates."','".$hour."','".$timestamp."')";
//echo $query;
$q=pg_query($conn,$query);  
//$q=mysql_query("INSERT INTO samples_table(sensor_id,prova) VALUES('1','".$values."')") or die(mysql_error());  	
	if($q)
	echo "QUERY: ".$query."<br />";
	else echo "not inserted <br />";
	
echo pg_last_error() . "<br />";


pg_close($conn);

?> 
