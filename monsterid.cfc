<cfcomponent displayname="monsterid">
<!---	
	Copyright 2011 Joshua F. Rountree
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
	   http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
	
	==================================
	SPECIAL THANKS
	
	Another CFC for those that enjoy the MonsterID's icon system designed by Andreas Gohr.
	http://www.splitbrain.org/projects/monsterid
	
	I've converted this to ColdFusion for people to enjoy!
	
	The images are licensed under Creative Commons Attribution 2.5 License
--->

	<cfset $spriteZ = 0 />
	
	<cffunction name="init" access="public" output="no" returntype="monsterid">
		<cfargument name="icondir" type="string" default="#getDirectoryFromPath(getCurrentTemplatePath()) & 'monsters/'#" hint="absolute path where you want to store icons" required="no" />
		<cfargument name="webpath" type="string" default="#getWebPath() & 'monsters/'#" hint="example: /images/monsterid/" required="no" />
		<cfargument name="bodyparts" type="string" default="#getDirectoryFromPath(getCurrentTemplatePath()) & 'parts/'#" hint="absolute path where you want to store icons" required="no" />
		
		<cfset variables.icondir = arguments.icondir />
		<cfif right(variables.icondir,1) NEQ "\" AND right(variables.icondir,1) NEQ "/">
			<cfset variables.icondir = variables.icondir & "\" />
		</cfif>
		
		<cfset variables.webpath = arguments.webpath />
		<cfif right(variables.webpath,1) NEQ "/">
			<cfset variables.webpath = variables.webpath & "/" />
		</cfif>
		
		<cfset variables.bodyparts = arguments.bodyparts />
		<cfif right(variables.bodyparts,1) NEQ "\" AND right(variables.bodyparts,1) NEQ "/">
			<cfset variables.bodyparts = variables.bodyparts & "\" />
		</cfif>
		
		<!--- CREATES DIRECTORY IF IT DOESN'T EXIST --->
		<cfif NOT DirectoryExists(arguments.icondir)>
			<cfdirectory action="create" directory="#variables.icondir#">
		</cfif>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="get_monsterid" access="public" output="no" hint="returns a file path or web path to the icon created or cached">
		<cfargument name="str" type="string" required="yes" hint="any string you desire such as email address, username, ipaddress, etc." />
		<cfargument name="size" type="string" required="yes" hint="sq size in pixels of image" />
		<cfargument name="returnMode" type="string" required="no" default="url" hint="returns either 'physical' or 'absolute'" />
		
		<cfset var theModes = "absolute,physical" />
		<cfset var theStr = lcase(arguments.str) />
		<cfset var theHash = "" />
		<cfset var filePath = "" />
		<cfset var fileName = "" />
		<cfset var theSize = arguments.size />
		<cfset var returnPath = "" />
		
		<cfif NOT listFindNoCase(theModes,trim(arguments.returnMode))>
			<cfthrow message="You entered an invalid mode for your returnMode argument. Valid options are: #theModes#" />
		</cfif>
		
		<!--- check if already hashed --->
		<cfif isAlphanumeric(theStr) AND len(theStr) EQ 128>
			<!--- probably already an MD5 hash and we will leave it at that --->
			<cfset theHash = theStr />
			
		<cfelse>
			<!--- we will use the util function getHash() from the bottom of the cfc to make has / lcase cleaner --->
			
			<cfset theHash = getHash(theStr) />
		</cfif>
		
		<cfset fileName = theHash & "_#theSize#.png" />
		<cfset filePath = variables.icondir & fileName />
		
		<cfswitch expression="#arguments.returnMode#">
			<cfcase value="absolute">
				<cfset returnPath = "#variables.webpath##fileName#" />
			</cfcase>
			<cfcase value="physical">
				<cfset returnPath = "#variables.icondir##fileName#" />
			</cfcase>
		</cfswitch>
		
		
		<cfif NOT fileExists(filePath)>
			<!--- DOESN'T EXIST AND NEEDS GENERATED --->
			
			<cfscript>
			// init random seed
			if(len(theHash)) {
				Randomize(hexdec(substr(theHash,0,6)));
			}
		
			// throw the dice for body parts
			$parts = {
				legs = RandRange(1,5),
				hair = RandRange(1,5),
				arms = RandRange(1,5),
				body = RandRange(1,15),
				eyes = RandRange(1,15),
				mouth= RandRange(1,10)}
			;
			// create backgound
			$monster = ImageNew("",120, 120,"argb");
		
			// add parts
			
			for($part in $parts){
			
				$file = variables.bodyparts & $part & "_" & $parts[$part] & ".png";
		
				$im = ImageNew($file);
				cpSection = ImageCopy($im,0,0,120,120);
				ImagePaste($monster,cpSection,0,0);
				$im = '';
				
				// color the body
				if($part == 'body'){
					//ImageSetDrawingColor($monster, "#RandRange(20,235)#, #RandRange(20,235)#, #RandRange(20,235)#");
				}
			}
		
			// restore random seed
			/*if(theHash) srand();*/
		
			// resize if needed, then output
			$out = ImageNew("",theSize,theSize,"rgb","#RandRange(200,235)#,#RandRange(200,235)#,#RandRange(200,235)#");
			ImageSetAntialiasing($out,"on");
			cpSection = ImageCopy($monster,0,0,120,120);
			ImageResize(cpSection, theSize,theSize);
			ImagePaste($out,cpSection,0,0);
			</cfscript>
			<cfimage action="write" source="#$out#" destination="#filePath#"  />
		</cfif>
		
		<cfreturn returnPath />
	</cffunction>
	
	<cffunction name="getsprite" output="no" access="private" hint="generates a cf image shape for one of the 9 points">
		<cfargument name="shape" type="string" required="yes" />
		<cfargument name="R" type="string" required="yes" />
		<cfargument name="G" type="string" required="yes" />
		<cfargument name="B" type="string" required="yes" />
		<cfargument name="rotation" type="string" required="yes" />
		
		<cfset var $shape = arguments.shape />
		<cfset var $R = arguments.R />
		<cfset var $G = arguments.G />
		<cfset var $B = arguments.B />
		<cfset var $rotation = arguments.rotation />
		<cfset var $sprite = ImageNew("",$spriteZ,$spriteZ,"argb") />
		<cfscript>
		ImageSetAntialiasing($sprite,"on");
		
		/*$fg=imagecolorallocate($sprite,$R,$G,$B);
		$bg=imagecolorallocate($sprite,255,255,255);
		imagefilledrectangle($sprite,0,0,$spriteZ,$spriteZ);*/
		ImageSetDrawingColor($sprite,$R & "," & $G & "," & $B);
		
		switch($shape) {
			case 1: // triangle
				$shape=[
					0.5,1,
					1,0,
					1,1
				];
				break;
			case 2: // parallelogram
				$shape=[
					0.5,0,
					1,0,
					0.5,1,
					0,1
				];
				break;
			case 3: // mouse ears
				$shape=[
					0.5,0,
					1,0,
					1,1,
					0.5,1,
					1,0.5
				];
				break;
			case 4: // ribbon
				$shape=[
					0,0.5,
					0.5,0,
					1,0.5,
					0.5,1,
					0.5,0.5
				];
				break;
			case 5: // sails
				$shape=[
					0,0.5,
					1,0,
					1,1,
					0,1,
					1,0.5
				];
				break;
			case 6: // fins
				$shape=[
					1,0,
					1,1,
					0.5,1,
					1,0.5,
					0.5,0.5
				];
				break;
			case 7: // beak
				$shape=[
					0,0,
					1,0,
					1,0.5,
					0,0,
					0.5,1,
					0,1
				];
				break;
			case 8: // chevron
				$shape=[
					0,0,
					0.5,0,
					1,0.5,
					0.5,1,
					0,1,
					0.5,0.5
				];
				break;
			case 9: // fish
				$shape=[
					0.5,0,
					0.5,0.5,
					1,0.5,
					1,1,
					0.5,1,
					0.5,0.5,
					0,0.5
				];
				break;
			case 10: // kite
				$shape=[
					0,0,
					1,0,
					0.5,0.5,
					1,0.5,
					0.5,1,
					0.5,0.5,
					0,1
				];
				break;
			case 11: // trough
				$shape=[
					0,0.5,
					0.5,1,
					1,0.5,
					0.5,0,
					1,0,
					1,1,
					0,1
				];
				break;
			case 12: // rays
				$shape=[
					0.5,0,
					1,0,
					1,1,
					0.5,1,
					1,0.75,
					0.5,0.5,
					1,0.25
				];
				break;
			case 13: // double rhombus
				$shape=[
					0,0.5,
					0.5,0,
					0.5,0.5,
					1,0,
					1,0.5,
					0.5,1,
					0.5,0.5,
					0,1
				];
				break;
			case 14: // crown
				$shape=[
					0,0,
					1,0,
					1,1,
					0,1,
					1,0.5,
					0.5,0.25,
					0.5,0.75,
					0,0.5,
					0.5,0.25
				];
				break;
			case 15: // radioactive
				$shape=[
					0,0.5,
					0.5,0.5,
					0.5,0,
					1,0,
					0.5,0.5,
					1,0.5,
					0.5,1,
					0.5,0.5,
					0,1
				];
				break;
			default: // tiles
				$shape=[
					0,0,
					1,0,
					0.5,0.5,
					0.5,0,
					0,0.5,
					1,0.5,
					0.5,1,
					0.5,0.5,
					0,1
				];
				break;
		}
		Xcoords = ArrayNew(1);
		Ycoords = ArrayNew(1);
		xpos = 0;
		ypos = 0;
		
		for ($i=1; $i <= arrayLen($shape); $i++) {
			if ($i mod 2 eq 1) {
				xpos = xpos+1;
				ArrayAppend(Xcoords,$shape[$i]*$spriteZ);
			} else {
				ypos = ypos+1;
				ArrayAppend(Ycoords,$shape[$i]*$spriteZ);
			}
		}
		
			
		ImageDrawLines($sprite,Xcoords,Ycoords,"yes","yes");
		/* apply ratios 
		for ($i=0;$i<count($shape);$i++)
			$shape[$i]=$shape[$i]*$spriteZ;
			imagefilledpolygon($sprite,$shape,count($shape)/2,$fg);
			/* rotate the sprite 
			for ($i=0;$i<$rotation;$i++)
				$sprite=imagerotate($sprite,90,$bg);
				*/
		</cfscript>
		<cfreturn $sprite />
	</cffunction>
	
	<cffunction name="getcenter" output="no" access="private" hint="get center point shape">
		<cfargument name="shape" type="string" required="yes" />
		<cfargument name="fR" type="string" required="yes" />
		<cfargument name="fG" type="string" required="yes" />
		<cfargument name="fB" type="string" required="yes" />
		<cfargument name="bR" type="string" required="yes" />
		<cfargument name="bG" type="string" required="yes" />
		<cfargument name="bB" type="string" required="yes" />
		<cfargument name="usebg" type="string" required="yes" />
		
		<cfset var $shape = arguments.shape />
		<cfset var $fR = arguments.fR />
		<cfset var $fG = arguments.fG />
		<cfset var $fB = arguments.fB />
		<cfset var $bR = arguments.bR />
		<cfset var $bG = arguments.bG />
		<cfset var $bB = arguments.bB />
		<cfset var $usebg = arguments.usebg />
		<cfset var $sprite = ImageNew("",$spriteZ,$spriteZ,"argb") />
		<cfscript>
			ImageSetAntialiasing($sprite,"on");
			
			/*$fg=imagecolorallocate($sprite,$R,$G,$B);
			$bg=imagecolorallocate($sprite,255,255,255);
			imagefilledrectangle($sprite,0,0,$spriteZ,$spriteZ);*/
			ImageSetDrawingColor($sprite,$fR & "," & $fG & "," & $fB);
			
			/*$fg=imagecolorallocate($sprite,$fR,$fG,$fB);*/
			/* make sure there's enough contrast before we use background color of side sprite
			if ($usebg>0 && (abs($fR-$bR)>127 || abs($fG-$bG)>127 || abs($fB-$bB)>127))
				$bg=imagecolorallocate($sprite,$bR,$bG,$bB);
			else
				$bg=imagecolorallocate($sprite,255,255,255);
			imagefilledrectangle($sprite,0,0,$spriteZ,$spriteZ,$bg); */
			
			switch($shape) {
				case 1: // empty
					$shape=[];
					break;
				case 2: // fill
					$shape=[
						0,0,
						1,0,
						1,1,
						0,1
					];
					break;
				case 3: // diamond
					$shape=[
						0.5,0,
						1,0.5,
						0.5,1,
						0,0.5
					];
					break;
				case 4: // reverse diamond
					$shape=[
						0,0,
						1,0,
						1,1,
						0,1,
						0,0.5,
						0.5,1,
						1,0.5,
						0.5,0,
						0,0.5
					];
					break;
				case 5: // cross
					$shape=[
						0.25,0,
						0.75,0,
						0.5,0.5,
						1,0.25,
						1,0.75,
						0.5,0.5,
						0.75,1,
						0.25,1,
						0.5,0.5,
						0,0.75,
						0,0.25,
						0.5,0.5
					];
					break;
				case 6: // morning star
					$shape=[
						0,0,
						0.5,0.25,
						1,0,
						0.75,0.5,
						1,1,
						0.5,0.75,
						0,1,
						0.25,0.5
					];
					break;
				case 7: // small square
					$shape=[
						0.33,0.33,
						0.67,0.33,
						0.67,0.67,
						0.33,0.67
					];
					break;
				case 8: // checkerboard
					$shape=[
						0,0,
						0.33,0,
						0.33,0.33,
						0.66,0.33,
						0.67,0,
						1,0,
						1,0.33,
						0.67,0.33,
						0.67,0.67,
						1,0.67,
						1,1,
						0.67,1,
						0.67,0.67,
						0.33,0.67,
						0.33,1,
						0,1,
						0,0.67,
						0.33,0.67,
						0.33,0.33,
						0,0.33
					];
					break;
			}
			/* apply ratios */
			Xcoords = ArrayNew(1);
			Ycoords = ArrayNew(1);
			xpos = 0;
			ypos = 0;
			
			for ($i=1; $i <= arrayLen($shape); $i++) {
				if ($i mod 2 eq 1) {
					xpos = xpos+1;
					ArrayAppend(Xcoords,$shape[$i]*$spriteZ);
				} else {
					ypos = ypos+1;
					ArrayAppend(Ycoords,$shape[$i]*$spriteZ);
				}
			}
			
				
			ImageDrawLines($sprite,Xcoords,Ycoords,"yes","yes");
		</cfscript>
		
		<cfreturn $sprite />
	</cffunction>
	
	<!--- UTILITY FUNCTIONS --->
	<cffunction name="getHash" access="public" output="no" hint="allows you to get the hash with one call and also applies LCASE">
		<cfargument name="string" type="string" required="yes" />
		
		<cfset var theHash = lcase(HASH(arguments.string,'MD5')) />
		
		<cfreturn theHash />
	</cffunction>	
	
	<cffunction name="hexdec" access="public" output="no">
		<cfargument name="str" type="string" required="yes" />
		
		<cfreturn InputBaseN(str, 16) />
	</cffunction>
	
	<cffunction name="substr" access="public" output="no">
		<cfargument name="str" type="string" required="yes" />
		<cfargument name="start" type="string" required="yes" />
		<cfargument name="count" type="string" required="yes" />
		
		<cfreturn mid(arguments.str,arguments.start+1,arguments.count) />
	</cffunction>
	
	<cfscript>
	/**
	* Checks if a string is alphanumeric
	*
	* @param str      String you want to check.
	* @return Returns a Boolean value.
	* @author Marcus Raphelt (cflib@raphelt.de)
	* @version 1, November 2, 2001
	*/
	function IsAlphanumeric(str) {
	if (REFindNoCase("[^a-z0-9]", str) eq 0)
	return true;
	else
	return false;
	}
	</cfscript>
	
	<cffunction name="getWebPath" access="public" output="false" returntype="string" hint="Gets the absolute path to the current web folder.">
		<cfargument name="url" required="false" default="#getPageContext().getRequest().getRequestURI()#" hint="Defaults to the current path_info" />
		<cfargument name="ext" required="false" default="\.(cfml?.*|html?.*|[^.]+)" hint="Define the regex to find the extension. The default will work in most cases, unless you have really funky urls like: /folder/file.cfm/extra.path/info" />
		<!---// trim the path to be safe //--->
		<cfset var sPath = trim(arguments.url) />
		<!---// find the where the filename starts (should be the last wherever the last period (".") is) //--->
		<cfset var sEndDir = reFind("/[^/]+#arguments.ext#$", sPath) />
		<cfreturn left(sPath, sEndDir) />
	</cffunction>
</cfcomponent>