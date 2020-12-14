use strict; use warnings;
use Test::More tests => 65;

use Graph;
my $g = Graph->new(multiedged => 1);

is( $g->get_edge_count('a', 'b'), 0 );

ok( $g->add_edge_by_id('a', 'b', 'red') );

is( $g->get_edge_count('a', 'b'), 1 );

ok( $g->has_edge('a', 'b') );
ok(!$g->has_edge('b', 'c') );

ok( $g->has_edge('a', 'b') );
ok(!$g->has_edge('b', 'c') );

ok( $g->has_edge_by_id('a', 'b', 'red') );
ok(!$g->has_edge_by_id('a', 'b', 'blue') );

ok( $g->has_edge_by_id('a', 'b', 'red') );
ok(!$g->has_edge_by_id('a', 'b', 'blue') );

$g->add_edge_by_id('a', 'b', 'blue');

is( $g->get_edge_count('a', 'b'), 2 );

ok( $g->has_edge_by_id('a', 'b', 'blue') );
ok( $g->has_edge_by_id('a', 'b', 'red') );

$g->add_edge('a', 'b');
ok( $g->has_edge('a', 'b') );
ok(!$g->has_edge('b', 'c') );

is( $g->get_edge_count('a', 'b'), 3 );

is( $g->add_edge_get_id('a', 'b'), 1);
is( $g->add_edge_get_id('a', 'b'), 2);
is( $g->add_edge_get_id('a', 'b'), 3);

is( $g->get_edge_count('a', 'b'), 6 );

ok( $g->delete_edge_by_id('a', 'b', 'blue') );

ok(!$g->has_edge_by_id('a', 'b', 'blue') );
ok( $g->has_edge_by_id('a', 'b', 'red') );

ok(!$g->delete_edge_by_id('a', 'b', 'green') );

ok(!$g->has_edge_by_id('a', 'b', 'blue') );
ok( $g->has_edge_by_id('a', 'b', 'red') );
ok(!$g->has_edge_by_id('a', 'b', 'green') );

ok( $g->delete_edge_by_id('a', 'b', 'red') );

my @i = sort $g->get_multiedge_ids('a', 'b');

is("@i", "0 1 2 3");

ok( $g->has_edge_by_id('a', 'b', '0') );
ok( $g->has_edge_by_id('a', 'b', '1') );
ok( $g->has_edge_by_id('a', 'b', '2') );
ok( $g->has_edge_by_id('a', 'b', '3') );

is( $g->get_edge_count('a', 'b'), 4 );

is( $g->delete_edge('a', 'b'), 'a,b' );

ok(!$g->has_edge_by_id('a', 'b', '0') );
ok(!$g->has_edge_by_id('a', 'b', '1') );
ok(!$g->has_edge_by_id('a', 'b', '2') );
ok(!$g->has_edge_by_id('a', 'b', '3') );

is( $g->get_multiedge_ids('a', 'b'), undef );

is( $g->add_edge_get_id('a', 'b'), 0);
ok( $g->delete_edge_by_id('a', 'b', 0) ); # exercise deleting last one

my $h = Graph->new;

eval { $h->add_edge_by_id("b", "c", "black") };
like($@, qr/add_edge_by_id: expected multiedged/);

eval { $h->has_edge_by_id("b", "c", "black") };
like($@, qr/has_edge_by_id: expected multiedged/);

eval { $h->get_multiedge_ids() };
like($@, qr/get_multiedge_ids: expected multiedged/);

eval { $h->delete_edge_by_id("b", "c", "black") };
like($@, qr/delete_edge_by_id: expected multiedged/);

$h = Graph->new(multiedged => 1, hyperedged => 1);

ok( $h->add_edge_by_id('u', 'v', 'w', 'genghis') );
ok( $h->add_edge_by_id('u', 'khan') );

ok( $h->has_edge('u' ,'v', 'w') );
ok(!$h->has_edge('u' ,'v') );
ok( $h->has_edge('u') );
ok(!$h->has_edge('v') );
ok(!$h->has_edge() );

ok( $h->has_edge_by_id('u', 'v', 'w', 'genghis') );
ok( $h->has_edge_by_id('u', 'khan') );

my $g1 = Graph->new;

ok ( !$g1->multiedged );

my $g2 = Graph->new( multiedged => 1 );

ok (  $g2->multiedged );

eval { my $g3 = Graph->new( multiedged => 1, countedged => 1 ) };

like ( $@, qr/both countedged and multiedged/ );

{
  my $g4a = Graph->new(undirected => 1, multiedged => 1);

  $g4a->add_edge_get_id("a1","s1");
  $g4a->add_edge_get_id("a2","s2");
  $g4a->add_edge_get_id("a2","a1"); # Last.

  my @e = $g4a->edges;
  is(@e, 3);

  my $g4b = Graph->new(undirected => 1, multiedged => 1);

  $g4b->add_edge_get_id("a2","a1");  # First.
  $g4b->add_edge_get_id("a1","s1");
  $g4b->add_edge_get_id("a2","s2");

  @e = $g4b->edges;
  is(@e, 3);
}

{
    # rt.cpan.org 107567 edges() missing on undirected multiedged graph
    my $graph = Graph->new(undirected => 1, multiedged => 1);
    $graph->add_vertex(0);
    $graph->add_vertex(1);
    $graph->add_edge(1,0);
    is($graph, "0=1");
    my @edges = $graph->edges;
    is(scalar @edges, 1);
    is_deeply(@edges, [0, 1]) or diag explain \@edges;
    is($graph->edges, 1);
}
