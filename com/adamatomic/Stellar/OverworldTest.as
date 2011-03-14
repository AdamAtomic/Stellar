package com.adamatomic.Stellar
{
	import com.adamatomic.flixel.*;
	
	import flash.geom.Point;

	public class OverworldTest extends FlxState
	{
		[Embed(source="../../../data/overworld.png")] private var ImgOverworld:Class;
		[Embed(source="../../../data/overworld_mini.png")] private var ImgOverworldMini:Class;
		//[Embed(source="../../../data/box.png")] private var ImgBox:Class;
		[Embed(source="../../../data/player.png")] private var ImgPlayer:Class;
		
		private var _camera:FlxSprite;
		private var _mapString:String;
		private var _map:FlxTilemap;
		private var _status:FlxText;
		private var _status2:FlxText;
		private var _gen:Boolean;
		private var _mapMode:Boolean;
		
		public function OverworldTest()
		{
			super();
			_gen = false;
			_status2 = this.add(new FlxText(0,1,240,20,"C to toggle zelda mode, X to regenerate",0xff000000,null,8)) as FlxText;
			_status2.scrollFactor.x = 0; _status2.scrollFactor.y = 0;
			_status = this.add(new FlxText(0,0,240,20,"C to toggle zelda mode, X to regenerate",0xffffffff,null,8)) as FlxText;
			_status.scrollFactor.x = 0; _status.scrollFactor.y = 0;
			generate();
			_camera = this.add(new FlxSprite(ImgPlayer,_map.width/2-4,_map.height/2-4)) as FlxSprite;
			FlxG.follow(_camera,4);
			FlxG.followBounds(0,0,_map.width,_map.height);
			
			_mapMode = true;
			
			//FlxG.setCursor(ImgBox);
		}
		
		override public function update():void
		{
			if(_gen) { _gen = false; _status.setText("C to toggle zelda mode, X to regenerate"); _status2.setText("C to toggle zelda mode, X to regenerate"); generate(); FlxG.followBounds(0,0,_map.width,_map.height); _camera.x = _map.width/2-4; _camera.y = _map.height/2-4; }
			if(FlxG.justPressed(FlxG.A)) { _gen = true; _mapMode = true; _status.setText("Generating..."); _status2.setText("Generating..."); return; }
			if(FlxG.justPressed(FlxG.B)) { _mapMode = !_mapMode; if(_mapMode) { _map = new FlxTilemap(_mapString,ImgOverworldMini); _camera.x /= 16; _camera.y /= 16; FlxG.followBounds(0,0,_map.width,_map.height); } else { _map = new FlxTilemap(_mapString,ImgOverworld,9); FlxG.followBounds(0,0,_map.width,_map.height); _camera.x *= 16; _camera.y *= 16; }return; }
			if(_mapMode) { super.update(); _map.update(); return; }
			
			//if(FlxG.justPressed(FlxG.LEFT)) _map.x = 0;
			//else if(FlxG.justPressed(FlxG.RIGHT)) _map.x = FlxG.width-_map.width;
			
			//Move player around
			var velocity:int = 120;
			_camera.velocity.x = 0;
			_camera.velocity.y = 0;
			if(FlxG.kUp)
				_camera.velocity.y -= velocity;
			if(FlxG.kDown)
				_camera.velocity.y += velocity;
			if(FlxG.kLeft)
				_camera.velocity.x -= velocity;
			if(FlxG.kRight)
				_camera.velocity.x += velocity;
			if((FlxG.kLeft && FlxG.kUp) || (FlxG.kLeft && FlxG.kDown) || (FlxG.kRight && FlxG.kUp) || (FlxG.kRight && FlxG.kDown)) { _camera.velocity.x *= 0.7; _camera.velocity.y *= 0.7; }
			
			super.update();
			_map.update();

			_map.collide(_camera);
			if(_camera.x < 0) _camera.x = 0;
			if(_camera.y < 0) _camera.y = 0;
			if(_camera.x > _map.width-_camera.width) _camera.x = _map.width-_camera.width;
			if(_camera.y > _map.height-_camera.height) _camera.y = _map.height-_camera.height;
		}
		
		override public function render():void
		{
			_map.render();
			super.render();
		}
		
		private function generate():void
		{
			//Basic generation variables
			var i:uint;
			var j:uint;
			var mapWidth:uint = 512;
			var mapHeight:uint = 256;
			_mapString = "";
			
			//Create a simple heightmap
			var height:FlxArray = new FlxArray();
			for(i = 0; i < mapHeight; i++)
			{
				height.push(new FlxArray());
				for(j = 0; j < mapWidth; j++)
					height[i].push(13);
			}
			
			//Then bombard it with meteorites of varying sizes
			var hits:uint = 1;
			for(i = 11; i > 2; i--)
			{
				for(j = 0; j < hits; j++)
					geomod(height,i);
				hits += (12-i);
			}
			
			//Then add some volcanic activity
			hits = 1;
			for(i = 7; i > 3; i--)
			{
				for(j = 0; j < hits; j++)
					geomod(height,i,false);
				hits += (10-i)*1.8;
			}
			
			//Integerize the heightmap
			for(i = 0; i < mapHeight; i++)
			{
				for(j = 0; j < mapWidth; j++)
					height[i][j] = Math.round(height[i][j]);
			}
			
			//Fill in the heightmap with appropriate basic tiles
			var h:uint;
			var index:uint;
			var prob:Number;
			var water:uint = 2;
			var tileData:FlxArray = new FlxArray();
			for(i = 0; i < mapHeight; i++)
			{
				tileData.push(new FlxArray());
				for(j = 0; j < mapWidth; j++)
				{
					//tileData[i].push(height[i][j]); /*
					h = height[i][j];
					if(h == 0)			  index = 9;	//sea
					else if(h < water)	  index = 8;	//shallows
					else if(h < water+1)  index = 4;   	//sand (shore)
					else if(h < water+2)  index = 2; 	//dirt (plains)
					else if(h < water+5)  index = 1; 	//grass (plains)
					else if(h < water+6)  index = 12; 	//terrace
					else if(h < water+7)  index = 2; 	//dirt (plains)
					else if(h < water+10) index = 1; 	//grass (plains)
					else if(h < water+12) index = 11; 	//forest (plains)
					else if(h < water+13) index = 12; 	//hill (foothills)
					else				  index = 13; 	//mountain
					
					tileData[i].push(index);
					//*/
				}
			}
			
			//Cut ramps in the hills so the highlands are accessible
			var k:uint;
			var l:uint;
			var rx:int;
			var ry:int;
			var orx:uint;
			var ory:uint;
			var rsafe:uint;
			var grid:uint = 8;
			var counts:Array;
			var thickness:uint;
			var rh:uint = mapHeight/grid;
			var rw:uint = mapWidth*.8/grid;
			for(i = 0; i < grid; i++)
			{
				ry = rh*i;
				for(j = 0; j < grid; j++)
				{
					//Figure out how thick the ramp should be
					thickness = Math.random()*4;
					thickness *= 2;
					if(thickness == 0) thickness = 1;
					var halfThick:uint = thickness/2;
					
					//Find a nice place for a ramp
					rx = mapWidth*.1+rw*j;
					rsafe = 256;
					do
					{
						k = ry + Math.random()*rh;
						l = rx + Math.random()*rw;
						if(l < halfThick) l = halfThick;
						if(k < halfThick) k = halfThick;
						if(l >= mapWidth-halfThick) l = mapWidth-halfThick-1;
						if(k >= mapHeight-halfThick) k = mapHeight-halfThick-1;
					} while ((--rsafe > 0) && (height[k][l] != water+5));
					if(rsafe == 0) continue;
					
					//Fire 8 rays from a box centered at the ramp locus
					counts = new Array(); for(rsafe = 0; rsafe < 8; rsafe++) counts.push(0); rsafe = 0;
					while((k-counts[rsafe] > 0) && (height[k-counts[rsafe]][l-halfThick] == water+5)) { counts[rsafe]++; } rsafe++;
					while((k-counts[rsafe] > 0) && (height[k-counts[rsafe]][l+halfThick] == water+5)) { counts[rsafe]++; } rsafe++;
					while((k+counts[rsafe] < mapHeight) && (height[k+counts[rsafe]][l-halfThick] == water+5)) { counts[rsafe]++; } rsafe++;
					while((k+counts[rsafe] < mapHeight) && (height[k+counts[rsafe]][l+halfThick] == water+5)) { counts[rsafe]++; } rsafe++;
					while((l-counts[rsafe] > 0) && (height[k-halfThick][l-counts[rsafe]] == water+5)) { counts[rsafe]++; } rsafe++;
					while((l-counts[rsafe] > 0) && (height[k+halfThick][l-counts[rsafe]] == water+5)) { counts[rsafe]++; } rsafe++;
					while((l+counts[rsafe] < mapWidth) && (height[k-halfThick][l+counts[rsafe]] == water+5)) { counts[rsafe]++; } rsafe++;
					while((l+counts[rsafe] < mapWidth) && (height[k+halfThick][l+counts[rsafe]] == water+5)) { counts[rsafe]++; } rsafe++;
					
					//figure out which rays are the longest, then pad them a bit
					if(counts[1] > counts[0]) counts[0] = counts[1];
					if(counts[3] > counts[2]) counts[2] = counts[3];
					if(counts[5] > counts[4]) counts[4] = counts[5];
					if(counts[7] > counts[6]) counts[6] = counts[7];
					counts[0] += 2; if(k + counts[0] < mapHeight-3) counts[2] += 2; counts[4] += 2; counts[6] += 2;
					
					//Actually draw out the ramps
					orx = l; ory = k;
					if(counts[0] + counts[2] < counts[4] + counts[6]) //Vertical ramp
					{
						if(counts[0] + counts[2] > 16) continue;
						if(thickness == 1)
						{
							for(k = ory - counts[0]; k < ory + counts[2]; k++)
								if(height[k][orx] == water+5) tileData[k][orx] = 2; //dirt
						}
						else
						{
							for(k = ory - counts[0]; k < ory + counts[2]; k++)
								for(l = orx - halfThick; l < orx + halfThick; l++)
									if(height[k][l] == water+5) tileData[k][l] = 2; //dirt
						}
					}
					else //Horizontal ramp
					{
						if(counts[4] + counts[6] > 16) continue;
						if(thickness == 1)
						{
							for(l = orx - counts[4]; l < orx + counts[6]; l++)
								if(height[ory][l] == water+5) tileData[ory][l] = 2; //dirt
						}
						else
						{
							for(k = ory - halfThick; k < ory + halfThick; k++)
								for(l = orx - counts[4]; l < orx + counts[6]; l++)
									if(height[k][l] == water+5) tileData[k][l] = 2; //dirt
						}
					}
				}
			}

			/*
			//Cut some rivers into the landscape
			//TODO: rivers should follow the heightmap down to water, not just toggle however they want!
			var rinc:int;
			var rc:uint;
			var rt:Boolean;
			var ort:Boolean;
			var orinc:int;
			var rtc:uint;
			var wt1:Boolean;
			var wt2:Boolean;
			var numRivers:uint = 2+Math.random()*2;
			var segment:uint = mapHeight*.6 / numRivers;
			for(i = 0; i < numRivers; i++)
			{
				wt1 = false;
				wt2 = false;
				rsafe = 512;
				do
				{
					rx = mapWidth*.2 + Math.random()*mapWidth*.6;
					ry = mapHeight*.2 + i*segment + Math.random()*segment;
				}
				while((tileData[ry][rx] != 13) && (--rsafe > 0));
				
				rc = 0;
				orinc = 1;
				rt = true;
				rtc = 0;
				if(uint(Math.random()*2) == 0)
					orinc = -orinc;
				while(tileData[ry][rx] != 9)
				{
					//Actually paint the tile (or tiles) for this chunk of the river
					orx = rx;
					ory = ry;
					tileData[ry][rx] = 8;
					if(uint(Math.random()*8) == 0) wt1 = !wt1;
					if(wt1)
					{
						if(rt) ry--; else rx--;
						if(rx < 0) rx = mapWidth-1;
						else if(rx >= mapWidth) rx = 0;
						if(ry < 0) ry = mapHeight-1;
						else if(ry >= mapHeight) ry = 0;
						tileData[ry][rx] = 8;
					}
					if(uint(Math.random()*8) == 0) wt2 = !wt2;
					if(wt2)
					{
						if(rt) ry++; else rx++;
						if(rx < 0) rx = mapWidth-1;
						else if(rx >= mapWidth) rx = 0;
						if(ry < 0) ry = mapHeight-1;
						else if(ry >= mapHeight) ry = 0;
						tileData[ry][rx] = 8;
					}
					rx = orx;
					ry = ory;
					
					//Then figure out if we should change direction or not
					if(rt) rinc = orinc;
					
					if(rt)
					{
						rx += rinc;
						if(uint(Math.random()*4) == 0) ry += int(Math.random()*3)-1;
					}
					else
					{
						ry += rinc;
						if(uint(Math.random()*4) == 0) rx += int(Math.random()*3)-1;
					}
					rc++;
					rtc++;
					
					if((rc%16 == 0) && (uint(Math.random()*2) != 0))
					{
						ort = rt;
						rt = true;
						if(uint(Math.random()*2) == 0) rt = false;
						if((ort == rt) && (rtc > 4)) rt = !ort;
						if(ort != rt)
						{
							rtc = 0;
							rinc = 1;
							if(uint(Math.random()*2) == 0)
								rinc = -rinc;
						}
					}
					
					//Keep the value safe for the next pass
					if(rx < 0) rx = mapWidth-1;
					else if(rx >= mapWidth) rx = 0;
					if(ry < 0) ry = mapHeight-1;
					else if(ry >= mapHeight) ry = 0;
				}
			}
			*/

			//TODO: deserts and poles (pretty easy)
			
			//Outcroppings and "gardens" (boulders, trees, and primitive structures)
			//TODO: organize gardens somehow - they should be connected, and maybe spiral out from cities?
			//NOTE: commented out for now as it yields fairly F'd up results
			/*
			var sw:uint = 32;
			var sh:uint = 16;
			var si:uint;
			var sj:uint;
			for(i = 0; i < mapHeight/sh; i++)
			{
				si = i*sh;
				for(j = 0; j < mapWidth/sw; j++)
				{
					sj = j*sw;
					if(uint(Math.random()*8) == 0)
					{
						//Make outcropping
						var outcropX:uint = Math.floor(sj+Math.random()*sw);
						var outcropY:uint = Math.floor(si+Math.random()*sh);
						if(tileData[outcropY][outcropX] < 8)
							geomod(tileData,13,false,new Point(outcropX,outcropY));
					}
					else
					{
						var walls:Boolean = false;
						var block:Boolean = false;
						
						//Check for water in this block
						var hasWater:Boolean = false;
						for(k = 0; (k < sh) && !hasWater; k++)
							for(l = 0; (l < sw) && !hasWater; l++)
								hasWater = tileData[si+k][sj+l] == 9;
						
						if(!hasWater)
						{	//Only put walls and blocks on screens with no water
							var paths:FlxArray = new FlxArray();
							for(k = 0; k < sw*sh; k++) paths.push(false);
							thickness = 2;
							if(Math.random() > 0.35) thickness += 2;
							if(Math.random() > 0.5) thickness += 2;
							if(Math.random() > 0.5) thickness += 2;
							if(Math.random() > 0.65) thickness += 2;
							for(k = 0; k < sh; k++)
							{
								for(l = 0; l < sw; l++)
								{
									//TODO: make non-cross paths too (T bones, Ls, dead ends)
									paths[k*sw+l] = ((k >= (sh-thickness)/2) && (k < (sh+thickness)/2)) || ((l >= (sw-thickness)/2) && (l < (sw+thickness)/2));
								} 
							}
							
							if(Math.random() > 0.85)
							{
								walls = true;
								thickness = 1;
								if(Math.random() > 0.2) thickness++;
								if(Math.random() > 0.9) thickness++;
								if(Math.random() > 0.9) thickness++;
								segment = uint(Math.random()*3);
								if(Math.random() > 0.5)
									index = 13; //stone
								else
									index = 11; //forest
								for(k = 0; k < sh; k++)
								{
									for(l = 0; l < sw; l++)
									{
										if(paths[k*sw+l]) continue;
										if((tileData[si+k][sj+l] >= 8) && (tileData[si+k][sj+l] != 11) && (tileData[si+k][sj+l] != 12) && (tileData[si+k][sj+l] != 13)) continue;
										if((k < thickness) || (k >= sh-thickness) || (l < thickness) || (l >= sw-thickness))
											tileData[si+k][sj+l] = index;
									}
								}
							}
							
							if((walls && (Math.random() < 0.4)) || (Math.random() > 0.8))
							{
								block = true;
								var blockWidth:uint = 4+Math.random()*(sw-4)/4;
								blockWidth *= 2;
								var blockHeight:uint = 4+Math.random()*(sh-4)/4;
								blockHeight *= 2;
								if(!walls) { blockWidth *= 2; blockHeight *= 2; }
								if(Math.random() > 0.65)
								{
									if(Math.random() > 0.5)
										index = 13; //stone
									else
										index = 14; //structure
								}
								else
									index = 11; //forest
								var carePaths:Boolean = Math.random() > 0.5;
								for(k = (sh-blockHeight)/2; k < (sh-blockHeight)/2 + blockHeight; k++)
								{
									for(l = (sw-blockWidth)/2; l < (sw-blockWidth)/2 + blockWidth; l++)
									{
										if(carePaths && paths[k*sw+l]) continue;
										if((tileData[si+k][sj+l] >= 8) && (tileData[si+k][sj+l] != 11) && (tileData[si+k][sj+l] != 12)) continue;
										tileData[si+k][sj+l] = index;
									}
								}
							}
						}
						if(!walls && (Math.random() > 0.65))
						{
							var xGap:uint = sw/2/(1+Math.random()*4);
							var yGap:uint = sh/2/(1+Math.random()*2);
							if(Math.random() > 0.65)
							{
								if(Math.random() > 0.5)
									index = 13; //stone
								else
									index = 14; //structure
							}
							else
								index = 11; //forest
							for(k = yGap; k <= sh-yGap; k++)
							{
								for(l = xGap; l <= sw-xGap; l++)
								{
									if((tileData[si+k][sj+l] >= 8) && (tileData[si+k][sj+l] != 11) && (tileData[si+k][sj+l] != 12)) continue;
									var kok:Boolean = false;
									var lok:Boolean = false;
									if(k < sh/2)
										kok = ((sh/2-k) > 0) && ((sh/2-k)%yGap == 0);
									else
										kok = ((k-sh/2) > 0) && ((k-sh/2)%yGap == 0);
									if(l < sw/2)
										lok = ((sw/2-l) > 0) && ((sw/2-l)%xGap == 0);
									else
										lok = ((l-sw/2) > 0) && ((l-sw/2)%xGap == 0);
									if(kok && lok) tileData[si+k][sj+l] = index;
								}
							}
						} 
					}
				}
			}
			*/

			//TODO: Cities, roads, & bridges?
			
			//Dump data to string and load it into the tilemap
			for(i = 0; i < mapHeight; i++)
			{
				for(j = 0; j < mapWidth; j++)
				{
					_mapString += tileData[i][j];
					if(j < mapWidth-1) _mapString += ",";
				}
				_mapString += "\n";
			}
			_map = new FlxTilemap(_mapString,ImgOverworldMini,9);
		}
		
		private function geomod(Map:FlxArray,Power:uint,Dig:Boolean=true,Outcrop:Point=null):void
		{
			var i:int = 0;
			var j:int = 0;
			var im:int = 0;
			var jm:int = 0;
			var distance:int;
			var radius:uint = Power*Power;
			if(Outcrop != null) radius = 4+Math.random()*12;
			var radius2:uint = radius*radius;
			var epiX:uint;
			var epiY:uint;
			if(Outcrop != null)
			{
				epiX = Outcrop.x;
				epiY = Outcrop.y;
			}
			else
			{
				epiX = uint(Math.random()*Map[0].length);
				epiY = uint(Math.random()*Map.length);
				if(Dig && (Power > 7)) epiX = 0;
				else if(!Dig)
				{
					if(Power > 5)
						epiX = Map[0].length/5 + uint(Math.random()*(Map[0].length-2*Map[0].length/5));
					else if(uint(Math.random()*4) == 0)
					{
						epiX = Map[0].length/5 + uint(Math.random()*(Map[0].length-2*Map[0].length/5));
						epiY = 0;
					}
				}
			}
			var it:int = epiY+radius;
			var jt:int = epiX+radius;
			for(i = epiY-radius; i < it; i++)
			{
				im = i;
				if(im < 0) im += Map.length;
				else if(im >= Map.length) im -= Map.length;
				for(j = epiX-radius; j < jt; j++)
				{
					distance = dist(j,i,epiX,epiY);
					if(distance < radius)
					{
						jm = j;
						if(jm < 0) jm += Map[0].length;
						else if(jm >= Map[0].length) jm -= Map[0].length;
						if(Dig) Map[im][jm] -= Power*((radius2-(distance*distance))/radius2);
						else if(Outcrop != null) Map[im][jm] = (Math.random() > ((radius2-((distance-radius)*(distance-radius)))/radius2))?Power:Map[im][jm];
						else	Map[im][jm] += Power*(((distance-radius)*(distance-radius))/radius2);
						if(Map[im][jm] < 0) Map[im][jm] = 0;
						if(Map[im][jm] > 15) Map[im][jm] = 15;
					}
				}
			}
		}
		
		private function dist(X1:int,Y1:int,X2:int,Y2:int):Number
		{
			return Math.sqrt((X1-X2)*(X1-X2)+(Y1-Y2)*(Y1-Y2));
		}
	}
}
