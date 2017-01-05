use FindBin qw($Bin);
use lib "$Bin/../lib";
use ChineseNumbersU8;
use Encode;

my $settings_file = "$Bin/../config/" . "g-1.ini";
#  @class_teachers; # 隐藏的，在读取配置文件时，从节名生成
#  @class_week;     # 隐藏的，在读取配置文件时，从节名生成

# 定义一些到处可用的临时变量
my @temp_lines;
my $temp_struct_name;
my $temp_array;
my $temp_count_in_while;
my $error_message;

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
      } else {
	# 如果班级不是 ？（？） 的格式，就退出
	$error_message = encode("gb2312",decode("utf8","的格式不正确"));
	die "$temp_struct_name $error_message";
      }
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
    }
  }
  # 不是哈希，就是数组
    push (@{$temp_struct_name}, $_);
}
close TEMP;

print $class_week[0][0][4] . "\n";

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
print $temp_sum_elements_grades  . "\n";
foreach my $i (@temp_sum_elements_classes) {
  print $i . "\n";
}
$temp_sum_elements = $#class_week;
print $temp_sum_elements . "\n";

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

foreach my $i (@gap_of_week) {
  foreach my $j (@{$i}) {
    if ($j) {
      foreach my $k (@{$j}) {
	print $k;
      }
    }
    print "\n";
  }
}


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
