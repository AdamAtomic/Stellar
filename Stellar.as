package {
	import com.adamatomic.flixel.FlxGame;
	import com.adamatomic.Stellar.MenuState;
	
	[SWF(width="960", height="540", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]

	public class Stellar extends FlxGame
	{
		public function Stellar():void
		{
			super(480,270,MenuState,2,0xff000000,false,0xffff0000);
		}
	}
}
