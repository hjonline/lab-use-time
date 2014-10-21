#{{{
# Ҫ����İ�
#{{{
use DateTime;
use Encode;
#}}}
# �������� 
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
		      "һ��5��" => "л��",
		      "һ��6��" => "���",
		      "һ��7��" => "л��",
		      "һ��8��" => "л��",
		      "һ��9��" => "���",
		     },
		     {
		      "����5��" => "������",
		      "����6��" => "������",
		      "����7��" => "������",
		      "����8��" => "������",
		      "����9��" => "������",
		     },
		     {
		      "����5��" => "л��",
		      "����6��" => "л��",
		      "����7��" => "л��",
		      "����8��" => "л��",
		     },
		     {
		      "�ģ�5��" => "������",
		      "�ģ�6��" => "������",
		      "�ģ�7��" => "������",
		      "�ģ�8��" => "������",
		     },
		     {
		      "�壨5��" => "���",
		      "�壨6��" => "���",
		      "�壨7��" => "���",
		      "�壨8��" => "���",
		     },
		    );
#}}}

my @classes_lessons;
#{{{
@classes_lessons = (
		    [
		     {
		      "һ��5��" => 3,
		      "һ��6��" => 2,
		      "һ��7��" => 1,
		      "һ��8��" => 1,
		      "һ��9��" => 4,
		     },
		     {
		      "����5��" => 4,
		      "����6��" => 1,
		      "����7��" => 1,
		      "����8��" => 1,
		      "����9��" => 4,
		     },
		     {
		      "����5��" => 2,
		      "����6��" => 1,
		      "����7��" => 2,
		      "����8��" => 3,
		     },
		     {
		      "�ģ�5��" => 2,
		      "�ģ�6��" => 1,
		      "�ģ�7��" => 2,
		      "�ģ�8��" => 3,
		     },
		     {
		      "�壨5��" => 3,
		      "�壨6��" => 1,
		      "�壨7��" => 1,
		      "�壨8��" => 2,
		     },
		    ],
		    [
		     {
		      "һ��5��" => 5,
		      "һ��6��" => 2,
		      "һ��7��" => 5,
		      "һ��8��" => 3,
		      "һ��9��" => 5,
		     },
		     {
		      "����5��" => 5,
		      "����6��" => 5,
		      "����7��" => 3,
		      "����8��" => 2,
		      "����9��" => 5,
		     },
		     {
		      "����5��" => 4,
		      "����6��" => 3,
		      "����7��" => 5,
		      "����8��" => 4,
		     },
		     {
		      "�ģ�5��" => 4,
		      "�ģ�6��" => 3,
		      "�ģ�7��" => 4,
		      "�ģ�8��" => 4,
		     },
		     {
		      "�壨5��" => 4,
		      "�壨6��" => 4,
		      "�壨7��" => 3,
		      "�壨8��" => 3,
		     },
		    ],
		   );
#}}}

my @weeks_grades_subjects;
#{{{
# gawk "{print \"[\"$1\"],\",\"[\"��\"],\",\"[\"$2\"],\",\"[\"$3\"]\"}" testlesson1.txt > t2.txt
# replace [ ] with " " in t2.txt
# gawk "{print \"[\"$0\"],\"}" t2.txt > t3.txt
@weeks_grades_subjects = (
			  ["��һ��", "��", "һ", "��һ��"],
			  ["��һ��", "��", "��", "�ڶ���"],
			  ["�ڶ���", "��", "��", "������"],
			  ["������", "��", "��", "���Ŀ�"],
			  ["������", "��", "��", "�����"],
);
#}}}
my %week_number;
#{{{
%week_number = (
		   "��һ��" => 0,
		   "�ڶ���" => 1,
		   "������" => 2,
		   "������" => 3,
		   "������" => 4,
		   "������" => 5,
		   "������" => 6,
		   "�ڰ���" => 7,
		   "�ھ���" => 8,
		   "��ʮ��" => 9,
		   "��ʮһ��" => 10,
		   "��ʮ����" => 11,
		   "��ʮ����" => 12,
		   "��ʮ����" => 13,
		   "��ʮ����" => 14,
		   "��ʮ����" => 15,
		   "��ʮ����" => 16,
		   "��ʮ����" => 17,
);
#}}}
my %half_week;
#{{{
%half_week = (
	      "��" => 0,
	      "��" => 1,
);
#}}}
my %grade_number;
#{{{
%grade_number = (
		 "һ" => 0,
		 "��" => 1,
		 "��" => 2,
		 "��" => 3,
		 "��" => 4,
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

    # ��������
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
