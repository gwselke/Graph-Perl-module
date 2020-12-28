use strict; use warnings;
use Test::More tests => 36;

use Graph::Undirected;
use Graph::Directed;

my $g0 = Graph::Undirected->new;
my $g1 = Graph::Directed->new;

my @EDGES = (
    [qw(a b)], [qw(a c)], [qw(a d)], [qw(a e)], [qw(a f)],
    [qw(b c)], [qw(c b)], [qw(b d)], [qw(d b)],
    [qw(b e)], [qw(e b)], [qw(b f)], [qw(f b)],
    [qw(d c)], [qw(e c)], [qw(f c)],
    [qw(d e)], [qw(d f)],
    [qw(e f)],
);
$g0->add_edge(@$_) for @EDGES;
$g1->add_edge(@$_) for @EDGES;

is($g0, 'a=b,a=c,a=d,a=e,a=f,b=c,b=d,b=e,b=f,c=d,c=e,c=f,d=e,d=f,e=f')
    for 1..10;
is($g1, 'a-b,a-c,a-d,a-e,a-f,b-c,b-d,b-e,b-f,c-b,d-b,d-c,d-e,d-f,e-b,e-c,e-f,f-b,f-c')
    for 1..10;

is $g0->[ Graph::_V ]->stringify, <<'EOF';
Graph::AdjacencyMap::Light arity=1 flags: _LIGHT
   a    0
   b    1
   c    2
   d    3
   e    4
   f    5
EOF
is $g0->[ Graph::_E ]->stringify, <<'EOF';
Graph::AdjacencyMap::Light arity=2 flags: _UNORD|_LIGHT
 to:    1    2    3    4    5
   0    1    1    1    1    1
   1         1    1    1    1
   2              1    1    1
   3                   1    1
   4                        1
EOF

is $g1->[ Graph::_V ]->stringify, <<'EOF';
Graph::AdjacencyMap::Light arity=1 flags: _LIGHT
   a    0
   b    1
   c    2
   d    3
   e    4
   f    5
EOF
is $g1->[ Graph::_E ]->stringify, <<'EOF';
Graph::AdjacencyMap::Light arity=2 flags: _LIGHT
 to:    1    2    3    4    5
   0    1    1    1    1    1
   1         1    1    1    1
   2    1                    
   3    1    1         1    1
   4    1    1              1
   5    1    1               
EOF

$g1->set_edge_attribute(qw(a b weight 2));
$g1->set_vertex_attribute(qw(a size 2));
is $g1->[ Graph::_V ]->stringify, <<'EOF';
Graph::AdjacencyMap::Light arity=1 flags: _LIGHT
   a 0,{'size' => '2'}
   b    1
   c    2
   d    3
   e    4
   f    5
EOF
is $g1->[ Graph::_E ]->stringify, <<'EOF';
Graph::AdjacencyMap::Light arity=2 flags: _LIGHT
 to:    1    2    3    4    5
   0 {'weight' => '2'}    1    1    1    1
   1         1    1    1    1
   2    1                    
   3    1    1         1    1
   4    1    1              1
   5    1    1               
EOF

my $g2 = Graph::Directed->new(multivertexed => 1, multiedged => 1);
$g2->add_edge(qw(a c));
$g2->set_edge_attribute_by_id(qw(a b x weight 2));
$g2->set_vertex_attribute_by_id(qw(a z other 5));
$g2->set_vertex_attribute_by_id(qw(a 0 other2 6));
is $g2->[ Graph::_V ]->stringify, <<'EOF';
Graph::AdjacencyMap arity=1 flags: _MULTI
   a 0,{'0' => {'other2' => '6'},'z' => {'other' => '5'}}
   b 2,{'0' => {}}
   c 1,{'0' => {}}
EOF
is $g2->[ Graph::_E ]->stringify, <<'EOF';
Graph::AdjacencyMap arity=2 flags: _MULTI
 to:    1    2
   0 {'0' => {}} {'x' => {'weight' => '2'}}
EOF

{
  my $null = Graph->new;
  ok($null, "boolify wins over stringify for empty graph");
  ok($g0, "boolify");
}

{
  # Inspired by
  # rt.cpan.org 93278: SPT_Dijkstra sometimes returns a wrong answer
  use Graph::Directed;
  my $null = Graph::Directed->new;
  for ( 1..5 ) {  # Adds _NOTHING_ -- but dies.
    eval { $null->add_vertex };
    like($@, qr/Graph::add_vertex: use add_vertices for more than one vertex/);
  }
  is($null, "");
}
