use Date::Manip;

$year = 2016;
$month = 9;
$day = 1;
$first = 1;

$wkno=&Date_WeekOfYear($month, $day, $year, $first);
print $wkno . "\n";
