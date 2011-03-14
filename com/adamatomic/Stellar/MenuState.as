package com.adamatomic.Stellar
{
	import com.adamatomic.flixel.*;

	public class MenuState extends FlxState
	{
		[Embed(source="../../../data/cursor.png")] private var ImgCursor:Class;
		
		override public function MenuState():void
		{
			this.add(new FlxText(140,20,200,40,"stellar",0xffff0000,null,32,"center"));
			this.add(new FlxButton(140,80,new FlxSprite(null,0,0,false,false,200,40,0x00000000),onOverworld,new FlxSprite(null,0,0,false,false,200,40,0x7fffffff),new FlxText(0,8,200,40,"overworld",0xffffffff,null,16,"center"),null));
			FlxG.setCursor(ImgCursor);
		}
		
		private function onOverworld():void
		{
			FlxG.switchState(OverworldTest);
		}
	}
}
