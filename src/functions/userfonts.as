import flash.text.Font;

/**************************************************************************
 Embedded fonts
 ***************************************************************************/
[Embed(source='assets/userfonts/Akronim_Regular.ttf', 
	fontFamily='_eAkronim',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eAkronim:Class;

[Embed(source='assets/userfonts/Calligraffitti_Regular.ttf', 
	fontFamily='_eCalligraffitti',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eCalligraffitti:Class;

[Embed(source='assets/userfonts/Raleway_Regular.ttf', 
	fontFamily='_eRaleway',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eRaleway:Class;

[Embed(source='assets/userfonts/Vera.ttf', 
	fontFamily='_eVera',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eVera:Class;

[Embed(source='assets/userfonts/comic.ttf', 
	fontFamily='_eComicSans',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eComicSans:Class;

[Embed(source='assets/userfonts/verdana.ttf', 
	fontFamily='_eVerdana',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eVerdana:Class;

[Embed(source='assets/userfonts/daniel.ttf', 
	fontFamily='_eDaniel',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eDaniel:Class;

[Embed(source='assets/userfonts/cour.ttf', 
	fontFamily='_eCourierNew',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eCourierNew:Class;

[Embed(source='assets/userfonts/AlegreyaSans_Regular.ttf', 
	fontFamily='_eAlegreySans',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eAlegreySans:Class;

[Embed(source='assets/userfonts/times.ttf', 
	fontFamily='_eTimesNewRoman',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eTimesNewRoman:Class;

[Embed(source='assets/userfonts/Futura LT Book.ttf', 
	fontFamily='_eFuturaBook',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eFuturaBook:Class;

[Embed(source='assets/userfonts/Muli_Regular.ttf', 
	fontFamily='_eMuli',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eMuli:Class;

[Embed(source='assets/userfonts/IndieFlower.ttf', 
	fontFamily='_eIndieFlower',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eIndieFlower:Class;

[Embed(source='assets/userfonts/OpenSans_Regular.ttf', 
	fontFamily='_eOpenSans',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eOpenSans:Class;

[Embed(source='assets/userfonts/GenBasR.ttf', 
	fontFamily='_eGentiumBasic',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eGentiumBasic:Class;

[Embed(source='assets/userfonts/georgia.ttf', 
	fontFamily='_eGeorgia',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eGeorgia:Class;

[Embed(source='assets/userfonts/BPreplay.otf', 
	fontFamily='_eBPreplay',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eBPreplay:Class;

[Embed(source='assets/userfonts/arial.ttf', 
	fontFamily='_eArial',
	unicodeRange="U+0040-U+00FF", 
	embedAsCFF="true")]     
public var _eArial:Class;

public function RegisterUserFonts():void {
	
	Font.registerFont(_eAkronim);
	Font.registerFont(_eCalligraffitti);
	Font.registerFont(_eRaleway);
	Font.registerFont(_eVera);
	Font.registerFont(_eVerdana);
	Font.registerFont(_eComicSans);
	Font.registerFont(_eDaniel);
	Font.registerFont(_eCourierNew);
	Font.registerFont(_eAlegreySans);
	Font.registerFont(_eTimesNewRoman);
	Font.registerFont(_eFuturaBook);
	Font.registerFont(_eMuli);
	Font.registerFont(_eIndieFlower);
	Font.registerFont(_eOpenSans);
	Font.registerFont(_eGentiumBasic);
	Font.registerFont(_eGeorgia);
	Font.registerFont(_eBPreplay);
	Font.registerFont(_eArial);
}