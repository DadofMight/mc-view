#!/usr/bin/perl
use JSON;
use Data::Dumper;

my $json = JSON->new->pretty->allow_nonref;
my $base_dir = $ARGV[0];
my $cmd;

if ($base_dir eq "") {
	die "Usage: $0 MC_INSTALL_DIRECTORY\n"
}

my ($scoreboard, @teams);
$scoreboard = &read_scoreboard_json();
my %players_counted;
#print "Scoreboard data:\n";
#print Dumper($scoreboard);
my $team_chunks = $scoreboard->{'value'}->[0]->{'value'}->[0]->{'value'}->{'value'};
#print "teams:\n";
#print Dumper($scoreboard);
foreach my $team_chunk (@{$team_chunks}) {
	#print "Team:";
	#print Dumper($team_chunk);
	my %team;
	my @players;
	$team{'XpLevel'} = 0;
	foreach my $chunk (@{$team_chunk}) {
		if ($chunk->{'name'} eq "Players") {
			$team{'PlayerNames'} = $chunk->{'value'}->{'value'};
			if ($team{'PlayerNames'} ne "") {
				foreach my $player_name (@{$team{'PlayerNames'}}) {
					next if ($players_counted{lc($player_name)});
					my $player_data = &read_player_json(lc($player_name));
					$team{'XpLevel'} += $player_data->{'XpLevel'};
					$team{'XpTotal'} += $player_data->{'XpTotal'};
					my %p;
					$p{'Name'} = $player_name;
					$p{'XpLevel'} = int($player_data->{'XpLevel'});
					$p{'XpTotal'} = int($player_data->{'XpTotal'});
					push(@players, \%p);
					$players_counted{lc($player_name)} = 1;
				}
			}
		} else {
			$team{$chunk->{'name'}} = $chunk->{'value'};
		}
	}
	$team{'Players'} = \@players;
	if (@players > 0) {
		push(@teams, \%team);
	}
}
my @sort = reverse(sort sortby_xptotal(@teams));
my $out = $json->encode(\@sort);
unless(open(OUTPUT, ">$base_dir/www/teams.json")) {
	 die "Cannot open file for writing at: $base_dir/www/teams.json";
}
print OUTPUT $out;
close(OUTPUT);

exit;


sub read_scoreboard_json {
my ($filedata, $d);
$filedata = `cat $base_dir/www/scoreboard.json`;
$d = $json->decode($filedata);
return($d);
}


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
	} else {
		$player->{$chunk->{'name'}} = $chunk->{'value'};
	}
}
#print "player:\n";
#print Dumper($player);
return($player);
}

sub sortby_name { $a->{'Name'} cmp $b->{'Name'} }
sub sortby_xplevel { $a->{'XpLevel'} <=> $b->{'XpLevel'} }
sub sortby_xptotal { $a->{'XpTotal'} <=> $b->{'XpTotal'} }
