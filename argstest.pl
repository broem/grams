#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper qw(Dumper); # I used this to visualize the hash structure

# [^!-~\s]


# be sure to add lots of comments and how you did all this amazingness

sub rmwhite { my $i = shift; $i=~s/^\s*(.*?)\s*$/$1/; return $i};
sub rmstuff { my $i = shift; $i=~s/(\\|\{|\}|"|\;|'|”|“|\:|\$|\%|\#|\=|\<|\>|\(|\)|\[|\])//g; return $i};
sub rmeol { my $i = shift; $i=~s/(\.|\!|\?)//g; return $i};

my %vocab = (); 
my $counter = 0;
my $singleCounter = 0;
my $wordCount = 0;
my $uniqueWord = 0;
my %words = ();
my %generationLine = ();
my $fh;
my $n= $ARGV[0];
my $sentenceCount = $ARGV[1];
my @array = ();


my %hash = ();
	for my $i(0..$#ARGV){
		print "$i: $ARGV[$i]\n";
	}


	for my $file(@ARGV){
		if(open($fh, '<', $file)){
			 # or die "cant open $file\n";
		while(<$fh>){
			foreach my $word(split/\s+/){
				chomp;
				$word = rmstuff($word);
				my $holder;
				# this is long couldn't get $1 to match?
				if($word=~m/\./){
					$holder = ".";
				}
				if($word=~m/\,/){
					$holder = ",";
				}
				if($word=~m/\?/){
					$holder = "?";
				}
				if($word=~m/\!/){
					$holder = "!";
				}
				$word=~s/\.|\,|\?|\!//g;
				push (@array, $word);
				if(defined $holder){
					# print "hmm\n";	
					push (@array, $holder);}
				
			}
		}

		close $fh;
	}
	}
	# my $len = $#array;
	# print "$len\n";



    # this gets our n-1 word set
    # get freq of starts and ends
    for my $word(0..$#array) {
    	my $first;
    	for(0..$n){
    	$first = $array[$word];
    }
    	# newline remove
    	chomp($first);
		
		# this is not getting quotes
		$first = rmstuff($first);
		$first = rmwhite($first);

		# find line ends
		# consider Mr. Mrs. Dr. etc...
		# if the word ends with a .?! then mark it
		# add a start and end tag
		if($first =~m/\./) {
			$vocab{"."}++;
    		# $vocab{"<end>"}++;
    		$vocab{"<start>"}++;
    	}
    	if($first =~m/\?/) {
			$vocab{"."}++;
    		# $vocab{"<end>"}++;
    		$vocab{"<start>"}++;
    	}
    	if($first =~m/\!/) {
			$vocab{"."}++;
    		# $vocab{"<end>"}++;
    		$vocab{"<start>"}++;
    	}
    	# if it contains these ugly things, remove them
    	# WOW WTF
    	# $first=~s/"|'|“//g;
    	# $first = rmeol($first);
		$first = lc($first);
		if(length($first) != 0) {
			$wordCount++;
			$vocab{$first}++;
    	}
	}


    # this gets our ngram hash table setup
    # make those variable readable

    # to get the first word of text out and marked
    # set up the start 
    my $begin; 
    # chomp $begin;
    # $begin = rmstuff($begin);
    # $begin = rmeol($begin);
    # $begin = lc($begin);
    for my $i(0..$n-1){
    	$begin .= "$array[$i] ";
    	$begin = lc($begin);
    	$begin = rmstuff($begin);
    }
    $hash{"<start>"}{$begin}++;
    for my $i(0..$#array) {
    	# get first starting word
		my $j = $i + $n - 1;
		my $first = $array[$i+$n];
		
		# $first = rmstuff($first);
		$first = lc($first);
		# chomp($first);
		my $ngram = "";
		
		if($j > $#array) { next; }

		# for start tag processing.
		my $comparable = $array[$i];
		if($comparable=~m/\.|\?\!/){
			# exclude the punctuation.
			my $startingTag;
			my $r = $i+1;
			my $rn = $r+$n-1;
			for my $wow($r..$rn){
				$startingTag .= "$array[$wow] ";
			}
			chomp $startingTag;
			$startingTag = lc($startingTag);
			$startingTag=~s/\s+$//; # remove trailing right space
			$hash{"<start>"}{$startingTag}++;
		}


		
		for my $k ($i..$j) {
			# k-1 = bigram, k-2 trigram...etc.
			# change 1 to n when ready
    		$ngram .= "$array[$k] ";
    		# chomp($ngram);
    		# make ending and starting tags
    		# $ngram = rmstuff($ngram);
			# $ngram = rmwhite($ngram);
			$ngram = lc($ngram);

			# if the ends are found, store em and go
			# if ($first=~m/\.|\?|\!/) {
			# 	# $first = rmeol($first);
			# 	# chomp($first); 
			# 	# $hash{"<end>"}{$first}++;
			# 	# $hash{$first}{"<end>"}++;
				
			# 	# here we get the next after end condition
			# 	# if there is something beyond, its a start
			# 	my $z = $i+$n;
			# 	my $nextWord;
			# 	for my $o($i..$z){
			# 	# if (($counter+1) < $#array){

			# 		$nextWord .= "$array[$o] ";
			# 		chomp($nextWord);
			# 		$nextWord = lc($nextWord);
			# 		$nextWord = rmstuff($nextWord);
			# 		$hash{"<start>"}{$nextWord}++;
				
			# }
			# }
			# $ngram = rmeol($ngram);
		}
		$counter++;
		chomp $ngram;
		$ngram=~s/\s+$//;
		$hash{$ngram}{$first}++; } #}
		# close $fh;
		my $divisor;
foreach my $firstHashKey( keys %hash) {
	foreach my $secondHashKey( keys %{$hash{$firstHashKey}}) {
		# where second hash key matches our unigram freqs
			# if( $secondHashKey eq %vocab{$secondHashKey} ) {
				# print "$unigramKey matched -> $vocab{$unigramKey}\n";
				if(defined $vocab{$secondHashKey}){
				$divisor = $vocab{$secondHashKey};
				# print "$divisor, \n";
				if($divisor != 0){ # what is wrong here?
				my $frequency = $hash{$firstHashKey}{$secondHashKey} / $vocab{$secondHashKey};
				$hash{$firstHashKey}{$secondHashKey} = $frequency;
			}
			}
			
		}
		# print "$firstHashKey -> $secondHashKey ($hash{$firstHashKey}{$secondHashKey})\n";
	}

# normalize the frequencies...this is getting ugly
foreach my $firstHashKey( keys %hash) {
	my $total = 0;
	my $otherTotal = 0;
	foreach my $secondHashKey( keys %{$hash{$firstHashKey}}) {
		# add up values in key 
			# print "$value\n";
		$total = $total + $hash{$firstHashKey}{$secondHashKey};
		}
		foreach my $secondHashKey( keys %{$hash{$firstHashKey}}) {
			$hash{$firstHashKey}{$secondHashKey} = $hash{$firstHashKey}{$secondHashKey} / $total;

		}
		# now we must make this a range 
		foreach my $secondHashKey ( sort { $hash{$firstHashKey}{$b} <=> $hash{$firstHashKey}{$a}} keys %{$hash{$firstHashKey}}) {
			$hash{$firstHashKey}{$secondHashKey} += $otherTotal;
			$otherTotal = $hash{$firstHashKey}{$secondHashKey}; 
		}
	}

# print Dumper(\%hash);
# print Dumper(\%vocab);

my $random;
my $from;
my $to;
my $sentence;

# generate random sentences, this is really ugly code
# basically we generate a random number, sort our hash values
# at the given <start> tag. We then compare against our random number
# where if random < value choose value. 
# from there we have a series of magical if's while's and for's to 
# utterly confuse anyone who dare's to read it. 
# I will attempt to describe this: 
OUTER: for my $i(1..$sentenceCount) {
	$from = "<start>";
	$to = "";
	$sentence = "";
	my $dangerCount = 0;
	INNER: while($dangerCount < 20) {

		# print "I should be here\n";
		# print "from: $from\n";

		$random = rand();
		# to check amt of values for the hash
		my $count = keys %{$hash{$from}};
		# print "COUNT = $count\n";

		# this shouldn't be necessary but for some reason
		# it is. 
		if ($count == 0) {
			print "is it here?\n";
			$from = "<start>";
		}

		# check to make sure we have more than one value.
		# also check for ending statements. omg
		# if ($count == 1) {
		# 	foreach my $element(keys %{$hash{$from}}) {
		# 		if($element=~m/\./g){
		# 			$sentence .= "$element";
		# 			last OUTER;}
		# 			else{
		# 		$sentence .= "$element ";
		# 		$from = $element;
		# 		next; }
		# 	}
		# }

		foreach my $element( sort { $hash{$from}{$a} <=> $hash{$from}{$b}} keys %{$hash{$from}}) {
			# print "$element -> $hash{$from}{$element}\n";
			# print "$rand\n";
			# print "Random: $rand and Val: $hash{$from}{$element} \n";
			# my $end = "<end>";
			# print "$from";
			# compare the random to the values in the hash
			my $tableValue = $hash{$from}{$element}; 
			if (defined $tableValue && $random < $tableValue) {

				# print "$element\n";
				# if that value is punctuation, escape
				if ($element=~m/\./g){
					$sentence .= "$element ";
					last INNER;
				}
				else{
					# print "$element ";
					if($from=~m/\<start\>/g){
						# print "$from\n";
						$from = $element;
						# print "$from\n";
						$sentence .= "$element ";
						last;
					}
					else {
						# print "hello ben\n";
					$sentence .= "$element ";
					# split from into its elements
					# check for from being == 1
					$from .= " $element";
					# print "FROM: $from\n";
					my @sent = split(/\s+/, $from);
					my $newFrom;
					for my $this(1..$#sent){
						# print "$sent[$this] \n";
						$newFrom .= "$sent[$this] ";
						# print "way inside from: $from\n";
					}
					$from = $newFrom;
					# print "new from: $from\n";
					$from=~s/\s+$//;
					$dangerCount++;
					if($dangerCount == 20){
						$sentence=~s/\s+$//;
						$sentence .= ".";
					}
				}

					# redo INNER;	
				}
			}
		}
		# print "\n";
	} 
	$sentence = ucfirst($sentence);
	print "$sentence\n";
	# print "\n";
	# $i++;
}

# print "$n , $sentenceCount!!!";