#!C:\Strawberry\perl\bin

# returns 10 most common words in a given document

sub rmwhite { my $i = shift; $i=~s/^\s*(.*?)\s*$/$1/; return $i};
sub rmstuff { my $i = shift; $i=~s/(\.|\\|\!|\?|\{|\}|\"|\;|\'|\$|\%|\#|\=|\<|\>|\(|\))//g; return $i};

my %vocab = (); my $counter = 0;
my $wordCount = 0;
my $uniqueWord = 0;

while(<>){
	chomp;
	foreach $element(split/ /){
	$element= rmstuff($element);
	$element = rmwhite($element);
	#chomp;
	if(length($element) != 0){
		$wordCount++;
		$vocab{$element}++;
	}
	} #split on ws
}
	foreach $word(sort{$vocab{$b}<=>$vocab{$a}}keys%vocab){
		print "$word $vocab{$word}\n";
		if($counter==10){last;}$counter++;
	}
	$uniqueWord = keys %vocab;

	print "$wordCount words: $uniqueWord types";


# p(w4|w1w2w3)= f(w1w2w3w4)/ f(w1w2w3)
# maximum likelihood estimation

