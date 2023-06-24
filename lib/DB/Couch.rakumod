use Cro::HTTP::Client;
use Base64;
use JSON::Fast;
use DB::Couch::Document;

unit class DB::Couch;

has Str:D $.db is required;
has Str:D $.host is required;
has Str:D $.port is required;
has Bool:D $.is-secure is required;

has Hash:D %!headers = (user-agent => 'raku-DB-Couch');

has Cro::HTTP::Client $!client is built;
has Str $!uri is built;

method !make-request[T](Str:D $method, Str:D $location, T:D $body, Associative:D %query --> Promise:D) {
    Cro::HTTP::Client.^methods.first(*.gist eqv $method).(
        $!client,
        $location,
        :%query,
        :%!headers,
        content-type => 'application/json; charset=utf8',
        :$body
    );
}

method add-header(Pair:D $kv) {
    %!headers.append: $kv;
}

method new(Str:D :$username, Str:D :$password, Str:D :$db, Str:D :$host, Int:D :$port, Bool:D :$is-secure = False) {
    my $proto = $is-secure ?? 'https' !! 'http';
    my $auth = 'Basic ' + encode-base64(sprintf('%s:%s', $username, $password));
    self.add-header(authorization => $auth);
    my $uri = sprintf('%s://%s:%d/%s', $proto, $host, $port, $db);
    my $client = Cro::HTTP::Client.new(base-uri => $uri);
    return self.bless(:$host, :$port, :$db, :$is-secure, :$client, :$uri);
}

#|
#| Saves a document, if the document has a `_id` field, it will update instead.
#|
method save(DB::Couch::Document:D $data) {
    self!make-request('post', '', $data); 
}

#|
#| See [save].
#|
method save-many(Array[DB::Couch::Document:D] @data) {
    self!make-request('post', 'bulk_docs', Map.new(docs => @data));
}

#|
#| Perform an explicit update, requires the `_id` and `_rev` of a document.
#| Throws DB::Couch::X::BadRequest unless `_id` and `_rev` are provided.
#|
method update(DB::Couch::Document:D $data) {
    die DB::Couch::X::BadRequest.new unless $data._id and $data._rev;
    self!make-request('put', $data._id, $data);
}
