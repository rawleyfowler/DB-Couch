unit class DB::Couch::X::Unauthorized is Exception;

method message { "Invalid credentials provided for operation" }
