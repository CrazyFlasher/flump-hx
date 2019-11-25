//
// flump-runtime

package flump.display;


class MoviePlayerNode
{
    public var movie:Movie;
    public var player:MoviePlayer;
    public var prev:MoviePlayerNode;
    public var next:MoviePlayerNode;

    @:allow(flump.display)
    private function new(movie:Movie, player:MoviePlayer)
    {
        this.movie = movie;
        this.player = player;
    }
}


