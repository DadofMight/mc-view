#!/usr/bin/perl
use JSON;
my $base_dir = $ARGV[0];
if ($base_dir eq "") {
	die "Usage: $0 MC_INSTALL_DIRECTORY\n"
}
my $json = JSON->new->pretty->allow_nonref;
my @players;

# Translate player NBT files into JSON
my $cmd = 'ls ' . $base_dir . '/world/players';
my @filelist = `$cmd`;
foreach my $file (@filelist) {
	chomp($file);
	if ($file =~ /([A-Za-z0-9\_]+)\.dat$/) {
		my $player_name = $1;
		$cmd = "php -q $base_dir/tools/dump_file.php $base_dir/world/players/$file > $base_dir/world/players_json/" . lc($player_name) . ".json";
		`$cmd`;
		push(@players, $player_name);
	}
}

# Sanitize player files for www
foreach my $player (@players) {
	my $player_data = &read_player_json(lc($player));
	$player_data->{'Pos'} = "REDACTED";
	&write_player_json_www($player_data, $player);
}



# Copy stats files to www
$cmd = 'ls ' . $base_dir . '/world/stats';
@filelist = `$cmd`;
foreach my $file (@filelist) {
	chomp($file);
	if ($file =~ /([A-Za-z0-9\_]+)\.json$/) {
		$cmd = "cp $base_dir/world/stats/$file $base_dir/www/stats/" . lc($1) . ".json";
		`$cmd`;
	}
}

# Copy system files
my @files = ('scoreboard.dat');
foreach my $file (@files) {
	if ($file =~ /([A-Za-z0-9\_]+)\.dat$/) {
		$cmd = "php -q $base_dir/tools/dump_file.php $base_dir/world/data/$file > $base_dir/www/" . $1 . ".json";
		`$cmd`;
	}
}
exit;





sub read_player_json {
my ($name) = @_;
my ($filedata, $d, $player);
$filedata = `cat $base_dir/world/players_json/$name.json`;
$d = $json->decode($filedata);
foreach my $chunk (@{$d->{'value'}}) {
	if ($chunk->{'name'} eq "Inventory") {
		$player->{'Inventory'} = $chunk->{'value'}->{'value'};
		my @items;
		foreach my $inventory_chunk (@{$player->{'Inventory'}}) {
			my %inventory_item;
			foreach my $inventory_item_chunk (@{$inventory_chunk}) {
				$inventory_item{$inventory_item_chunk->{'name'}} = $inventory_item_chunk->{'value'};
			}
			push(@items, \%inventory_item);
		}
		$player->{'Items'} = \@items;
	} elsif ($chunk->{'name'} eq "EnderItems") {
		$player->{'EnderItems'} = $chunk->{'value'}->{'value'};
		my @items;
		foreach my $inventory_chunk (@{$player->{'EnderItems'}}) {
			my %inventory_item;
			foreach my $inventory_item_chunk (@{$inventory_chunk}) {
				$inventory_item{$inventory_item_chunk->{'name'}} = $inventory_item_chunk->{'value'};
			}
			push(@items, \%inventory_item);
		}
		$player->{'EnderChest'} = \@items;
	} else {
		$player->{$chunk->{'name'}} = $chunk->{'value'};
	}
}
#print "player:\n";
#print Dumper($player);
return($player);
}

sub write_player_json_www {
my ($in, $name) = @_;
my $out = $json->encode($in);
my $out_path = "$base_dir/www/players/" . lc($name) . ".json";
unless(open(OUTPUT, ">$out_path")) {
	 die "Cannot open file for writing at: $out_path";
}
print "Writing player data to $out_path\n";
print OUTPUT $out;
close(OUTPUT);
return();
}
