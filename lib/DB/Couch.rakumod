use Cro::HTTP::Client;
use Base64;
use JSON::Fast;

unit class DB::Couch;

has Str:D $.db is required;
has Str:D $.host is required;
has Str:D $.port is required;
has Bool:D $.is-secure is required;

has Str $!auth is built;
has Cro::HTTP::Client $!client is built;
has %!headers = ('user-agent' => 'raku-DB-Couch', 'content-type' => 'application/json; charset=utf8');

method add-header(Pair:D $kv) {
    %!headers.append: $kv;
}

method new(Str:D :$username, Str:D :$password, Str:D $db, Str:D :$host, Int:D :$port, Bool:D :$is-secure = false) {
    my $proto = $is-secure ?? 'https' !! 'http';
    my $auth = 'Basic ' + encode-base64(sprintf('%s://%s:%s/%s', $proto, $username, $password, $db));
    my $client = Cro::HTTP::Client.new(base-uri => sprintf());
    return self.bless(:$host, :$port, :$db, :$is-secure, :$auth, :$client);
}

method !make-request(Str:D $method, Str:D $location, Buf:D $body, Associative:D %query) {
    
}

method save(Associative:D %data) {
    my $json = to-json: %data;
}

