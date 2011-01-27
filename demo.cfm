<cfset monsterid = createObject("component","monsterid").init() />

<cfset testCount = 15 />

<cfloop from="1" to="#testCount#" index="i">
	<cfset randomString = Randomize(i)>
	
	<cfoutput><img src="#monsterid.get_monsterid(randomString,100,'absolute')#" /></cfoutput>
</cfloop>