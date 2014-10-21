#{{{
# 要引入的包
#{{{
use DateTime;
use Encode;
#}}}
# 定义日期 
#{{{
my $base_year = "2014";
my $term_start_month = "9";
my $term_start_day = "1";
my $base_workweek;

my $workweek =  DateTime->new( year => $base_year, month => $term_start_month, day => $term_start_day );
my $base_workweek = $workweek->week;

my $base_workyear=$base_year . "W";
my @short_holidays = qw (0101 0405 0406 0407 0501 0502 0503 0602 0908 1001 1002 1003 1004 1005 1006 1007 );
#}}}
my @classes_teachers;
#{{{
@classes_teachers = (
		     {
		      "一（5）" => "谢芳",
		      "一（6）" => "洪钧",
		      "一（7）" => "谢芳",
		      "一（8）" => "谢芳",
		      "一（9）" => "洪钧",
		     },
		     {
		      "二（5）" => "辛韶琴",
		      "二（6）" => "辛韶琴",
		      "二（7）" => "辛韶琴",
		      "二（8）" => "辛韶琴",
		      "二（9）" => "辛韶琴",
		     },
		     {
		      "三（5）" => "谢芳",
		      "三（6）" => "谢芳",
		      "三（7）" => "谢芳",
		      "三（8）" => "谢芳",
		     },
		     {
		      "四（5）" => "辛韶琴",
		      "四（6）" => "辛韶琴",
		      "四（7）" => "辛韶琴",
		      "四（8）" => "辛韶琴",
		     },
		     {
		      "五（5）" => "洪钧",
		      "五（6）" => "洪钧",
		      "五（7）" => "洪钧",
		      "五（8）" => "洪钧",
		     },
		    );
#}}}

my @classes_lessons;
#{{{
@classes_lessons = (
		    [
		     {
		      "一（5）" => 3,
		      "一（6）" => 2,
		      "一（7）" => 1,
		      "一（8）" => 1,
		      "一（9）" => 4,
		     },
		     {
		      "二（5）" => 4,
		      "二（6）" => 1,
		      "二（7）" => 1,
		      "二（8）" => 1,
		      "二（9）" => 4,
		     },
		     {
		      "三（5）" => 2,
		      "三（6）" => 1,
		      "三（7）" => 2,
		      "三（8）" => 3,
		     },
		     {
		      "四（5）" => 2,
		      "四（6）" => 1,
		      "四（7）" => 2,
		      "四（8）" => 3,
		     },
		     {
		      "五（5）" => 3,
		      "五（6）" => 1,
		      "五（7）" => 1,
		      "五（8）" => 2,
		     },
		    ],
		    [
		     {
		      "一（5）" => 5,
		      "一（6）" => 2,
		      "一（7）" => 5,
		      "一（8）" => 3,
		      "一（9）" => 5,
		     },
		     {
		      "二（5）" => 5,
		      "二（6）" => 5,
		      "二（7）" => 3,
		      "二（8）" => 2,
		      "二（9）" => 5,
		     },
		     {
		      "三（5）" => 4,
		      "三（6）" => 3,
		      "三（7）" => 5,
		      "三（8）" => 4,
		     },
		     {
		      "四（5）" => 4,
		      "四（6）" => 3,
		      "四（7）" => 4,
		      "四（8）" => 4,
		     },
		     {
		      "五（5）" => 4,
		      "五（6）" => 4,
		      "五（7）" => 3,
		      "五（8）" => 3,
		     },
		    ],
		   );
#}}}

my @weeks_grades_subjects;
#{{{
# gawk "{print \"[\"$1\"],\",\"[\"上\"],\",\"[\"$2\"],\",\"[\"$3\"]\"}" testlesson1.txt > t2.txt
# replace [ ] with " " in t2.txt
# gawk "{print \"[\"$0\"],\"}" t2.txt > t3.txt
@weeks_grades_subjects = (
			  ["第一周", "上", "一", "第一课"],
			  ["第一周", "上", "二", "第二课"],
			  ["第二周", "上", "三", "第三课"],
			  ["第三周", "上", "四", "第四课"],
			  ["第六周", "上", "五", "第五课"],
);
#}}}
my %week_number;
#{{{
%week_number = (
		   "第一周" => 0,
		   "第二周" => 1,
		   "第三周" => 2,
		   "第四周" => 3,
		   "第五周" => 4,
		   "第六周" => 5,
		   "第七周" => 6,
		   "第八周" => 7,
		   "第九周" => 8,
		   "第十周" => 9,
		   "第十一周" => 10,
		   "第十二周" => 11,
		   "第十三周" => 12,
		   "第十四周" => 13,
		   "第十五周" => 14,
		   "第十六周" => 15,
		   "第十七周" => 16,
		   "第十八周" => 17,
);
#}}}
my %half_week;
#{{{
%half_week = (
	      "上" => 0,
	      "下" => 1,
);
#}}}
my %grade_number;
#{{{
%grade_number = (
		 "一" => 0,
		 "二" => 1,
		 "三" => 2,
		 "四" => 3,
		 "五" => 4,
);
#}}}
my @holidays;
#{{{
@holidays = @short_holidays;
foreach my $hdays (@holidays) {
  $hdays = $base_year . $hdays;
};
#}}}
#}}}

my $cur_week;
my $cur_day;
my $cur_time;
my $t_date;
my $cur_teacher;
my $cur_class;
my $cur_subject;
my $in_hdays;
my $curr_time; 

foreach my $emt_line (@weeks_grades_subjects) {
  $cur_week = $week_number{@$emt_line[0]};
  while (($key,$value) = each $classes_lessons[@$emt_line[1]][$grade_number{@$emt_line[2]}] ) {
    $in_hdays = 0;
    $cur_day = $value;
    $curr_time = DateTime->new(year => $base_year, month => $term_start_month, day => $term_start_day);
    $curr_time->add(weeks => $cur_week, days => $cur_day );

    $t_date = $curr_time->ymd;
    $t_date =~ s/\-//g;

    # 跳过假期
    foreach my $hdays (@holidays) {
      if ($hdays == $t_date) {
    	$in_hdays = 1;
    	last;
      }
    };
    if ($in_hdays == 1) {
      next;
    } else {
      print "$t_date $key ";
      print "$classes_teachers[$grade_number{@$emt_line[2]}]{$key} @$emt_line[3]\n";
    }
  }

}; 
