use FindBin qw($Bin);
use lib "$Bin/../lib";
use ChineseNumbersU8;
use Date::Manip;
use Encode;

my $settings_file = "$Bin/../config/" . "g-1.ini";
my $temp_result_1 = "$Bin/../result/" . "temp_result_1.txt";
my $temp_result_2 = "$Bin/../result/" . "temp_result_2.txt";

#  @class_teachers; # 隐藏的，在读取配置文件时，从节名生成
#  @class_week;     # 隐藏的，在读取配置文件时，从节名生成

# 定义一些到处可用的临时变量
my @temp_lines;
my $temp_struct_name;
my $temp_array_1;
my $temp_array_2;
my $temp_count_in_while;
my $error_message;
my @lesson_per_week;

open ( TEMP, "<$settings_file" ) 
  or die "Can't open \"$settings_file\" due to $! \n";
while (<TEMP>) {
  s/#.*//;		   # ignore comments by erasing them 用擦除的方法去掉注释行
  next if /^(\s)*$/;	   # skip blank lines  去掉空白行，顺便把上面擦掉的注释行去掉
  chomp;      

  if (/^\[(.*)\]/) {
    $temp_struct_name = $1;
    next;
  }
  # 如果一行里有=号，说明是要放到哈希里去的
  if (/=/) {
    # 把一行拆分为两个元素的数组，并去除每个元素首尾的空白字符
    @temp_lines = split /=/, $_;
    $temp_lines[0] =~ s/(^\s+|\s+$)//g;
    $temp_lines[1] =~ s/(^\s+|\s+$)//g;

    # 读取班级安排表
    if ( $temp_struct_name =~ /(class_week)_(\d+)/ ) {
      my $temp_array_element = $2 - 1;
      my $temp_struct_name_1 = $1;
      if ($temp_lines[0] =~ /(.*)（(.*)）/) {
	my $match_1 = $1;
	my $match_2 = $2;
	# 如果班级安排的不是一个数字（代表周几，指这个班周几上这节课），就退出
	if (!($temp_lines[1] =~ /\d+/)) {
	  $error_message = encode("gb2312",decode("utf8","的格式不正确"));
	  die "$temp_struct_name $error_message";
	}

	${$temp_struct_name_1}
	  [$temp_array_element]
	    [ChineseNumbers->ChineseToEnglishNumber($match_1, "arabic") - 1]
	    [$match_2 - 1]
	= $temp_lines[1];
	$lesson_per_week[ChineseNumbers->ChineseToEnglishNumber($match_1, "arabic") - 1][$match_2 - 1] = $temp_array_element; 
      } else {
	# 如果班级不是 ？（？） 的格式，就退出
	$error_message = encode("gb2312",decode("utf8","的格式不正确"));
	die "$temp_struct_name $error_message";
      }
      next;
    }
    # 读取教师安排表
    if ( $temp_struct_name =~ /(class_teachers)_(\d+)/ ) {
      my $temp_struct_name_1 = $1;
      if ($temp_lines[0] =~ /(.*)（(.*)）/) {
	${$temp_struct_name_1}  
	  [ChineseNumbers->ChineseToEnglishNumber($1, "arabic") - 1]  
	  [$2 - 1]  
        = $temp_lines[1];
      } else {
	$error_message = encode("gb2312",decode("utf8","的格式不正确"));
	die "$temp_struct_name $error_message";
      }
      next;
    }
    # 普通 hash ，不需要把几个 hash 合在一个大的数组中
    ${$temp_struct_name}{$temp_lines[0]} = $temp_lines[1];
  }
  # 不是哈希，就是数组
  push (@{$temp_struct_name}, $_);
}
close TEMP;

# print $class_week[0][0][4] . "\n";

# 现在我们要建立一个数组，用来保存两次课之间的间隔
# 结构是这样的[年级][班级] = {间隔1，间隔2，...最后间隔}
# 间隔数的循环次数，是 @class_week 的第一层的元素个数，因为这是课的次数
# @class_week 的结构，[课时数][年级][班级] = 上课日期
# 那么，如果一个星期一节课的话，间隔数组就是 { 7 - 这周的上课日期 + 下周的上课日期 } ，就这一个元素，其实就是 7，因为两个日期一样。
# 一个星期两节课的话，{ 这周第二节课日期 - 这周第一节课日期，7 - 这周第二节课日期 + 下周的第一节课日期 }
# 一个星期三节课的话，{ 这周第二节课日期 - 这周第一节课日期，这周第三节课日期 - 这周第二节课日期，7 - 这周第三节课日期 + 下周的第一节课日期 }
# 所以，需要借助一个辅助数组，用来保存前一次课的日期，每次做完计算后，更新为这一次的日期
# 循环开始时，是不用计算的，要跳过
# 循环到最后一节课的日期时，要改一下计算公式。

my @gap_of_week;
my @prev_day;

# 因为每一次课时里，班级的个数都是一样的，所以只要选取 @class_work 的第一层的第一个元素，就得到全部的班级表
my $temp_count_in_while_i;
my $temp_count_in_while_j;
my $temp_count_in_while_k;

# 还要一个变量来记录有几个年级，一个数组来记录每个年级的班级数，那那个年级变量就不要了
my $temp_sum_elements_grades;
my @temp_sum_elements_classes;

$temp_count_in_while_i = 0;
while ($class_week[$temp_count_in_while_i]) {
  $temp_count_in_while_j = 0;
  while ($class_week[$temp_count_in_while_i][$temp_count_in_while_j]) {
    $temp_count_in_while_k = 0;
    foreach $i (@{$class_week[$temp_count_in_while_i][$temp_count_in_while_j]}) {
      $temp_count_in_while_k ++;
    }
    $temp_sum_elements_classes[$temp_count_in_while_j] = $temp_count_in_while_k;
    $temp_count_in_while_j ++;
  }
  $temp_count_in_while_i ++;
}
  
$temp_sum_elements_grades = $#temp_sum_elements_classes;
# print $temp_sum_elements_grades  . "\n";
foreach my $i (@temp_sum_elements_classes) {
  # print $i . "\n";
}
$temp_sum_elements = $#class_week;
# print $temp_sum_elements . "\n";

# 计算固定的日期差
# 这里第一层是年级数
$temp_count_in_while_i = 0;
while ($temp_count_in_while_i <= $temp_sum_elements_grades) {
  # 这里第二层是班级数
  $temp_count_in_while_j = 0;
  while ($temp_count_in_while_j <= $temp_sum_elements_classes[$temp_count_in_while_i]) {
    if ($class_week[0][$temp_count_in_while_i][$temp_count_in_while_j]) {
      $temp_count_in_while_k = 0;
      while ($temp_count_in_while_k <= $temp_sum_elements + 1) {
	if ($temp_count_in_while_k == 0) {
	  $prev_day[$temp_count_in_while_i][$temp_count_in_while_j] 
	    = $class_week[0][$temp_count_in_while_i][$temp_count_in_while_j];
	  $temp_count_in_while_k ++;
	  next;
	}
	if ($temp_count_in_while_k == $temp_sum_elements + 1) {
	  push @{$gap_of_week[$temp_count_in_while_i][$temp_count_in_while_j]},
	    7 - $class_week[$temp_sum_elements][$temp_count_in_while_i][$temp_count_in_while_j]
	    + $class_week[0][$temp_count_in_while_i][$temp_count_in_while_j];
	  $temp_count_in_while_k ++;
	  next;
	}
	push @{$gap_of_week[$temp_count_in_while_i][$temp_count_in_while_j]},
	  $class_week[$temp_count_in_while_k][$temp_count_in_while_i][$temp_count_in_while_j]
	  - $prev_day[$temp_count_in_while_i][$temp_count_in_while_j];
	$temp_count_in_while_k ++;
	next;
      }
    }
    $temp_count_in_while_j ++;
  }
  $temp_count_in_while_i ++;  
}

# 对节假日的计算，有一个讨厌的事情是，开学的第一天，如果不是一周的周一，那么，开学日的前几天，应该也作为假日，添加到节假日表里
# 这样，设定节假日时，只要给出开学日和非公历的假日，比如清明节，中秋节，其它公历的假日，固定的开学日都不用去改了，并且非固定的
# 假日，应该在前面加注释
# 测试开学日前加假日
my $first_day_year;
my $first_day_month;
my $first_day_day;
my $first_day_first = "1";
 
$_ = @first_day[0];
if (/(\d\d\d\d)(\d\d)(\d\d)/) {
  $first_day_year = $1;
  $first_day_month = $2;
  $first_day_day = $3;
}

my $base_workweek=&Date_WeekOfYear($first_day_month, $first_day_day, $first_day_year, $first_day_first);
my $base_year = $first_day_year;
my $base_workyear = $base_year . "W";

# print $base_workweek . "\n";


my $first_day_week = &Date_DayOfWeek($first_day_month, $first_day_day, $first_day_year, $first_day_first);
# print $first_day_week . "\n";

# 排除开学日这一周中，开学日前的日期
my $hday;
for (my $i = 1;$i < $first_day_week; $i ++) {
  $hday = DateCalc($first_day[0],"-$i days");
  $hday =~ s/00:00:00//;
  push @holidays, $hday;
}

# 现在需要再构建两个数组，一个数组是指针，指向 gap_of_week 中下一个需要添加的间隔
# 另一个数组，是把每次添加的间隔值都累加起来，这样后续的日期只要加上这个间隔的累加值就行了
# 这两个数组的结构都是 $数组名[年级][班级]
my @all_gaps;
my @point_2_gap_of_week;

# 先要初始化一下 @all_gaps
# print "sum grade $temp_sum_elements_grades \n";
for (my $i = 0; $i <= $temp_sum_elements_grades; $i ++){
  # print "sum class $temp_sum_elements_classes[$i]\n";
  for (my $j = 0; $j <= $temp_sum_elements_classes[$i]; $j++) {
    # print "all_gaps_out $all_gaps[$i][$j]\n";
    for (my $k = 0; $k <=$#class_week; $k++ ) {
      if ($class_week[0][$i][$j]) {
	$all_gaps[$i][$j][$k] = 0;
	$point_2_gap_of_week[$i][$j][$k] = $k;
	# print "grade $i class $j turn $k $point_2_gap_of_week[$i][$j][$k]\n";
      }
    }
  }
}

# 测试程序
my $cur_week;
my $cur_grade;
my $cur_class_in_week_turn;
my $cur_class;
my $cur_day;
my $in_hdays;
my $cur_gap;
my $cur_grade_final;
my $cur_class_final;
my $tmp_lesson_per_week_loop;

foreach my $emt_line (@weeks_grades_subjects) {
  @temp_lines = split " ",$emt_line;
  # print "emt_line $temp_lines[0]\n";
  if ($temp_lines[0] =~ /第(.*)周/) {
    # print "found match\n";
    # print $1 . "\n";
    $cur_week = $base_workweek + ChineseNumbers->ChineseToEnglishNumber($1, "arabic") - 1;
  }
  # print "cur_week  $cur_week\n";

  # 确定年级
  $cur_grade = ChineseNumbers->ChineseToEnglishNumber($temp_lines[2], "arabic") - 1;
  $cur_class_in_week_turn = $temp_lines[1] -1;
  # print "cur_class_in_week_turn $cur_class_in_week_turn\n";
  # print "cur_grade is $cur_grade \n";

  # 从 @temp_sum_elements_classes 的结构中可以知道，它就是说明 0-4 个年级中，每个年级有几个班级的
  # 所以，给定年级num ，就是 $temp_sum_elements_classes[num] ，就知道班级数
  # 所以设定一个 $temp_sum_elements_classes[num] 次的循环，跳过空的班级，有的班级，加上年级号，就可以从
  # @class_week[$cur_class_in_week_turn][cur_grade][$cur_class] 中取得上课日期

  $cur_class = 0;
  while ($cur_class <= $temp_sum_elements_classes[$cur_grade] -1 ) {
    
    my $temp_class_day;
    if ($class_week[$cur_class_in_week_turn][$cur_grade][$cur_class]) {
      # 求出初步结果
      $temp_class_day = $class_week[$cur_class_in_week_turn][$cur_grade][$cur_class];
      # print "grade $cur_grade class $cur_class temp_class_day $temp_class_day\n";
	  if ($cur_week < 10) { 
		$cur_day = $base_workyear . "0" . $cur_week . $temp_class_day; 
	  } else {
		$cur_day = $base_workyear . $cur_week . $temp_class_day;
	  }
      $cur_day = ParseDateString($cur_day);
      $cur_day = UnixDate($cur_day,"%Y%m%d");
      # print "1st cur_day $cur_day\n";
      # 首先要加上原有的延迟
      # print "all_gap $all_gaps[$cur_grade][$cur_class][$cur_class_in_week_turn]\n";
      $cur_day = DateCalc($cur_day, "+$all_gaps[$cur_grade][$cur_class][$cur_class_in_week_turn] days");
      $cur_day =~ s/00:00:00//;
      # print "gap1 cur_day $cur_day\n";
	  
      # 预设有延迟的标志，强制进入判断是否延迟的循环
      $in_hdays = 1;
      while ($in_hdays) {
	    $in_hdays = 0;
	    foreach my $temp_hday (@holidays) {
	      if ($cur_day eq $temp_hday) {
		# if ( $point_2_gap_of_week[$cur_grade][$cur_class][$cur_class_in_week_turn + 1] ) {
		#   $tmp_cur_class_in_week_turn = $cur_class_in_week_turn +1;
		# } else {
		#   $tmp_cur_class_in_week_turn = 0;
		# }
		$tmp_lesson_per_week_loop = 0;
		while ( $tmp_lesson_per_week_loop <= $lesson_per_week[$cur_grade][$cur_class] ) {
		  $cur_gap = $point_2_gap_of_week[$cur_grade][$cur_class][$tmp_lesson_per_week_loop];
		  # print "tmp_lesson_per_week_loop $tmp_lesson_per_week_loop\n";
		  # print "cur_gap $cur_gap\n";
		  # 指向 gap 数组的指针，在小于 class_week 的总数时，都是递增 1
		  # 但是在等于总数时，要归零。
		  # all_gap 数组中，一个班级的一周的所有的课，都得添加间隔。用循环来完成。
		  # print "all_gaps_1 $all_gaps[$cur_grade][$cur_class][tmp_lesson_per_week_loop]\n";

		  $all_gaps[$cur_grade][$cur_class][$tmp_lesson_per_week_loop]
	          = $all_gaps[$cur_grade][$cur_class][$tmp_lesson_per_week_loop]
	          + $gap_of_week[$cur_grade][$cur_class][$cur_gap];
  		  # print "gap_of_week  $gap_of_week[$cur_grade][$cur_class][$cur_gap]\n";
		  # print "all_gaps $all_gaps[$cur_grade][$cur_class][tmp_lesson_per_week_loop]\n";

		  if ( $tmp_lesson_per_week_loop == $cur_class_in_week_turn ) {
		    $cur_day = DateCalc($cur_day, "+$gap_of_week[$cur_grade][$cur_class][$cur_gap] days");
		    $cur_day =~ s/00:00:00//;
		    $in_hdays = 1;
		    # print "in_hdays 1 cur_day $cur_day\n";
		  }
		  if ($point_2_gap_of_week[$cur_grade][$cur_class][$tmp_lesson_per_week_loop] < $#class_week) {
		    $point_2_gap_of_week[$cur_grade][$cur_class][$tmp_lesson_per_week_loop] ++;
		  } else {
		    $point_2_gap_of_week[$cur_grade][$cur_class][$tmp_lesson_per_week_loop] = 0;
		  }

		  $tmp_lesson_per_week_loop ++;
		}
	      }
	    }
      }


      # 最后看看是不是交换上课日期的情况
      if (exists $exchange_holidays{$cur_day}) {
	    $cur_day = $exchange_holidays{$cur_day};
      }
      $cur_grade_final = ChineseNumbers->EnglishToChineseNumber($cur_grade + 1, "simp");
      $cur_class_final = $cur_class +1;
      #现在可以打印日期 班级 教师 课题 效果 损坏
      push @temp_array_1, "$cur_day    $cur_grade_final（$cur_class_final）    $class_teachers[$cur_grade][$cur_class]    $temp_lines[3]    好    无"; 
    }
    # print "in_hday cur_day $cur_day    $cur_grade_final（$cur_class_final）    $class_teachers[$cur_grade][$cur_class]    $temp_lines[3] \n";
    $cur_class ++;

  }
}

@temp_array_2 = sort (@temp_array_1);

foreach my $tmp (@temp_array_2) {
  print $tmp . "\n";
}
# foreach my $hdays (@holidays) {
#   print $hdays . "\n";
# }


# # 对形如 “第XX周” 的数据，可以用正则表达式圈出 “第” 和 “周” 中间的中文数字，转阿拉伯数字，不用 hash 来对应了。

# foreach my $i (@gap_of_week) {
#   foreach my $j (@{$i}) {
#     if ($j) {
#       foreach my $k (@{$j}) {
# 	print $k;
#       }
#     }
#     print "\n";
#   }
# }

# while ( ($key, $value) = each %grade_number ) {
#   $key = encode("gb2312",decode("utf8",$key));
#   print "$key => $value\n";
# }



# 按周课时安排最后还是要排序的。

# foreach my $i (@class_week[0]) {
#   foreach my $j (@{$i}) {
#     if ($j) {
#       $temp_count_in_while = 0;
#       while ($temp_count_in_while <= $#class_week) {
# 	if ($temp_count_in_while == 0) {
# 	  $prev_day[$]
# 	}
#       print $k . "\n";
#       }
#     }
#   }
# }

#print $#{$class_teachers[0]} . "\n";


  #   # 把数组转化到哈希，注意 temp_struct_name 前的 $ 说明是个变量，而外面的 ${} 是去掉哈希的引用
  #   ${$temp_struct_name}{$temp_lines[0]} = $temp_lines[1];
  #   next;
  # }

    # 考虑在一个数组中，随 ini 文件中读到的节的名称，在运行时来创建元素，而每个元素都是一个 hash 数组
    # 目的：是因为如果一个星期中，一个班级一般都是上两节自然课，那要是以后有三节了呢？所以，程序中不要
    # 写死了只用两节课的那种，而是随 ini 文件中的节，例如 class_week_1 ， class_week_2 ， class_week_3 ...
    # 这样，每读入一个这样的节，都往 class_week 的数组中添加一个元素。
    # 20170103 修改，既然如此，为什么在读入数据时，不直接整理到多维数组？
    # if ( $temp_struct_name =~ /class_week_(\d+)/ ) {
    #   $class_week[$1-1] = \%{$temp_struct_name};
    #   next;
    # }
    # if ( $temp_struct_name =~ /class_teachers_(\d+)/ ) {
    #   $class_teachers[$1-1] = \%{$temp_struct_name};
    #   next;
    # }
    


# foreach $var (@holidays) {
#   print "$var" . "\n";
# }

# foreach $var (@class_week) {
  
#   while ( ($key, $value) = each %{$var} ) {
#     $key = encode("gb2312",decode("utf8",$key));
#     $value = encode("gb2312",decode("utf8",$value));
#     print "$key => $value\n";
#   }
# }

# foreach $var (@class_teachers) {
  
#   while ( ($key, $value) = each %{$var} ) {
#     $key = encode("gb2312",decode("utf8",$key));
#     $value = encode("gb2312",decode("utf8",$value));
#     print "$key => $value\n";
#   }
# }

# # 现在对 @class_week 要求出元素的个数，由此知道每个班级一周有几节课。
# my $classes_a_week = $#class_week + 1;
# print $classes_a_week . "\n";

# # 所以现在，每个班要产生一个有 $classes_a_week 个元素的数组，第一个元素是第一次课到第二次课的日期差，如果只有一节课，那么就只有一个日期差
# # 如果有两节课，那么第二节就是最后一个元素，最后一个元素的算法是 7-最后一节的日期+第一节的日期
# # 如果有三节，那么第二个元素，是第三节减去第二节的日期，第三个元素就是最后一个元素，算法同上。
# # 所以做一个循环，次数为 $classes_a_week ，然后又是一个循环，是从 $class_week[0] 中遍历每个 hash 的 key，取出值就是第一次课的日期，
# # 刚才取出的 key ，还可以到 $class_week[1] 中再取出一个值，就是第二次课的日期，用来减去前面一个日期，求出日期差，
# # 刚才取出的 key ，还用来建立一个 hash 数组，把 key 就是班级，每一个班级要对应一个数组，这个数组是个二维数组，第一维是年级，第二维是班级，
# # 所以需要对 key ，做一个字符串对应变化的操作，从 key 中取出年级，比如 “一” ，然后对应到 0 ，取出“（4）”，那就对应到 3，这样就建好了一个班级的数组
# # 班级的数组还要再复制一份，用来储存在处理过程中，记录的跳过假期有几次
# # 现在把日期差放到这个二维数组中，并且把它变成了三维的数组，
# # 暂时把这个班级数组叫做  @classes 
# # 用 ChineseNumbersU8 模块，试试直接把班级数组做出来

# my $array_1;
# my $array_2;
# my @class_week_array;

# $temp_count_in_while = 0;
# while ($temp_count_in_while <= $#class_week) {
#   while ( ($key, $value) = each %{$class_week[0]} ) {
#     # 对每个 $key 进行分解
#     if ( $key =~ /(.*)（(.*)）/) {
#       $array_1 = ChineseNumbers->ChineseToEnglishNumber($1, arabic) - 1;
#       $array_2 = ChineseNumbers->ChineseToEnglishNumber($2, arabic) - 1;
#     }
#     $class_week_array[$temp_count_in_while][$array_1][$array_2] = $value;
#     print "\$class_week_array\[$temp_count_in_while\]\[$array_1\]\[$array_2\] = $value\n";
#   }
#   $temp_count_in_while ++;
# }

# # my @short_holidays;
# # my $holidays_file = "holidays.txt";

# # sub get_array_from_file
# #   # 第一个参数是要保存的数组名，以引用方式传递进来
# #   # 第二个参数是要打开的文件名
# #   {
# #     my $array_ref = $_[0];
# #     my $temp_file = $_[1];
# #     open ( TEMP, "<$temp_file" ) 
# #       or die "Can't open \"$temp_file\" due to $! \n";
# #     while (<TEMP>) {
# #       chomp;
# #       push (@{$array_ref}, $_);
# #     }
# #     close TEMP;
# #   }


# # get_array_from_file(\@short_holidays, $holidays_file);
# # foreach $var (@short_holidays) {
# #   print "$var" . "\n";
# # }


# #   # 跳过空行或全由空白字符组成的行， \s 是空白字符
# #   # \S 则是非空行
# # next if($line =~ s/^\s*&/);
