//
// flump-runtime

package flump.mold;


class TextureGroupMold
{
    public var scaleFactor : Int;
    public var atlases : Array<AtlasMold> = [];
    
    public static function fromJSON(o : Dynamic) : TextureGroupMold
    {
        var mold : TextureGroupMold = new TextureGroupMold();
        mold.scaleFactor = require(o, "scaleFactor");
        for (atlas/* AS3HX WARNING could not determine type for var: atlas exp: ECall(EIdent(require),[EIdent(o),EConst(CString(atlases))]) type: null */ in require(o, "atlases"))
        {
            mold.atlases.push(AtlasMold.fromJSON(atlas));
        }
        return mold;
    }
    
    public function toJSON(_ : Dynamic) : Dynamic
    {
        return {
            scaleFactor : scaleFactor,
            atlases : atlases
        };
    }
    
    public function toXML() : FastXML
    {
        var xml : FastXML = FastXML.parse("<textureGroup scaleFactor={scaleFactor}/>");
        for (atlas in atlases)
        {
            xml.node.appendChild.innerData(atlas.toXML());
        }
        return xml;
    }

    public function new()
    {
    }
}

