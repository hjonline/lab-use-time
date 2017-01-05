use Date::Manip;

$year = "2016";
$month = "09";
$day = "01";
$first = "1";

$wkno=&Date_WeekOfYear($month, $day, $year, $first);
print $wkno . "\n";
$wkno=&Date_DayOfWeek($month, $day, $year, $first);
print $wkno . "\n";
